import CommonUI
import DomainKit
import SwiftUI

/// SwiftUI content of the details screen; hosted by `DetailsViewController`.
struct DetailsView: View {
  @ObservedObject var presenter: DetailsPresenter
  
  var body: some View {
    List {
      if let notice = presenter.state.notice {
        Section {
          InfoBanner(
            message: notice.message,
            style: notice.kind == .info ? .info : .warning
          )
          .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets())
          .listRowSeparator(.hidden)
        }
      }
      
      university(presenter.state.university)
    }
    .listStyle(.insetGrouped)
  }
  
  @ViewBuilder
  private func university(_ university: University) -> some View {
    Section("University") {
      DetailRow(title: "Name", value: university.name)
      DetailRow(title: "Country", value: university.country)
      if !university.alphaTwoCode.isEmpty {
        DetailRow(title: "Country Code", value: university.alphaTwoCode)
      }
      if let stateProvince = university.stateProvince, !stateProvince.isEmpty {
        DetailRow(title: "State / Province", value: stateProvince)
      }
    }
    
    if !university.domains.isEmpty {
      Section("Domains") {
        ForEach(university.domains, id: \.self) { domain in
          Text(domain)
            .font(.body)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
    }
    
    if !university.webPages.isEmpty {
      Section("Web Pages") {
        ForEach(university.webPages, id: \.self) { webPage in
          if let url = URL(string: webPage) {
            Link(destination: url) {
              Text(webPage)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            }
          } else {
            Text(webPage)
              .font(.body)
              .fixedSize(horizontal: false, vertical: true)
          }
        }
      }
    }
  }
}

/// Caption + value pair; the value is always rendered in full (no truncation).
private struct DetailRow: View {
  let title: String
  let value: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.caption)
        .foregroundColor(.secondary)
      Text(value)
        .font(.body)
        .fixedSize(horizontal: false, vertical: true)
        .textSelection(.enabled)
    }
    .padding(.vertical, 2)
    .accessibilityElement(children: .combine)
  }
}
