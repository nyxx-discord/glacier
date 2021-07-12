import 'dart:io';

import "package:args/command_runner.dart";
import 'package:glacier/glacier.dart';

class InitCommand extends Command {
  @override
  final String name = "init";

  @override
  final String description = "Create a new glacier project";

  @override
  Future<void> run() async {
    if (await ConfigUtils.doesConfigExist()) {
      throw "Config already exists!";
    }

    final config = ConfigUtils.createConfig();

    var configFile = await File("./glacier.yaml").create();
    configFile = await configFile.writeAsString(config.toString());

    final srcDirectory = Directory("./src").create();

    var exampleFile = await File("./src/index.md").create();
    exampleFile = await exampleFile.writeAsString("# ${config.name}");
  }
}
