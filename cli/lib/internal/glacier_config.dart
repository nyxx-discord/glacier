import 'dart:io';

import 'package:yaml/yaml.dart';

import 'package:glacier/internal/glacier_exception.dart';
import 'package:glacier/internal/yaml_writer.dart';

class GlacierConfig {
  late final String name;
  late final String sourceDirectory;
  late final String destinationDirectory;
  late final String baseDirectory;

  late final String? description;
  late final String? githubUrl;
  late final List<String>? destinationFilesExclude;
  late final List<String>? destinationFilesInclude;

  GlacierConfig(
    this.name, {
    this.description = "Glacier generated config file",
    this.githubUrl,
    this.sourceDirectory = "./src",
    this.destinationDirectory = "./dist",
    this.baseDirectory = "./base",
    this.destinationFilesExclude,
    this.destinationFilesInclude = const ["base.js", "base.css"],
  });

  GlacierConfig.fromYaml(String yaml) {
    final doc = loadYaml(yaml);

    name = doc["name"] as String;
    sourceDirectory = doc["source_directory"] as String;
    destinationDirectory = doc["destination_directory"] as String;
    baseDirectory = doc["base_directory"] as String;

    description = doc["description"] as String?;
    githubUrl = doc["github_url"] as String?;

    destinationFilesExclude = (doc["destination_files"]?["exclude"] as YamlList?)?.cast<String>();

    destinationFilesInclude = (doc["destination_files"]?["include"] as YamlList?)?.cast<String>();
  }

  /// Load glacier.yaml from file
  factory GlacierConfig.loadFromFile() {
    final configFile = File("glacier.yaml");
    if (!configFile.existsSync()) {
      throw GlacierException("Cannot find glacier config file");
    }

    return GlacierConfig.fromYaml(configFile.readAsStringSync());
  }

  @override
  String toString() =>
      // ignore: prefer_interpolation_to_compose_strings
      "# Glacier Config\n" +
      YamlWriter().write(
        <String, dynamic>{
          "name": name,
          "source_directory": sourceDirectory,
          "destination_directory": destinationDirectory,
          "base_directory": baseDirectory,
          if (description != null) "description": description!,
          if (githubUrl != null) "github_url": githubUrl!,
          if (destinationFilesExclude != null || destinationFilesInclude != null)
            "destination_files": {
              if (destinationFilesInclude != null) "include": destinationFilesInclude,
              if (destinationFilesExclude != null) "exclude": destinationFilesExclude,
            }
        },
      );
}
