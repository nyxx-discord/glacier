import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:glacier/internal/markdown_metadata.dart';

class FileCacheable {
  late final File file;
  late final MarkdownMetadata metadata;
  late final String content;

  String get url => "${path.basenameWithoutExtension(file.path)}.html";

  FileCacheable(this.file, this.metadata, this.content);

  static Future<FileCacheable> initFileCacheable(File file) async {
    final sourceContent = await file.readAsString();

    final firstMatch = sourceContent.indexOf("---");
    final lastMatch = sourceContent.indexOf("---", 3);
    final metadataPart = sourceContent.substring(firstMatch + 3, lastMatch);
    final strippedContent = sourceContent.substring(lastMatch + 3);

    final fileMetadata = MarkdownMetadata.fromRaw(metadataPart);

    return FileCacheable(file, fileMetadata, strippedContent);
  }
}
