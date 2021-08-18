part of glacier_cli;

class GlacierConfig {
  late final String name;
  late final String document_directory;

  late final String? description;
  late final String? github_url;

  GlacierConfig._new(this.name, {this.description, this.github_url, this.document_directory = "./src"});

  GlacierConfig._fromYaml(String yaml) {
    final doc = loadYaml(yaml);

    this.name = doc["name"] as String;
    this.document_directory = doc["base_directory"] as String;

    this.description = doc["description"] as String?;
    this.github_url = doc["github_url"] as String?;
  }

  @override
  String toString() =>
      "# Glacier Config\n" +
          _YamlWriter().write(
            <String, String>{
              "name": this.name,
              "document_directory": this.document_directory,
              if (this.description != null) "description": this.description!,
              if (this.github_url != null) "github_url": this.github_url!,
            },
          );
}
