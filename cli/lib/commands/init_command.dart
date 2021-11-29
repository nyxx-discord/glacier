import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import "package:http/http.dart" as http;

import 'package:glacier/internal/glacier_config.dart';
import 'package:glacier/utils/config_utils.dart';

String _getConfigMdContent(GlacierConfig config) => """
---
title: Example title
author: xyz
timestamp: 2021-08-20
category: example
---
# ${config.name}
""";

class InitCommand extends Command<int> {
  @override
  final String name = "init";

  @override
  final String description = "Create a new glacier project";

  InitCommand() {
    argParser.addOption("template", abbr: "t", defaultsTo: "nyxx-discord/glacier/templates/default");
  }

  @override
  Future<int> run() async {
    if (await ConfigUtils.doesConfigExist()) {
      throw Exception("Config already exists!");
    }

    final config = ConfigUtils.createConfig();

    final configFile = await File("./glacier.yaml").create();
    await configFile.writeAsString(config.toString());

    final srcDirectory = await Directory(config.sourceDirectory).create();

    final exampleFile = await File(path.join(srcDirectory.absolute.path, "index.md")).create();
    await exampleFile.writeAsString(_getConfigMdContent(config));

    final baseDirectory = await Directory(config.baseDirectory).create();

    final baseArg = argResults!["template"] as String;

    // Get the firt 2 parts of the string as this is the repo name and author e.g. nyxx-discord/glacier
    final repoName = baseArg.split("/").sublist(0, 2).join("/");
    // Gets the rest of the repo path, could be simplifed with another options?
    final repoPath = baseArg.split("/").sublist(2).join("/");

    await downloadTemplate(repoName, repoPath, baseDirectory);

    print("Cloned template files into ${baseDirectory.path}");

    return 0;
  }

  Future<void> downloadTemplate(String repoName, String path, Directory baseDirectory) async {
    final repoApiContentsPath = "https://api.github.com/repos/$repoName/contents/$path";
    final httpResponse = await http.get(Uri.parse(repoApiContentsPath));

    if (httpResponse.statusCode >= 300 || httpResponse.statusCode < 200) {
      throw Exception("Failed to clone the docs base.");
    }

    final jsonBody = jsonDecode(httpResponse.body) as List<dynamic>;
    for (final rawFileData in jsonBody) {
      final fileJson = rawFileData as Map<String, dynamic>;
      if ((fileJson["download_url"] as String?) == null) {
        print("No download path for ${fileJson["name"]}, ignoring file.");
        return;
      }
      final fileData = await http.read(Uri.parse(fileJson["download_url"] as String));
      final filePath = baseDirectory.path + (fileJson["path"] as String).replaceAll(path, "");
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsString(fileData);
    }
  }
}
