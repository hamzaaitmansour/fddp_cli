# fddp 🚀

**Flutter Feature-Driven Development Pattern CLI**

Generate a full clean architecture feature in one command — data, domain, and presentation layers, wired up and ready to go.

[![pub version](https://img.shields.io/pub/v/fddp.svg)](https://pub.dev/packages/fddp)
[![Dart SDK](https://img.shields.io/badge/dart-%3E%3D3.0.0-blue)](https://dart.dev)

---

## Installation

```bash
dart pub global activate fddp
```

Make sure Dart's global bin is on your PATH:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:$HOME/.pub-cache/bin"
```

---

## Quick start

Run from the **root of your Flutter project**:

```bash
# 1. Initialize core structure
fddp init

# 2. Generate your first feature
fddp add feature auth
```

---

## Commands

### `fddp init`
Scaffolds the core project structure. **Skips any file that already exists.**

```
lib/
├── core/
│   ├── result/result.dart
│   ├── exceptions/app_exception.dart
│   ├── usecases/usecase.dart
│   ├── network/network_info.dart
│   ├── theme/app_theme.dart
│   ├── constants/app_constants.dart
│   └── widgets/loading_widget.dart
├── config/
│   ├── routes/app_router.dart
│   └── di/injection_container.dart
└── features/
```

---

### `fddp add feature <name>`

Generates a complete feature with your chosen state manager.

```bash
fddp add feature auth                  # Provider (default)
fddp add feature cart --bloc
fddp add feature orders --cubit
fddp add feature products --riverpod
fddp add feature employee/profile      # nested inside employee/
```

**Generated structure (Provider):**

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
    ├── view_state/auth_view_state.dart
    ├── view_model/auth_view_model.dart
    ├── view/auth_view.dart
    └── widgets/
```

---

### `fddp add page <feature> <name>`

```bash
fddp add page auth login
fddp add page auth register
```

### `fddp add usecase <feature> <name>`

```bash
fddp add usecase auth logout
fddp add usecase auth refresh_token
```

---

## Shortcuts

| Full | Short |
|---|---|
| `fddp add feature auth` | `fddp a f auth` |
| `fddp add page auth login` | `fddp a p auth login` |
| `fddp add usecase auth logout` | `fddp a u auth logout` |
| `fddp init` | `fddp i` |

---

## Result type

Uses a custom `Result<T>` sealed class — no `dartz` needed:

```dart
result.when(
  success: (data)  => emit(AuthSuccess(data)),
  failure: (error) => emit(AuthError(error.errorMessage)),
);
```

---

## Recommended dependencies

```yaml
dependencies:
  provider: ^6.1.2          # for --provider (default)
  flutter_bloc: ^8.1.6      # for --bloc / --cubit
  equatable: ^2.0.5         # for --bloc / --cubit
  flutter_riverpod: ^2.5.1  # for --riverpod
  get_it: ^7.7.0
  dio: ^5.4.3
```
