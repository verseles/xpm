## v0.76.0
- feat: native package manager
## v0.75.0
- update to latest dart stable version
## v0.74.0
- lock update
## v0.73.0
- lock update
## v0.69.0
- add support for 'any' on ARCH, fixex #106
## v0.68.0
- small fixes
## v0.67.0
- small fix for flatpak
## v0.66.0
- small fix for flatpak
## v0.65.0
- small fix for flatpak
## v0.64.0
- small fix for flatpak
## v0.63.0
- small fix for flatpak
## v0.62.0
- small fix
## v0.61.0
- move decisions do findBest instead bestForAny
## v0.60.0
- comment out unused Global.updateCommand and add a FIXME note about the missing update command for swupd only upgrade
## v0.59.0
- Better normalization of architeture function
## v0.58.0
- Small changes
## v0.57.0
- feat(prepare.dart): add support for  parameter to skip installation methods in  method
## v0.56.0
- Many fixes
## v0.55.0
- Full support for Linux shortcuts
## v0.54.0
- Fix #63 - check for updates on repos and of xpm itself
## v0.53.0
- Fix use of best method, preferred method and forced method
## v0.52.0
- Fix get command when moving to bin
## v0.51.0
- Separate Flatpak, Snap and AppImage functions and adjusts others files to this change. fix #103
## v0.50.0
- completely removed appimage weird support and updated readme. fix #97
## v0.49.0
- fix support for macos
## v0.48.0
- fix support for macos x86_64
## v0.47.0
- enable macos build
## v0.46.0
- fix: terminate sharedStdIn after database write in install.dart and remove.dart commands to prevent hanging processes
## v0.45.0
- Fix problems with validation of remove
## v0.44.0
- Fix problems with validation of remove
## v0.43.0
- Fix problems with pack method
## v0.42.0
- Prioritize flatpak over appimage and snap
## v0.41.0
- Fixed support for distros like opensuse
## v0.40.0
- Implemented -f --force option to force removal of apps
## v0.39.0
- Added -f --force option to force removal of apps
## v0.38.0
- Catching trivial errors on bash
## v0.37.0
- Testing new build release system
## v0.36.1
- Testing new build release system
## v0.36.0
- Testing new build release system
## v0.35.0
- Testing new build release system
## v0.34.0
- better error messages when forced method not found
## v0.33.0
- add support for sudo when using pacman package manager in bestForArch method; working update command
## v0.32.0
- change Y variable to X; no more auto sudo for methods of install and remove
## v0.31.0
- fix apt bug hasDefault
## v0.28.0
- refactor(get.dart): comment out unused adapter instances and change the declaration of adapter to be late-initialized
## v0.27.0
- Many fixes
## v0.26.0
- fixes
## v0.25.0
- pub fix and upgrade
## v0.24.0
- build fix
## v0.23.0
- some minor updates
## v0.22.0
- Now we support xDEFAULT variable on bash
## v0.21.1
- Better line length
## v0.21.0
- Fix: fallsback to any if the best method does not exist in the package script
## v0.20.0
- fix tests
## v0.19.0
- fixes
## v0.18.1
- upgrade dependencies
## v0.18.0
- update checker
## v0.17.0
- zypper fix, auto refresh every 3 days and many other fixes
## v0.16.0
- more fixes about sudo usage
## v0.15.0
- more fixes about sudo usage
## v0.14.0
- more fixes about sudo usage
## v0.13.0
- some fixes about sudo usage
## v0.12.0
- some fixes and new xpm search --all or 'xpm s -a'
## v0.10.2
- some fix and support for architectures
## v0.10.0
- some fixes
## v0.8.0
- better support for platform arch
## v0.7.0
- Fix #52
## v0.6.0
- Fix #51
## v0.4.0
- xpm get --user-agent available
## v0.3.3
- finished first great installer.bash
## v0.3.1
- testing release arch on windows
## v0.3.0
- testing release binaries with gzip and arch
## v0.2.4
- testing release binaries with gzip and arch
## v0.2.3
- testing release binaries with gzip and arch
## v0.2.2
- testing release binaries with gzip
## v0.2.0
- testing release binaries
## v0.1.8
- testing release binaries
## v0.1.7
- testing release binaries
## v0.1.5
- testing release binaries
## v0.1.4
- testing release binaries
## v0.1.3
- ci:testing pre-release binaries
## v0.1.2
- ci:testing pre-release binaries
## v0.1.1
- ci:testing pre-release binaries
## v0.1.0
- ci:testing pre-release binaries
## v0.0.33
- fix: new adjustments to reflect #23
## v0.0.32
- fix: show 'reinstalling' when reinstalling
## v0.0.31
- fix: many fixes
## v0.0.30
- fix: many fixes
## v0.0.29
- many new commands to manage files and install bin
## v0.0.28
- small changes in logger
## v0.0.27
- Small adjustment for leave function
## v0.0.26
- Make logger class output to strerr to avoid conflicts with stdout
## v0.0.25
- Small fixes (I can't remember)
## v0.0.23
- Fix get command
## v0.0.22
- Added support for installation from dart pub global activate
## v0.0.21
- Add moveToBin method
## v0.0.20
- Add tests for Logger
## v0.0.19
- Fix #33 and set search command as default
## v0.0.18
- hotfix
## v0.0.17
- wrong db path saving
## v0.0.16
- pub upgrade
## v0.0.15
- upgrade and clean pub version
## v0.0.14
- better version output
## v0.0.13
- applying new pubspec.dart location
## v0.0.12
- preparing to use dpp
## v0.0.11
- Fix #34 Checksum: class, command and tests
## v0.0.10
- Shortcut class tests
## v0.0.9
- Fix #28
## v0.0.8
- bigger pub.dev description
## v0.0.7
- Renamed LICENSE.md to LICENSE
## v0.0.6
- Fix #28
## 0.0.1
- Initial version.
