import 'package:yaml/yaml.dart';

class Author {
  late final String name;
  late final String? imageUrl;
  late final String? url;
  late final String? title;

  Author(this.name, {this.imageUrl, this.url, this.title});

  Author.fromYamlObject(YamlMap doc) {
    name = doc["name"] as String;

    imageUrl = doc["image_url"] as String?;
    url = doc["url"] as String?;
    title = doc["title"] as String?;
  }

  Map<String, String> toJson() {
    return <String, String>{
      "name": name,
      if (imageUrl != null) "image_url": imageUrl!,
      if (url != null) "url": url!,
      if (title != null) "title": title!,
    };
  }
}
