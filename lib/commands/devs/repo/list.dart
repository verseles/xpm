import 'package:args/command_runner.dart';
import 'package:xpm/os/repositories.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

class ListCommand extends Command {
  @override
  final name = "list";
  @override
  final aliases = ['l', 'ls'];
  @override
  final description = "List all repositories";

  ListCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    out("{@green}List of repositories:{@end}");
    final reposList = await Repositories.allRepos();
    print(reposList[0].url);
  }
}


// 1. Duplica o lib/commands/devs/repo/add.dart para lib/commands/devs/repo/list.dart
// 2. Ajusta lib/commands/devs/repo/list.dart com os nomes corretos.
// 3. Adiciona a função correta em lib/commands/devs/repo/repo.dart
// 4. No arquivo lib/commands/devs/repo/list.dart você deve colocar na função run(), a listagem dos repositórios cadastrados. Você consegue isso com o Repositories.AllRepos(), só precisa fazer um forEach e listar bonitinho.