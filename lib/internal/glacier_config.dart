import 'dart:io';

import 'package:glacier/internal/glacier_exception.dart';
import 'package:glacier/internal/yaml_writer.dart';
import 'package:yaml/yaml.dart';

class GlacierTemplateConfig {
  late final String directory;
  late final List<String>? exclude;

  GlacierTemplateConfig(
    this.directory, {
    this.exclude,
  });

  GlacierTemplateConfig.fromYaml(String yaml) {
    final doc = loadYaml(yaml);

    directory = doc["directory"] as String;
    exclude = (doc["exclude"] as YamlList?)?.cast<String>();
  }

  GlacierTemplateConfig.fromYamlObject(YamlMap doc) {
    directory = doc["directory"] as String;
    exclude = (doc["exclude"] as YamlList?)?.cast<String>();
  }
}

class GlacierBuildConfig {
  late final String directory;
  late final String? buildCommand;

  GlacierBuildConfig(
    this.directory, {
    this.buildCommand,
  });

  GlacierBuildConfig.fromYaml(String yaml) {
    final doc = loadYaml(yaml);

    directory = doc["directory"] as String;
    buildCommand = doc["build_command"] as String?;
  }

  GlacierBuildConfig.fromYamlObject(YamlMap doc) {
    directory = doc["directory"] as String;
    buildCommand = doc["build_command"] as String?;
  }
}

class GlacierConfig {
  late final String name;
  late final String? githubUrl;
  late final String? description;

  late final String sourceDirectory;

  late final GlacierTemplateConfig template;
  late final GlacierBuildConfig build;

  GlacierConfig(this.name, this.sourceDirectory, {this.githubUrl, this.description = "Glacier generated config file"}) {
    template = GlacierTemplateConfig("./static");
  }

  GlacierConfig.fromYaml(String yaml) {
    final doc = loadYaml(yaml);

    name = doc["name"] as String;
    sourceDirectory = doc["source"] as String;
    description = doc["description"] as String?;

    template = GlacierTemplateConfig.fromYamlObject(doc["template"] as YamlMap);
    build = GlacierBuildConfig.fromYamlObject(doc["build"] as YamlMap);
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
          if (description != null) "description": description!,
          if (githubUrl != null) "github_url": githubUrl!,
          "template": {
            "directory": template.directory,
            if (template.exclude != null) "exclude": template.exclude,
          },
          "build": {
            "directory": build.directory,
            if (build.buildCommand != null) "command": build.buildCommand,
          }
        },
      );
}
