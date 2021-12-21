import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:glacier/utils/config_utils.dart';

class InitCommand extends Command<int> {
  @override
  final String name = "init";

  @override
  final String description = "Create a new glacier project";

  InitCommand() {
    argParser.addOption("template", abbr: "t", defaultsTo: "https://github.com/nyxx-discord/glacier_template.git");
  }

  bool isValidUrl(String gitRepoUrl) {
    return ['https://', 'git@'].map((e) => gitRepoUrl.startsWith(e)).isNotEmpty;
  }

  @override
  Future<int> run() async {
    if (await ConfigUtils.doesConfigExist()) {
      print("[ERROR] This directory has already been initialised with another Glacier project.");
      return 1;
    }

    //? Validate that git is installed and working
    try {
      final result = await Process.run('git', ['--version']);
      final String gitVersionString = result.stdout as String;
      final gitVersion = gitVersionString.replaceAll("git version", "").trim(); // Remove prefix and blank spaces
      print("[INFO] Using git version: $gitVersion");
    } catch (e) {
      if (e.runtimeType == ProcessException) {
        print("[ERROR] Git is not installed or in the current path, please install git and try again.");
        return 1;
      }
      print("[ERROR] Unknown error testing git!");
      return 1;
    }

    // Get template URL from args
    final templateUrl = argResults!["template"] as String;

    if (!isValidUrl(templateUrl)) {
      print(
          "[ERROR] $templateUrl is not a valid git repository. Please try again with a valid url from from GitHub, Bitbucket, GitLab, or any other public git repo.");
      return 128;
    }

    // Try clone the template
    final cloneResult = await Process.run('git', ['clone', '--recursive', templateUrl, '.']);
    if (cloneResult.exitCode != 0) {
      print("[ERROR] Cloning Git template - $templateUrl - failed!");
      return 128;
    }

    print("""
Created new Glacier project! 

We recommend you go and change a few files:

- glacier.yml
- authors.yml
- README.md

After that you can run a couple commands:

- glacier generate
  Generate static files that can be deployed
  
- glacier server
  Serve a version of your docs locally, not recommended for production
  
Happy building with Glacier!
"""
        .trim());

    return 0;
  }
}
