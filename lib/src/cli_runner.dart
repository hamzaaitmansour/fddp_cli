import 'dart:io';
import 'package:args/command_runner.dart';
import 'commands/add_command.dart';
import 'commands/init_command.dart';

// Shortcut expansions — order matters (first match wins)
const _shortcuts = {
  'a': 'add',
  'f': 'feature',
  'p': 'page',
  'u': 'usecase',
  'i': 'init',
};

/// Expands shortcut args before parsing.
/// e.g. ['a', 'f', 'auth'] → ['add', 'feature', 'auth']
List<String> _expand(List<String> args) {
  return args.map((arg) => _shortcuts[arg] ?? arg).toList();
}

class CliRunner {
  late final CommandRunner<void> _runner;

  CliRunner() {
    _runner = CommandRunner<void>(
      'fddp',
      '🚀 Flutter Feature-Driven Development Pattern CLI',
    )
      ..addCommand(AddCommand())
      ..addCommand(InitCommand());
  }

  Future<void> run(List<String> args) async {
    final expanded = _expand(args);

    try {
      await _runner.run(expanded);
    } on UsageException catch (e) {
      print('\x1B[31m✗ ${e.message}\x1B[0m');
      print('');
      print(e.usage);
      exit(1);
    } catch (e) {
      print('\x1B[31m✗ Error: $e\x1B[0m');
      exit(1);
    }
  }
}
