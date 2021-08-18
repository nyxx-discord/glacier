part of glacier_cli;

// TODO fix?
class DirectoryUtils {
  static String get osSlash => Platform.isWindows ? "\\" : "/";

  // TODO remove .replaceAll and use osSlash
  static String get currentDirName => Directory.current.path.replaceAll("\\", "/").split("/").last;
}
