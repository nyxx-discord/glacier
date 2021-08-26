part of glacier_cli;

String _getBaseCssContent(GlacierConfig config) => """
:root {
    --default-padding: 10px;
    --nav-height: 50px;
    --default-background: #2c2f33;
    --sidebar-background: #23272a;
    color: #d9dadb;
}

body, html {
    height: 100%;
    width: 100%;
    margin: 0;
    background-color: var(--default-background);
}

a {
    color: white;
}

a:hover {
    color: lightblue;
}

.navbar {
    width: calc(100% - 2 * var(--default-padding));
    height: var(--nav-height);
    background-color: var(--default-background);
    padding: var(--default-padding);
    outline: solid black 2px;
}

.sidebar {
    height: calc(100% - 2 * var(--default-padding));
    width: calc(15% - 2 * var(--default-padding));
    float: left;
    background-color: var(--sidebar-background);
    padding: var(--default-padding);
}

.body {
    height: calc(100% - 2 * var(--default-padding));
    width: calc(85% - 2 * var(--default-padding));
    float: right;
    background-color: var(--default-background);
    padding: var(--default-padding);
}

@media screen and (max-width: 1200px) {
    .sidebar {
        height: calc(100% - 2 * var(--default-padding));
        width: calc(40% - 2 * var(--default-padding));
        float: left;
        background-color: var(--sidebar-background);
        padding: var(--default-padding);
    }
    
    .body {
        height: calc(100% - 2 * var(--default-padding));
        width: calc(60% - 2 * var(--default-padding));
        float: right;
        background-color: var(--default-background);
        padding: var(--default-padding);
    }
}

@media screen and (max-width: 1800px) {
    .sidebar {
        height: calc(100% - 2 * var(--default-padding));
        width: calc(25% - 2 * var(--default-padding));
        float: left;
        background-color: var(--sidebar-background);
        padding: var(--default-padding);
    }
    
    .body {
        height: calc(100% - 2 * var(--default-padding));
        width: calc(75% - 2 * var(--default-padding));
        float: right;
        background-color: var(--default-background);
        padding: var(--default-padding);
    }
}
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
    
    <link rel="stylesheet"href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.2.0/styles/a11y-dark.min.css">
    <script defer src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.2.0/highlight.min.js"></script>
    
    <title>{{title}}</title>
</head>
<body>
  <div class='sidebar'>
    {{# sidebar_entries}}
      <h5>{{category}}</h5>
      {{# entries}}
        <p>➡ <a href='{{url}}'>{{name}}</a></p>
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
# ${config.name}
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
