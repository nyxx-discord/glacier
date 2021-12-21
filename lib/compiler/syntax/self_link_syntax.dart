import 'package:markdown/markdown.dart';

class SelfLinkSyntax extends InlineSyntax {
  static const String selfLinkSyntax = r"\((.*)\)\((.+)\.md\)";

  final List<Map<String, dynamic>> sidebarEntries;

  SelfLinkSyntax(this.sidebarEntries) : super(selfLinkSyntax);

  @override
  bool onMatch(InlineParser parser, Match match) {
    var title = match.group(1);
    final fileName = match.group(2);

    if (title != null && title.isEmpty) {
      title = null;
    }

    if (fileName == null) {
      return false;
    }

    final sidebarEntry = findEntry(_getInternalUrl(fileName));
    if (sidebarEntry != null) {
      final finalTitle = title ?? sidebarEntry["name"];

      parser.addNode(Text("<a href='$fileName.html'>$finalTitle</a>"));
      return true;
    }

    if (title != null) {
      parser.addNode(Text("<a href='$fileName.html'>$title</a>"));
      return true;
    }

    return false;
  }

  String _getInternalUrl(String name) => "$name.html";

  Map<String, dynamic>? findEntry(String url) {
    for (final sidebarEntry in sidebarEntries) {
      for (final e in sidebarEntry["entries"]) {
        if (e["url"] == url) {
          return e as Map<String, dynamic>;
        }
      }
    }

    return null;
  }
}
