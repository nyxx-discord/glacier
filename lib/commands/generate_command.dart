import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:glacier/compiler/compiler.dart';

import 'package:glacier/internal/glacier_config.dart';
import 'package:glacier/utils/utils.dart';

class GenerateCommand extends Command<int> {
  @override
  String get description => "Generates docs";

  @override
  String get name => "generate";

  @override
  List<String> get aliases => const [
        "gen",
        "g",
      ];

  @override
  Future<int> run() async {
    final config = GlacierConfig.loadFromFile();

    final sourceDir = Directory(path.join(Directory.current.absolute.path, Utils.stripRelativePath(config.sourceDirectory)));
    final destinationDir = Directory(path.join(Directory.current.absolute.path, Utils.stripRelativePath(config.destinationDirectory)));
    final baseFilesDir = Directory(path.join(Directory.current.absolute.path, Utils.stripRelativePath(config.baseDirectory)));

    final compiler = Compiler(sourceDir, destinationDir, baseFilesDir, config);
    await compiler.compile();

    return 0;
  }
}
