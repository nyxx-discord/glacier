import 'dart:io';

import 'package:glacier/compiler/syntax/self_link_syntax.dart';
import 'package:glacier/internal/author.dart';
import 'package:glacier/internal/glacier_config.dart';
import 'package:markdown/markdown.dart';
import 'package:mustache_template/mustache.dart';
import 'package:path/path.dart' as path;

import 'file_cacheable.dart';

class Compiler {
  late final Directory sourceDirectory;
  late final Directory templateDirectory;
  late final Directory outDirectory;

  late final Map<String, Author> authors;
  late final GlacierConfig config;

  late final Template template;

  final Map<String, FileCacheable> fileContentCache = {};
  Iterable<Map<String, dynamic>> sidebarEntries = [];

  Compiler(
      {required this.sourceDirectory,
      required this.templateDirectory,
      required this.outDirectory,
      required this.authors,
      required this.config}) {
    final templateContent = File(path.join(templateDirectory.absolute.path, "base.mustache")).readAsStringSync();
    template = Template(templateContent, name: "base.mustache");
  }

  Future<void> compile() async {
    await _ensureDirsCreated();
    await _runBuildCommand();

    final srcFiles = _findFilesForPath(sourceDirectory);

    await for (final sourceFile in srcFiles) {
      final extension = path.extension(sourceFile.path);

      if (extension == ".md") {
        fileContentCache[sourceFile.absolute.path] = await FileCacheable.initFileCacheable(sourceFile);

        continue;
      }

      if (['.png', '.jpg', '.jpeg'].contains(extension)) {
        await sourceFile.copy(path.join(outDirectory.path, path.basename(sourceFile.path)));
      }
    }

    sidebarEntries = _getSidebarEntries();

    final templateFiles = _findFilesForPath(templateDirectory);

    await for (final sourceFile in templateFiles) {
      final extension = path.extension(sourceFile.path);

      if (!['.html', '.mustache'].contains(extension) && !(config.template.exclude ?? []).contains(sourceFile.path)) {
        await sourceFile.copy(path.join(outDirectory.path, path.basename(sourceFile.path)));
      }
    }

    for (final fileCacheableEntry in fileContentCache.entries) {
      await _processFile(fileCacheableEntry.value);
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

  Future<void> _processFile(FileCacheable fileCacheable) async {
    final mustacheMetadata = await _generateMustacheMetadata(fileCacheable);

    final sourceFileName = path.basenameWithoutExtension(fileCacheable.file.path);
    final destFileName = "${path.join(outDirectory.absolute.path, sourceFileName)}.html";

    final outputMarkdown = markdownToHtml(fileCacheable.content,
        extensionSet: ExtensionSet.gitHubWeb, inlineSyntaxes: [SelfLinkSyntax(sidebarEntries.toList())]);

    final compiledContent = template.renderString({"body": outputMarkdown, ...mustacheMetadata});

    final destFile = File(destFileName);
    if (!await destFile.exists()) {
      await destFile.create(recursive: true);
    }

    await destFile.writeAsString(compiledContent);
  }

  Future<Map<String, dynamic>> _generateMustacheMetadata(FileCacheable file) async {
    final Author? author = authors[file.metadata.author];

    return <String, dynamic>{
      "title": file.metadata.title,
      "author": (author ?? Author(file.metadata.author)).toJson(),
      "category": file.metadata.category,
      "sidebar_entries": sidebarEntries,
      "metadata": file.metadata.rawData,
      "timestamp": file.metadata.timestamp
    };
  }

  Stream<File> _findFilesForPath(Directory dir) async* {
    await for (final entity in dir.list()) {
      if (entity is File) {
        yield entity;
      }

      if (entity is Directory) {
        yield* _findFilesForPath(entity);
      }
    }
  }

  Future<void> _ensureDirsCreated() async {
    if (!await outDirectory.exists()) {
      await outDirectory.create();
    } else {
      await outDirectory.delete(recursive: true);
      await outDirectory.create();
    }
  }

  Future<void> _runBuildCommand() async {
    if (config.build.buildCommand == null) return;

    List<String> buildCommandSplit = config.build.buildCommand!.split(" ");
    if (buildCommandSplit.isEmpty) {
      return;
    }

    if (buildCommandSplit.length == 1) {
      await Process.run(buildCommandSplit[0], []);
    } else {
      await Process.run(buildCommandSplit[0], buildCommandSplit.sublist(1));
    }
  }
}
