import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/command_runner.dart';

import 'package:xpm/os/shortcut.dart';
import 'package:xpm/utils/logger.dart';

class ShortcutCommand extends Command {
  @override
  final name = "shortcut";
  @override
  final description = "Create a shortcut on the system/desktop";
  @override
  final category = "For developers";

  ShortcutCommand() {
    argParser.addOption("name", abbr: "n", help: "Name of the application", valueHelp: 'name', mandatory: true);

    argParser.addOption("path", abbr: "p", help: "Path of the executable", valueHelp: 'path');

    argParser.addOption("icon", abbr: "i", help: "Name or path of the icon", valueHelp: 'name|path');

    argParser.addOption("description", abbr: "d", help: "Description of the application", valueHelp: 'description');

    argParser.addMultiOption(
      "category",
      abbr: "c",
      help: "Categories, multiple times or once using semicolon",
      valueHelp: 'category[;category2]',
    );

    argParser.addFlag("terminal", abbr: 't', help: 'Run in terminal', defaultsTo: false);

    argParser.addOption(
      "type",
      abbr: 'y',
      help: 'Type of the shortcut',
      valueHelp: 'type',
      allowed: ['Application', 'Link', 'Directory', 'Menu', 'FSDevice', 'FSVolume', 'Location', 'Window'],
      defaultsTo: 'Application',
    );

    argParser.addMultiOption(
      'mime',
      abbr: 'm',
      help: 'MimeTypes, multiple times or once using semicolon',
      valueHelp: 'mime[;mime2]',
    );

    argParser.addFlag("startup", abbr: 'u', help: 'Notify on startup', negatable: true, defaultsTo: true);

    argParser.addFlag("sudo", abbr: 's', help: 'Run as sudo', negatable: true, defaultsTo: true);

    // Remove shortcut flag
    argParser.addFlag("remove", abbr: 'r', help: 'Remove shortcut', negatable: false);
  }

  @override
  void run() async {
    final String name = argResults!['name'];
    final String? executablePath = argResults!['path'];
    final String? icon = argResults!['icon'];
    final String? description = argResults!['description'];
    final List<String> category = argResults!['category'];
    final bool terminal = argResults!['terminal'];
    final String type = argResults!['type'];
    final List<String> mime = argResults!['mime'];
    final bool startup = argResults!['startup'];

    final bool sudo = argResults!['sudo'];
    final bool remove = argResults!['remove'];

    var shortcut = Shortcut(
      name: name,
      executablePath: executablePath,
      icon: icon,
      comment: description,
      categories: category.join(';'),
      terminal: terminal,
      type: type,
      mime: mime.join(';'),
      startup: startup,
      sudo: sudo,
    );

    if (remove) {
      await shortcut.delete();

      Logger.info("Shortcut removed.");
    } else {
      await shortcut.create();

      Logger.info("Shortcut created.");
    }
    exit(success);
  }
}
