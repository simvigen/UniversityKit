import XCTest
@testable import NetworkKit

final class URLSessionNetworkClientTests: XCTestCase {
  private var sut: URLSessionNetworkClient!
  
  override func setUp() {
    super.setUp()
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [URLProtocolStub.self]
    sut = URLSessionNetworkClient(
      baseURL: URL(string: "http://example.com")!,
      session: URLSession(configuration: configuration)
    )
  }
  
  override func tearDown() {
    URLProtocolStub.handler = nil
    super.tearDown()
  }
  
  func test_successfulResponse_returnsData() async throws {
    let expected = Data("[]".utf8)
    URLProtocolStub.handler = { request in
      (Self.httpResponse(for: request, status: 200), expected)
    }
    
    let data = try await sut.data(for: Endpoint(path: "search"))
    
    XCTAssertEqual(data, expected)
  }
  
  func test_non2xxStatus_throwsUnacceptableStatus() async {
    URLProtocolStub.handler = { request in
      (Self.httpResponse(for: request, status: 500), Data())
    }
    
    do {
      _ = try await sut.data(for: Endpoint(path: "search"))
      XCTFail("Expected unacceptableStatus")
    } catch let NetworkError.unacceptableStatus(code) {
      XCTAssertEqual(code, 500)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func test_transportError_throwsTransport() async {
    URLProtocolStub.handler = { _ in
      throw URLError(.notConnectedToInternet)
    }
    
    do {
      _ = try await sut.data(for: Endpoint(path: "search"))
      XCTFail("Expected transport error")
    } catch let NetworkError.transport(urlError) {
      XCTAssertEqual(urlError.code, .notConnectedToInternet)
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func test_decode_mapsDecodingFailures() async {
    URLProtocolStub.handler = { request in
      (Self.httpResponse(for: request, status: 200), Data("not json".utf8))
    }
    
    do {
      _ = try await sut.decode([String].self, from: Endpoint(path: "search"))
      XCTFail("Expected decoding error")
    } catch is NetworkError {
      // expected: NetworkError.decoding
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func test_decode_returnsDecodedValue() async throws {
    URLProtocolStub.handler = { request in
      (Self.httpResponse(for: request, status: 200), Data(#"["a","b"]"#.utf8))
    }
    
    let values = try await sut.decode([String].self, from: Endpoint(path: "search"))
    
    XCTAssertEqual(values, ["a", "b"])
  }
  
  private static func httpResponse(for request: URLRequest, status: Int) -> HTTPURLResponse {
    HTTPURLResponse(
      url: request.url ?? URL(string: "http://example.com")!,
      statusCode: status,
      httpVersion: nil,
      headerFields: nil
    )!
  }
}

/// Intercepts URLSession traffic so client behavior is tested without networking.
final class URLProtocolStub: URLProtocol {
  static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
  
  override class func canInit(with request: URLRequest) -> Bool { true }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  
  override func startLoading() {
    guard let handler = Self.handler else {
      client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
      return
    }
    do {
      let (response, data) = try handler(request)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }
  
  override func stopLoading() {}
}
