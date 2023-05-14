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

    argParser.addOption("path", abbr: "p", help: "Path of the executable", valueHelp: 'path', mandatory: true);

    argParser.addOption("icon", abbr: "i", help: "Name or path of the icon", valueHelp: 'name|path');

    argParser.addOption("description", abbr: "d", help: "Description of the application", valueHelp: 'description');

    argParser.addMultiOption("category",
        abbr: "c", help: "Categories, multiple times or once using comma", valueHelp: 'category[,category2]');

    argParser.addFlag('sudo', abbr: 's', help: 'Run as sudo', negatable: true, defaultsTo: true);
  }

  @override
  void run() async {
    final String name = argResults!['name'];
    final String executablePath = argResults!['path'];
    final String? icon = argResults!['icon'];
    final String? description = argResults!['description'];
    final List<String> category = argResults!['category'];
    final bool sudo = argResults!['sudo'];

    var shortcut = Shortcut(
        name: name,
        executablePath: executablePath,
        icon: icon,
        comment: description,
        categories: category.join(';'),
        sudo: sudo);

    await shortcut.create();

    Logger.info("Shortcut created successfully!");
    exit(success);
  }
}
