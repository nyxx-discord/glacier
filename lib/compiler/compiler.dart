import 'dart:io';

import 'package:glacier/compiler/file_cacheable.dart';
import 'package:glacier/compiler/syntax/self_link_syntax.dart';
import 'package:glacier/utils/utils.dart';
import 'package:glacier/internal/glacier_config.dart';
import 'package:mustache_template/mustache.dart';
import 'package:path/path.dart' as path;
import 'package:glacier/internal/markdown_metadata.dart';
import 'package:markdown/markdown.dart';

class Compiler {
  final Directory sourceDir;
  final Directory destinationDir;
  final Directory baseFilesDir;

  late final Directory assetsDir;

  final GlacierConfig _config;

  late final Template template;

  Compiler(this.sourceDir, this.destinationDir, this.baseFilesDir, this._config) {
    final templateContent = File(path.join(baseFilesDir.absolute.path, "base.html")).readAsStringSync();
    template = Template(templateContent, name: "base.html");

    assetsDir = Directory(path.join(destinationDir.absolute.path, 'assets'));
  }

  final Map<String, FileCacheable> fileContentCache = {};

  Stream<File> findFilesForPath(Directory dir) async* {
    await for (final entity in dir.list()) {
      if (entity is File) {
        yield entity;
      }

      if (entity is Directory) {
        yield* findFilesForPath(entity);
      }
    }
  }

  Future<void> compile() async {
    await ensureDirsCreated();

    final srcFiles = findFilesForPath(sourceDir);

    await for (final sourceFile in srcFiles) {
      final extension = path.extension(sourceFile.path);

      if (extension == ".md") {
        fileContentCache[sourceFile.absolute.path] = await FileCacheable.initFileCacheable(sourceFile);

        continue;
      }

      if (['.png', '.jpg', '.jpeg'].contains(extension)) {
        await sourceFile.copy(path.join(assetsDir.absolute.path, path.basename(sourceFile.path)));
      }
    }

    for (final fileCacheableEntry in fileContentCache.entries) {
      await processFile(fileCacheableEntry.value);
    }

    await copyBaseFiles();
  }

  Future<void> copyBaseFiles() async {
    final filesToCopy = baseFilesDir
        .list()
        .where((event) => event is File)
        .where((event) {
          final baseName = path.basename(event.path);

          return baseName.endsWith(".js") || baseName.endsWith(".css") || baseName.endsWith(".png");
        })
        .where((event) => !event.path.contains("base/base.html"))
        .cast<File>();

    await for (final file in filesToCopy) {
      final shouldFileBeExcluded = _config.destinationFilesExclude?.contains(file.path.replaceAll(baseFilesDir.absolute.path, "").replaceAll("\\", "/"));

      if (!(shouldFileBeExcluded ?? true)) {
        await file.copy(path.join(destinationDir.absolute.path, path.basename(file.path)));
      }
    }

    for (final includePath in _config.destinationFilesInclude ?? <String>[]) {
      final file = File(path.join(baseFilesDir.absolute.path, path.relative(Utils.makeRelativePath(includePath))));

      if (!file.existsSync()) {
        return;
      }

      final copyFile = File(path.join(destinationDir.absolute.path, path.relative(Utils.makeRelativePath(includePath))));

      await copyFile.create(recursive: true);

      await file.copy(path.join(destinationDir.absolute.path, path.relative(Utils.makeRelativePath(includePath))));
    }
  }

  Future<void> processFile(FileCacheable fileCacheable) async {
    final sourceFileName = path.basenameWithoutExtension(fileCacheable.file.path);
    final destFileName = "${path.join(destinationDir.absolute.path, sourceFileName)}.html";

    final compiledContent = await processTemplate(fileCacheable.content, fileCacheable.metadata);

    final destFile = File(destFileName);
    if (!await destFile.exists()) {
      await destFile.create(recursive: true);
    }

    await destFile.writeAsString(compiledContent);
  }

  Future<String> processTemplate(String inputString, MarkdownMetadata metadata) async {
    final sidebarEntries = _getSidebarEntries();

    final outputMarkdown = markdownToHtml(inputString, extensionSet: ExtensionSet.gitHubWeb, inlineSyntaxes: [SelfLinkSyntax(sidebarEntries.toList())]);

    return template.renderString({
      "title": metadata.title,
      "body": outputMarkdown,
      "sidebar_entries": sidebarEntries,
      "metadata": metadata.rawData,
    });
  }

  Future<void> ensureDirsCreated() async {
    if (!await destinationDir.exists()) {
      await destinationDir.create();
    } else {
      await destinationDir.delete(recursive: true);
      await destinationDir.create();
    }

    if (!await assetsDir.exists()) {
      await assetsDir.create();
    }
  }

  Iterable<Map<String, dynamic>> _getSidebarEntries() {
    final sidebarEntries = fileContentCache.entries.map((entry) {
      final category = path.join(path.basename(path.dirname(entry.value.file.path))).replaceFirst("src", "");

      return {
        "url": entry.value.url,
        "name": entry.value.metadata.title,
        "category": category != "src" ? category : null,
      };
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
