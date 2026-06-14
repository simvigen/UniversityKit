import Foundation

extension Array where Element == University {
  /// The dataset occasionally contains duplicate entries and arrives unordered;
  /// every use case applies the same normalization so screens always agree.
  func normalizedForPresentation() -> [University] {
    var seen = Set<University.ID>()
    return filter { seen.insert($0.id).inserted }
      .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
  }
}
