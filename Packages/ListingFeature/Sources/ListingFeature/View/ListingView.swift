import CommonUI
import DomainKit
import SwiftUI

/// SwiftUI content of the listing screen; hosted by `ListingViewController`.
struct ListingView: View {
  @ObservedObject var presenter: ListingPresenter
  
  var body: some View {
    content
      .onAppear { presenter.send(.viewAppeared) }
  }
  
  @ViewBuilder
  private var content: some View {
    switch presenter.state {
    case .idle, .loading:
      LoadingListView()
    case .empty:
      EmptyStateView(
        title: "No Universities",
        message: "There is nothing to show for this country yet.",
        systemImage: "graduationcap"
      )
    case .failed(let message):
      ErrorStateView(message: message) {
        presenter.send(.retryTapped)
      }
    case .loaded(let loaded):
      universitiesList(loaded)
    }
  }
  
  private func universitiesList(_ loaded: ListingViewState.Loaded) -> some View {
    List {
      if let banner = banner(for: loaded) {
        Section {
          InfoBanner(message: banner.message, style: banner.style)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
      }
      
      Section {
        ForEach(loaded.universities) { university in
          Button {
            presenter.send(.universitySelected(university))
          } label: {
            UniversityRow(university: university)
          }
          .buttonStyle(.plain)
        }
      } footer: {
        Text("\(loaded.universities.count) universities")
      }
    }
    .listStyle(.insetGrouped)
    .refreshable { await presenter.refresh() }
  }
  
  private func banner(for loaded: ListingViewState.Loaded) -> (message: String, style: InfoBanner.Style)? {
    if let refreshError = loaded.refreshErrorMessage {
      return ("Refresh failed: \(refreshError)", .warning)
    }
    if loaded.origin == .cache {
      return ("You're offline — showing saved results. Pull to refresh.", .warning)
    }
    return nil
  }
}

/// One university row; the name is always rendered in full (no truncation).
struct UniversityRow: View {
  let university: University
  
  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      VStack(alignment: .leading, spacing: 4) {
        Text(university.name)
          .font(.body.weight(.medium))
          .multilineTextAlignment(.leading)
          .fixedSize(horizontal: false, vertical: true)
        
        if let stateProvince = university.stateProvince, !stateProvince.isEmpty {
          Text(stateProvince)
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        
        if let domain = university.domains.first {
          Text(domain)
            .font(.footnote)
            .foregroundColor(.secondary)
        }
      }
      
      Spacer(minLength: 8)
      
      Image(systemName: "chevron.right")
        .font(.footnote.weight(.semibold))
        .foregroundColor(Color(.tertiaryLabel))
    }
    .padding(.vertical, 4)
    .contentShape(Rectangle())
    .accessibilityElement(children: .combine)
  }
}
