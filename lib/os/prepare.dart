import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/args.dart';
import 'package:xpm/os/bash_script.dart';
import 'package:xpm/os/executable.dart';
import 'package:xpm/os/get_architeture.dart';
import 'package:xpm/os/os_release.dart';
import 'package:xpm/os/repositories.dart';
import 'package:xpm/utils/slugify.dart';
import 'package:xpm/xpm.dart';
import 'package:xpm/utils/leave.dart';

class Prepare {
  final String repo, package;
  final ArgResults? args;

  static final String distro = osRelease('ID') ?? Platform.operatingSystem;
  static final String distroLike = osRelease('ID_LIKE') ?? '';

  late final String repoSlug;
  late final Future<Directory> cacheRepoDir;
  late final Future<Directory> packageDir;
  late final File baseScript;
  late final BashScript packageScript;
  bool booted = false;

  Prepare(this.repo, this.package, {this.args});

  Future<void> boot() async {
    if (booted) return;
    repoSlug = repo.slugify();
    cacheRepoDir = XPM.cacheDir("repos/$repoSlug/$package");
    packageDir = Repositories.dir(repo, package: package);

    final String packageDirPath = (await packageDir).path;
    baseScript = File('$packageDirPath/../base.bash');

    packageScript = BashScript('$packageDirPath/$package.bash');

    if (await packageScript.contents() == null) {
      leave(message: 'Script for "{@blue}$package{@end}" does not exist.', exitCode: unableToOpenInputFile);
    }

    booted = true;
  }

  Future<File> writeThisBeast(String script) async {
    await boot();

    return File('${(await cacheRepoDir).path}/together.bash').writeAsString(script.trim());
  }

  Future<String> best({to = 'install'}) async {
    await boot();

    final String preferedMethod = args?['method'] ?? 'auto';
    final bool forceMethod = args!['force-method'];

    // @FIXME on any "best" function, check if the method is available on the package script

    if (forceMethod) {
      if (preferedMethod == 'auto') {
        leave(message: 'Use --force-method with --method=', exitCode: wrongUsage);
      }
      switch (preferedMethod) {
        case 'any':
          return bestForAny(to: to);
        case 'pack':
          return bestForPack(to: to);
        case 'apt':
          return bestForApt(to: to);
        case 'brew':
          return bestForMacOS(to: to);
        case 'choco':
          return bestForWindows(to: to);
        case 'dnf':
          return bestForFedora(to: to);
        case 'pacman':
          return bestForArch(to: to);
        case 'android':
          return bestForAndroid(to: to);
        case 'yum':
          return bestForCentOS(to: to);
        case 'zypper':
          return bestForOpenSUSE(to: to);
        default:
          leave(message: 'Unknown method: $preferedMethod', exitCode: notFound);
      }
    }

    if (preferedMethod == 'any') return bestForAny(to: to);

    if (preferedMethod == 'apt' || distro == 'debian' || distroLike == 'debian') {
      return bestForApt(to: to);
    }

    if (preferedMethod == 'pacman' || distroLike == 'arch') {
      return bestForArch(to: to);
    }

    if (preferedMethod == 'dnf' || distro == 'fedora') {
      return bestForFedora(to: to);
    }

    if (preferedMethod == 'android' || distro == 'android') {
      return bestForAndroid(to: to);
    }

    if (preferedMethod == 'yum' || distro == 'centos' || distro == 'rhel' || distroLike == 'rhel fedora') {
      return bestForCentOS(to: to);
    }

    if (preferedMethod == 'zypper' || distro == 'opensuse' || distro == 'sles') {
      return bestForOpenSUSE(to: to);
    }

    if (preferedMethod == 'brew' || distro == 'macos') {
      return bestForMacOS(to: to);
    }

    if (preferedMethod == 'choco' || distro == 'windows') {
      return bestForWindows(to: to);
    }

    return bestForAny(to: to);
  }

  Future<String> bestForAny({String to = 'install'}) async => '${to}_any';

  Future<String> bestForPack({String to = 'install'}) async {
    final String? snap = await Executable('snap').find();
    final String? flatpak = await Executable('flatpak').find();
    final String? appimage = await Executable('appimage').find();

    late final String? bestPack;

    if (snap != null) {
      bestPack = snap;
    } else if (flatpak != null) {
      bestPack = '$flatpak --assumeyes';
    } else if (appimage != null) {
      bestPack = appimage;
    }

    return bestPack != null ? '${to}_pack "$bestPack"' : await bestForAny(to: to);
  }

  Future<String> bestForApt({String to = 'install'}) async {
    final apt = await Executable('apt').find();
    final aptGet = await Executable('apt-get').find();

    final String? bestApt = apt ?? aptGet;

    return bestApt != null ? '${to}_apt "$bestApt -y"' : await bestForAny(to: to);
  }

  Future<String> bestForArch({String to = 'install'}) async {
    final paru = await Executable('paru').find();
    final yay = await Executable('yay').find();
    final pacman = await Executable('pacman').find();
    String? bestArchLinux = paru ?? yay ?? pacman;

    return bestArchLinux != null ? '${to}_pacman "$bestArchLinux --noconfirm"' : await bestForAny(to: to);
  }

  Future<String> bestForFedora({String to = 'install'}) async {
    final dnf = await Executable('dnf').find();
    final yum = await Executable('yum').find();

    String? bestFedora = dnf ?? yum;

    return bestFedora != null ? '${to}_dnf "$bestFedora -y"' : await bestForAny(to: to);
  }

  Future<String> bestForCentOS({String to = 'install'}) async {
    final dnf = await Executable('dnf').find();
    final yum = await Executable('yum').find();

    String? bestCentOS = dnf ?? yum;

    return bestCentOS != null ? '${to}_yum "$bestCentOS -y"' : await bestForAny(to: to);
  }

  Future<String> bestForMacOS({String to = 'install'}) async {
    final brew = await Executable('brew').find();

    return brew != null ? '${to}_macos "$brew"' : await bestForAny(to: to);
  }

  Future<String> bestForOpenSUSE({String to = 'install'}) async {
    final zypper = await Executable('zypper').find();

    return zypper != null ? '${to}_zypper "$zypper -y"' : await bestForAny(to: to);
  }

  Future<String> bestForAndroid({String to = 'install'}) async {
    final pkg = await Executable('pkg').find(); // termux

    return pkg != null ? '${to}_android "$pkg -y"' : await bestForAny(to: to);
  }

  Future<String> bestForWindows({String to = 'install'}) async {
    final choco = await Executable('choco').find();
    final scoop = await Executable('scoop').find();

    late final String? bestWindows;

    if (choco != null) {
      bestWindows = '$choco -y';
    } else if (scoop != null) {
      bestWindows = '$scoop --yes';
    }

    return bestWindows != null ? '${to}_windows "$bestWindows"' : await bestForAny(to: to);
  }

  Future<String> toInstall() async {
    await boot();

    String togetherContents = '''
#!/usr/bin/env bash

${await dynamicCode()}

${await baseScriptContents()}

${await packageScript.contents()}

${await best(to: 'install')}
''';

    return (await writeThisBeast(togetherContents)).path;
  }

  Future<String> toRemove() async {
    await boot();

    String togetherContents = '''
#!/usr/bin/env bash

${await dynamicCode()}

${await baseScriptContents()}

${await packageScript.contents()}

${await best(to: 'remove')}
''';

    return (await writeThisBeast(togetherContents)).path;
  }

  Future<String> toValidate() async {
    await boot();

    late final String? bestValidateExecutable;

    final String? firstProvides = await packageScript.getFirstProvides();
    if (firstProvides != null) {
      final firstProvidesExecutable = await Executable(firstProvides).find();
      if (firstProvidesExecutable != null) {
        bestValidateExecutable = firstProvidesExecutable;
      }
    }
    if (bestValidateExecutable == null) {
      final String? nameExecutable = await Executable(package).find();
      if (nameExecutable != null) {
        bestValidateExecutable = nameExecutable;
      }
    }

    if (bestValidateExecutable == null) {
      leave(
        message: 'No executable found for $package, validation failed.',
        exitCode: notFound,
      );
    }

    String togetherContents = '''
#!/usr/bin/env bash

${await dynamicCode()}

${await baseScriptContents()}

${await packageScript.contents()}

validate "$bestValidateExecutable"
''';

    return (await writeThisBeast(togetherContents)).path;
  }

  Future<String> dynamicCode() async {
    String xARCH = await getArchitecture();
    String yCHANNEL = args!['channel'] as String;
    return '''
readonly yARCH = "$xARCH";
readonly yCHANNEL = "$yCHANNEL";
''';
  }

  Future<String> baseScriptContents() async {
    if (!await baseScript.exists()) {
      return '';
    }

    return await baseScript.readAsString();
  }
}
