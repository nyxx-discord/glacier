import 'dart:io';

import 'package:glacier/internal/glacier_exception.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import "package:shelf/shelf_io.dart" as shelf_io;
import "package:shelf_static/shelf_static.dart" as shelf_static;

import 'package:glacier/internal/glacier_config.dart';
import 'package:glacier/utils/utils.dart';

class ServeCommand extends Command<int> {
  @override
  String get description => "Run the builtin development server";

  @override
  String get name => "serve";

  ServeCommand() {
    argParser.addOption("host", defaultsTo: "localhost");
    argParser.addOption("port", defaultsTo: "3000", valueHelp: "3001");
  }

  @override
  Future<int> run() async {
    try {
      final config = GlacierConfig.loadFromFile();
      final destinationDir = path.join(
        Directory.current.absolute.path,
        Utils.stripRelativePath(config.destinationDirectory),
      );

      if (!Directory(destinationDir).existsSync()) {
        throw GlacierException("Run `glacier generate` before serving the content");
      }

      final port = int.tryParse(argResults!["port"] as String)!;
      final host = argResults!["host"] as String;

      final handler = shelf_static.createStaticHandler(
        destinationDir,
        defaultDocument: "index.html",
      );

      await shelf_io.serve(handler, host, port).then((_) => print("Running at http://$host:$port/"));

      return 0;
    } on GlacierException catch (e) {
      print("Error: ${e.message}");

      return 1;
    }
  }
}
