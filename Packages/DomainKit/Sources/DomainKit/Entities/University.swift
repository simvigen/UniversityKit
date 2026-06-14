import Foundation

/// A university as understood by the app, independent of any API or storage schema.
///
/// This is the shared model passed between features (Listing → Details) and
/// the only currency the presentation layer ever deals in.
public struct University: Hashable, Identifiable, Sendable {
  public let name: String
  public let country: String
  public let alphaTwoCode: String
  public let stateProvince: String?
  public let domains: [String]
  public let webPages: [String]
  
  /// Stable identity across refreshes. The API exposes no identifier, so the
  /// name + country pair is used; it is unique within this dataset.
  public var id: String { "\(name)|\(country)" }
  
  public init(
    name: String,
    country: String,
    alphaTwoCode: String,
    stateProvince: String?,
    domains: [String],
    webPages: [String]
  ) {
    self.name = name
    self.country = country
    self.alphaTwoCode = alphaTwoCode
    self.stateProvince = stateProvince
    self.domains = domains
    self.webPages = webPages
  }
}
