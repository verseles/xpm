import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
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

  void create() {
    if (Platform.isLinux) {
      _createLinuxShortcut();
    } else if (Platform.isMacOS) {
      _createMacOSShortcut();
    } else if (Platform.isWindows) {
      _createWindowsShortcut();
    }
  }

  void _createLinuxShortcut() async {
    final runner = Run();
    final filePath = '/usr/share/applications/$name.desktop';
    final file = File(filePath);

    if (await file.exists()) {
      await runner.simple('rm', ['-f', filePath], sudo: true);
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
    await runner.simple('touch', [filePath], sudo: true);

    await runner.writeToFile(filePath, content, sudo: true);

    await runner.simple('chmod', ['+x', file.path], sudo: true);

    exit(success);
  }

  void _createMacOSShortcut() {
    final linkPath = "$home/Desktop/$name.lnk";
    final runner = Run();
    final command = "-s $executablePath $linkPath";
    runner.simple('ln', command.split(' '));
  }

  void _createWindowsShortcut() {
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
    shell.run(command);
  }
}
