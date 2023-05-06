import 'package:args/command_runner.dart';
import 'package:xpm/utils/logger.dart';
import 'package:xpm/utils/show_usage.dart';

class LogCommand extends Command {
  @override
  final name = "log";
  @override
  final description =
      "Output info, warning, and error messages\nIf the first argument is 'info', 'warning', 'error', or 'tip', the second argument will be output as that type of message. Otherwise, the arguments will be output as a log message.";
  @override
  String get invocation => '${runner!.executableName} $name [info|warning|error|tip] <message>';
  @override
  final category = "For developers";

  // [run] may also return a Future.
  @override
  void run() {
    List<String> args = argResults!.rest;
    showUsage(args.isEmpty, () => printUsage());
    String type = args[0];
    String message = args.sublist(1).join(' ');
    switch (type) {
      case 'info':
        Logger.info(message);
        break;
      case 'warning':
        Logger.warning(message);
        break;
      case 'error':
        Logger.error(message);
        break;
      case 'tip':
        Logger.tip(message);
        break;
      default:
        Logger.log(args.toString());
    }
  }
}
