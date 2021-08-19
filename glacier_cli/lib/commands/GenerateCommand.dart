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

  GenerateCommand() {
    this.argParser
      ..addOption("source", abbr: "s", help: "source directory where markdown files are located", defaultsTo: "./src")
      ..addOption("destination", abbr: "d", help: "destination directory where compiled project will be located", defaultsTo: "./dest")
      ..addOption("template", abbr: "t", help: "location of base template", defaultsTo: "./src/base.html");
  }

  @override
  Future<void> run() async {
    final sourceDir = Directory.fromUri(Uri.parse(Directory(this.argResults!["source"] as String).absolute.path));
    final destinationDir = Directory.fromUri(Uri.parse(Directory(this.argResults!["destination"] as String).absolute.path));
    final templateFileContent = await File(Uri.parse(this.argResults!["template"] as String).path).readAsString();

    final compiler = Compiler(sourceDir, destinationDir, templateFileContent);

    await compiler.compile();
  }
}
