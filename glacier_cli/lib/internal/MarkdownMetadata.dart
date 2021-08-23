part of glacier_cli;

class MarkdownMetadata {
  late final String title;
  late final DateTime timestamp;
  late final String author;
  late final String category;

  MarkdownMetadata._fromRaw(String metadataPart) {
    final parsed = loadYaml(metadataPart);

    this.title = parsed["title"] as String;
    this.timestamp = DateTime.parse(parsed["timestamp"] as String);
    this.author = parsed["author"] as String;
    this.category = parsed["category"] as String;
  }
}
