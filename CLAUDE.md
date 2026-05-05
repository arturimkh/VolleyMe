# CLAUDE.md — VolleyMe Architecture

iOS (UIKit, Swift 5, iOS 15+).

---

## iOS: MVP + Coordinator + Assembly

Each screen is a feature module:
```
FeatureScreen/
├── FeatureAssembly.swift          # DI wiring, returns UIViewController
├── View/FeatureViewController.swift   # Renders ViewModel, forwards actions
├── Presenter/FeaturePresenter.swift   # State + business logic
├── Service/FeatureService.swift       # Network via IRequestProcessor
├── Model/FeatureModel.swift           # API DTOs, domain models, toDomain()
└── ViewModelFactory/
    ├── FeatureViewModelFactory.swift  # Domain → ViewModel (no UIKit, testable)
    └── ViewModels/FeatureViewModels.swift
```

**Data flow:** User action → Presenter → Service → RequestProcessor → domain model → ViewModelFactory → `view.configure(viewModel)`.

**Protocols per screen:**
```swift
protocol IFeatureView: AnyObject {
    func configure(with viewModel: FeatureViewModel)
    func showShimmer(_ show: Bool)
    func showError(_ message: String)
}
protocol IFeaturePresenter: AnyObject {
    func viewDidLoad()
    func handleAction(_ action: FeatureAction)
}
protocol IFeatureOutput: AnyObject {
    func featureDidSelectItem(id: String)
}
```

View owns Presenter (strong). Presenter holds View/Output as weak.

**Assembly = composition root:**
```swift
func assemble(output: IFeatureOutput?) -> UIViewController {
    let service = FeatureService(requestProcessor: requestProcessor)
    let presenter = FeaturePresenter(service: service, viewModelFactory: FeatureViewModelFactory())
    let vc = FeatureViewController(presenter: presenter)
    presenter.view = vc; presenter.output = output
    return vc
}
```

**ViewModel is a plain struct** — display-ready values only, no loading/error state inside it. Loading and errors go through separate View methods:
```swift
struct FeatureViewModel {
    let title: String
    let items: [ItemViewModel]
    // only what the view needs to render
}
```

**State in Presenter:**
```swift
private func loadData() {
    view?.showShimmer(true)
    Task { @MainActor [weak self] in
        guard let self else { return }
        do {
            let items = try await service.fetchItems()
            self.view?.showShimmer(false)
            self.view?.configure(with: self.viewModelFactory.makeViewModel(items: items))
        } catch {
            self.view?.showShimmer(false)
            self.view?.showError(error.userFacingMessage)
        }
    }
}
```

**Coordinator:** `AppCoordinator` owns `UIWindow`, handles Splash → Onboarding → Auth → Main. `MainFlowController: UINavigationController` implements Output protocols and drives push navigation. Session expiry: `RequestProcessor` posts `Notification.Name.userSessionExpired`, `AppCoordinator` listens and shows Auth.

**DI container** (created once in SceneDelegate):
```swift
protocol IDependencyContainer {
    var requestProcessor: IRequestProcessor { get }
    var tokenStorage: ITokenStorage { get }
    var logoutService: ILogoutService { get }
}
```

---

## Networking

`IRequestProcessor` — the only HTTP client. Services never use URLSession directly.
```swift
protocol IRequestProcessor {
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T
    func post<T: Decodable>(_ endpoint: String, body: Data?) async throws -> T
    func post(_ endpoint: String, body: Data?) async throws
    func delete(_ endpoint: String) async throws
}
```

Built-in: Bearer token injection, silent token refresh on 401 via `actor RefreshCoordinator` (prevents duplicate refresh), posts `userSessionExpired` on refresh failure, auth endpoints bypass token injection.

Errors: `NetworkError` enum (`.apiError(APIError)`, `.serverError(Int)`, `.unauthorized`, etc.). Don't pass `error.localizedDescription` to user — switch on `NetworkError` cases.

---

## Models

Three layers, never mixed: `*Response` (Decodable, mirrors JSON) → domain model (plain struct, parsed dates/enums) → `*ViewModel` (display strings/colors). Mapping via `toDomain()` extension in `Model/`. ViewModel construction only in `ViewModelFactory`.

---

## Auth
Tokens in Keychain only (never UserDefaults). `TokenStorage` wraps Keychain with in-memory cache. `LogoutService` calls `POST /auth/logout/` then clears Keychain.

---

## iOS config
Layout: SnapKit (SPM), no storyboards. iOS 15+ target. HTTP exceptions in Info.plist for local dev (`localhost`, `local.charles`).

---

## Backend: Clean Architecture

```
src/<app>/
├── presentation/rest/  # FastAPI routers, Pydantic schemas, deps.py, exc_handlers/
├── application/        # usecases/ (one class, execute()), dto/, services/, query_repos/
├── domain/             # repos/ (abstract), aggregates.py, enums.py, types.py
└── infra/              # db/models/, db/repos/, services/ (JWT/password), di/
```

Dependency direction: Presentation → Application → Domain ← Infrastructure.

**Use case pattern:**
```python
@dataclasses.dataclass
class CreateEventUseCase:
    event_repo: repos.EventRepo
    async def execute(self, dto: CreateEventDto, user_id: UserId) -> EventDetailsDto: ...
```

**DI** via `dependency-injector`, injected into endpoints with `@wiring.inject`. Auth: JWT RS256, Argon2 passwords. Error format (must match iOS `APIError`):
```json
{"details": [{"code": "...", "messages": ["..."], "fields": {...}}]}
```

API conventions: trailing `/` on all routes, ISO 8601 timestamps, `?limit=25&offset=0` pagination.

Stack: `fastapi, uvicorn, sqlalchemy[asyncio], alembic, dependency-injector, pyjwt[crypto], pwdlib[argon2], asyncpg`.

---

## Key rules
- No storyboards, no Combine/RxSwift — async/await + plain closures
- No singletons — everything through DI container
- ViewModel = plain struct with display values only; loading/error via `showShimmer()`/`showError()`
- ViewModelFactory has no UIKit imports — fully unit testable
- Services are thin — network call + DTO→Domain mapping only
- Assembly is the only place dependencies are wired
- Output protocols for navigation — Presenters never reference other screens
- No PII in logs (no tokens, emails, personal data in print/logs)
- Tokens in Keychain only
