part of glacier_cli;

class MarkdownMetadata {
  late final String title;
  late final DateTime timestamp;
  late final String author;

  final RegExp metadataRegex = RegExp('source');

  MarkdownMetadata._fromRaw(String rawMarkdown) {
    final firstMatch = rawMarkdown.indexOf("---");
    final lastMatch = rawMarkdown.indexOf("---", 3);

    final metadataPart = rawMarkdown.substring(firstMatch + 3, lastMatch);

    print(metadataPart);

    final parsed = loadYaml(metadataPart);

    this.title = parsed["title"] as String;
    this.timestamp = DateTime.parse(parsed["timestamp"] as String);
    this.author = parsed["author"] as String;
  }
}
