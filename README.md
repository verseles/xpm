# xpm - uniX Package Manager

## What is xpm?
XPM is a package manager for unix systems like Linux, BSD, MacOS, etc. It can be a wrapper for native package managers or a package manager itself by using its way of installing packages.

### Our key values

- Easy to install, update, remove and search (and filter)
- No questions asked, can run in a non-interactive way
- Easy to create new installers or a full repository
- Be agnostic, following unix standards and relying on very known tools
- Include all popular distros, and macOS
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
XPM provides a set of tools to let community create their installers, or a group of installers (repository). The only requirement is to follow the [xpm spec](https://github.com/verseles/xpm-popular/blob/main/micro/micro.bash). The spec is a set of bash functions that must be implemented in order to be a valid installer. The required methods are: `install_any`, `remove_any`, `validate`. The rest are optional, but highly recommended. The others can be: `install_apt`, `install_pacman`, [etc](https://github.com/verseles/xpm-popular/blob/main/micro/micro.bash).
## Architecture
XPM takes care of detecting the operating system and the package manager, and then it calls the installer. The installer is a bash script that follows the [xpm spec]. Before call the bash script, it provides important variables to the script, like the package manager available, xpm commands to let download files, move to binary system folder, change permissions, move|copy|delete files, and even create shortcuts. All of this without need to know or rely in the operating system.

XPM tries to use the native package manager way, but if it's not available, it will use its own way. For example, if you are using a debian based distro, and you want to install `micro`, it will use `apt` to install it. But if you are using a distro that doesn't have `apt`, it will use `xpm` to install it. The same happens with `pacman` and `dnf`, etc. If you want to know more about how it works, you can read the [xpm spec](https://github.com/verseles/xpm-popular/blob/main/micro/micro.bash).
## Contribute with installers
We have a main repository with many popular installers, but we need more. If you want to contribute with an installer, you can make a PR to [xpm-popular](https://github.com/verseles/xpm-popular). If you want to create a repository with your own installers, you can do it. Just follow the [xpm spec](https://github.com/verseles/xpm-popular/blob/main/micro/micro.bash).
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

