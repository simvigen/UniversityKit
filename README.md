# UniversalKit — Universities Browser

A small, production-quality iOS app that lists universities for a country
(United Arab Emirates), caches them locally, and shows a details screen for a
selected item. Built for architecture, modularization, and code quality.

- **Minimum iOS:** 15.1 · **Swift** · **VIPER + Clean Architecture** · **SPM local packages**
- Screens are `UIViewController`-based, embedding SwiftUI via `UIHostingController`
- Navigation via `UINavigationController` push/pop through the Router layer
- async/await for network & database, Combine for state binding
- Core Data (programmatic model) as the local database, in its own package
- Custom URLSession-based network layer, in its own package, zero third-party dependencies

## Module map

```
UniversalKit (app target — composition root only)
│   AppDependencies      builds network + persistence stacks, exposes use cases
│   AppFlowCoordinator   owns UINavigationController, wires modules, mediates Details→Listing refresh
│
├── DomainKit            entities + repository protocol + use cases (depends on nothing)
├── NetworkKit           Endpoint, NetworkClient, URLSessionNetworkClient, NetworkError (generic, reusable)
├── PersistenceKit       Core Data stack, local/remote data sources, CachedUniversityRepository
│                        (depends on DomainKit + NetworkKit — the data layer)
├── CommonUI             ErrorStateView, EmptyStateView, LoadingListView (shimmer), InfoBanner,
│                        UIViewController.embedSwiftUIView (the shared UIKit↔SwiftUI bridge)
├── ListingFeature       VIPER module A (SwiftUI list hosted in a UIViewController)
└── DetailsFeature       VIPER module B (UIKit VC + Refresh bar button, SwiftUI content)
```

Dependency rule (Clean Architecture): features depend only on `DomainKit`
abstractions and `CommonUI`; the data layer implements domain protocols; only
the app target sees everything and wires it together.

## VIPER per feature

| Role       | Listing                                     | Details                                          |
|------------|---------------------------------------------|--------------------------------------------------|
| View       | `ListingViewController` + `ListingView` (SwiftUI) | `DetailsViewController` (UIKit Refresh button) + `DetailsView` |
| Interactor | `ListingInteractor` → domain use cases       | `DetailsInteractor` → delegates refresh upstream  |
| Presenter  | `ListingPresenter` (`ObservableObject`, `@MainActor`) | `DetailsPresenter` (`ObservableObject`, `@MainActor`) |
| Entity     | `University` (DomainKit)                     | `University` (DomainKit)                          |
| Router     | `ListingRouter` (pushes Details via injected factory) | `DetailsRouter` (pop)                       |

Each presenter publishes a single MVI state value (`ListingViewState` /
`DetailsViewState`) — the single source of truth per screen. Views send
intents (`ListingIntent` / `DetailsIntent`); state flows back through
`@Published`. The Details view controller additionally binds a Combine
subscription to swap its UIKit Refresh button for a spinner while a refresh
is in flight.

## Data flow

1. Listing appears → `LoadUniversitiesUseCase`: API fetch → cache refresh → `.loaded(origin: .remote)`.
2. API failure → cached data if present (`.loaded(origin: .cache)` with an offline banner) → otherwise the shared `ErrorStateView` with **Try Again**.
3. Tapping a row → `ListingRouter` pushes Details with the **passed** `University` (no API call in Details).
4. **Refresh** in Details → `DetailsInteractor` → `DetailsModuleOutput` (implemented by `AppFlowCoordinator`) → `ListingModuleInput.refreshFromExternalTrigger()` → the *listing* module runs `RefreshUniversitiesUseCase`, updating the cache **and** the listing state; the updated item is returned to Details. Details never touches NetworkKit or PersistenceKit.

University names render with `fixedSize(horizontal: false, vertical: true)`
on both screens — full names wrap, never truncate.

## Notable decisions

- **Repository in PersistenceKit.** The spec assigns "caching repositories" to
  PersistenceKit, so that package is the data layer's composition point: it
  implements `DomainKit.UniversityRepository` from a remote data source
  (via generic NetworkKit) plus a Core Data local store.
- **Programmatic Core Data model.** The schema is declared in code
  (`UniversityRecord.entityDescription()`), so the package ships no
  `.xcdatamodeld` resource and tests run the exact same schema in-memory.
- **Cache write failures don't fail a fetch** — fresh data is served and the
  failure is logged; the next successful fetch retries the write.
- **Stable identity.** The API exposes no id; `University.id` is the
  name+country pair, which keeps list diffing and the Details refresh-match stable.
- **Normalization in use cases.** The dataset occasionally contains duplicates
  and arrives unordered; both use cases dedupe + sort so every consumer agrees.
- **HTTP exception.** The API is HTTP-only; Info.plist carries an ATS exception
  scoped to `universities.hipolabs.com` only.

## Tests

- `DomainKitTests` — use case behavior: remote-first, cache fallback, error propagation, normalization.
- `NetworkKitTests` — request building/encoding; status, transport and decoding error mapping via a `URLProtocol` stub.
- `PersistenceKitTests` — DTO decoding (including the hyphenated `state-province` key), cache round-trip/replace/isolation on an in-memory store, repository success/failure paths.
- `ListingFeatureTests` / `DetailsFeatureTests` — presenter state machines with mock interactors/routers.
- `UniversalKitTests` — composition-root smoke test.
- `UniversalKitUITests` — end-to-end flow: listing loads, push Details, Refresh round-trips through the listing module, back navigation.

Run them per package, e.g.:

```bash
xcodebuild test -scheme DomainKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  # …from Packages/DomainKit; same pattern for the other packages
xcodebuild test -project UniversalKit.xcodeproj -scheme UniversalKit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```
