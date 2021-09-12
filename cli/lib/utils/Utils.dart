part of glacier_cli;

// Misc utils
class Utils {
  static String makeRelativePath(String path) =>
      path.replaceFirst("/", "./").replaceFirst("\\", ".\\");

  static String stripRelativePath(String path) => path.replaceFirst("./", "");
}
