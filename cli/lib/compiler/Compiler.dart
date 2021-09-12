part of glacier_cli;

class FileCacheable {
  late final File file;
  late final MarkdownMetadata metadata;
  late final String content;

  String get url => "${path.basenameWithoutExtension(this.file.path)}.html";

  FileCacheable(this.file, this.metadata, this.content);

  static Future<FileCacheable> initFileCacheable(File file) async {
    final sourceContent = await file.readAsString();

    final firstMatch = sourceContent.indexOf("---");
    final lastMatch = sourceContent.indexOf("---", 3);
    final metadataPart = sourceContent.substring(firstMatch + 3, lastMatch);
    final strippedContent = sourceContent.substring(lastMatch + 3);

    final fileMetadata = MarkdownMetadata._fromRaw(metadataPart);

    return FileCacheable(file, fileMetadata, strippedContent);
  }
}

class Compiler {
  final Directory sourceDir;
  final Directory destinationDir;
  final Directory baseFilesDir;

  final GlacierConfig _config;

  late final Template template;

  Compiler(
      this.sourceDir, this.destinationDir, this.baseFilesDir, this._config) {
    final templateContent =
        File(path.join(baseFilesDir.absolute.path, "base.html"))
            .readAsStringSync();
    this.template = Template(templateContent, name: "base.html");
  }

  final Map<String, FileCacheable> fileContentCache = {};

  Future<void> compile() async {
    if (!await this.destinationDir.exists()) {
      await this.destinationDir.create();
    } else {
      await this.destinationDir.delete(recursive: true);
      await this.destinationDir.create();
    }

    final mdFilesStream = await sourceDir
        .list()
        .where((entity) => path.extension(entity.path) == ".md")
        .cast<File>()
        .toList();

    final mdSubdirs = await sourceDir
        .list()
        .where((entity) => entity is Directory)
        .cast<Directory>()
        .toList();
    final mdSubdirsFilesStream = mdSubdirs
        .map((dir) async => dir
            .list()
            .where((entity) => path.extension(entity.path) == ".md")
            .cast<File>()
            .toList())
        .toList();

    for (final sourceFileDir in mdSubdirsFilesStream) {
      mdFilesStream.addAll(await sourceFileDir);
    }

    for (final sourceFile in mdFilesStream) {
      this.fileContentCache[sourceFile.absolute.path] =
          await FileCacheable.initFileCacheable(sourceFile);
    }

    for (final fileCacheableEntry in this.fileContentCache.entries) {
      await this.processFile(fileCacheableEntry.value);
    }

    await this.copyFiles();
  }

  Future<void> copyFiles() async {
    final filesToCopy = this
        .baseFilesDir
        .list()
        .where((event) => event is File)
        .where((event) =>
            path.basename(event.path).endsWith(".js") ||
            path.basename(event.path).endsWith(".css"))
        .where((event) => !event.path.contains("base/base.html"))
        .cast<File>();

    await for (final file in filesToCopy) {
      final shouldFileBeExcluded = this
          ._config
          .destinationFilesExclude
          ?.contains(file.path
              .replaceAll(baseFilesDir.absolute.path, "")
              .replaceAll("\\", "/"));
      if (!(shouldFileBeExcluded ?? true)) {
        await file.copy(
            path.join(destinationDir.absolute.path, path.basename(file.path)));
      }
    }

    for (final includePath
        in this._config.destinationFilesInclude ?? <String>[]) {
      final file = File(path.join(baseFilesDir.absolute.path,
          path.relative(Utils.makeRelativePath(includePath))));

      if (!file.existsSync()) {
        return;
      }

      final copyFile = File(path.join(destinationDir.absolute.path,
          path.relative(Utils.makeRelativePath(includePath))));

      await copyFile.create(recursive: true);

      await file.copy(path.join(destinationDir.absolute.path,
          path.relative(Utils.makeRelativePath(includePath))));
    }
  }

  Future<void> processFile(FileCacheable fileCacheable) async {
    final sourceFileName =
        path.basenameWithoutExtension(fileCacheable.file.path);
    final String destFileName;
    if (path.basename(path.dirname(fileCacheable.file.path)) != "src") {
      destFileName =
          "${path.join(destinationDir.absolute.path, path.basename(path.dirname(fileCacheable.file.path)), sourceFileName)}.html";
    } else {
      destFileName =
          "${path.join(destinationDir.absolute.path, sourceFileName)}.html";
    }

    final compiledContent = await this
        .processTemplate(fileCacheable.content, fileCacheable.metadata);

    final destFile = File(destFileName);
    if (!await destFile.exists()) {
      await destFile.create(recursive: true);
    }

    await destFile.writeAsString(compiledContent);
  }

  Future<String> processTemplate(
      String inputString, MarkdownMetadata metadata) async {
    final outputMarkdown =
        markdownToHtml(inputString, extensionSet: ExtensionSet.gitHubWeb);

    return this.template.renderString({
      "title": metadata.title,
      "body": outputMarkdown,
      "sidebar_entries": this._getSidebarEntries(),
      "metadata": metadata.rawData,
    });
  }

  Iterable<Map<String, dynamic>> _getSidebarEntries() {
    final sidebarEntries = this.fileContentCache.entries.map((entry) {
      final category = path
          .join(path.basename(path.dirname(entry.value.file.path)))
          .replaceFirst("src", "");

      return {
        "url": path.join(category, entry.value.url),
        "name": entry.value.metadata.title,
        "category": category != "src" ? category : null,
      };
    });

    final sidebarEntriesFinal = <Map<String, dynamic>>[];
    for (final sidebarEntry in sidebarEntries) {
      try {
        final result = sidebarEntriesFinal.firstWhere(
            (element) => element["category"] == sidebarEntry["category"]);
        result["entries"].add(sidebarEntry);
      } on StateError {
        sidebarEntriesFinal.add({
          "category": sidebarEntry["category"],
          "entries": [sidebarEntry],
        });
      }
    }
    return sidebarEntriesFinal;
  }
}
