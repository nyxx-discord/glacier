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

    final sourceDir = Directory.fromUri(Uri.parse(Directory(config.sourceDirectory).absolute.path));
    final destinationDir = Directory.fromUri(Uri.parse(Directory(config.destinationDirectory).absolute.path));
    final baseFilesDir = Directory.fromUri(Uri.parse(Directory(config.baseDirectory).absolute.path));

    final templateFileContent = await File(Uri.parse(join(baseFilesDir.absolute.path, "base.html")).path).readAsString();

    final compiler = Compiler(sourceDir, destinationDir, templateFileContent);
    await compiler.compile();
  }
}
