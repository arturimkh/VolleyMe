# VolleyMe — Архитектура и стек

## Стек

| Слой | Технология |
|---|---|
| Платформа | iOS, UIKit (без SwiftUI) |
| Язык | Swift 5, GCD |
| Layout | SnapKit 5.7.1 (Auto Layout DSL) |
| Сеть | URLSession (нативная), без сторонних HTTP-клиентов |
| Хранилище токенов | Keychain |
| Персистентность настроек | UserDefaults (флаг онбординга) |
| Зависимости | Swift Package Manager |
| Бэкенд | REST API |

---

## Архитектурный паттерн: MVP + Coordinator + Assembly

Каждый экран изолирован в отдельный модуль и состоит из пяти слоёв:

```
App/<ScreenName>/
├── Model/            — API DTOs + доменные модели + маппинг
├── View/             — UIViewController + переиспользуемые компоненты / ячейки
├── Presenter/        — бизнес-логика экрана, протоколы IXxxView / IXxxPresenter / IXxxOutput
├── ViewModelFactory/ — преобразование доменных моделей в View-модели (без UIKit-зависимостей)
├── Service/          — сетевые запросы через IRequestProcessor
└── XxxAssembly.swift — сборка (DI-wiring) модуля
```

### Роли слоёв

| Слой | Ответственность |
|---|---|
| **Model** | Структуры ответа API (`XxxResponse: Decodable`), доменные объекты |
| **Service** | Один метод → один запрос; зависит только от `IRequestProcessor` |
| **Presenter** | Получает данные от Service, агрегирует состояние, отдаёт во View через ViewModel |
| **ViewModelFactory** | Чистая функция: домен → ViewModel; не знает об UIKit |
| **View** | Только рендер ViewModel и проброс событий в Presenter; нет логики |
| **Assembly** | Создаёт все объекты модуля, связывает их, принимает внешние зависимости и `output` |

---

## Навигация

```
AppCoordinator (владеет UIWindow)
│
├── SplashViewController          — анимация запуска
├── OnboardingViewController      — показывается один раз (UserDefaults)
├── AuthViewController            — логин
│    └── RegisterViewController   — регистрация (modal fullscreen)
│
└── MainFlowController : UINavigationController
     ├── HomeViewController        — root
     ├── EventDetailsViewController — push
     └── NewEventViewController    — push
```

**AppCoordinator** реализует `IOnboardingOutput`, `IAuthOutput`, `IRegisterOutput` — получает callback-и от экранов через output-протоколы и сам решает, какой flow показывать.

**MainFlowController** реализует `IHomeOutput`, `IEventDetailsOutput`, `INewEventOutput` — управляет `UINavigationController`-стеком внутри основного флоу.

---

## Dependency Injection

Единственная точка входа — `DependencyContainer`, создаётся в `SceneDelegate` и передаётся в `AppCoordinator`.

```
DependencyContainer
├── KeychainService    — CRUD в Keychain
├── TokenStorage       — кэш + сериализация AuthTokens
├── RequestProcessor   — HTTP-клиент
└── LogoutService      — POST /auth/logout/
```

Каждый Assembly получает только те зависимости, которые нужны его модулю.

---

## Сетевой слой

`RequestProcessor` — центральный HTTP-клиент с тремя ключевыми возможностями:

1. **Bearer-авторизация** — автоматически подставляет `Authorization: Bearer <token>` из `TokenStorage`.
2. **Silent token refresh** — при получении 401 выполняет `POST /auth/refresh/` и повторяет исходный запрос. Обновление сериализовано через `actor RefreshCoordinator`, чтобы параллельные 401 не гонялись за токеном.
3. **Session expiry** — если refresh не удался, токены очищаются и постится `Notification.Name.userSessionExpired`; `AppCoordinator` переводит пользователя на экран логина.

```swift
protocol IRequestProcessor {
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T
    func post<T: Decodable>(_ endpoint: String, body: Data?) async throws -> T
    func post(_ endpoint: String, body: Data?) async throws
    func delete(_ endpoint: String) async throws
}
```

В DEBUG-сборке существует `MockRequestProcessor` — полная замена для разработки без сервера.

---

## Структура проекта

```
VolleyMe/
├── AppDelegate.swift
├── SceneDelegate.swift
│
├── Core/
│   ├── Coordinator/    AppCoordinator
│   ├── DI/             DependencyContainer
│   ├── Auth/           KeychainService, TokenStorage, PasswordPolicy, LogoutService
│   └── Network/        RequestProcessor (+ MockRequestProcessor)
│
├── Presentation/
│   ├── MVP/            Базовые протоколы: PresenterLifecycle, IViewModel
│   └── Assembly/       BaseAssembly протокол
│
└── App/
    ├── SplashScreen/
    ├── OnboardingScreen/
    ├── AuthScreen/
    ├── RegisterScreen/
    ├── HomeScreen/
    ├── EventDetailsScreen/
    ├── NewEventScreen/
    └── MainFlowController/
```

---

## Экраны

| Экран | Описание |
|---|---|
| **Splash** | Анимация запуска, триггер перехода к следующему флоу |
| **Onboarding** | 5 слайдов (изображения в Assets), показывается один раз |
| **Auth** | Логин по email/паролю, валидация полей |
| **Register** | Регистрация нового пользователя |
| **Home** | Список событий; два таба: «Мои встречи» / «Найти встречу»; pull-to-refresh |
| **EventDetails** | Детали события, список участников, кнопки «Вступить» / «Отменить» / «Покинуть» |
| **NewEvent** | Форма создания события (название, дата, время, количество игроков и т.д.) |

---

## Доменные модели

```
AuthTokens          — access + refresh + email
EventListItem       — элемент списка событий
EventParticipantRole — host / participant / nobody
EventSection        — today / tomorrow / later / past
HomeTab             — myEvents / findEvents
CreateEventDTO      — DTO для создания события
```

---

## Принятые решения

- **Нет Firebase** — собственный REST-бэкенд, JWT-аутентификация.
- **Нет RxSwift / Combine** — управление состоянием через обычные замыкания и `async/await`.
- **Нет координаторов на каждый модуль** — output-протоколы на Presenter заменяют роутер; AppCoordinator управляет window-level навигацией.
- **MockRequestProcessor** в DEBUG полностью подменяет сетевой слой без моков на уровне тестов.
