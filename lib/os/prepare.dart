import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/args.dart';
import 'package:xpm/database/models/package.dart';
import 'package:xpm/database/models/repo.dart';
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
  final Repo repo;
  final Package package;
  final ArgResults? args;

  static final String distro = osRelease('ID') ?? Platform.operatingSystem;
  static final List distroLike = (osRelease('ID_LIKE') ?? '').split(" ");
  static final errorOnUpdate = 'echo -e "\\\\033[38;5;208m Errors on update repositores. Proceeding... \\\\033[0m"';

  late final String preferredMethod;
  late final bool forceMethod;

  late final String repoSlug, packageName;
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

    preferredMethod = args?['method'] ?? 'auto';
    forceMethod = args!['force-method'];

    repoSlug = repo.url.slugify();
    packageName = package.name;
    cacheRepoDir = XPM.cacheDir("repos/$repoSlug/$packageName");
    packageDir = Repositories.dir(repoSlug, package: packageName);

    final String packageDirPath = (await packageDir).path;
    baseScript = File('$packageDirPath/../base.bash');

    packageScript = BashScript(package.script);

    if (await packageScript.contents() == null) {
      leave(message: 'Script for "{@blue}$packageName{@end}" does not exist.', exitCode: unableToOpenInputFile);
    }

    Global.sudoPath = await Executable('sudo').find() ?? '';
    Global.hasFlatpak = await Executable('flatpak').find() != null;
    Global.hasSnap = await Executable('snap').find() != null;

    booted = true;
  }

  /// Writes the given script to a file in the cache directory.
  ///
  /// The [script] parameter is the script to write.
  Future<File> writeThisBeast(String script) async {
    await boot();

    return File('${(await cacheRepoDir).path}/together.bash').writeAsString(script.trim());
  }

  /// Determines the best installation method based on the user's preferences and the operating system.
  ///
  /// The [to] parameter is the installation target.
  Future<String> best({to = 'install'}) async {
    await boot();

    if (forceMethod) {
      if (preferredMethod == 'auto') {
        leave(message: 'Use --force-method with --method=', exitCode: wrongUsage);
      }
    }

    return await useMethod(to);
  }

  Future<String> useMethod(to) async {
    await boot();

    switch (preferredMethod) {
      case 'any':
        return await bestForAny(to: to);
      case 'flatpak':
        return await bestForFlatpak(to: to);
      case 'snap':
        return await bestForSnap(to: to);
      case 'appimage':
        return await bestForAppImage(to: to);
      case 'apt':
        return await bestForApt(to: to);
      case 'brew':
        return await bestForMacOS(to: to);
      case 'choco':
        return await bestForWindows(to: to);
      case 'dnf':
        return await bestForFedora(to: to);
      case 'pacman':
        return await bestForArch(to: to);
      case 'android':
        return await bestForAndroid(to: to);
      case 'zypper':
        return await bestForOpenSUSE(to: to);
      case 'swupd':
        return await bestForClearLinux(to: to);
      default:
        return await findBest(to);
    }
  }

  Future<String> findBest(to) async {
    await boot();

    if (distro == 'debian' || distroLike.contains('debian')) {
      return await bestForApt(to: to);
    }

    if (distroLike.contains('arch')) {
      return await bestForArch(to: to);
    }

    if (distro == 'fedora' || distro == 'rhel' || distroLike.contains('rhel') || distroLike.contains('fedora')) {
      return await bestForFedora(to: to);
    }

    if (distro == 'android') {
      return await bestForAndroid(to: to);
    }

    if (distro == 'opensuse' ||
        distro == 'sles' ||
        distroLike.contains('sles') ||
        distroLike.contains('opensuse') ||
        distroLike.contains('suse')) {
      return await bestForOpenSUSE(to: to);
    }

    if (distro == 'macos' || distro == 'darwin' || distroLike.contains('darwin') || distroLike.contains('macos')) {
      return await bestForMacOS(to: to);
    }

    if (distro == 'windows') {
      return await bestForWindows(to: to);
    }

    if (distro == 'clear-linux-os' || distroLike.contains('clear-linux-os')) {
      return await bestForClearLinux(to: to);
    }

    return await bestForAny(to: to);
  }

  /// Determines the best installation method for any operating system.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForAny({String to = 'install'}) async {
    final methods = package.methods ?? [];
    final hasMethod = methods.contains('snap');

    if (hasMethod) {
      return '${to}_any';
    }

    leave(message: 'No installation method found for "{@blue}$packageName{@end}".', exitCode: notFound);
  }

  /// Determines the best installation method for Flatpak.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForFlatpak({String to = 'install'}) async {
    // @TODO: Add support for hasDefault and xSUDO and global update.

    final methods = package.methods ?? [];
    final hasMethod = methods.contains('flatpak');

    if (hasMethod) {
      final String? flatpak = await Executable('flatpak').find();

      final String? bestFlatpak = flatpak;

      if (bestFlatpak != null) {
        // no update command available, only upgrade
        return '${to}_flatpak "${Global.sudoPath} $bestFlatpak --noninteractive"';
      }
    }

    stopIfForcedMethodNotFound();

    return await bestForAny(to: to);
  }

  /// Determines the best installation method for package managers that work on any operating system.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForSnap({String to = 'install'}) async {
    // @TODO: Add support for hasDefault and xSUDO and global update.
    final methods = package.methods ?? [];
    final hasMethod = methods.contains('snap');

    final defaults = package.defaults ?? [];
    final hasDefault = defaults.contains('snap');

    if (hasMethod) {
      final String? snap = await Executable('snap').find();

      final String? bestSnap = snap;

      if (bestSnap != null) {
        // no update command available, only upgrade

        if (hasDefault) {
          return '${Global.sudoPath} $bestSnap $to ${package.name}';
        }
        return '${to}_snap "${Global.sudoPath} $bestSnap"';
      }
    }

    stopIfForcedMethodNotFound();

    return await bestForAny(to: to);
  }

  /// Determines the best installation method for package managers that work on any operating system.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForAppImage({String to = 'install'}) async {
    // @TODO: Research if there is something to do here.

    final methods = package.methods ?? [];
    final hasMethod = methods.contains('appimage');

    if (hasMethod) {
      final String bestAppImage = 'echo "AppImage has no executable"';

      return '${to}_appimage "$bestAppImage"';
    }

    stopIfForcedMethodNotFound();

    return await bestForAny(to: to);
  }

  /// Determines the best installation method for Clear Linux OS.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForClearLinux({String to = 'install'}) async {
    final methods = package.methods ?? [];
    final hasMethod = methods.contains('swupd');

    final defaults = package.defaults ?? [];
    final hasDefault = defaults.contains('swupd');

    if (hasMethod || hasDefault) {
      final swupd = await Executable('swupd').find();

      final String? bestSwupd = swupd;

      if (bestSwupd != null) {
        Global.updateCommand = '${Global.sudoPath} $bestSwupd update || $errorOnUpdate';
        if (hasDefault) {
          final operation = to == 'install' ? 'bundle-add' : 'bundle-remove';
          return '${Global.sudoPath} $bestSwupd $operation -y ${package.name}';
        }
        return '${to}_swupd "${Global.sudoPath} $bestSwupd"';
      }
    }

    stopIfForcedMethodNotFound();

    return await bestForAny(to: to);
  }

  /// Determines the best installation method for Debian-based Linux distributions.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForApt({String to = 'install'}) async {
    final methods = package.methods ?? [];
    final hasMethod = methods.contains('apt');

    final defaults = package.defaults ?? [];
    final hasDefault = defaults.contains('apt');

    if (hasMethod || hasDefault) {
      final apt = await Executable('apt').find();
      final aptGet = await Executable('apt-get').find();

      final String? bestApt = apt ?? aptGet;

      if (bestApt != null) {
        Global.updateCommand = '${Global.sudoPath} $bestApt update || $errorOnUpdate';
        if (hasDefault) {
          return '${Global.sudoPath} $bestApt $to -y ${package.name}';
        }
        return '${to}_apt "${Global.sudoPath} $bestApt -y"';
      }
    }

    stopIfForcedMethodNotFound();

    return await bestForAny(to: to);
  }

  /// Determines the best installation method for Arch Linux.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForArch({String to = 'install'}) async {
    /// Here can be the path to sudo if the package manager is pacman, others ask for sudo automatically.
    String needsSudo = '';

    final methods = package.methods ?? [];
    final hasMethod = methods.contains('pacman');

    final defaults = package.defaults ?? [];
    final hasDefault = defaults.contains('pacman');

    if (hasMethod || hasDefault) {
      final paru = await Executable('paru').find();
      final yay = await Executable('yay').find();
      final pacman = await Executable('pacman').find();
      String? bestArchLinux = paru ?? yay ?? pacman;

      if (bestArchLinux != null) {
        if (bestArchLinux == pacman) {
          needsSudo = Global.sudoPath;
        }
        Global.updateCommand = '${Global.sudoPath} $bestArchLinux -Sy || $errorOnUpdate';
        if (hasDefault) {
          final operation = to == 'install' ? '-S' : '-R';
          return '$needsSudo $bestArchLinux --noconfirm $operation ${package.name}';
        }
        return '${to}_pacman "$needsSudo $bestArchLinux --noconfirm"';
      }
    }

    stopIfForcedMethodNotFound();

    return await bestForAny(to: to);
  }

  /// Determines the best installation method for Fedora.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForFedora({String to = 'install'}) async {
    final methods = package.methods ?? [];
    final hasMethod = methods.contains('dnf');

    final defaults = package.defaults ?? [];
    final hasDefault = defaults.contains('dnf');

    if (hasMethod || hasDefault) {
      final dnf = await Executable('dnf').find();

      String? bestFedora = dnf;

      if (bestFedora != null) {
        Global.updateCommand = '${Global.sudoPath} $bestFedora check-update || $errorOnUpdate';
        if (hasDefault) {
          return '${Global.sudoPath} $bestFedora -y $to ${package.name}';
        }
        return '${to}_dnf "${Global.sudoPath} $bestFedora -y"';
      }
    }

    stopIfForcedMethodNotFound();

    return await bestForAny(to: to);
  }

  /// Determines the best installation method for macOS.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForMacOS({String to = 'install'}) async {
    final methods = package.methods ?? [];
    final hasMethod = methods.contains('brew');

    final defaults = package.defaults ?? [];
    final hasDefault = defaults.contains('brew');

    if (hasMethod || hasDefault) {
      final brew = await Executable('brew').find();

      if (brew != null) {
        Global.updateCommand = '$brew update || $errorOnUpdate';
        if (hasDefault) {
          return '$brew $to ${package.name}';
        }
        return '${to}_macos "$brew"';
      }
    }

    stopIfForcedMethodNotFound();

    return await bestForAny(to: to);
  }

  /// Determines the best installation method for OpenSUSE.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForOpenSUSE({String to = 'install'}) async {
    final methods = package.methods ?? [];
    final hasMethod = methods.contains('zypper');

    final defaults = package.defaults ?? [];
    final hasDefault = defaults.contains('zypper');

    if (hasMethod || hasDefault) {
      final zypper = await Executable('zypper').find();

      if (zypper != null) {
        Global.updateCommand = '${Global.sudoPath} $zypper refresh || $errorOnUpdate';
        if (hasDefault) {
          return '${Global.sudoPath} $zypper --non-interactive $to ${package.name}';
        }
        return '${to}_zypper "${Global.sudoPath} $zypper --non-interactive"';
      }
    }

    if (forceMethod) {
      leave(message: 'No suitable package manager found. [FORCED: $preferredMethod]', exitCode: notFound);
    }

    return await bestForAny(to: to);
  }

  /// Determines the best installation method for Android.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForAndroid({String to = 'install'}) async {
    final methods = package.methods ?? [];
    final hasMethod = methods.contains('termux');

    final defaults = package.defaults ?? [];
    final hasDefault = defaults.contains('termux');

    if (hasMethod || hasDefault) {
      final pkg = await Executable('pkg').find(); // termux

      if (pkg != null) {
        Global.updateCommand = '${Global.sudoPath} $pkg update || $errorOnUpdate';
        if (hasDefault) {
          return '${Global.sudoPath} $pkg $to -y ${package.name}';
        }
        return '${to}_android "${Global.sudoPath} $pkg -y"';
      }
    }

    stopIfForcedMethodNotFound();

    return await bestForAny(to: to);
  }

  /// Determines the best installation method for Windows.
  ///
  /// The [to] parameter is the installation target.
  Future<String> bestForWindows({String to = 'install'}) async {
    // @TODO add support for global update (if possible)

    final methods = package.methods ?? [];
    final hasMethod = methods.contains('choco');

    final defaults = package.defaults ?? [];
    final hasDefault = defaults.contains('choco');

    if (hasMethod || hasDefault) {
      final choco = await Executable('choco').find();
      final scoop = await Executable('scoop').find();

      late final String? bestWindows;

      if (choco != null) {
        bestWindows = '$choco -y';
        if (hasDefault) {
          return '$choco $to -y ${package.name}';
        }
      } else if (scoop != null) {
        // @TODO add support for hasDefault "scoop"
        bestWindows = '$scoop --yes';
      }

      if (bestWindows != null) {
        return '${to}_windows "$bestWindows"';
      }
    }

    stopIfForcedMethodNotFound();

    throw Exception('No package manager found for Windows');
  }

  /// Generates a script to install the package.
  ///
  /// The script is generated based on the current operating system and package manager.
  Future<String> toInstall() async {
    await boot();

    final bestFor = await best(to: 'install');

    final dynamicCode = await this.dynamicCode();

    final baseScriptContents = await this.baseScriptContents();

    final packageScriptContents = await packageScript.contents();

    String togetherContents = '''
#!/usr/bin/env bash

$dynamicCode

$baseScriptContents

$packageScriptContents

${Global.updateCommand}

$bestFor
''';

    final togetherFile = await writeThisBeast(togetherContents);

    return togetherFile.path;
  }

  /// Generates a script to remove the package.
  ///
  /// The script is generated based on the current operating system and package manager.
  Future<String> toRemove() async {
    await boot();

    final bestFor = await best(to: 'remove');

    final dynamicCode = await this.dynamicCode();

    final baseScriptContents = await this.baseScriptContents();

    final packageScriptContents = await packageScript.contents();

    String togetherContents = '''
#!/usr/bin/env bash

$dynamicCode

$baseScriptContents

$packageScriptContents

${Global.updateCommand}

$bestFor
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
      final firstProvidesExecutable = await Executable(firstProvides).find(cache: false);
      if (firstProvidesExecutable != null) {
        bestValidateExecutable = firstProvidesExecutable;
      }
    }
    if (bestValidateExecutable == null) {
      final String? nameExecutable = await Executable(packageName).find(cache: false);
      if (nameExecutable != null) {
        bestValidateExecutable = nameExecutable;
      }
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

  /// Generates the dynamic code that will be added to the script.
  ///
  /// This code includes information about the current environment, such as the
  /// path to the Dart executable, the architecture, and the channel.
  Future<String> dynamicCode() async {
    String executable = Platform.resolvedExecutable;

    if (Platform.script.path.endsWith('.dart') || executable.endsWith('/dart')) {
      // If we are running from a dart file or from a dart executable, add the
      // executable to the script.
      executable += ' ${Platform.script.path}';
    }

    String xOS = Platform.operatingSystem;
    bool isWindows = xOS == 'windows';
    bool isLinux = xOS == 'linux';
    bool isMacOS = xOS == 'macos';
    bool isAndroid = xOS == 'android';

    String xARCH = getArchitecture();
    String xCHANNEL = args!['channel'] ?? '';

    String xTMP = (await XPM.temp(packageName)).path;

    return '''
readonly XPM="$executable";
readonly xOS="$xOS";
readonly isWindows="$isWindows";
readonly isLinux="$isLinux";
readonly isMacOS="$isMacOS";
readonly isAndroid="$isAndroid";
readonly xARCH="$xARCH";
readonly xCHANNEL="$xCHANNEL";
readonly xBIN="${binDirectory().path}";
readonly xHOME="${XPM.userHome.path}";
readonly xTMP="$xTMP";
readonly xSUDO="${Global.sudoPath}";
readonly hasSnap="${Global.hasSnap}";
readonly hasFlatpak="${Global.hasFlatpak}";
''';
  }

  /// Returns the contents of the base script, if it exists.
  ///
  /// The base script is a script that is included with the package and can be
  /// used to customize the installation process.
  Future<String> baseScriptContents() async {
    if (!await baseScript.exists()) return '';

    return await baseScript.readAsString();
  }

  void stopIfForcedMethodNotFound() {
    if (forceMethod) {
      Logger.error('No method found for forced installation using $preferredMethod.', exitCode: notFound);
    }
  }
}
