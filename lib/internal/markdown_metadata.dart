import 'package:yaml/yaml.dart';

class MarkdownMetadata {
  late final String title;
  late final DateTime timestamp;
  late final String author;
  late final String? category;
  late final dynamic rawData;

  MarkdownMetadata.fromRaw(String metadataPart) {
    final parsed = loadYaml(metadataPart);

    title = parsed["title"] as String;
    timestamp = DateTime.parse(parsed["timestamp"] as String);
    author = parsed["author"] as String;
    category = parsed["category"] as String?;
    rawData = parsed;
  }
}
