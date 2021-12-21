import 'dart:io';

import 'package:glacier/internal/glacier_config.dart';

class ConfigUtils {
  static GlacierConfig createConfig({String? name}) => GlacierConfig(name ?? Directory.current.path.replaceAll("\\", "/").split("/").last);

  static Future<GlacierConfig> getConfig({String path = "./glacier.yaml"}) async {
    if (!await doesConfigExist(path: path)) {
      throw Exception("Invalid config path");
    }

    final file = File(path);
    final content = await file.readAsString();

    return GlacierConfig.fromYaml(content);
  }

  static GlacierConfig getConfigSync({String path = "./glacier.yaml"}) {
    if (!doesConfigExistSync(path: path)) {
      throw Exception("Invalid config path");
    }

    final file = File(path);
    final content = file.readAsStringSync();

    return GlacierConfig.fromYaml(content);
  }

  static bool doesConfigExistSync({String path = "./glacier.yaml"}) => File(path).existsSync();
  static Future<bool> doesConfigExist({String path = "./glacier.yaml"}) => File(path).exists();
}
