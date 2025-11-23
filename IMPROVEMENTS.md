# Pontos de Melhoria - XPM

Este documento identifica oportunidades de melhoria no projeto XPM (Universal Package Manager).

---

## 1. Arquitetura e Design

### 1.1 Detector de Package Manager Incompleto
**Arquivo:** `lib/native_is_for_everyone/native_package_manager_detector.dart`

O detector atual só suporta APT e Pacman, mas o sistema declara suporte para DNF, Zypper, Brew, etc.

```dart
// Atual - apenas 2 gerenciadores
if (await Executable('apt').find() != null) return AptPackageManager();
if (await Executable('pacman').find() != null) return PacmanPackageManager();
return null;
```

**Sugestao:** Implementar adaptadores para outros gerenciadores declarados:
- DNF (Fedora)
- Zypper (openSUSE)
- Homebrew (macOS)
- Swupd (Clear Linux)

### 1.2 Estado Global Mutavel
**Arquivo:** `lib/global.dart`

O uso de variaveis globais mutaveis (`_hasSnap`, `_hasFlatpak`, `_sudoPath`) pode causar problemas de estado em cenarios concorrentes.

**Sugestao:** Converter para um singleton com estado imutavel ou usar um pattern de dependency injection.

### 1.3 Interface Abstrata Incompleta
**Arquivo:** `lib/native_is_for_everyone/native_package_manager.dart`

A interface `NativePackageManager` tem um parametro `a = true` sem proposito claro:

```dart
Future<void> install(String name, {bool a = true});
```

**Sugestao:** Remover parametros nao utilizados ou documentar seu proposito.

---

## 2. Qualidade de Codigo

### 2.1 Typo no Nome do Arquivo
**Arquivo:** `lib/os/get_archicteture.dart`

O nome do arquivo contem um erro de digitacao: `archicteture` deveria ser `architecture`.

### 2.2 Tratamento de Erros Inconsistente
**Arquivo:** `lib/commands/humans/install.dart`

O tratamento de erros varia entre diferentes partes do codigo:

```dart
// Algumas vezes usa leave()
leave(message: 'Package not found.', exitCode: cantExecute);

// Outras vezes apenas imprime o erro
Logger.error(error);
```

**Sugestao:** Padronizar o tratamento de erros em toda a aplicacao.

### 2.3 Funcoes Async sem Await
**Arquivo:** `lib/setting.dart`

Algumas operacoes de banco de dados nao usam `await` corretamente nas transacoes lazy:

```dart
// Linhas 24, 71, 95-97: Sem await dentro da transacao
db.writeTxn(() async => db.kVs.putByKey(data));
```

**Sugestao:** Garantir que todas as operacoes async sejam aguardadas corretamente.

### 2.4 Hard-coded Strings em Portugues
**Arquivo:** `lib/native_is_for_everyone/distro_managers/pacman.dart`

O parser de informacoes de pacote usa strings em portugues:

```dart
if (trimmedLine.startsWith('Nome                 :')) ...
if (trimmedLine.startsWith('Versao               :')) ...
if (trimmedLine.startsWith('Descricao            :')) ...
```

**Sugestao:** Usar parsing baseado em padroes ou suportar multiplos idiomas via locale do sistema.

---

## 3. Testes

### 3.1 Cobertura de Testes Limitada
O projeto tem 14 arquivos de teste, mas varios componentes importantes nao tem testes:
- `install.dart` - Comando principal, sem testes
- `search.dart` - Comando principal, sem testes
- `remove.dart` - Sem testes
- `upgrade.dart` - Sem testes
- `apt.dart` - Adaptador APT sem testes
- `db.dart` - Camada de banco de dados sem testes

**Sugestao:** Adicionar testes para os comandos principais e adaptadores.

### 3.2 Testes Dependentes de Ambiente
Varios testes dependem de executaveis do sistema (`git`, `bash`, `pacman`), tornando-os frageis em diferentes ambientes.

**Sugestao:** Usar mocks para dependencias externas ou melhorar a configuracao de skip para CI.

---

## 4. Seguranca

### 4.1 Execucao de Scripts sem Sandboxing
**Arquivo:** `lib/commands/humans/install.dart`

Scripts bash sao executados diretamente sem nenhum isolamento:

```dart
await runner.simple(bash, ['-c', 'source ${await prepare.toInstall()}']);
```

**Sugestao:** Considerar adicionar opcoes de sandboxing ou pelo menos validacao mais rigorosa dos scripts.

### 4.2 Injecao de Comando Potencial
**Arquivo:** `lib/os/run.dart`

O metodo `writeToFile` usa interpolacao de string diretamente no shell:

```dart
List<String> args = ['-c', 'echo "$text" > $filePath'];
```

**Sugestao:** Escapar caracteres especiais ou usar metodos alternativos que nao passem pelo shell.

---

## 5. Performance

### 5.1 Multiplas Checagens de Executaveis
**Arquivo:** `lib/native_is_for_everyone/distro_managers/pacman.dart`

O metodo `_getHelpersInPriority()` faz checagens redundantes que ja foram feitas em `_getBestHelper()`:

```dart
// Mesmas checagens feitas duas vezes
final paru = await Executable('paru').find();
final yay = await Executable('yay').find();
final pacman = await Executable('pacman').find();
```

**Sugestao:** Cachear os resultados ou unificar a logica de deteccao.

### 5.2 Banco de Dados Inicializado Multiplas Vezes
**Arquivo:** `lib/database/db.dart`

Cada chamada a `DB.instance()` verifica a existencia do arquivo core e pode tentar baixar novamente.

**Sugestao:** Usar um singleton verdadeiro com inicializacao unica.

---

## 6. UX/Usabilidade

### 6.1 Mensagens de Erro Pouco Informativas
Algumas mensagens de erro nao dao contexto suficiente:

```dart
leave(message: 'Package "{@gold}$packageRequested{@end}" not found.', exitCode: cantExecute);
```

**Sugestao:** Adicionar sugestoes como "Voce quis dizer...?" ou "Tente: xpm refresh".

### 6.2 Sem Confirmacao para Operacoes Destrutivas
O comando `remove` nao pede confirmacao antes de desinstalar, embora seja um valor chave do projeto ser nao-interativo.

**Sugestao:** Adicionar flag `--yes` obrigatoria ou `--dry-run` para preview.

### 6.3 Sem Comando de Info/Show
Nao existe um comando para mostrar detalhes de um pacote sem instala-lo (como `apt show` ou `pacman -Si`).

**Sugestao:** Adicionar comando `xpm info <package>`.

---

## 7. Documentacao

### 7.1 Docstrings Incompletas
Varios metodos publicos nao tem documentacao:

```dart
// Exemplo em pacman.dart
bool get _hasSudo => _bestHelper != null && !_bestHelper!.contains('yay')...
```

**Sugestao:** Adicionar documentacao para todos os metodos e propriedades publicas.

### 7.2 README com Informacoes Desatualizadas
O README menciona suporte "experimental" para Windows, mas nao ha implementacao clara desse suporte no codigo.

---

## 8. Manutencao

### 8.1 Dependencia do Isar
O Isar e um banco de dados embutido que requer download de bibliotecas nativas no primeiro uso. Isso pode ser problematico em ambientes offline ou com restricoes de rede.

**Sugestao:** Considerar alternativas como Hive (pure Dart) ou SQLite, ou embutir as bibliotecas nativas.

### 8.2 Versao Hard-coded
**Arquivo:** `lib/pubspec.dart`

A versao precisa ser mantida em sincronia com `pubspec.yaml` manualmente.

**Sugestao:** Usar geracao de codigo para extrair a versao automaticamente do pubspec.yaml durante o build.

### 8.3 Falta de CI/CD para Releases
Embora exista CI para testes, o processo de release parece manual.

**Sugestao:** Automatizar releases com semantic versioning e changelog automatico.

---

## 9. Funcionalidades Ausentes

### 9.1 Sem Suporte a Rollback
Nao ha mecanismo para reverter uma instalacao falha ou voltar a versao anterior.

### 9.2 Sem Cache de Downloads
Downloads de pacotes nao sao cacheados, resultando em re-downloads desnecessarios.

### 9.3 Sem Suporte a Dependencias
O sistema nao gerencia dependencias entre pacotes XPM.

### 9.4 Sem Verificacao de Assinatura
Scripts de instalacao nao sao verificados criptograficamente.

---

## 10. Codigo Duplicado

### 10.1 Logica de Ordenacao Duplicada
**Arquivos:** `lib/commands/humans/search.dart` e `lib/native_is_for_everyone/distro_managers/pacman.dart`

A logica de separar e ordenar pacotes AUR vs oficiais esta duplicada:

```dart
// Em search.dart
aurPackages.sort((a, b) => aPop.compareTo(bPop));

// Em pacman.dart
aurPackages.sort((a, b) => aPop.compareTo(bPop));
```

**Sugestao:** Extrair para um utilitario compartilhado.

---

## Resumo de Prioridades

| Prioridade | Categoria | Item |
|------------|-----------|------|
| Alta | Seguranca | Injecao de comando em writeToFile |
| Alta | Bug | Typo em nome de arquivo (archicteture) |
| Alta | Testes | Cobertura de comandos principais |
| Media | UX | Mensagens de erro informativas |
| Media | Feature | Comando `info` para detalhes de pacote |
| Media | Arquitetura | Implementar mais adaptadores nativos |
| Baixa | Performance | Cache de executaveis |
| Baixa | Manutencao | Automatizacao de releases |

---

*Documento gerado em: 2025-11-23*
