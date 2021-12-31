import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:glacier/compiler/compiler.dart';
import 'package:glacier/internal/glacier_config.dart';
import 'package:glacier/utils/author_utils.dart';
import 'package:glacier/utils/utils.dart';
import 'package:path/path.dart' as path;

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
    final authors = AuthorUtils.getAuthorsFromFile();

    final sourceDir =
        Directory(path.join(Directory.current.absolute.path, Utils.stripRelativePath(config.sourceDirectory)));
    final destinationDir =
        Directory(path.join(Directory.current.absolute.path, Utils.stripRelativePath(config.build.directory)));
    final templateFilesDir =
        Directory(path.join(Directory.current.absolute.path, Utils.stripRelativePath(config.template.directory)));

    final compiler = Compiler(
      sourceDirectory: sourceDir,
      outDirectory: destinationDir,
      templateDirectory: templateFilesDir,
      config: config,
      authors: authors,
    );

    await compiler.compile();

    return 0;
  }
}
