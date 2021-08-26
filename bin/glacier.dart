import "package:args/command_runner.dart";
import "package:glacier_cli/glacier.dart";

Future<void> main(List<String> args) async {
  final commandRunner = CommandRunner<void>("glacier", "Dart markdown docs gen")
    ..addCommand(InitCommand())
    ..addCommand(GenerateCommand());

  return commandRunner.run(args);
}
