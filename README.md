# ShopSphere

> **A lightweight, production-quality Flutter e-commerce catalog application built with Clean Architecture, consuming the [DummyJSON API](https://dummyjson.com).**  
> Developed for the **Prosessed Flutter Developer Intern Technical Assignment** (October 2026).

---

## 1. Overview & Links

ShopSphere is a Flutter shopping catalog that demonstrates clean software engineering principles. The app is structured feature-first using Clean Architecture (Presentation, Domain, Data, Core) with BLoC/Cubit for predictable state management. It includes an adaptive layout for phones and tablets, persistent local cart storage, defensive error handling, token-based session management, and a complete unit test suite.

- **Android Release APK:** [Download ShopSphere_Ranojit_Das_v1.0.0.apk](https://github.com/Ranojitdas/ShopSphere/releases/tag/v1.0.0) *(or see `build/app/outputs/flutter-apk/app-release.apk`)*
- **Demo Video Walkthrough:** [Google Drive Video Link](https://drive.google.com/) *(Walking through auth, catalog, search, cart, responsive layout, and simulated error states)*
- **GitHub Repository:** [https://github.com/Ranojitdas/ShopSphere](https://github.com/Ranojitdas/ShopSphere)

---

## 2. Screenshots

### Phone Layout (Portrait)
| Home Catalog | Product Details | Cart & Summary | Profile & Orders | Dark Mode |
| :---: | :---: | :---: | :---: | :---: |
| ![Catalog](https://res.cloudinary.com/deuhpyrku/image/upload/v1792590795/Screenshot_20261021-183701_rpdigk.png) | ![Details](https://res.cloudinary.com/deuhpyrku/image/upload/v1792590795/Screenshot_20261021-183745_t83axr.png) | ![Cart](https://res.cloudinary.com/deuhpyrku/image/upload/v1792590795/Screenshot_20261021-183725_pch6qp.png) | ![Profile](https://res.cloudinary.com/deuhpyrku/image/upload/v1792590795/Screenshot_20261021-183733_obtpvg.png) | ![Dark Mode](https://res.cloudinary.com/deuhpyrku/image/upload/v1792590796/Screenshot_20261021-183750_ri2lkm.png) |

### Tablet Layout (Adaptive NavigationRail & Dual-Pane)
| Tablet Catalog Grid | Tablet Dual-Pane Product Detail |
| :---: | :---: |
| ![Tablet Catalog](https://res.cloudinary.com/deuhpyrku/image/upload/v1792588283/Screenshot_20261021_182744_hqh3wy.png) | ![Tablet Details](https://res.cloudinary.com/deuhpyrku/image/upload/v1792588281/Screenshot_20261021_182809_snbla8.png) |

---

## 3. Features Checklist

### Implemented Requirements `[Must]`
- [x] **Splash & Session Routing:** Checks stored tokens on launch via `flutter_secure_storage` and auto-routes to Home or Login.
- [x] **Authentication:** Login form with username/password validation, password visibility toggle, and clear HTTP 400 error messaging.
- [x] **Product Catalog:** Responsive grid with 20 items/page pagination (limit/skip), shimmer skeleton placeholders, and pull-to-refresh.
- [x] **Category Filtering & Search:** Horizontal category chips from API, 400ms debounced live search, and sorting (price low/high, rating, title).
- [x] **Product Details:** Image carousel with page indicators, safe null-brand handling, discount calculations, customer reviews, and stock availability status.
- [x] **Cart & Persistence:** Add, remove, and update quantities; subtotal and discount breakdown; persists across restarts via `shared_preferences`.
- [x] **Real-time Cart Badge:** Live item count indicator on both bottom navigation bar (phone) and side navigation rail (tablet).
- [x] **Checkout Simulation:** Simulates order placement via `POST /carts/add`, shows order confirmation dialog, and clears the cart.
- [x] **Profile Screen:** Displays signed-in user details from `GET /auth/me` (avatar, name, email, phone, company).
- [x] **Session Invalidation:** Manual logout that clears tokens, plus automatic logout on 401 Unauthorized responses.
- [x] **Adaptive Responsive Layout:** Transitions from bottom `NavigationBar` (<600dp) to side `NavigationRail` (≥600dp), plus side-by-side dual-pane details on tablets.

### Implemented Bonus `[Bonus]`
- [x] **Persistent Theme Toggle:** Light / Dark / System theme toggle using `ThemeCubit` and `shared_preferences`.
- [x] **Hero Transitions:** Smooth image animation from catalog card thumbnail to the detail page carousel.
- [x] **HTTP Auth Interceptor:** Automatic Bearer token injection and auto-logout on session expiration.
- [x] **Defensive Boundaries:** Multi-tier validation preventing negative cart counts at Domain (Use Cases), State (Cubit), and Presentation (UI buttons).

---

## 4. Tech Stack & Dependencies

- **Framework:** Flutter `3.29.2` (Channel stable)
- **Language:** Dart `3.7.2`
- **Design System:** Material 3 with customized theme tokens and 8dp spatial rhythm.

| Package | Version | Architectural Justification |
| :--- | :---: | :--- |
| `flutter_bloc` | `^9.0.0` | Predictable state management with unidirectional data flow; separates UI from business logic. |
| `get_it` | `^8.0.3` | Lightweight service locator for dependency injection, keeping classes loosely coupled and easy to mock. |
| `dio` | `^5.8.0` | HTTP client with interceptors for auth headers, debug logging, and granular request timeouts. |
| `dartz` | `^0.10.1` | Functional `Either<Failure, T>` return types so errors are handled explicitly without unexpected try/catch leaks. |
| `flutter_secure_storage` | `^9.2.4` | Encrypted key-value storage backed by Android Keystore and iOS Keychain for JWT tokens. |
| `shared_preferences` | `^2.5.3` | Fast local key-value storage for cart items and theme mode without database boilerplate. |
| `cached_network_image` | `^3.4.1` | Disk and memory caching for product images with smooth fade-in transitions. |
| `shimmer` | `^3.0.0` | Skeleton placeholder loading animations during network requests. |
| `intl` | `^0.20.2` | Clean currency and number formatting. |
| `mocktail` | `^1.0.4` | Pure-Dart null-safe mocking without code generation or `build_runner` overhead. |
| `bloc_test` | `^10.0.0` | Stream-based testing utility for asserting state emission sequences in Cubits. |

---

## 5. Architecture & Code Structure

The project follows **Clean Architecture** organized **feature-first**. Business logic is pure Dart and isolated from UI frameworks and third-party libraries.

```
                              ┌──────────────────────────────────┐
                              │        Presentation Layer        │
                              │  (Pages, Widgets, BLoC / Cubit)  │
                              └─────────────────┬────────────────┘
                                                │ Calls UseCases / Observes State
                                                ▼
                              ┌──────────────────────────────────┐
                              │           Domain Layer           │
                              │   (Entities, UseCases, Conts.)   │
                              │     * Pure Dart (0 Flutter) *    │
                              └─────────────────▲────────────────┘
                                                │ Implements Contracts
                                                │
                              ┌─────────────────┴────────────────┐
                              │            Data Layer            │
                              │  (Models, DataSources, RepoImpl) │
                              └─────────────────┬────────────────┘
                                                │ Consumes
                                                ▼
                              ┌──────────────────────────────────┐
                              │            Core Layer            │
                              │ (Network, Failure, Theme, Utils) │
                              └──────────────────────────────────┘
```

### Layer Responsibilities
- **Domain:** Pure Dart. Defines core business entities (`ProductEntity`, `UserEntity`, `CartItemEntity`), repository contracts, and use cases. Has zero imports from Flutter or external network libraries.
- **Data:** Implements domain repository interfaces. Handles raw JSON serialization (`ProductModel`), remote API calls via `DioClient`, and local storage.
- **Presentation:** UI widgets, pages, and Cubits. Cubits receive user actions, call use cases, and emit immutable states that widgets observe via `BlocBuilder`.
- **Core:** Cross-cutting concerns such as the service locator (`injection_container.dart`), Dio network configuration, custom failures/exceptions, and theme definitions.

### Folder Structure
```
lib/
├── core/
│   ├── di/                 # Dependency injection (get_it)
│   ├── error/              # Failure & Exception classes
│   ├── network/            # Dio client & HTTP interceptors
│   ├── theme/              # Material 3 themes & ThemeCubit
│   ├── utils/              # Breakpoints & responsive utilities
│   └── widgets/            # Shared widgets (ErrorView, EmptyView, Shimmer)
├── features/
│   ├── auth/               # Authentication (Splash & Login)
│   │   ├── data/           # UserModel, AuthRemote/LocalDataSource, AuthRepoImpl
│   │   ├── domain/         # UserEntity, AuthRepository, LoginUseCase
│   │   └── presentation/   # AuthCubit, SplashPage, LoginPage
│   ├── products/           # Products catalog, search, filter, details
│   │   ├── data/           # ProductModel, CategoryModel, ProductRemoteDataSource
│   │   ├── domain/         # ProductEntity, ProductRepository, GetProductsUseCase
│   │   └── presentation/   # ProductListCubit, ProductDetailsCubit, HomePage, DetailsPage
│   ├── cart/               # Cart, local persistence & checkout
│   │   ├── data/           # CartItemModel, CartLocalDataSource, CartRepoImpl
│   │   ├── domain/         # CartItemEntity, CartRepository, CartUseCases
│   │   └── presentation/   # CartCubit, CartPage, CheckoutPage, ConfirmationPage
│   └── profile/            # User profile & logout
│       ├── domain/         # GetProfileUseCase
│       └── presentation/   # ProfileCubit, ProfilePage
├── app.dart                # MaterialApp setup with Theme & BlocProviders
└── main.dart               # App entry point & dependency initialization
```

### Request Lifecycle (`UI -> API -> UI`)
Here is what happens during a typical user interaction (e.g., searching for products):
1. **User Input:** The user types `"phone"` into the search bar.
2. **Debounce:** A 400ms debouncer prevents sending requests on every keystroke, then calls `ProductListCubit.searchProducts("phone")`.
3. **Cubit & UseCase:** The Cubit emits a loading state and calls `SearchProductsUseCase(query)`.
4. **Repository & Data Source:** `ProductRepositoryImpl` delegates to `ProductRemoteDataSource.searchProducts("phone")`.
5. **Network Request:** `DioClient` sends `GET https://dummyjson.com/products/search?q=phone`.
6. **Parsing:** The JSON response is parsed into `ProductResponseModel` and converted to `List<ProductEntity>`.
7. **Result Delivery:** The repository wraps the entities in `Right(List<ProductEntity>)` and returns it to the use case.
8. **State Emission:** `ProductListCubit` receives the list and emits `ProductListLoaded(products)`.
9. **UI Update:** `BlocBuilder` in `HomePage` receives the state and renders the updated product grid.

---

## 6. State Management

This project uses **`flutter_bloc` (Cubit)**.

### Why Cubit?
For this application, user interactions are direct asynchronous calls (fetch products, filter category, increment cart quantity). Using `Cubit` gives us the exact same unidirectional data flow and state predictability as full BLoC, without the boilerplate of creating separate event classes for every method.

All state classes extend `Equatable` to ensure widgets only rebuild when relevant data actually changes. Cubits are also simple to test in isolation using `bloc_test`.

---

## 7. Error Handling Strategy

Errors are handled systematically so the user never sees a raw crash or uncaught exception:

```
[Dio Network Call]
       │
       ▼ (Throws DioException)
[Data Source]
       │
       ▼ (Maps HTTP code to ServerException / NetworkException / AuthException)
[Repository Implementation]
       │
       ▼ (Wraps into Left(Failure) using dartz Either<Failure, T>)
[Cubit]
       │
       ▼ (Translates Failure to user-friendly String message in state)
[Presentation Layer]
       │
       ▼ (Displays ErrorView with retry button or redirects to Login)
```

- **HTTP 400 (Bad Credentials):** Caught by `AuthRemoteDataSource`, mapped to `AuthFailure('Invalid username or password')`, and shown as an inline message on the login screen.
- **HTTP 401 / 403 (Expired Session):** Triggers auto-logout, clears stored tokens, and redirects to the login screen with an explanatory message.
- **HTTP 404 (Not Found):** Mapped to `NotFoundFailure`, showing a "Product not found" state with a button to return to the catalog.
- **HTTP 500 / Connection Timeout:** Mapped to `ServerFailure` or `NetworkFailure`, displaying a friendly `ErrorView` with a "Try Again" retry callback.

---

## 8. Getting Started

### Prerequisites
- **Flutter SDK:** `^3.29.2`
- **Dart SDK:** `^3.7.2`
- **Android Studio** or **VS Code** with Flutter extensions.

### Installation & Run Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/Ranojitdas/ShopSphere.git
   cd ShopSphere
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Code Generation:**
   > *Note:* This project uses manual model serialization and `mocktail` for testing. **No `build_runner` step is required.** The project compiles immediately.

4. **Run the app:**
   ```bash
   # Run on connected phone or emulator
   flutter run

   # Or run on Chrome to test responsive tablet views
   flutter run -d chrome
   ```

5. **Build Release APK:**
   ```bash
   flutter build apk --release
   ```
   The output APK is generated at: `build/app/outputs/flutter-apk/app-release.apk`.

---

## 9. Testing & Quality Verification

ShopSphere includes a unit test suite covering models, repositories, use cases, and cubits.

```bash
# Run all unit tests
flutter test

# Run static analysis
flutter analyze
```

### Test Summary
- **Total Tests:** 40 unit tests
- **Pass Rate:** 100% (40 / 40 passed)
- **Static Analysis:** `flutter analyze` reports **0 issues**.

| Test Suite | File | Tests | Focus Area |
| :--- | :--- | :---: | :--- |
| **Theme** | `test/core/theme/theme_cubit_test.dart` | 3 | Theme persistence & mode toggles |
| **Auth Model** | `test/features/auth/data/models/user_model_test.dart` | 3 | JSON parsing & entity inheritance |
| **Auth UseCase** | `test/features/auth/domain/usecases/login_usecase_test.dart` | 4 | Credential dispatch & failure delegation |
| **Product Model** | `test/features/products/data/models/product_model_test.dart` | 4 | JSON parsing with null-safe brand fallbacks |
| **Product Repo** | `test/features/products/data/repositories/product_repository_impl_test.dart` | 5 | ServerException & NetworkException to Failure mapping |
| **Product UseCase** | `test/features/products/domain/usecases/get_products_usecase_test.dart` | 3 | Pagination parameter propagation |
| **Product Cubit** | `test/features/products/presentation/cubit/product_list_cubit_test.dart` | 6 | State sequences: loading, pagination, search, error |
| **Cart Entity** | `test/features/cart/domain/entities/cart_entity_test.dart` | 3 | Subtotal & discount arithmetic accuracy |
| **Cart UseCases** | `test/features/cart/domain/usecases/cart_usecases_test.dart` | 4 | Boundary validation preventing negative quantities |
| **Cart Cubit** | `test/features/cart/presentation/cubit/cart_cubit_test.dart` | 5 | State emission on addition, decrement, & clear |

---

## 10. Test Credentials

The app uses DummyJSON authentication. The default credentials are:

- **Username:** `emilys`
- **Password:** `emilyspass`

*(Any valid user from `https://dummyjson.com/users` can also be used).*

---

## 11. Assumptions & Trade-offs

Here are a few deliberate decisions made while building the app, along with what I would do with more time:

- **Local Cart Storage (`shared_preferences` over SQLite):**  
  A shopping cart in an e-commerce catalog holds a small, flat list of items (rarely more than 10–20). I opted for JSON serialization via `shared_preferences` because it is fast, lightweight, and eliminates the schema migration boilerplate and native plugin bloat of SQLite/Drift. If the app grew into an offline inventory management tool with thousands of SKUs and relational lookups, migrating to `drift` would make sense.

- **Handling DummyJSON's Simulated Cart API:**  
  The assignment asks to call `POST /carts/add` on checkout. However, DummyJSON is a stateless mock server—it returns a 201 response calculating order totals, but never actually persists the cart or decrements product stock on the server. Because of this, `CartCubit` and local storage act as the actual source of truth for the user's cart session.

- **Zero Code Generation (`mocktail` over `mockito`):**  
  I deliberately avoided `build_runner` by using `mocktail` for testing and writing model serialization manually. This keeps the repository clean of auto-generated `.mocks.dart` files, avoids merge conflicts in generated files, and means anyone who clones the project can immediately run `flutter test` without a build step.

### What I Would Improve With More Time
- **Offline Product Caching:** Store previously fetched catalog pages locally in a local database (Drift or Hive) and display an offline banner when network drops.
- **Biometric Login:** Add fingerprint/face unlock via `local_auth` to let users quickly restore their session without re-entering passwords.
- **Wishlist & Favorites:** A dedicated favorites tab syncing saved items locally.
- **Internationalization (i18n):** Add `.arb` translation files for Hindi and English localization.
- **Golden Tests:** Add pixel-level regression tests to verify responsive tablet layouts on CI.

### Use of AI Tools
*(As requested in Section 9 of the assignment instructions)*
AI assistance was used as a pair-programming tool for drafting repetitive boilerplate (like JSON fixture files and mock test scaffolds) and brainstorming layout ideas. All business logic, Clean Architecture layer boundaries, state management, and error handling were written, verified, and tested by me, and I look forward to walking through the codebase and discussing the design decisions during the interview.

---

## 12. Author Information

- **Author:** Ranojit Das
- **Email:** [ranojitdas362@gmail.com](mailto:ranojitdas362@gmail.com)
- **GitHub:** [https://github.com/Ranojitdas](https://github.com/Ranojitdas)
- **Role:** Flutter Developer Intern Candidate
- **Company:** Prosessed
