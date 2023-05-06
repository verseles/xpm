import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/xpm.dart';

/// A class that represents a shortcut to an executable file.
class Shortcut {
  final String name;
  final String executablePath;
  final String? icon;
  final String? comment;
  final bool? terminal;
  final String? type;
  final String? categories;
  final String? destination;
  final bool sudo;

  Shortcut({
    required this.name,
    required this.executablePath,
    this.icon,
    this.comment,
    this.terminal = false,
    this.type = 'Application',
    this.categories,
    this.destination,
    this.sudo = true,
  });

  String home = XPM.userHome.path;

  /// Creates the shortcut.
  Future<String> create() async {
    if (Platform.isMacOS) {
      return _createMacOSShortcut();
    } else if (Platform.isWindows) {
      return _createWindowsShortcut();
    }

    return await _createLinuxShortcut();
  }

  /// Creates a shortcut on a Linux-based system.
  Future<String> _createLinuxShortcut() async {
    final runner = Run();
    final dest = destination ?? '/usr/share/applications';
    final filePath = '$dest/$name.desktop';
    final file = File(filePath);

    if (await file.exists()) {
      await runner.delete(filePath, sudo: sudo);
    }
    String content = '''[Desktop Entry]
    Name=$name
    Exec=$executablePath
    Icon=${icon ?? name}
    Type=$type
    Terminal=$terminal
    Comment=$comment
    Categories=${categories ?? 'Utility'};
    ''';
    await runner.touch(filePath, sudo: sudo);

    await runner.writeToFile(filePath, content, sudo: sudo);

    await runner.asExec(filePath, sudo: sudo);

    return filePath;
  }

  /// Creates a shortcut on a macOS system.
  Future<String> _createMacOSShortcut() async {
    final linkPath = "$home/Desktop/$name.lnk";
    final runner = Run();
    final command = "-s $executablePath $linkPath";
    await runner.simple('ln', command.split(' '));

    return linkPath;
  }

  /// Creates a shortcut on a Windows system.
  Future<String> _createWindowsShortcut() async {
    final linkPath = "$home/Desktop/$name.lnk";
    final command = "cmd /c "
        "echo Set oWS = WScript.CreateObject(\"WScript.Shell\") > CreateShortcut.vbs & "
        "echo sLinkFile = \"$linkPath\" >> CreateShortcut.vbs & "
        "echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs & "
        "echo oLink.TargetPath = \"$executablePath\" >> CreateShortcut.vbs & "
        "echo oLink.Save >> CreateShortcut.vbs & "
        "cscript CreateShortcut.vbs & "
        "del CreateShortcut.vbs";

    final Shell shell = Shell();

    await shell.run(command);

    return linkPath;
  }
}
