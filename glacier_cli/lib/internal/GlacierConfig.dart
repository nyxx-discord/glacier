part of glacier_cli;

class GlacierConfig {
  late final String name;
  late final String documentDirectory;

  late final String? description;
  late final String? githubUrl;

  GlacierConfig._new(this.name, {this.description, this.githubUrl, this.documentDirectory = "./src"});

  GlacierConfig._fromYaml(String yaml) {
    final doc = loadYaml(yaml);

    this.name = doc["name"] as String;
    this.documentDirectory = doc["base_directory"] as String;

    this.description = doc["description"] as String?;
    this.githubUrl = doc["github_url"] as String?;
  }

  @override
  String toString() =>
      "# Glacier Config\n" +
      _YamlWriter().write(
        <String, String>{
          "name": this.name,
          "document_directory": this.documentDirectory,
          if (this.description != null) "description": this.description!,
          if (this.githubUrl != null) "github_url": this.githubUrl!,
        },
      );
}
