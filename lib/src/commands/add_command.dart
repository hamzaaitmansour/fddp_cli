import 'dart:io';
import 'package:args/command_runner.dart';
import '../generators/feature_generator.dart';

class AddCommand extends Command<void> {
  @override
  String get name => 'add';

  @override
  String get description => 'Add a feature, page, or usecase to your project';

  AddCommand() {
    addSubcommand(AddFeatureCommand());
    addSubcommand(AddPageCommand());
    addSubcommand(AddUsecaseCommand());
  }
}

// ─── add feature ─────────────────────────────────────────────────────────────
class AddFeatureCommand extends Command<void> {
  @override
  String get name => 'feature';

  @override
  String get description => 'Generate a full clean architecture feature';

  @override
  String get invocation => 'fddp add feature <name_or_parent/name>';

  AddFeatureCommand() {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Base path for features folder',
        defaultsTo: 'lib/features',
      )
      ..addFlag(
        'provider',
        help: 'Use Provider for state management (default)',
        defaultsTo: false,
        negatable: false,
      )
      ..addFlag(
        'bloc',
        help: 'Use Bloc for state management',
        defaultsTo: false,
        negatable: false,
      )
      ..addFlag(
        'cubit',
        help: 'Use Cubit for state management',
        defaultsTo: false,
        negatable: false,
      )
      ..addFlag(
        'riverpod',
        help: 'Use Riverpod for state management',
        defaultsTo: false,
        negatable: false,
      );
  }

  @override
  Future<void> run() async {
    if (argResults!.rest.isEmpty) {
      print('\x1B[31m✗ Please provide a feature name\x1B[0m');
      print('');
      print('  Examples:');
      print('    fddp add feature auth');
      print('    fddp add feature employee/profile');
      print('    fddp add feature cart --bloc');
      print('    fddp add feature orders --cubit');
      print('    fddp add feature products --riverpod');
      exit(1);
    }

    final rawInput = argResults!.rest.first.toLowerCase().replaceAll('\\', '/');
    final segments = rawInput.split('/').where((s) => s.isNotEmpty).toList();
    final featureName = segments.last;
    final baseOption = argResults!['path'] as String;
    final basePath = segments.length > 1
        ? '$baseOption/${segments.sublist(0, segments.length - 1).join('/')}'
        : baseOption;

    StateManagement sm = StateManagement.provider;
    if (argResults!['bloc'] == true) sm = StateManagement.bloc;
    if (argResults!['cubit'] == true) sm = StateManagement.cubit;
    if (argResults!['riverpod'] == true) sm = StateManagement.riverpod;

    await FeatureGenerator(
      featureName: featureName,
      basePath: basePath,
      stateManagement: sm,
    ).generate();
  }
}

// ─── add page ─────────────────────────────────────────────────────────────────
class AddPageCommand extends Command<void> {
  @override
  String get name => 'page';

  @override
  String get description => 'Add a new view inside an existing feature';

  @override
  String get invocation => 'fddp add page <feature> <page_name>';

  @override
  Future<void> run() async {
    if (argResults!.rest.length < 2) {
      print('\x1B[31m✗ Usage: fddp add page <feature> <page_name>\x1B[0m');
      exit(1);
    }

    final feature = argResults!.rest[0].toLowerCase();
    final pageName = argResults!.rest[1].toLowerCase();
    final cls = _pascal(pageName);
    final path =
        'lib/features/$feature/presentation/view/${pageName}_view.dart';

    _safeWrite(path, '''import 'package:flutter/material.dart';

class ${cls}View extends StatelessWidget {
  const ${cls}View({super.key});

  static const routeName = '/$pageName';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$cls')),
      body: const Center(child: Text('$cls View')),
    );
  }
}
''');
    print('\x1B[32m✓ Created\x1B[0m $path');
  }
}

// ─── add usecase ──────────────────────────────────────────────────────────────
class AddUsecaseCommand extends Command<void> {
  @override
  String get name => 'usecase';

  @override
  String get description => 'Add a use case inside an existing feature';

  @override
  String get invocation => 'fddp add usecase <feature> <usecase_name>';

  @override
  Future<void> run() async {
    if (argResults!.rest.length < 2) {
      print(
          '\x1B[31m✗ Usage: fddp add usecase <feature> <usecase_name>\x1B[0m');
      exit(1);
    }

    final feature = argResults!.rest[0].toLowerCase();
    final usecaseName = argResults!.rest[1].toLowerCase();
    final cls = _pascal(usecaseName);
    final repoCls = _pascal(feature);
    final path =
        'lib/features/$feature/domain/usecases/${usecaseName}_usecase.dart';

    // Try to read package name for correct import
    String pkg = 'your_app';
    final pubspec = File('pubspec.yaml');
    if (pubspec.existsSync()) {
      try {
        final content = pubspec.readAsStringSync();
        final match =
            RegExp(r'^name:\s*(\S+)', multiLine: true).firstMatch(content);
        if (match != null) pkg = match.group(1)!;
      } catch (_) {}
    }

    _safeWrite(path, '''import 'package:$pkg/core/result/result.dart';
import 'package:$pkg/features/$feature/domain/repositories/${feature}_repository.dart';

class $cls {
  final ${repoCls}Repository _repository;
  $cls(this._repository);

  Future<Result<void>> call(/* Add params here */) async {
    return await _repository./* method */();
  }
}
''');
    print('\x1B[32m✓ Created\x1B[0m $path');
  }
}

// ─── helpers ─────────────────────────────────────────────────────────────────

String _pascal(String s) =>
    s.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join('');

void _safeWrite(String path, String content) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}

enum StateManagement { provider, bloc, cubit, riverpod }
