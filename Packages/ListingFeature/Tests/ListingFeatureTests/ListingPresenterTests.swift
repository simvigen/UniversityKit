import XCTest
import DomainKit
@testable import ListingFeature

@MainActor
final class ListingPresenterTests: XCTestCase {
  private var interactor: ListingInteractorMock!
  private var router: ListingRouterMock!
  private var sut: ListingPresenter!
  
  override func setUp() {
    super.setUp()
    interactor = ListingInteractorMock()
    router = ListingRouterMock()
    sut = ListingPresenter(interactor: interactor, router: router)
  }
  
  func test_viewAppeared_loadsAndPublishesLoadedState() async {
    let universities = [University.fixture(name: "Ajman University")]
    interactor.loadResult = .success(
      UniversitiesLoadResult(universities: universities, origin: .remote)
    )
    
    sut.send(.viewAppeared)
    XCTAssertEqual(sut.state, .loading)
    await sut.loadTask?.value
    
    XCTAssertEqual(sut.state, .loaded(.init(universities: universities, origin: .remote)))
  }
  
  func test_viewAppeared_isIgnoredOnceLoaded() async {
    sut.send(.viewAppeared)
    await sut.loadTask?.value
    
    sut.send(.viewAppeared)
    await sut.loadTask?.value
    
    XCTAssertEqual(interactor.loadCallCount, 1)
  }
  
  func test_emptyResult_publishesEmptyState() async {
    interactor.loadResult = .success(UniversitiesLoadResult(universities: [], origin: .remote))
    
    sut.send(.viewAppeared)
    await sut.loadTask?.value
    
    XCTAssertEqual(sut.state, .empty)
  }
  
  func test_cachedFallback_publishesCacheOrigin() async {
    interactor.loadResult = .success(
      UniversitiesLoadResult(universities: [.fixture()], origin: .cache)
    )
    
    sut.send(.viewAppeared)
    await sut.loadTask?.value
    
    guard case .loaded(let loaded) = sut.state else {
      return XCTFail("Expected loaded state, got \(sut.state)")
    }
    XCTAssertEqual(loaded.origin, .cache)
  }
  
  func test_loadFailure_publishesFailedStateWithLocalizedMessage() async {
    interactor.loadResult = .failure(StubError())
    
    sut.send(.viewAppeared)
    await sut.loadTask?.value
    
    XCTAssertEqual(sut.state, .failed(message: "Stub failure"))
  }
  
  func test_retryAfterFailure_reloads() async {
    interactor.loadResult = .failure(StubError())
    sut.send(.viewAppeared)
    await sut.loadTask?.value
    
    interactor.loadResult = .success(
      UniversitiesLoadResult(universities: [.fixture()], origin: .remote)
    )
    sut.send(.retryTapped)
    await sut.loadTask?.value
    
    guard case .loaded = sut.state else {
      return XCTFail("Expected loaded state after retry, got \(sut.state)")
    }
  }
  
  func test_universitySelected_routesToDetails() {
    let university = University.fixture(name: "Zayed University")
    
    sut.send(.universitySelected(university))
    
    XCTAssertEqual(router.shownDetails, [university])
  }
  
  func test_externalRefresh_updatesStateAndReturnsFreshList() async throws {
    let fresh = [University.fixture(name: "Fresh University")]
    interactor.refreshResult = .success(fresh)
    
    let returned = try await sut.refreshFromExternalTrigger()
    
    XCTAssertEqual(returned, fresh)
    XCTAssertEqual(sut.state, .loaded(.init(universities: fresh, origin: .remote)))
  }
  
  func test_externalRefreshFailure_throwsToCaller() async {
    interactor.refreshResult = .failure(StubError())
    
    do {
      _ = try await sut.refreshFromExternalTrigger()
      XCTFail("Expected refresh error to propagate to the caller")
    } catch {
      XCTAssertEqual(error as? StubError, StubError())
    }
  }
  
  func test_pullToRefreshFailure_keepsContentAndSetsBannerMessage() async {
    interactor.loadResult = .success(
      UniversitiesLoadResult(universities: [.fixture()], origin: .remote)
    )
    sut.send(.viewAppeared)
    await sut.loadTask?.value
    
    interactor.refreshResult = .failure(StubError())
    await sut.refresh()
    
    guard case .loaded(let loaded) = sut.state else {
      return XCTFail("Expected loaded state to survive a failed refresh")
    }
    XCTAssertEqual(loaded.universities.count, 1)
    XCTAssertEqual(loaded.refreshErrorMessage, "Stub failure")
  }
}
