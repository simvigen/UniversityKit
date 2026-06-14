import XCTest
@testable import NetworkKit

final class EndpointTests: XCTestCase {
  private let baseURL = URL(string: "http://universities.hipolabs.com")!
  
  func test_buildsURLWithEncodedQuery() throws {
    let endpoint = Endpoint(
      path: "search",
      queryItems: [URLQueryItem(name: "country", value: "United Arab Emirates")]
    )
    
    let request = try endpoint.urlRequest(relativeTo: baseURL)
    
    XCTAssertEqual(
      request.url?.absoluteString,
      "http://universities.hipolabs.com/search?country=United%20Arab%20Emirates"
    )
    XCTAssertEqual(request.httpMethod, "GET")
  }
  
  func test_joinsPathRegardlessOfSlashes() throws {
    let withSlashBase = URL(string: "http://example.com/api/")!
    
    let plainPath = try Endpoint(path: "search").urlRequest(relativeTo: withSlashBase)
    let slashedPath = try Endpoint(path: "/search").urlRequest(relativeTo: withSlashBase)
    
    XCTAssertEqual(plainPath.url?.absoluteString, "http://example.com/api/search")
    XCTAssertEqual(slashedPath.url?.absoluteString, "http://example.com/api/search")
  }
  
  func test_setsHeadersAndBody() throws {
    let body = Data("{}".utf8)
    let endpoint = Endpoint(
      path: "search",
      method: .post,
      headers: ["Content-Type": "application/json"],
      body: body
    )
    
    let request = try endpoint.urlRequest(relativeTo: baseURL)
    
    XCTAssertEqual(request.httpMethod, "POST")
    XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
    XCTAssertEqual(request.httpBody, body)
  }
}
