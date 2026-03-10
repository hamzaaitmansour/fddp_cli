# Changelog

## 1.0.0

- Initial release
- `fddp init` — scaffolds `lib/core/` and `lib/config/` with base files
- `fddp add feature <n>` — generates full clean architecture feature
  - Provider (default), Bloc, Cubit, Riverpod support
  - Nested paths: `fddp add feature employee/profile`
  - Skips existing files — safe to run multiple times
- `fddp add page <feature> <n>` — adds a view to an existing feature
- `fddp add usecase <feature> <n>` — adds a use case to an existing feature
- One-letter shortcuts: `fddp a f auth`, `fddp i`
- Auto-reads package name from `pubspec.yaml` for correct imports
- Uses custom `Result<T>` sealed class — no `dartz` dependency
