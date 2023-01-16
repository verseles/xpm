import 'package:xpm/os/bash_script.dart';

void main(List<String> args) async {
  final bashScript =
      BashScript('/home/helio/sync/WORK/xpm-popular/micro/micro.bash');
  Map<String, String?>? variables = await bashScript.variables();
  print(variables);

}
