import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/args.dart';
import 'package:xpm/os/bash_script.dart';
import 'package:xpm/os/bin_directory.dart';
import 'package:xpm/os/executable.dart';
import 'package:xpm/os/get_archicteture.dart';
import 'package:xpm/os/os_release.dart';
import 'package:xpm/os/repositories.dart';
import 'package:xpm/utils/logger.dart';
import 'package:xpm/utils/slugify.dart';
import 'package:xpm/xpm.dart';
import 'package:xpm/utils/leave.dart';
import 'package:xpm/global.dart';

/// A class that prepares a package for installation.
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

  /// Creates a new instance of the [Prepare] class.
  ///
  /// The [repo] parameter is the name of the repository that contains the package.
  /// The [package] parameter is the name of the package to prepare.
  /// The [args] parameter is an optional [ArgResults] object that contains the command-line arguments.
  Prepare(this.repo, this.package, {this.args});

  /// Initializes the class by setting some properties and loading the package script.
  Future<void> boot() async {
    if (booted) return;
    repoSlug = repo.slugify();
    cacheRepoDir = XPM.cacheDir("repos/$repoSlug/$package");
    packageDir = Repositories.dir(repo, package: package);

    final String packageDirPath = (await packageDir).path;
    baseScript = File('$packageDirPath/../base.bash');

    packageScript = BashScript('$packageDirPath/$package.bash');

    if (await packageScript.contents() == null) {
      leave(
          message: 'Script for "{@blue}$package{@end}" does not exist.',
          exitCode: unableToOpenInputFile);
    }

    Global.sudoPath = await Executable('sudo').find() ?? '';

    booted = true;
  }

  /// Writes the given script to a file in the cache directory.
  ///
  /// The [script] parameter is the script to write.
  Future<File> writeThisBeast(String script) async {
    await boot();

    return File('${(await cacheRepoDir).path}/together.bash')
        .writeAsString(script.trim());
  }

  /// Determines the best installation method based on the user's preferences and the operating system.
  ///
  /// The [to] parameter is the installation target.
  Future<String> best({to = 'install'}) async {
    await boot();

    final String preferedMethod = args?['method'] ?? 'auto';
    final bool forceMethod = args!['force-method'];
    // @FIXME on any "best" function, check if the method is available on the package script

    if (forceMethod) {
      if (preferedMethod == 'auto') {
        leave(
            message: 'Use --force-method with --method=', exitCode: wrongUsage);
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
        case 'zypper':
          return bestForOpenSUSE(to: to);
        case 'swupd':
          return bestForClearLinux(to: to);
        default:
          leave(message: 'Unknown method: $preferedMethod', exitCode: notFound);
      }
    }

    if (preferedMethod == 'any') return bestForAny(to: to);

    if (preferedMethod == 'apt' ||
        distro == 'debian' ||
        distroLike == 'debian') {
      return bestForApt(to: to);
    }

    if (preferedMethod == 'pacman' || distroLike == 'arch') {
      return bestForArch(to: to);
    }

    if (preferedMethod == 'dnf' ||
        distro == 'fedora' ||
        distro == 'rhel' ||
        distroLike == 'rhel fedora') {
      return bestForFedora(to: to);
    }

    if (preferedMethod == 'android' || distro == 'android') {
      return bestForAndroid(to: to);
    }

    if (preferedMethod == 'zypper' ||
        distro == 'opensuse' ||
        distro == 'sles') {
      return bestForOpenSUSE(to: to);
    }

    if (preferedMethod == 'brew' || distro == 'macos') {
      return bestForMacOS(to: to);
    }

    if (preferedMethod == 'choco' || distro == 'windows') {
      return bestForWindows(to: to);
    }

    if (preferedMethod == 'swupd' ||
        distro == 'clear-linux-os' ||
        distroLike == 'clear-linux-os') {
      return bestForClearLinux(to: to);
    }

    return bestForAny(to: to);
  }

  /// Determines the best installation method for any operating system.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForAny({String to = 'install'}) async => '${to}_any';

  /// Determines the best installation method for package managers that work on any operating system.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForPack({String to = 'install'}) async {
    final String? snap = await Executable('snap').find();
    final String? flatpak = await Executable('flatpak').find();
    final String? appimage = await Executable('appimage').find();

    late final String? bestPack;

    if (snap != null) {
      bestPack = snap;
      Global.isSnap = true;
    } else if (flatpak != null) {
      bestPack = '$flatpak --assumeyes';
      Global.isFlatpak = true;
    } else if (appimage != null) {
      bestPack = appimage;
      Global.isAppImage = true;
    }

    return bestPack != null
        ? '${to}_pack "$bestPack"'
        : await bestForAny(to: to);
  }

  /// Determines the best installation method for Clear Linux OS.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForClearLinux({String to = 'install'}) async {
    final swupd = await Executable('swupd').find();

    final String? bestSwupd = swupd;

    return bestSwupd != null
        ? '${to}_swupd "${Global.sudoPath} $bestSwupd"'
        : await bestForAny(to: to);
  }

  /// Determines the best installation method for Debian-based Linux distributions.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForApt({String to = 'install'}) async {
    final apt = await Executable('apt').find();
    final aptGet = await Executable('apt-get').find();

    final String? bestApt = apt ?? aptGet;

    return bestApt != null
        ? '${to}_apt "${Global.sudoPath} $bestApt -y"'
        : await bestForAny(to: to);
  }

  /// Determines the best installation method for Arch Linux.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForArch({String to = 'install'}) async {
    final paru = await Executable('paru').find();
    final yay = await Executable('yay').find();
    final pacman = await Executable('pacman').find();
    String? bestArchLinux = paru ?? yay ?? pacman;

    return bestArchLinux != null
        ? '${to}_pacman "${Global.sudoPath} $bestArchLinux --noconfirm"'
        : await bestForAny(to: to);
  }

  /// Determines the best installation method for Fedora.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForFedora({String to = 'install'}) async {
    final dnf = await Executable('dnf').find();

    String? bestFedora = dnf;

    return bestFedora != null
        ? '${to}_dnf "${Global.sudoPath} $bestFedora -y"'
        : await bestForAny(to: to);
  }

  /// Determines the best installation method for macOS.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForMacOS({String to = 'install'}) async {
    final brew = await Executable('brew').find();

    return brew != null ? '${to}_macos "$brew"' : await bestForAny(to: to);
  }

  /// Determines the best installation method for OpenSUSE.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForOpenSUSE({String to = 'install'}) async {
    final zypper = await Executable('zypper').find();

    return zypper != null
        ? '${to}_zypper "${Global.sudoPath} $zypper --non-interactive"'
        : await bestForAny(to: to);
  }

  /// Determines the best installation method for Android.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForAndroid({String to = 'install'}) async {
    final pkg = await Executable('pkg').find(); // termux

    return pkg != null
        ? '${to}_android "${Global.sudoPath} $pkg -y"'
        : await bestForAny(to: to);
  }

  /// Determines the best installation method for Windows.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForWindows({String to = 'install'}) async {
    final choco = await Executable('choco').find();
    final scoop = await Executable('scoop').find();

    late final String? bestWindows;

    if (choco != null) {
      bestWindows = '$choco -y';
    } else if (scoop != null) {
      bestWindows = '$scoop --yes';
    }

    return bestWindows != null
        ? '${to}_windows "$bestWindows"'
        : await bestForAny(to: to);
  }

  /// Generates a script to install the package.
  ///
  /// The script is generated based on the current operating system and package manager.
  Future<String> toInstall() async {
    await boot();

    String togetherContents = '''
#!/usr/bin/env bash

${await dynamicCode()}

${await baseScriptContents()}

${await packageScript.contents()}

${await best(to: 'install')}
''';

    final togetherFile = await writeThisBeast(togetherContents);

    return togetherFile.path;
  }

  /// Generates a script to remove the package.
  ///
  /// The script is generated based on the current operating system and package manager.
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

  /// Generates a script to validate the package installation.
  ///
  /// The script is generated based on the current operating system and package manager.
  ///
  /// If [removing] is `true`, the script will validate the package removal instead of installation.
  Future<String> toValidate({removing = false}) async {
    await boot();

    String? bestValidateExecutable;

    final String? firstProvides = await packageScript.getFirstProvides();
    if (firstProvides != null) {
      final firstProvidesExecutable =
          await Executable(firstProvides).find(cache: false);
      if (firstProvidesExecutable != null) {
        bestValidateExecutable = firstProvidesExecutable;
      }
    }
    if (bestValidateExecutable == null) {
      final String? nameExecutable =
          await Executable(package).find(cache: false);
      if (nameExecutable != null) {
        bestValidateExecutable = nameExecutable;
      }
    }

    String togetherContents = '''
#!/usr/bin/env bash

# no need to validate using bash
''';

    if (removing && bestValidateExecutable == null) {
      Logger.info('Validation for removing package $package passed!');
    } else if (bestValidateExecutable == null) {
      leave(
        message: 'No executable found for $package, validation failed.',
        exitCode: notFound,
      );
    } else {
      togetherContents = '''
#!/usr/bin/env bash

${await dynamicCode()}

${await baseScriptContents()}

${await packageScript.contents()}

validate "$bestValidateExecutable"
''';
    }

    return (await writeThisBeast(togetherContents)).path;
  }

  /// Generates the dynamic code that will be added to the script.
  ///
  /// This code includes information about the current environment, such as the
  /// path to the Dart executable, the architecture, and the channel.
  Future<String> dynamicCode() async {
    String executable = Platform.resolvedExecutable;

    if (Platform.script.path.endsWith('.dart') ||
        executable.endsWith('/dart')) {
      // If we are running from a dart file or from a dart executable, add the
      // executable to the script.
      executable += ' ${Platform.script.path}';
    }

    String yARCH = getArchitecture();
    String yCHANNEL = args!['channel'] ?? '';

    return '''
readonly XPM="$executable";
readonly yARCH="$yARCH";
readonly yCHANNEL="$yCHANNEL";
readonly yBIN="${binDirectory().path}";
readonly ySUDO="${Global.sudoPath}";
readonly isSnap="${Global.isSnap}";
readonly isFlatpak="${Global.isFlatpak}";
readonly isAppImage="${Global.isAppImage}";
''';
  }

  /// Returns the contents of the base script, if it exists.
  ///
  /// The base script is a script that is included with the package and can be
  /// used to customize the installation process.
  Future<String> baseScriptContents() async {
    if (!await baseScript.exists()) {
      return '';
    }

    return await baseScript.readAsString();
  }
}
