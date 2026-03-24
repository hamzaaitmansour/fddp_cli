import 'dart:io';
import 'package:yaml/yaml.dart';
import '../commands/add_command.dart';

String _readPackageName() {
  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    print('\x1B[31m✗ pubspec.yaml not found.\x1B[0m');
    print('  Run fddp from the root of your Flutter project.');
    exit(1);
  }
  final yaml = loadYaml(file.readAsStringSync()) as YamlMap;
  final name = yaml['name'] as String?;
  if (name == null || name.isEmpty) {
    print('\x1B[31m✗ Could not read package name from pubspec.yaml\x1B[0m');
    exit(1);
  }
  return name;
}

class FeatureGenerator {
  final String featureName;
  final String basePath;
  final StateManagement stateManagement;
  late final String _pkg;

  FeatureGenerator({
    required this.featureName,
    required this.basePath,
    required this.stateManagement,
  }) {
    _pkg = _readPackageName();
  }

  String get _cls => _pascal(featureName);
  String get _featurePath => '$basePath/$featureName';
  String get _fp => 'package:$_pkg/${_featurePath.replaceFirst('lib/', '')}';
  String get _cp => 'package:$_pkg/core';

  // ── Generate ──────────────────────────────────────────────────────────────

  Future<void> generate() async {
    final smLabel =
        stateManagement.name; // "provider" | "bloc" | "cubit" | "riverpod"
    print('');
    print('\x1B[36m🚀 Generating feature:\x1B[0m \x1B[1m$_featurePath\x1B[0m');
    print('\x1B[90m   package: $_pkg  |  state: $smLabel\x1B[0m');
    print('');

    for (final dir in _directories()) {
      Directory(dir).createSync(recursive: true);
    }

    int created = 0, skipped = 0;
    for (final entry in _files().entries) {
      final f = File(entry.key);
      if (f.existsSync()) {
        print('  \x1B[33m⚠ skip\x1B[0m  ${entry.key}');
        skipped++;
      } else {
        f.parent.createSync(recursive: true);
        f.writeAsStringSync(entry.value);
        print('  \x1B[32m✓\x1B[0m      ${entry.key}');
        created++;
      }
    }

    print('');
    print('\x1B[32m✅ Done!\x1B[0m  $created created, $skipped skipped');
    print('');
    _printTree();
  }

  // ── Directories ───────────────────────────────────────────────────────────

  List<String> _directories() {
    final base = [
      '$_featurePath/data/datasources',
      '$_featurePath/data/models',
      '$_featurePath/data/repositories',
      '$_featurePath/domain/entities',
      '$_featurePath/domain/repositories',
      '$_featurePath/domain/usecases',
      '$_featurePath/presentation/view',
      '$_featurePath/presentation/widgets',
    ];

    switch (stateManagement) {
      case StateManagement.provider:
        return [
          ...base,
          '$_featurePath/presentation/view_state',
          '$_featurePath/presentation/view_model',
        ];
      case StateManagement.bloc:
        return [
          ...base,
          '$_featurePath/presentation/bloc',
        ];
      case StateManagement.cubit:
        return [
          ...base,
          '$_featurePath/presentation/cubit',
        ];
      case StateManagement.riverpod:
        return [
          ...base,
          '$_featurePath/presentation/providers',
          '$_featurePath/presentation/state',
        ];
    }
  }

  // ── Files ─────────────────────────────────────────────────────────────────

  Map<String, String> _files() => {
        // ── Data ──────────────────────────────────────────────────────────
        '$_featurePath/data/models/${featureName}_model.dart': _modelFile(),
        '$_featurePath/data/datasources/${featureName}_remote_datasource.dart':
            _remoteDataSourceFile(),
        '$_featurePath/data/datasources/${featureName}_local_datasource.dart':
            _localDataSourceFile(),
        '$_featurePath/data/repositories/${featureName}_repository_impl.dart':
            _repoImplFile(),

        // ── Domain ────────────────────────────────────────────────────────
        '$_featurePath/domain/entities/${featureName}_entity.dart':
            _entityFile(),
        '$_featurePath/domain/repositories/${featureName}_repository.dart':
            _repoFile(),
        '$_featurePath/domain/usecases/get_${featureName}_usecase.dart':
            _usecaseFile(),

        // ── Presentation (state-management specific) ─────────────────────
        ..._presentationFiles(),
      };

  Map<String, String> _presentationFiles() {
    switch (stateManagement) {
      case StateManagement.provider:
        return {
          '$_featurePath/presentation/view_state/${featureName}_view_state.dart':
              _providerViewStateFile(),
          '$_featurePath/presentation/view_model/${featureName}_view_model.dart':
              _providerViewModelFile(),
          '$_featurePath/presentation/view/${featureName}_view.dart':
              _providerViewFile(),
        };
      case StateManagement.bloc:
        return {
          '$_featurePath/presentation/bloc/${featureName}_bloc.dart':
              _blocFile(),
          '$_featurePath/presentation/bloc/${featureName}_event.dart':
              _blocEventFile(),
          '$_featurePath/presentation/bloc/${featureName}_state.dart':
              _blocStateFile(),
          '$_featurePath/presentation/view/${featureName}_view.dart':
              _blocViewFile(),
        };
      case StateManagement.cubit:
        return {
          '$_featurePath/presentation/cubit/${featureName}_cubit.dart':
              _cubitFile(),
          '$_featurePath/presentation/cubit/${featureName}_state.dart':
              _cubitStateFile(),
          '$_featurePath/presentation/view/${featureName}_view.dart':
              _cubitViewFile(),
        };
      case StateManagement.riverpod:
        return {
          '$_featurePath/presentation/state/${featureName}_state.dart':
              _riverpodStateFile(),
          '$_featurePath/presentation/providers/${featureName}_provider.dart':
              _riverpodProviderFile(),
          '$_featurePath/presentation/view/${featureName}_view.dart':
              _riverpodViewFile(),
        };
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATA LAYER  (shared across all state managers)
  // ═══════════════════════════════════════════════════════════════════════════

  String _entityFile() => '''class ${_cls}Entity {
  final String id;
  // TODO: add your fields

  const ${_cls}Entity({required this.id});
}
''';

  String _modelFile() =>
      '''import '$_fp/domain/entities/${featureName}_entity.dart';

class ${_cls}Model extends ${_cls}Entity {
  const ${_cls}Model({required super.id});

  factory ${_cls}Model.fromJson(Map<String, dynamic> json) {
    return ${_cls}Model(id: json['id'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id};

  factory ${_cls}Model.fromEntity(${_cls}Entity e) => ${_cls}Model(id: e.id);
}
''';

  String _remoteDataSourceFile() =>
      '''import '$_fp/data/models/${featureName}_model.dart';

abstract class ${_cls}RemoteDataSource {
  Future<List<${_cls}Model>> getAll();
  Future<${_cls}Model>       getById(String id);
  Future<void>               create(${_cls}Model model);
  Future<void>               update(${_cls}Model model);
  Future<void>               delete(String id);
}

class ${_cls}RemoteDataSourceImpl implements ${_cls}RemoteDataSource {
  // TODO: inject Dio → final Dio _dio;

  @override Future<List<${_cls}Model>> getAll()               => throw UnimplementedError();
  @override Future<${_cls}Model>       getById(String id)     => throw UnimplementedError();
  @override Future<void>               create(${_cls}Model m) => throw UnimplementedError();
  @override Future<void>               update(${_cls}Model m) => throw UnimplementedError();
  @override Future<void>               delete(String id)      => throw UnimplementedError();
}
''';

  String _localDataSourceFile() =>
      '''import '$_fp/data/models/${featureName}_model.dart';

abstract class ${_cls}LocalDataSource {
  Future<List<${_cls}Model>> getCached();
  Future<void>               cache(List<${_cls}Model> data);
}

class ${_cls}LocalDataSourceImpl implements ${_cls}LocalDataSource {
  // TODO: inject SharedPreferences / Hive

  @override Future<List<${_cls}Model>> getCached()                => throw UnimplementedError();
  @override Future<void>               cache(List<${_cls}Model> d) => throw UnimplementedError();
}
''';

  String _repoFile() => '''import '$_cp/result/result.dart';
import '$_fp/domain/entities/${featureName}_entity.dart';

abstract class ${_cls}Repository {
  Future<Result<List<${_cls}Entity>>> getAll();
  Future<Result<${_cls}Entity>>       getById(String id);
  Future<Result<void>>                create(${_cls}Entity entity);
  Future<Result<void>>                update(${_cls}Entity entity);
  Future<Result<void>>                delete(String id);
}
''';

  String _repoImplFile() => '''import '$_cp/result/result.dart';
import '$_cp/exceptions/app_exception.dart';
import '$_fp/domain/entities/${featureName}_entity.dart';
import '$_fp/domain/repositories/${featureName}_repository.dart';
import '$_fp/data/datasources/${featureName}_remote_datasource.dart';
import '$_fp/data/datasources/${featureName}_local_datasource.dart';

class ${_cls}RepositoryImpl implements ${_cls}Repository {
  final ${_cls}RemoteDataSource _remote;
  final ${_cls}LocalDataSource  _local;

  const ${_cls}RepositoryImpl({
    required ${_cls}RemoteDataSource remote,
    required ${_cls}LocalDataSource  local,
  })  : _remote = remote,
        _local  = local;

  @override
  Future<Result<List<${_cls}Entity>>> getAll() async {
    try {
      final data = await _remote.getAll();
      await _local.cache(data);
      return Success(data);
    } catch (_) {
      try { return Success(await _local.getCached()); }
      catch (e) { return Failure(ServerError(e.toString())); }
    }
  }

  @override
  Future<Result<${_cls}Entity>> getById(String id) async {
    try { return Success(await _remote.getById(id)); }
    catch (e) { return Failure(ServerError(e.toString())); }
  }

  @override
  Future<Result<void>> create(${_cls}Entity entity) async {
    try { await _remote.create(entity as dynamic); return Success(null); }
    catch (e) { return Failure(ServerError(e.toString())); }
  }

  @override
  Future<Result<void>> update(${_cls}Entity entity) async {
    try { await _remote.update(entity as dynamic); return Success(null); }
    catch (e) { return Failure(ServerError(e.toString())); }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try { await _remote.delete(id); return Success(null); }
    catch (e) { return Failure(ServerError(e.toString())); }
  }
}
''';

  String _usecaseFile() => '''import '$_cp/result/result.dart';
import '$_fp/domain/entities/${featureName}_entity.dart';
import '$_fp/domain/repositories/${featureName}_repository.dart';

class Get${_cls} {
  final ${_cls}Repository _repository;
  Get${_cls}(this._repository);

  Future<Result<List<${_cls}Entity>>> call() => _repository.getAll();
}
''';

  // ═══════════════════════════════════════════════════════════════════════════
  // PROVIDER
  // ═══════════════════════════════════════════════════════════════════════════

  String _providerViewStateFile() => '''sealed class ${_cls}ViewState {
  const ${_cls}ViewState();
}

class ${_cls}Initial extends ${_cls}ViewState { const ${_cls}Initial(); }
class ${_cls}Loading extends ${_cls}ViewState { const ${_cls}Loading(); }

class ${_cls}Success extends ${_cls}ViewState {
  final List<dynamic> data; // TODO: replace dynamic with ${_cls}Entity
  const ${_cls}Success(this.data);
}

class ${_cls}Error extends ${_cls}ViewState {
  final String message;
  const ${_cls}Error(this.message);
}
''';

  String _providerViewModelFile() =>
      '''import 'package:flutter/foundation.dart';
import '$_fp/presentation/view_state/${featureName}_view_state.dart';
import '$_fp/domain/usecases/get_${featureName}_usecase.dart';

class ${_cls}ViewModel extends ChangeNotifier {
  final Get${_cls} _get${_cls};

  ${_cls}ViewModel(this._get${_cls});

  ${_cls}ViewState _state = const ${_cls}Initial();
  ${_cls}ViewState get state => _state;

  void _emit(${_cls}ViewState s) {
    _state = s;
    notifyListeners();
  }

  Future<void> load() async {
    _emit(const ${_cls}Loading());
    final result = await _get${_cls}();
    result.when(
      success: (data)  => _emit(${_cls}Success(data)),
      failure: (error) => _emit(${_cls}Error(error.errorMessage)),
    );
  }
}
''';

  String _providerViewFile() => '''import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '$_fp/presentation/view_model/${featureName}_view_model.dart';
import '$_fp/presentation/view_state/${featureName}_view_state.dart';

class ${_cls}View extends StatefulWidget {
  const ${_cls}View({super.key});
  static const routeName = '/$featureName';

  @override
  State<${_cls}View> createState() => _${_cls}ViewState();
}

class _${_cls}ViewState extends State<${_cls}View> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<${_cls}ViewModel>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$_cls')),
      body: Consumer<${_cls}ViewModel>(
        builder: (context, vm, _) => switch (vm.state) {
          ${_cls}Initial() => const SizedBox.shrink(),
          ${_cls}Loading() => const Center(child: CircularProgressIndicator()),
          ${_cls}Success() => const Center(child: Text('✓')), // TODO: build your UI
          ${_cls}Error(:final message) => _ErrorWidget(message: message, onRetry: vm.load),
        },
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
''';

  // ═══════════════════════════════════════════════════════════════════════════
  // BLOC
  // ═══════════════════════════════════════════════════════════════════════════

  String _blocEventFile() => '''import 'package:equatable/equatable.dart';

abstract class ${_cls}Event extends Equatable {
  const ${_cls}Event();
  @override List<Object?> get props => [];
}

class Get${_cls}sEvent extends ${_cls}Event {
  const Get${_cls}sEvent();
}
''';

  String _blocStateFile() => '''import 'package:equatable/equatable.dart';
import '$_fp/domain/entities/${featureName}_entity.dart';

abstract class ${_cls}State extends Equatable {
  const ${_cls}State();
  @override List<Object?> get props => [];
}

class ${_cls}Initial extends ${_cls}State { const ${_cls}Initial(); }
class ${_cls}Loading extends ${_cls}State { const ${_cls}Loading(); }

class ${_cls}Loaded extends ${_cls}State {
  final List<${_cls}Entity> data;
  const ${_cls}Loaded(this.data);
  @override List<Object?> get props => [data];
}

class ${_cls}Error extends ${_cls}State {
  final String message;
  const ${_cls}Error(this.message);
  @override List<Object?> get props => [message];
}
''';

  String _blocFile() => '''import 'package:flutter_bloc/flutter_bloc.dart';
import '$_fp/presentation/bloc/${featureName}_event.dart';
import '$_fp/presentation/bloc/${featureName}_state.dart';
import '$_fp/domain/usecases/get_${featureName}_usecase.dart';

class ${_cls}Bloc extends Bloc<${_cls}Event, ${_cls}State> {
  final Get${_cls} _get${_cls};

  ${_cls}Bloc({required Get${_cls} get${_cls}})
      : _get${_cls} = get${_cls},
        super(const ${_cls}Initial()) {
    on<Get${_cls}sEvent>(_onGet${_cls}s);
  }

  Future<void> _onGet${_cls}s(
    Get${_cls}sEvent event,
    Emitter<${_cls}State> emit,
  ) async {
    emit(const ${_cls}Loading());
    final result = await _get${_cls}();
    result.when(
      success: (data)  => emit(${_cls}Loaded(data)),
      failure: (error) => emit(${_cls}Error(error.errorMessage)),
    );
  }
}
''';

  String _blocViewFile() => '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '$_fp/presentation/bloc/${featureName}_bloc.dart';
import '$_fp/presentation/bloc/${featureName}_event.dart';
import '$_fp/presentation/bloc/${featureName}_state.dart';

class ${_cls}View extends StatefulWidget {
  const ${_cls}View({super.key});
  static const routeName = '/$featureName';

  @override
  State<${_cls}View> createState() => _${_cls}ViewState();
}

class _${_cls}ViewState extends State<${_cls}View> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<${_cls}Bloc>().add(const Get${_cls}sEvent()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$_cls')),
      body: BlocBuilder<${_cls}Bloc, ${_cls}State>(
        builder: (context, state) => switch (state) {
          ${_cls}Initial() => const SizedBox.shrink(),
          ${_cls}Loading() => const Center(child: CircularProgressIndicator()),
          ${_cls}Loaded()  => const Center(child: Text('✓')), // TODO: build your UI
          ${_cls}Error(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<${_cls}Bloc>().add(const Get${_cls}sEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
''';

  // ═══════════════════════════════════════════════════════════════════════════
  // CUBIT
  // ═══════════════════════════════════════════════════════════════════════════

  String _cubitStateFile() => '''import 'package:equatable/equatable.dart';
import '$_fp/domain/entities/${featureName}_entity.dart';

abstract class ${_cls}State extends Equatable {
  const ${_cls}State();
  @override List<Object?> get props => [];
}

class ${_cls}Initial extends ${_cls}State { const ${_cls}Initial(); }
class ${_cls}Loading extends ${_cls}State { const ${_cls}Loading(); }

class ${_cls}Loaded extends ${_cls}State {
  final List<${_cls}Entity> data;
  const ${_cls}Loaded(this.data);
  @override List<Object?> get props => [data];
}

class ${_cls}Error extends ${_cls}State {
  final String message;
  const ${_cls}Error(this.message);
  @override List<Object?> get props => [message];
}
''';

  String _cubitFile() => '''import 'package:flutter_bloc/flutter_bloc.dart';
import '$_fp/presentation/cubit/${featureName}_state.dart';
import '$_fp/domain/usecases/get_${featureName}_usecase.dart';

class ${_cls}Cubit extends Cubit<${_cls}State> {
  final Get${_cls} _get${_cls};

  ${_cls}Cubit({required Get${_cls} get${_cls}})
      : _get${_cls} = get${_cls},
        super(const ${_cls}Initial());

  Future<void> load() async {
    emit(const ${_cls}Loading());
    final result = await _get${_cls}();
    result.when(
      success: (data)  => emit(${_cls}Loaded(data)),
      failure: (error) => emit(${_cls}Error(error.errorMessage)),
    );
  }
}
''';

  String _cubitViewFile() => '''import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '$_fp/presentation/cubit/${featureName}_cubit.dart';
import '$_fp/presentation/cubit/${featureName}_state.dart';

class ${_cls}View extends StatelessWidget {
  const ${_cls}View({super.key});
  static const routeName = '/$featureName';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$_cls')),
      body: BlocBuilder<${_cls}Cubit, ${_cls}State>(
        builder: (context, state) => switch (state) {
          ${_cls}Initial() => const SizedBox.shrink(),
          ${_cls}Loading() => const Center(child: CircularProgressIndicator()),
          ${_cls}Loaded()  => const Center(child: Text('✓')), // TODO: build your UI
          ${_cls}Error(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<${_cls}Cubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
''';

  // ═══════════════════════════════════════════════════════════════════════════
  // RIVERPOD
  // ═══════════════════════════════════════════════════════════════════════════

  String _riverpodStateFile() =>
      '''import '$_fp/domain/entities/${featureName}_entity.dart';

class ${_cls}State {
  final bool isLoading;
  final List<${_cls}Entity> data;
  final String? error;

  const ${_cls}State({
    this.isLoading = false,
    this.data      = const [],
    this.error,
  });

  bool get hasError => error != null;

  ${_cls}State copyWith({
    bool?                isLoading,
    List<${_cls}Entity>? data,
    String?              error,
  }) {
    return ${_cls}State(
      isLoading: isLoading ?? this.isLoading,
      data:      data      ?? this.data,
      error:     error,
    );
  }
}
''';

  String _riverpodProviderFile() =>
      '''import 'package:flutter_riverpod/flutter_riverpod.dart';
import '$_fp/presentation/state/${featureName}_state.dart';
import '$_fp/domain/usecases/get_${featureName}_usecase.dart';

class ${_cls}Notifier extends StateNotifier<${_cls}State> {
  final Get${_cls} _get${_cls};

  ${_cls}Notifier(this._get${_cls}) : super(const ${_cls}State());

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final result = await _get${_cls}();
    result.when(
      success: (data)  => state = state.copyWith(isLoading: false, data: data),
      failure: (error) => state = state.copyWith(isLoading: false, error: error.errorMessage),
    );
  }
}

// TODO: wire this provider with your DI (e.g. get_it)
final ${featureName}Provider =
    StateNotifierProvider<${_cls}Notifier, ${_cls}State>((ref) {
  throw UnimplementedError(
    'Override ${featureName}Provider in your ProviderScope overrides.',
  );
});
''';

  String _riverpodViewFile() => '''import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '$_fp/presentation/providers/${featureName}_provider.dart';

class ${_cls}View extends ConsumerStatefulWidget {
  const ${_cls}View({super.key});
  static const routeName = '/$featureName';

  @override
  ConsumerState<${_cls}View> createState() => _${_cls}ViewState();
}

class _${_cls}ViewState extends ConsumerState<${_cls}View> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(${featureName}Provider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(${featureName}Provider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(${featureName}Provider.notifier).load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('$_cls')),
      body: const Center(child: Text('✓')), // TODO: build your UI
    );
  }
}
''';

  // ── Tree printer ──────────────────────────────────────────────────────────

  void _printTree() {
    final smDir = switch (stateManagement) {
      StateManagement.provider => 'view_model/ + view_state/',
      StateManagement.bloc => 'bloc/',
      StateManagement.cubit => 'cubit/',
      StateManagement.riverpod => 'providers/ + state/',
    };

    print('\x1B[33m📁 $featureName/\x1B[0m');
    print('   ├── data/');
    print('   │   ├── datasources/  (remote + local)');
    print('   │   ├── models/');
    print('   │   └── repositories/');
    print('   ├── domain/');
    print('   │   ├── entities/');
    print('   │   ├── repositories/ (Result<T>)');
    print('   │   └── usecases/');
    print('   └── presentation/');
    print('       ├── $smDir');
    print('       ├── view/');
    print('       └── widgets/');
    print('');
  }
}

String _pascal(String s) =>
    s.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join('');
