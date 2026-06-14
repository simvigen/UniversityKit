import Foundation

enum AppConfiguration {
  /// The universities API is HTTP-only; the matching ATS exception for this
  /// host lives in Info.plist.
  static let universitiesAPIBaseURL = URL(string: "http://universities.hipolabs.com")!
  
  /// The country whose universities the app browses.
  static let country = "United Arab Emirates"
}
