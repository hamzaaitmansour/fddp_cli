# fddp Example

This package is a CLI tool, so its example is command-based.
Run these commands from the root of a Flutter app project.

## 1) Initialize base architecture

```bash
fddp init
```

## 2) Generate features with different state managers

```bash
# Provider (default)
fddp add feature auth

# Bloc
fddp add feature cart --bloc

# Cubit
fddp add feature orders --cubit

# Riverpod
fddp add feature notifications --riverpod

# Nested feature path
fddp add feature employee/profile
```

## 3) Add a page and a usecase

```bash
fddp add page auth login
fddp add usecase auth logout
```

## 4) Shortcuts

```bash
fddp i
fddp a f auth
fddp a p auth login
fddp a u auth logout
```
