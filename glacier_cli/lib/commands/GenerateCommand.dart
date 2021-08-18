part of glacier_cli;

class GenerateCommand extends Command {
  @override
  String get description => "Generates docs";

  @override
  String get name => "generate";

  @override
  List<String> get aliases => const [
    "gen"
  ];

  GenerateCommand() {
    this.argParser
      ..addOption("source", abbr: "s", help: "source directory where markdown files are located", defaultsTo: "./src")
      ..addOption("destination", abbr: "d", help: "destination directory where compiled project will be located", defaultsTo: "./dest");
  }

  @override
  Future<void> run() async {
    final sourceDir = Directory.fromUri(Uri.parse(Directory(this.argResults!["source"] as String).absolute.path));
    final destinationDir = Directory.fromUri(Uri.parse(Directory(this.argResults!["destination"] as String).absolute.path));

    if (!await destinationDir.exists()) {
      await destinationDir.create();
    }

    final mdFilesStream = sourceDir.list().where((entity) => extension(entity.path) == ".md").cast<File>();
    await for (final sourceFile in mdFilesStream) {
      print("got file: ${sourceFile.path}");

      final sourceFileName = basenameWithoutExtension(sourceFile.path);
      final destFileName = "${join(destinationDir.absolute.path, sourceFileName)}.html";

      print(destFileName);

      final sourceContent = await sourceFile.readAsString();
      final compiledContent = markdownToHtml(sourceContent, extensionSet: ExtensionSet.gitHubWeb);

      final destFile = File(destFileName);

      if (!await destFile.exists()) {
        await destFile.create();
      }

      await destFile.writeAsString(compiledContent);
    }
  }
}
