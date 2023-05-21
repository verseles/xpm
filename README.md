# xpm - uniX Package Manager

## What is xpm?
XPM is a package manager for unix systems like Linux, BSD, MacOS, etc. It can be a wrapper for native package managers or a package manager itself by using its way of installing packages.

### Our key values

- Easy to install, update, remove and search (and filter)
- No questions asked, can run in a non-interactive way
- Easy to create new installers or a full repository
- Be agnostic, following unix standards and relying on very known tools
- Include many popular distros, and macOS
- Prefer native pm way and falls back to xpm way
  
## Installation

Just run the following command in your terminal:

```bash
curl -sL xpm.link | sh
```

## Usage
To search for a package:
```bash
xpm <package>
```
To install a package:
```bash
xpm i <package>
```
To remove a package:

```bash
xpm r <package>
```
> For all commands, run `xpm --help`
## How it works
XPM provides a set of tools to let community create their installers, or a group of installers (repository). The only requirement is to follow the [xpm spec](#xpm-specification). The spec is a set of bash functions that must be implemented in order to be a valid installer. The only required methods in the bash file is `validate` the others are optional but highly recommended: `install_any`, `remove_any`, `install_apt`, `install_pacman`, [etc](#xpm-specification).
## Architecture
XPM takes care of detecting the operating system and the package manager, and then it calls the installer. The installer is a bash script that follows the [xpm spec]. Before call the bash script, it provides important variables to the script, like the package manager available, xpm commands to let download files, move to binary system folder, change permissions, move, copy, delete files, and even create shortcuts. All of this without need to know or rely in the operating system.

XPM tries to use the native package manager way, but if it's not available, it will use its own way. For example, if you are using a debian based distro, and you want to install `micro` (an text editor in terminal), it will use `apt` to install it. But if you are using a distro that doesn't have `apt`, it will use `xpm` to install it. The same happens with `pacman` and `dnf`, and others. If you want to know more about how it works, you can read the [xpm spec](#xpm-specification).

## Contribute with installer scripts
We have a main repository with many popular installer scripts, but we need more. If you want to contribute with an installer script, you can make a PR to [xpm-popular](https://github.com/verseles/xpm-popular). The installer script are bash script. If you want to create a repository with your own installers, you can do it. Just follow the [xpm spec](#xpm-specification).

## Contribute to XPM
[![CI tests](https://github.com/verseles/xpm/actions/workflows/ci.yml/badge.svg)](https://github.com/verseles/xpm/actions/workflows/ci.yml)

We rely on dart lang. If you want to contribute, just follow good practices and make a PR. We will review it and merge it if it's ok.
Don't forget to run the tests before make a PR:
```bash
dart pub get && dart format --fix . && dart analyze && dart test
```
The binaries are automatically generated and published in the [releases](https://github.com/verseles/xpm/releases) page.

## License
Our code uses [BSD 4-Clause “Original” or “Old” License](LICENSE.md)

Dart SDK and his own packages are licensed under the [BSD 3-Clause "New" or "Revised" License](https://github.com/dart-lang/sdk/blob/main/LICENSE)

## XPM Specification
The xpm spec is a set of bash functions that must be implemented in order to be a valid installer. The only required methods in the bash file is `validate` the others are optional but highly recommended: `install_any`, `remove_any`, `install_apt`, `install_pacman`, and others see below.

The main house of the installer scripts are the repository [xpm-popular](https://github.com/verseles/xpm-popular). Every program has its own folder, and inside of it, there is a bash file that implements the xpm spec. For example, the [micro](https://github.com/verseles/xpm-popular/blob/main/micro/micro.bash) installer script. Optionally, the root directory of the repository can have a `base.bash` file with common code for all installers, its is included in every installer script.

Every script should follow the specs and be considered valid to be included in the repository. The specs are:

### Read-only variables
The following variables should be informed by the installer script, in the example below, the micro installer script:
```bash
# The name of the package
readonly xNAME="micro"
# The version of the package, important for updates
readonly xVERSION="2.0.11"
# A short friendly title of the package
readonly xTITLE="Micro Text Editor"
# A description of the package
readonly xDESC="A modern and intuitive terminal-based text editor"
# The url of the package (OPTIONAL)
readonly xURL="https://micro-editor.github.io"
# The architecture supported by the package
readonly xARCHS=('linux64' 'linux32' 'linux-arm' 'linux-arm64' 'macos-arm64' 'macos' 'win32' 'win64' 'freebsd64' 'freebsd32' 'openbsd64' 'openbsd32' 'netbsd64' 'netbsd32')
# The license of the package, can be an url or a initialisms like MIT, BSD, etc.
readonly xLICENSE="https://raw.githubusercontent.com/zyedidia/micro/v$xVERSION/LICENSE"
# The name(s) of the binary file(s) generated (OPTIONAL)
# If not informed, the xNAME variable will be used in validate() function
readonly xPROVIDES=("micro")

# If you inform here, there is no need to implement install_apt() and remove_apt(), the same for pacman, dnf, etc. Because xpm will use the xDEFAULT variable to call the most standard command to install. 
readonly xDEFAULT=('apt' 'pacman' 'dnf' 'choco' 'brew' 'termux')
```
### Variables available
The following variables are provided by xpm to the installer script, and are optional to use:

`$1` inside every function which starts with `install_` or `remove_`. 
Returns path to the package manager binary available (apt, pacman, dnf, xpm) it comes with some flags like -y and add sudo if available.

example:
```bash
install_apt() {
	$1 install $xNAME # with -y, with sudo if available
}
```

`$XPM`
Returns the path to the xpm binary.

`$xCHANNEL`
Returns the channel of the package, if it's a stable version, or a beta version, or a nightly version. Default is empty which means latest stable.

`$xARCH`
Returns the current architecture of the system. For example: `x86_64`, `arm64`, `arm`, etc.

`$xOS`
Returns the current operating system. For example: `linux`, `macos`, `windows`, `android`, etc.

`$xBIN`
Returns the binary folder of the system. For example: `/usr/bin`, `/usr/local/bin`, `/data/data/com.termux/files/usr/bin`, etc.

`$xHOME`
Returns the home folder of the system. For example: `/home/user`, `/data/data/com.termux/files/home`, `/Users/user`, `/root`, etc.

`$xTMP`
Returns the temporary folder of the system. For example: `/tmp`, `/data/data/com.termux/files/usr/tmp`, `/var/tmp`, etc.

`$xSUDO`
Returns the sudo command if available, otherwise returns empty.

`$hasSnap`
Returns `true` if the system has snap installed, otherwise returns `false`.

`$hasFlatpak`
Returns `true` if the system has flatpak installed, otherwise returns `false`.

`$hasAppImage`
Returns `true` if the system has appimage installed, otherwise returns `false`.

### Functions available
`validate()`
This function is required and must be implemented. It should validate if the package is installed or not. If the package is installed, it should return 0, otherwise, it should return non-zero.

The following functions can be used by the installer script, and are optional to use:

`install_any()` and `remove_any()`
These functions are called if no better option is available. It is the most techinical function because let you use anything to install/uninstall in any unix-like system and should not rely in any other package manager, only XPM and its commands available. We recommend to use well known unix tools like, `cp`, `mv`, `wget`, `curl`, `tar`, `gzip`, etc.

`install_apt()` and `remove_apt()`
These functions are called if the system has `apt` package manager installed. It should install/uninstall the package using apt. `$1` is the path to the `apt` (or similar) binary, and alread includes `-y` and `sudo` if available.

`install_pacman()` and `remove_pacman()`
Same as above, but for pacman/paru/yay.

`install_dnf()` and `remove_dnf()`
Same as above, but for dnf.

`install_brew()` and `remove_brew()`
Same as above, but for brew.

`install_choco()` and `remove_choco()`
Same as above, but for choco (or scoop).

`install_termux()` and `remove_termux()`
Same as above, but for termux.

`install_pack` and `remove_pack`
These functions are called if the system has `snap` or `flatpak` or `appimage` installed. It should install/uninstall the package using snap/flatpak/appimage. `$1` is the path to the snap/flatpak/appimage binary. You should check what is available in the system before using it. Example:
```bash
if [[ $hasFlatpak == true ]]; then 
    $1 uninstall $xNAME # with --assumeyes
    exit 1
elif [[ $hasAppImage == true ]]; then 
    rm -f $xHOME/.local/share/appimagekit/$xNAME
    exit 1
else
    $1 remove $xNAME # snap with --yes
fi
```

`install_zypper()` and `remove_zypper()`
Same as above, but for zypper. `$1` includes `--non-interactive`, with `sudo` if available.

`install_swupd()` and `remove_swupd()`
Same as above, but for swupd. `$1` with `sudo` if available. But NOT includes `-y` because it comes after `bundle-add`/`bundle-remove` command.

### XPM commands available
The commands available to use in the installer script by calling `$XPM <command>`. Below the list of commands available by calling `$XPM help`:

```
Universal package manager for any unix-like distro including macOS

Usage: xpm <command> [arguments]

Global options:
-h, --help       Print this usage information.
-v, --version    Prints the version of xpm.

Available commands:

For developers
  check      Checks the build.sh package file specified
  checksum   Check the checksum of a file
  file       File operations like copy, move, delete, make executable, etc.
  get        Download file from the internet
  log        Output info, warning, and error messages
  make       Makes a build.sh package file
  repo       Manage registered repositories
  shortcut   Create a shortcut on the system/desktop

For humans
  install    Install a package.
  refresh    Refresh the package list
  remove     Removes a package
  search     Search for a package
  upgrade    Upgrade one, many or all packages

Run "xpm help <command>" for more information about a command.
```
```
Download file from the internet

Usage: xpm get <url>
-h, --help                     Print this usage information.
-o, --out=<path>               Output file path with filename
-u, --user-agent=<<string>>    Identification of the software accessing the internet
    --no-user-agent            Disable user agent
-n, --name                     Define the name of the downloaded file without defining the path (only works without --out)
-x, --exec                     Make executable the downloaded file (unix only)
-b, --bin                      Install to bin folder of the system
    --no-progress              Disable progress bar
    --md5=<hash>               Check MD5 hash
    --sha1=<hash>              Check SHA1 hash
    --sha256=<hash>            Check SHA256 hash
    --sha512=<hash>            Check SHA512 hash
    --sha224=<hash>            Check SHA224 hash
    --sha384=<hash>            Check SHA384 hash
    --sha512-224=<hash>        Check SHA512/224 hash
    --sha512-256=<hash>        Check SHA512/256 hash
```
```
Output info, warning, and error messages
If the first argument is 'info', 'warning', 'error', or 'tip', the second argument will be output as that type of message. Otherwise, the arguments will be output as a log message.

Usage: xpm log [info|warning|error|tip] <message>
-h, --help    Print this usage information.
```
```
Create a shortcut on the system/desktop

Usage: xpm shortcut [arguments]
-h, --help                               Print this usage information.
-n, --name=<name> (mandatory)            Name of the application
-p, --path=<path>                        Path of the executable
-i, --icon=<name|path>                   Name or path of the icon
-d, --description=<description>          Description of the application
-c, --category=<category[,category2]>    Categories, multiple times or once using comma
-s, --[no-]sudo                          Run as sudo
                                         (defaults to on)
-r, --remove                             Remove shortcut
```
> As you can see, the commands available for developers are the same available for humans, but the commands for developers are more technical and can be used to create a package.

> $XPM returns dinamically the path to the xpm binary, so you can use it in your script.

### Full example for firefox browser
```bash
#!/usr/bin/env bash
# shellcheck disable=SC2034

readonly xNAME="firefox"
readonly xVERSION="113.0.1"
readonly xTITLE="Mozilla Firefox"
readonly xDESC="A free and open-source web browser developed by the Mozilla Foundation and its subsidiary, the Mozilla Corporation"
readonly xURL="https://www.mozilla.org/firefox"
readonly xARCHS=('linux64' 'linux32' 'linux-arm' 'linux-arm64' 'macos-arm64' 'macos' 'win32' 'win64' 'freebsd64' 'freebsd32' 'openbsd64' 'openbsd32' 'netbsd64' 'netbsd32')
readonly xLICENSE="MPL GPL LGPL"
readonly xPROVIDES=("firefox")

readonly xDEFAULT=('apt' 'pacman' 'dnf' 'choco' 'brew' 'termux')

validate() {
    $1 --version
}

install_any() {
    local file
    file="$($XPM get "http://archive.mozilla.org/pub/firefox/releases/$xVERSION/linux-x86_64/en-US/firefox-$xVERSION.tar.bz2" --no-progress --no-user-agent --name="$xNAME-$xVERSION.tar.bz2")"
    $xSUDO mkdir -p "/opt/$xNAME"
    $xSUDO tar xvf "$file" -C "/opt"
    $xSUDO ln -sf "/opt/$xNAME/$xNAME" "$xBIN/$xNAME"
    $XPM shortcut --name="$xNAME" --path="$xNAME" --icon="/opt/$xNAME/browser/chrome/icons/default/default128.png" --description="$xDESC" --category="Network"
}

remove_any() {
    $xSUDO rm -rf "/opt/$xNAME"
    $xSUDO rm -f "$xBIN/$xNAME"
    $XPM shortcut --remove --name="$xNAME"
}

install_zypper() { # $1 means [sudo] zypper -y install [package]
    $1 install mozillaFirefox
}

remove_zypper() { # $1 means [sudo] zypper -y remove [package]
    $1 remove mozillaFirefox
}
```
### Full example for micro text editor
```bash
#!/usr/bin/env bash
# shellcheck disable=SC2034

readonly xNAME="micro"
readonly xVERSION="2.0.11"
readonly xTITLE="Micro Text Editor"
readonly xDESC="A modern and intuitive terminal-based text editor"
readonly xURL="https://micro-editor.github.io"
readonly xARCHS=('linux64' 'linux32' 'linux-arm' 'linux-arm64' 'macos-arm64' 'macos' 'win32' 'win64' 'freebsd64' 'freebsd32' 'openbsd64' 'openbsd32' 'netbsd64' 'netbsd32')
readonly xLICENSE="https://raw.githubusercontent.com//v$xVERSION/LICENSE"
readonly xPROVIDES=("micro")

# Here you can inform if this package is well-known to some package manager and is installed using xNAME
# it is good for batch install and remove, when informed here, you can safely remove install_(PM here)
# and remove_(PM here) function. Example: readonly xDEFAULT='apt' let you remove install_apt and remove_apt
readonly xDEFAULT=('apt' 'pacman' 'dnf' 'choco' 'brew' 'termux')

# variables which is dinamically set and available for use
# $xCHANNEL
#  the default channel is empty, which means the latest stable version
#  user can change using -c or --channel flag
# $hasSnap, $hasFlatpak, $hasAppImage
#  these boolean variables are set to true if the package manager is available and selected
# $XPM is the path to xpm executable
# $xSUDO is the sudo command, if available. Most commands already add sudo if available
# $xBIN is the path to first bin folder on PATH.

# the only required function is validate. install_any and remove_any are very important, but not required.
validate() { # $1 is the path to executable from $xPROVIDES (if defined) or $xNAME
	$1 --version
}

install_any() {
	# shellcheck disable=SC1090
	sh "$($XPM get https://getmic.ro --exec --no-progress --no-user-agent)"
	$XPM file bin $xNAME --sudo --exec
}

remove_any() {
	$XPM file unbin $xNAME --sudo --force
}

# apt update will be called before install_apt and remove_apt
install_apt() {    # $1 means an executable compatible with apt (Debian, Ubuntu)
	$1 install $xNAME # with -y, with sudo if available
}

remove_apt() {    # $1 means apt compatible, with sudo if available
	$1 remove $xNAME # with -y, with sudo if available
}

# pacman -Syu will be called before install_pacman and remove_pacman
install_pacman() { # $1 means an executable compatible with pacman (Arch Linux)
	$1 -S $xNAME      # with --noconfirm, with sudo if available
}

remove_pacman() { # $1 means pacman compatible
	$1 -R $xNAME     # with --noconfirm, with sudo if available
}

# dnf update will be called before install_dnf and remove_dnf
install_dnf() {    # $1 means an executable compatible with dnf (Fedora)
	$1 install $xNAME # with -y, with sudo if available
}

remove_dnf() {       # $1 means dnf compatible with -y, with sudo if available
	$1 remove -y $xNAME # with -y, with sudo if available
}

# update commands will be called before install_pack and remove_pack
install_pack() { # $1 means an executable compatible with snap, flatpack or appimage
	# $hasSnap, $hasFlatpak, $hasAppImage are available as boolean
	# shellcheck disable=SC2154
	if [[ $hasFlatpak == true ]]; then # actually micro is not available on flatpack
		# $1 install $xNAME                   # with --assumeyes
		return 1
	elif [[ $hasAppImage == true ]]; then # actually micro is not available on appimage
		# $1 install $xNAME
		return 1
	else # snap
		$1 install $xNAME
	fi
}

remove_pack() {
	# $hasSnap, $hasFlatpak, $hasAppImage are available as boolean
	# shellcheck disable=SC2154
	if [[ $hasFlatpak == true ]]; then # actually micro is not available on flatpack
		# $1 uninstall $xNAME                 # with --assumeyes
		exit 1
	elif [[ $hasAppImage == true ]]; then # actually micro is not available on appimage
		# rm -f ~/.local/share/appimagekit/$xNAME
		exit 1
	else
		$1 remove $xNAME
	fi
}

# choco update will be called before install_choco and remove_choco
install_choco() { # $1 means an executable compatible  with chocolatey (Windows)
	$1 install $xNAME
}

remove_choco() { # $1 means choco compatible with -y
	$1 remove $xNAME
}

# brew update will be called before install_brew and remove_brew
install_brew() { # $1 means an executable compatible with brew (macOS)
	$1 install $xNAME
}

remove_brew() {
	$1 remove $xNAME
}

install_zypper() {          # $1 means an executable compatible with zypper (openSUSE) or zypper with -y
	$1 install "$xNAME-editor" # with --non-interactive, with sudo if available
}

remove_zypper() {          # $1 means zypper compatible with -y
	$1 remove "$xNAME-editor" # with --non-interactive, with sudo if available
}

install_termux() { # $1 means an executable compatible with pkg (Termux Android) with -y
	$1 install $xNAME # with -y, with sudo if available
}

remove_termux() { # $1 means pkg compatible with -y
	$1 remove $xNAME # with -y, with sudo if available
}

install_swupd() {       # $1 means an executable compatible with swupd (Clear Linux), with -y, with sudo if available
	$1 bundle-add go-basic # we don't really need go, but it's just an example
	install_any
}

remove_swupd() { # $1 means swupd compatible with -y, with sudo if available
	$1 bundle-remove --orphans
	remove_any
}
```
> This is a full example of a package installer script. It is the installer script of [micro](https://micro-editor.github.io), a terminal-based text editor.

> This script is available in the [xpm-popular](https://github.com/verseles/xpm-popular) repository, where you can find the installer script of the most popular packages. You can use it as a reference to create your own installer script. Keep in mind that if you informed the a package manager in the `xDEFAULT` variable (bash array), you can safely remove the `install_(PM)` and `remove_(PM)` functions.
