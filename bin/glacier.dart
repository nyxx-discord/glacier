import "package:args/command_runner.dart";

import "commands/init_command.dart";

Future<void> main(List<String> args) async {
  final commandRunner = CommandRunner<void>("glacier", "Dart markdown docs gen")..addCommand(InitCommand());

  return commandRunner.run(args);
}
