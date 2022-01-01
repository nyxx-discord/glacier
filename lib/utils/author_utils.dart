import 'dart:io';

import 'package:glacier/internal/author.dart';
import 'package:glacier/internal/glacier_exception.dart';
import 'package:yaml/yaml.dart';

class AuthorUtils {
  /// Load glacier.yaml from file
  static Map<String, Author> getAuthorsFromFile({String? file}) {
    final configFile = File(file ?? "authors.yaml");
    if (!configFile.existsSync()) {
      throw GlacierException("Cannot find author config file");
    }

    final doc = loadYaml(configFile.readAsStringSync());

    final Map<String, Author> authors = {};

    (doc as YamlMap).keys.forEach((key) {
      authors[key as String] = Author.fromYamlObject(doc[key] as YamlMap);
    });

    return authors;
  }
}
