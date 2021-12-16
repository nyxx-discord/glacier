import "package:args/command_runner.dart";
import "package:glacier/glacier.dart";

main(List<String> args) async {
  final commandRunner = CommandRunner<int>("glacier", "Dart markdown docs gen")
    ..addCommand(InitCommand())
    ..addCommand(GenerateCommand())
    ..addCommand(ServeCommand());

  return commandRunner.run(args);
}
