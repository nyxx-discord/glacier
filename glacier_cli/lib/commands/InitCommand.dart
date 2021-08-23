part of glacier_cli;

String _getBaseCssContent(GlacierConfig config) => """

""";

String _getBaseJsContent(GlacierConfig config) => """

""";

String _getBaseHtmlContent(GlacierConfig config) => """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel='stylesheet' href='base.css'>
    <script defer src="base.js"></script>
    
    <title>{{title}}</title>
</head>
<body>
  <div class='sidebar'>
    {{# sidebar_entries}}
      <h5>{{category}}</h5>
      {{# entries}}
        <p><a href='{{url}}'>{{name}}</a></p>
      {{/ entries}}
    {{/ sidebar_entries}}
  </div>
  <div class='body'>
    {{{body}}}
  </div>
</body>
</html>
""";

String _getConfigMdContent(GlacierConfig config) => """
---
title: Example title
author: xyz
timestamp: 2021-08-20
category: example
---
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

    final srcDirectory = await Directory(config.sourceDirectory).create();

    final exampleFile = await File(join(srcDirectory.absolute.path, "index.md")).create();
    await exampleFile.writeAsString(_getConfigMdContent(config));

    final baseDirectory = await Directory(config.baseDirectory).create();

    final baseHtml = await File(join(baseDirectory.absolute.path, "base.html")).create();
    await baseHtml.writeAsString(_getBaseHtmlContent(config));

    final baseCss = await File(join(baseDirectory.absolute.path, "base.css")).create();
    await baseCss.writeAsString(_getBaseCssContent(config));

    final baseJs = await File(join(baseDirectory.absolute.path, "base.js")).create();
    await baseJs.writeAsString(_getBaseJsContent(config));
  }
}
