part of glacier_cli;

class GenerateCommand extends Command {
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
  Future<void> run() async {
    final config = GlacierConfig.loadFromFile();

    final sourceDir = Directory(path.join(Directory.current.absolute.path,
        Utils.stripRelativePath(config.sourceDirectory)));
    final destinationDir = Directory(path.join(Directory.current.absolute.path,
        Utils.stripRelativePath(config.destinationDirectory)));
    final baseFilesDir = Directory(path.join(Directory.current.absolute.path,
        Utils.stripRelativePath(config.baseDirectory)));

    final compiler = Compiler(sourceDir, destinationDir, baseFilesDir, config);
    await compiler.compile();
  }
}
