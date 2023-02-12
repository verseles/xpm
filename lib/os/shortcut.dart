import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/xpm.dart';

class Shortcut {
  final String name;
  final String executablePath;
  final String? icon;
  final String? comment;
  final bool? terminal;
  final String? type;
  final String? categories;

  Shortcut({
    required this.name,
    required this.executablePath,
    this.icon,
    this.comment,
    this.terminal = false,
    this.type = 'Application',
    this.categories,
  });

  String home = XPM.userHome.path;

  Future<String> create() async {
    if (Platform.isMacOS) {
      return _createMacOSShortcut();
    } else if (Platform.isWindows) {
      return _createWindowsShortcut();
    }

    return await _createLinuxShortcut();
  }

  Future<String> _createLinuxShortcut() async {
    final runner = Run();
    final filePath = '/usr/share/applications/$name.desktop';
    final file = File(filePath);

    if (await file.exists()) {
      await runner.delete(filePath, sudo: true);
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
    await runner.touch(filePath, sudo: true);

    await runner.writeToFile(filePath, content, sudo: true);

    await runner.asExec(filePath, sudo: true);

    return filePath;
  }

  Future<String> _createMacOSShortcut() async {
    final linkPath = "$home/Desktop/$name.lnk";
    final runner = Run();
    final command = "-s $executablePath $linkPath";
    await runner.simple('ln', command.split(' '));

    return linkPath;
  }

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
