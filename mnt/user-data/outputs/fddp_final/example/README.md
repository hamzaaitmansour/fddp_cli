# fddp — Usage Examples

Run all commands from the **root of your Flutter project**.

---

## 1. Initialize core structure

```bash
fddp init
```

This creates `lib/core/` with `Result<T>`, `AppError`, `UseCase`, theme, constants,
network info, and a loading widget. Also creates `lib/config/` with router and DI.
**Skips anything that already exists.**

---

## 2. Generate features

```bash
# Provider (default)
fddp add feature auth

# Bloc
fddp add feature cart --bloc

# Cubit
fddp add feature orders --cubit

# Riverpod
fddp add feature notifications --riverpod

# Nested — creates lib/features/employee/profile/
fddp add feature employee/profile
```

---

## 3. Add pages and use cases

```bash
# Add a view to auth feature
fddp add page auth login
fddp add page auth register
fddp add page auth forgot_password

# Add use cases
fddp add usecase auth login
fddp add usecase auth logout
fddp add usecase auth refresh_token
```

---

## 4. Using shortcuts

```bash
fddp i                         # init
fddp a f auth                  # add feature auth (Provider)
fddp a f cart --bloc           # add feature cart with Bloc
fddp a p auth login            # add page
fddp a u auth logout           # add usecase
```

---

## 5. What gets generated for `fddp add feature auth`

```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart
│   │   └── auth_local_datasource.dart
│   ├── models/
│   │   └── auth_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── auth_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       └── get_auth_usecase.dart
└── presentation/
    ├── view_state/
    │   └── auth_view_state.dart    ← sealed class with Initial/Loading/Success/Error
    ├── view_model/
    │   └── auth_view_model.dart    ← ChangeNotifier, uses result.when()
    ├── view/
    │   └── auth_view.dart          ← Consumer<AuthViewModel>, switch(state)
    └── widgets/
```

All imports use the correct `package:your_app/...` format,
read automatically from your `pubspec.yaml`.
