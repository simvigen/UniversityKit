import XCTest
import DomainKit
@testable import DetailsFeature

@MainActor
final class DetailsPresenterTests: XCTestCase {
  private var output: DetailsModuleOutputMock!
  private var sut: DetailsPresenter!
  private let initial = University.fixture(name: "Ajman University")
  
  override func setUp() {
    super.setUp()
    output = DetailsModuleOutputMock()
    sut = DetailsPresenter(
      university: initial,
      interactor: DetailsInteractor(output: output),
      router: DetailsRouterMock()
    )
  }
  
  func test_initialState_showsPassedUniversity() {
    XCTAssertEqual(sut.state, DetailsViewState(university: initial))
  }
  
  func test_refreshSuccess_updatesUniversity() async {
    let updated = University.fixture(name: "Ajman University", stateProvince: "Ajman")
    output.result = .success(updated)
    
    sut.send(.refreshTapped)
    await sut.refreshTask?.value
    
    XCTAssertEqual(sut.state.university, updated)
    XCTAssertEqual(sut.state.notice?.kind, .info)
    XCTAssertFalse(sut.state.isRefreshing)
    XCTAssertEqual(output.refreshRequests, [initial])
  }
  
  func test_refreshWhenItemDisappeared_keepsDataAndWarns() async {
    output.result = .success(nil)
    
    sut.send(.refreshTapped)
    await sut.refreshTask?.value
    
    XCTAssertEqual(sut.state.university, initial)
    XCTAssertEqual(sut.state.notice?.kind, .warning)
  }
  
  func test_refreshFailure_keepsDataAndShowsLocalizedMessage() async {
    output.result = .failure(StubError())
    
    sut.send(.refreshTapped)
    await sut.refreshTask?.value
    
    XCTAssertEqual(sut.state.university, initial)
    XCTAssertEqual(sut.state.notice, .init(kind: .warning, message: "Stub failure"))
    XCTAssertFalse(sut.state.isRefreshing)
  }
}

// MARK: - Test doubles

extension University {
  static func fixture(
    name: String = "Test University",
    stateProvince: String? = nil
  ) -> University {
    University(
      name: name,
      country: "United Arab Emirates",
      alphaTwoCode: "AE",
      stateProvince: stateProvince,
      domains: ["test.ac.ae"],
      webPages: ["http://www.test.ac.ae"]
    )
  }
}

struct StubError: LocalizedError, Equatable {
  var errorDescription: String? { "Stub failure" }
}

@MainActor
final class DetailsModuleOutputMock: DetailsModuleOutput {
  var result: Result<University?, Error> = .success(nil)
  private(set) var refreshRequests: [University] = []
  
  func detailsDidRequestRefresh(for university: University) async throws -> University? {
    refreshRequests.append(university)
    return try result.get()
  }
}

@MainActor
final class DetailsRouterMock: DetailsRouting {
  func closeDetails() {}
}
