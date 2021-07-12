part of glacier;

class ConfigUtils {
  static GlacierConfig createConfig({String? name}) =>
      GlacierConfig._new(name ?? Directory.current.path.replaceAll("\\", "/").split("/").last);

  static Future<GlacierConfig> getConfig({String path = "./glacier.yaml"}) async {
    if (!await doesConfigExist(path: path)) {
      throw "Invalid config path";
    }

    final file = File(path);
    final content = await file.readAsString();

    return GlacierConfig._fromYaml(content);
  }

  static GlacierConfig getConfigSync({String path = "./glacier.yaml"}) {
    if (!doesConfigExistSync(path: path)) {
      throw "Invalid config path";
    }

    final file = File(path);
    final content = file.readAsStringSync();

    return GlacierConfig._fromYaml(content);
  }

  static bool doesConfigExistSync({String path = "./glacier.yaml"}) => File(path).existsSync();
  static Future<bool> doesConfigExist({String path = "./glacier.yaml"}) async => File(path).exists();
}
