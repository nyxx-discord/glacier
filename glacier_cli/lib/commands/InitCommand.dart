part of glacier_cli;

String _getBaseHtmlContent(GlacierConfig config) => """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{title}}</title>
</head>
<body>
    {{{body}}}
</body>
</html>
""";

String _getConfigMdContent(GlacierConfig config) => """
# ${config.name}"
""";

class InitCommand extends Command {
  @override
  final String name = "init";

  @override
  final String description = "Create a new glacier project";

  @override
  Future<void> run() async {
    if (await ConfigUtils.doesConfigExist()) {
      throw Exception("Config already exists!");
    }

    final config = ConfigUtils.createConfig();

    final configFile = await File("./glacier.yaml").create();
    await configFile.writeAsString(config.toString());

    await Directory("./src").create();

    final exampleFile = await File("./src/index.md").create();
    await exampleFile.writeAsString(_getConfigMdContent(config));

    final baseHtml = await File("./src/base.html").create();
    await baseHtml.writeAsString(_getBaseHtmlContent(config));
  }
}
