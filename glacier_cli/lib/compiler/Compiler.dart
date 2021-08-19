part of glacier_cli;

class Compiler {
  final Directory sourceDir;
  final Directory destinationDir;

  late final Template template;

  Compiler(this.sourceDir, this.destinationDir, String templateContent) {
    this.template = Template(templateContent, name: "base.html");
  }

  Future<void> compile() async {
    final mdFilesStream = sourceDir.list().where((entity) => extension(entity.path) == ".md").cast<File>();
    await for (final sourceFile in mdFilesStream) {
      await this.processFile(sourceFile);
    }
  }

  Future<void> processFile(File sourceFile) async {
    print("got file: ${sourceFile.path}");

    final sourceFileName = basenameWithoutExtension(sourceFile.path);
    final destFileName = "${join(destinationDir.absolute.path, sourceFileName)}.html";

    final sourceContent = await sourceFile.readAsString();

    final firstMatch = sourceContent.indexOf("---");
    final lastMatch = sourceContent.indexOf("---", 3);
    final metadataPart = sourceContent.substring(firstMatch + 3, lastMatch);
    final strippedContent = sourceContent.substring(lastMatch + 3);

    final fileMetadata = MarkdownMetadata._fromRaw(metadataPart);
    final compiledContent = await this.processTemplate(strippedContent, fileMetadata);

    final destFile = File(destFileName);
    if (!await destFile.exists()) {
      await destFile.create();
    }

    await destFile.writeAsString(compiledContent);
  }

  Future<String> processTemplate(String inputString, MarkdownMetadata metadata) async {
    final outputMarkdown = markdownToHtml(inputString, extensionSet: ExtensionSet.gitHubWeb);

    return this.template.renderString({
      "title": metadata.title,
      "body": outputMarkdown,
    });
  }
}
