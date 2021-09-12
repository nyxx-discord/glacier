part of glacier_cli;

class ServeCommand extends Command {
  @override
  String get description => "Run the builtin development server";

  @override
  String get name => "serve";

  ServeCommand() {
    argParser.addOption("host", defaultsTo: "localhost");
    argParser.addOption("port", defaultsTo: "3000", valueHelp: "3001");
  }

  @override
  Future<void> run() async {
    final config = GlacierConfig.loadFromFile();
    final destinationDir = path.join(
      Directory.current.absolute.path,
      Utils.stripRelativePath(config.destinationDirectory),
    );
    final port = int.tryParse(argResults!["port"] as String)!;
    final host = argResults!["host"] as String;

    final handler = shelf_static.createStaticHandler(
      destinationDir,
      defaultDocument: "index.html",
    );

    await shelf_io
        .serve(handler, host, port)
        .then((_) => print("Running at http://$host:$port/"));
  }
}
