part of glacier_cli;

class GlacierConfig {
  late final String name;
  late final String sourceDirectory;
  late final String destinationDirectory;
  late final String baseDirectory;

  late final String? description;
  late final String? githubUrl;
  late final List<String>? destinationFilesExclude;
  late final List<String>? destinationFilesInclude;

  GlacierConfig._new(
    this.name, {
    this.description = "Glacier generated config file",
    this.githubUrl,
    this.sourceDirectory = "./src",
    this.destinationDirectory = "./dist",
    this.baseDirectory = "./base",
    this.destinationFilesExclude,
    this.destinationFilesInclude = const ["base.js", "base.css"],
  });

  GlacierConfig._fromYaml(String yaml) {
    final doc = loadYaml(yaml);

    this.name = doc["name"] as String;
    this.sourceDirectory = doc["source_directory"] as String;
    this.destinationDirectory = doc["destination_directory"] as String;
    this.baseDirectory = doc["base_directory"] as String;

    this.description = doc["description"] as String?;
    this.githubUrl = doc["github_url"] as String?;

    this.destinationFilesExclude =
        (doc["destination_files"]?["exclude"] as YamlList?)?.cast<String>();

    this.destinationFilesInclude =
        (doc["destination_files"]?["include"] as YamlList?)?.cast<String>();
  }

  /// Load glacier.yaml from file
  factory GlacierConfig.loadFromFile() {
    final configFileContent = File("glacier.yaml").readAsStringSync();
    return GlacierConfig._fromYaml(configFileContent);
  }

  @override
  String toString() =>
      // ignore: prefer_interpolation_to_compose_strings
      "# Glacier Config\n" +
      _YamlWriter().write(
        <String, dynamic>{
          "name": this.name,
          "source_directory": this.sourceDirectory,
          "destination_directory": this.destinationDirectory,
          "base_directory": this.baseDirectory,
          if (this.description != null) "description": this.description!,
          if (this.githubUrl != null) "github_url": this.githubUrl!,
          if (this.destinationFilesExclude != null ||
              this.destinationFilesInclude != null)
            "destination_files": {
              if (this.destinationFilesInclude != null)
                "include": this.destinationFilesInclude,
              if (this.destinationFilesExclude != null)
                "exclude": this.destinationFilesExclude,
            }
        },
      );
}
