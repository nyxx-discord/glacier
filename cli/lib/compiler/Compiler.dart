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

  late final Template template;

  Compiler(this.sourceDir, this.destinationDir, this.baseFilesDir) {
    final templateContent = File(Uri.parse(path.join(baseFilesDir.absolute.path, "base.html")).path).readAsStringSync();
    this.template = Template(templateContent, name: "base.html");
  }

  final Map<String, FileCacheable> fileContentCache = {};

  Future<void> compile() async {
    if (!await this.destinationDir.exists()) {
      await this.destinationDir.create();
    }

    final mdFilesStream = await sourceDir.list().where((entity) => path.extension(entity.path) == ".md").cast<File>().toList();

    for (final sourceFile in mdFilesStream) {
      this.fileContentCache[sourceFile.absolute.path] = await FileCacheable.initFileCacheable(sourceFile);
    }

    for (final fileCacheableEntry in this.fileContentCache.entries) {
      await this.processFile(fileCacheableEntry.value);
    }

    await this.copyFiles();
  }

  Future<void> copyFiles() async {
   final filesToCopy = this.baseFilesDir.list()
        .where((event) => event is File)
        .where((event) => path.basename(event.path).endsWith(".js") || path.basename(event.path).endsWith(".css"))
        .where((event) => !event.path.contains("base/base.html"))
        .cast<File>();

    await for (final file in filesToCopy) {
      await file.copy(path.join(destinationDir.absolute.path, path.basename(file.path)));
    }
  }

  Future<void> processFile(FileCacheable fileCacheable) async {
    final sourceFileName = path.basenameWithoutExtension(fileCacheable.file.path);
    final destFileName = "${path.join(destinationDir.absolute.path, sourceFileName)}.html";

    final compiledContent = await this.processTemplate(fileCacheable.content, fileCacheable.metadata);

    final destFile = File(destFileName);
    if (!await destFile.exists()) {
      await destFile.create();
    }

    await destFile.writeAsString(compiledContent);
  }

  Future<String> processTemplate(String inputString, MarkdownMetadata metadata) async {
    final outputMarkdown = markdownToHtml(inputString, extensionSet: ExtensionSet.gitHubWeb);

    return this.template.renderString({
      "title": metadata.title,
      "body": outputMarkdown,
      "sidebar_entries": this._getSidebarEntries()
    });
  }

  Iterable<Map<String, dynamic>> _getSidebarEntries() {
    final sidebarEntries = this.fileContentCache.entries.map((entry) => {
      "url": entry.value.url,
      "name": entry.value.metadata.title,
      "category": entry.value.metadata.title,
    });

    final sidebarEntriesFinal = <Map<String, dynamic>>[];
    for (final sidebarEntry in sidebarEntries) {
      try {
        final result = sidebarEntriesFinal.firstWhere((element) => element["category"] == sidebarEntry["category"]);
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
