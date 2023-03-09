import 'package:args/command_runner.dart';
import 'package:xpm/commands/devs/file/bin.dart';
import 'package:xpm/commands/devs/file/copy.dart';
import 'package:xpm/commands/devs/file/delete.dart';
import 'package:xpm/commands/devs/file/exec.dart';
import 'package:xpm/commands/devs/file/move.dart';
import 'package:xpm/commands/devs/file/unbin.dart';

class FileCommand extends Command {
  @override
  final name = "file";
  @override
  final description =
      "File operations like copy, move, delete, make executable, etc.";
  @override
  final category = "For developers";

  FileCommand() {
    addSubcommand(FileCopyCommand());
    addSubcommand(FileMoveCommand());
    addSubcommand(FileDeleteCommand());
    addSubcommand(FileExecCommand());
    addSubcommand(FileBinCommand());
    addSubcommand(FileUnbinCommand());
  }

  // [run] may also return a Future.
  @override
  void run() {}
}
