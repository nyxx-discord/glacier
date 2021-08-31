part of glacier_cli;

String _getConfigMdContent(GlacierConfig config) => """
---
title: Example title
author: xyz
timestamp: 2021-08-20
category: example
---
# ${config.name}
""";

class InitCommand extends Command {
  @override
  final String name = "init";

  @override
  final String description = "Create a new glacier project";

  InitCommand() {
    argParser.addOption("base",
        abbr: "b", defaultsTo: "nyxx-discord/glacier/templates/default");
  }

  @override
  Future<void> run() async {
    if (await ConfigUtils.doesConfigExist()) {
      throw Exception("Config already exists!");
    }

    final config = ConfigUtils.createConfig();

    final configFile = await File("./glacier.yaml").create();
    await configFile.writeAsString(config.toString());

    final srcDirectory = await Directory(config.sourceDirectory).create();

    final exampleFile =
        await File(path.join(srcDirectory.absolute.path, "index.md")).create();
    await exampleFile.writeAsString(_getConfigMdContent(config));

    final baseDirectory = await Directory(config.baseDirectory).create();

    final baseArg = argResults!["base"] as String;

    final repoName = baseArg.split("/").sublist(0, 2).join("/");
    final repoPath = baseArg.split("/").sublist(2).join("/");
    final repoApiContentsPath =
        "https://api.github.com/repos/$repoName/contents/$repoPath";
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
      final fileData =
          await http.read(Uri.parse(fileJson["download_url"] as String));
      final filePath = baseDirectory.path +
          (fileJson["path"] as String).replaceAll(repoPath, "");
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsString(fileData);
    }

    print("Cloned ${jsonBody.length} files into ${baseDirectory.path}");
  }
}
