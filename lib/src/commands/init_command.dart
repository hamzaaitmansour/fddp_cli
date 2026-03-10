import 'dart:io';
import 'package:args/command_runner.dart';

class InitCommand extends Command<void> {
  @override
  String get name => 'init';

  @override
  String get description =>
      'Initialize FDDP core structure in your Flutter project (skips existing files)';

  @override
  Future<void> run() async {
    print('');
    print('\x1B[36m🔧 Initializing FDDP project structure...\x1B[0m');
    print('');

    final structure = {
      'lib/core/result/result.dart': _resultTemplate(),
      'lib/core/exceptions/app_exception.dart': _appExceptionTemplate(),
      'lib/core/usecases/usecase.dart': _usecaseTemplate(),
      'lib/core/network/network_info.dart': _networkInfoTemplate(),
      'lib/core/theme/app_theme.dart': _themeTemplate(),
      'lib/core/constants/app_constants.dart': _constantsTemplate(),
      'lib/core/widgets/loading_widget.dart': _loadingWidgetTemplate(),
      'lib/config/routes/app_router.dart': _routerTemplate(),
      'lib/config/di/injection_container.dart': _diTemplate(),
    };

    int created = 0;
    int skipped = 0;

    for (final entry in structure.entries) {
      final file = File(entry.key);
      if (file.existsSync()) {
        print('  \x1B[33m⚠ skip\x1B[0m  ${entry.key}');
        skipped++;
      } else {
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(entry.value);
        print('  \x1B[32m✓\x1B[0m      ${entry.key}');
        created++;
      }
    }

    // Ensure lib/features/ exists but never touch what's inside
    final featuresDir = Directory('lib/features');
    if (!featuresDir.existsSync()) {
      featuresDir.createSync(recursive: true);
      print('  \x1B[32m✓\x1B[0m      lib/features/');
      created++;
    } else {
      print('  \x1B[33m⚠ skip\x1B[0m  lib/features/ (already exists)');
      skipped++;
    }

    print('');
    print('\x1B[32m✅ Init done!\x1B[0m  $created created, $skipped skipped');
    print('');
    print('Next steps:');
    print('  \x1B[36mfddp add feature auth\x1B[0m');
    print('  \x1B[36mfddp add feature cart --bloc\x1B[0m');
    print('  \x1B[36mfddp add feature orders --cubit\x1B[0m');
    print('  \x1B[36mfddp add feature products --riverpod\x1B[0m');
    print('  \x1B[36mfddp add feature employee/profile\x1B[0m');
    print('');
  }

  // ── Templates ──────────────────────────────────────────────────────────────

  String _resultTemplate() => '''import '../exceptions/app_exception.dart';

sealed class Result<T> {
  R when<R>({
    required R Function(T value) success,
    required R Function(AppError error) failure,
  });
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(AppError error) failure,
  }) =>
      success(value);
}

class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);

  @override
  R when<R>({
    required R Function(T value) success,
    required R Function(AppError error) failure,
  }) =>
      failure(error);
}
''';

  String _appExceptionTemplate() => '''sealed class AppError {
  const AppError();
  String get errorMessage;
}

// ── Network ───────────────────────────────────────────────────────────────────
class NetworkError extends AppError {
  final String message;
  const NetworkError(this.message);
  @override String get errorMessage => message;
}

class TimeoutError extends AppError {
  final String message;
  const TimeoutError(this.message);
  @override String get errorMessage => message;
}

// ── Server ────────────────────────────────────────────────────────────────────
class ServerError extends AppError {
  final String message;
  const ServerError(this.message);
  @override String get errorMessage => message;
}

class NotFoundError extends AppError {
  final String message;
  const NotFoundError(this.message);
  @override String get errorMessage => message;
}

class ForbiddenError extends AppError {
  final String message;
  const ForbiddenError(this.message);
  @override String get errorMessage => message;
}

class RateLimitError extends AppError {
  final String message;
  const RateLimitError(this.message);
  @override String get errorMessage => message;
}

// ── Auth ──────────────────────────────────────────────────────────────────────
class UnauthorizedError extends AppError {
  final String message;
  const UnauthorizedError(this.message);
  @override String get errorMessage => message;
}

class InvalidCredentialsError extends AppError {
  final String message;
  const InvalidCredentialsError(this.message);
  @override String get errorMessage => message;
}

class UserNotFoundError extends AppError {
  final String message;
  const UserNotFoundError(this.message);
  @override String get errorMessage => message;
}

// ── Local storage ─────────────────────────────────────────────────────────────
class LocalStorageError extends AppError {
  final String message;
  const LocalStorageError(this.message);
  @override String get errorMessage => message;
}

// ── Firestore ─────────────────────────────────────────────────────────────────
class FirestorePermissionDeniedError extends AppError {
  final String message;
  const FirestorePermissionDeniedError(this.message);
  @override String get errorMessage => message;
}

class FirestoreUnavailableError extends AppError {
  final String message;
  const FirestoreUnavailableError(this.message);
  @override String get errorMessage => message;
}

class FirestoreAbortedError extends AppError {
  final String message;
  const FirestoreAbortedError(this.message);
  @override String get errorMessage => message;
}

class FirestoreDataLossError extends AppError {
  final String message;
  const FirestoreDataLossError(this.message);
  @override String get errorMessage => message;
}

// ── Device ────────────────────────────────────────────────────────────────────
class DeviceInfoError extends AppError {
  final String message;
  const DeviceInfoError(this.message);
  @override String get errorMessage => message;
}

class DeviceMismatchError extends AppError {
  final String message;
  const DeviceMismatchError(this.message);
  @override String get errorMessage => message;
}

class PlatformError extends AppError {
  final String message;
  const PlatformError(this.message);
  @override String get errorMessage => message;
}

// ── Location ──────────────────────────────────────────────────────────────────
class LocationError extends AppError {
  final String message;
  const LocationError(this.message);
  @override String get errorMessage => message;
}

// ── Config / Remote ───────────────────────────────────────────────────────────
class ConfigurationError extends AppError {
  final String message;
  const ConfigurationError(this.message);
  @override String get errorMessage => message;
}

class RemoteConfigError extends AppError {
  final String message;
  const RemoteConfigError(this.message);
  @override String get errorMessage => message;
}

class UpdateRequiredError extends AppError {
  final String message;
  final String currentVersion;
  final String minimumVersion;
  final bool isForceUpdate;

  const UpdateRequiredError(
    this.message, {
    required this.currentVersion,
    required this.minimumVersion,
    required this.isForceUpdate,
  });

  @override String get errorMessage => message;
}

// ── Notifications ─────────────────────────────────────────────────────────────
class NotificationNotFoundError extends AppError {
  final String message;
  const NotificationNotFoundError(this.message);
  @override String get errorMessage => message;
}

class NotificationPermissionDeniedError extends AppError {
  final String message;
  const NotificationPermissionDeniedError(this.message);
  @override String get errorMessage => message;
}

class NotificationServiceUnavailableError extends AppError {
  final String message;
  const NotificationServiceUnavailableError(this.message);
  @override String get errorMessage => message;
}

class NotificationAlreadyProcessedError extends AppError {
  final String message;
  const NotificationAlreadyProcessedError(this.message);
  @override String get errorMessage => message;
}

class NotificationSyncError extends AppError {
  final String message;
  const NotificationSyncError(this.message);
  @override String get errorMessage => message;
}

// ── External APIs ─────────────────────────────────────────────────────────────
class PlacesApiError extends AppError {
  final String message;
  final String? status;
  const PlacesApiError(this.message, {this.status});
  @override String get errorMessage => message;
}

// ── Generic ───────────────────────────────────────────────────────────────────
class ParseError extends AppError {
  final String message;
  const ParseError(this.message);
  @override String get errorMessage => message;
}

class UnexpectedError extends AppError {
  final String message;
  const UnexpectedError(this.message);
  @override String get errorMessage => message;
}
''';

  String _usecaseTemplate() => '''import '../result/result.dart';

abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

class NoParams {}
''';

  String _networkInfoTemplate() => '''abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  // TODO: inject connectivity_plus
  @override
  Future<bool> get isConnected async => true;
}
''';

  String _themeTemplate() => '''import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
    brightness: Brightness.light,
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
    brightness: Brightness.dark,
  );
}
''';

  String _constantsTemplate() => '''class AppConstants {
  AppConstants._();

  static const String appName    = 'My App';
  static const String baseUrl    = 'https://api.example.com';
  static const int    timeoutSec = 30;
}
''';

  String _loadingWidgetTemplate() => '''import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
''';

  String _routerTemplate() => '''import 'package:flutter/material.dart';
// import your views here

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case AuthView.routeName:
      //   return MaterialPageRoute(builder: (_) => const AuthView());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('404 — Page not found')),
          ),
        );
    }
  }
}
''';

  String _diTemplate() => '''// Dependency Injection
// Recommended: flutter pub add get_it
//
// import 'package:get_it/get_it.dart';
// final sl = GetIt.instance;
//
// Future<void> init() async {
//   // ── Auth (Provider) ───────────────────────────────────────────────────
//   sl.registerFactory(() => AuthViewModel(sl()));
//   sl.registerLazySingleton(() => GetAuth(sl()));
//   sl.registerLazySingleton<AuthRepository>(
//     () => AuthRepositoryImpl(remote: sl(), local: sl()),
//   );
//   sl.registerLazySingleton<AuthRemoteDataSource>(
//     () => AuthRemoteDataSourceImpl(dio: sl()),
//   );
//   sl.registerLazySingleton<AuthLocalDataSource>(
//     () => AuthLocalDataSourceImpl(),
//   );
//
//   // ── Cart (Bloc) ───────────────────────────────────────────────────────
//   sl.registerFactory(() => CartBloc(getCart: sl()));
//
//   // ── External ─────────────────────────────────────────────────────────
//   sl.registerSingleton(Dio());
// }
''';
}
