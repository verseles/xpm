# Migration Guide - XPM v1.0.0

Este guia detalha todas as mudanças da versão 0.83.0 para 1.0.0 e como migrar seu código.

---

## Breaking Changes

### 1. Interface `NativePackageManager.install()` alterada

**Antes (v0.83.0):**
```dart
Future<void> install(String name, {bool a = true});
```

**Depois (v1.0.0):**
```dart
Future<void> install(String name);
```

**Como migrar:**
Se você implementou a interface `NativePackageManager`, remova o parâmetro `{bool a = true}` do método `install`:

```dart
// Antes
class MyPackageManager extends NativePackageManager {
  @override
  Future<void> install(String name, {bool a = true}) async {
    // ...
  }
}

// Depois
class MyPackageManager extends NativePackageManager {
  @override
  Future<void> install(String name) async {
    // ...
  }
}
```

### 2. Arquivo renomeado: `get_archicteture.dart` → `get_architecture.dart`

**Antes (v0.83.0):**
```dart
import 'package:xpm/os/get_archicteture.dart';
```

**Depois (v1.0.0):**
```dart
import 'package:xpm/os/get_architecture.dart';
```

**Como migrar:**
Atualize todos os imports que referenciam o arquivo antigo.

---

## Novas Funcionalidades

### 1. Novos Adaptadores de Package Manager

Agora o XPM detecta e suporta automaticamente:

| Sistema | Gerenciador | Arquivo |
|---------|-------------|---------|
| Fedora/RHEL | DNF | `lib/native_is_for_everyone/distro_managers/dnf.dart` |
| openSUSE/SLES | Zypper | `lib/native_is_for_everyone/distro_managers/zypper.dart` |
| macOS | Homebrew | `lib/native_is_for_everyone/distro_managers/homebrew.dart` |

**Uso:**
```dart
import 'package:xpm/native_is_for_everyone/native_package_manager_detector.dart';

final manager = await NativePackageManagerDetector.detect();
// Retorna automaticamente o adaptador correto para o sistema
```

### 2. Novo Comando `xpm info`

Mostra informações detalhadas sobre um pacote:

```bash
xpm info <package>
xpm show <package>    # alias
xpm details <package> # alias
xpm i <package>       # alias (atenção: conflita com install se não houver argumento)
```

**Flags:**
- `--native` / `--no-native`: Controla se deve consultar o gerenciador nativo (default: true)

### 3. Helper para Mensagens de Erro

Novo utilitário para criar mensagens de erro informativas:

```dart
import 'package:xpm/utils/error_helper.dart';

// Mostra erro com sugestões de pacotes similares
await ErrorHelper.packageNotFound('vim');

// Mostra erro de instalação com dicas
ErrorHelper.installationFailed('package', 'detalhes do erro');

// Mostra erro genérico com sugestões customizadas
ErrorHelper.showError('Algo deu errado', suggestions: [
  'Tente isso',
  'Ou aquilo',
]);
```

### 4. Método `NativePackage.sortForDisplay()`

Ordena pacotes para exibição no terminal:

```dart
import 'package:xpm/native_is_for_everyone/models/native_package.dart';

final packages = [...]; // Lista de NativePackage
final sorted = NativePackage.sortForDisplay(packages);
// Retorna: AUR (por popularidade) → extra/chaotic → outros oficiais
```

### 5. Propriedades auxiliares em `NativePackage`

```dart
final package = NativePackage(name: 'pkg', repo: 'aur');

package.isAur;      // true se repo == 'aur'
package.isOfficial; // true se repo é extra, core, community, ou chaotic-aur
```

---

## Melhorias de Segurança

### 1. Correção de Injeção de Comando

**Antes (VULNERÁVEL):**
```dart
// lib/os/run.dart - writeToFile
List<String> args = ['-c', 'echo "$text" > $filePath'];
final result = await simple('sh', args, sudo: sudo);
```

**Depois (SEGURO):**
```dart
// Usa Process.start com stdin para evitar interpolação no shell
final process = await Process.start('sudo', ['tee', filePath]);
process.stdin.write(text);
await process.stdin.close();
```

---

## Melhorias de Internacionalização

### Parser do Pacman Multi-idioma

O parser de informações do pacman agora suporta múltiplos idiomas:

- Inglês (Name, Version, Description, Architecture)
- Português (Nome, Versão, Descrição, Arquitetura)
- Espanhol (Nombre, Versión, Descripción, Arquitectura)
- Alemão (Name, Version, Beschreibung, Architektur)

---

## Infraestrutura de Testes

### Novos Arquivos de Teste

| Arquivo | Descrição |
|---------|-----------|
| `test/apt_test.dart` | Testes para adaptador APT |
| `test/dnf_test.dart` | Testes para adaptador DNF |
| `test/zypper_test.dart` | Testes para adaptador Zypper |
| `test/homebrew_test.dart` | Testes para adaptador Homebrew |
| `test/native_package_test.dart` | Testes para modelo NativePackage |
| `test/db_test.dart` | Testes para camada de banco de dados |

### Docker Compose para Testes Multi-Sistema

```bash
# Executar testes em todas as plataformas
make test-all

# Executar em plataforma específica
make test-ubuntu
make test-fedora
make test-arch
make test-opensuse

# Gerar relatório de cobertura
make coverage
```

### Arquivos Docker Adicionados

- `docker-compose.yml`
- `docker/test/Dockerfile.ubuntu`
- `docker/test/Dockerfile.fedora`
- `docker/test/Dockerfile.arch`
- `docker/test/Dockerfile.opensuse`

---

## Troubleshooting

### Testes Falhando Localmente

1. **Erro: `dart: command not found`**
   ```bash
   # Verifique se o Dart SDK está instalado e no PATH
   which dart
   dart --version
   ```

2. **Erro: Isar core not found**
   ```bash
   # O Isar precisa baixar bibliotecas nativas no primeiro uso
   # Verifique sua conexão com a internet
   dart pub get
   ```

3. **Testes de adaptadores falhando**
   ```bash
   # Os testes de adaptadores requerem o gerenciador instalado
   # Use a tag skip-ci para pular em CI:
   dart test --exclude-tags=skip-ci
   ```

### Testes Falhando no Docker/Podman

1. **Erro: Cannot connect to Docker daemon**
   ```bash
   # Verifique se o daemon está rodando
   systemctl status docker
   # ou para Podman
   systemctl status podman
   ```

2. **Erro: Permission denied**
   ```bash
   # Adicione seu usuário ao grupo docker
   sudo usermod -aG docker $USER
   # Ou use podman (não requer root)
   ```

3. **Erro: Image build failed**
   ```bash
   # Limpe cache e reconstrua
   docker-compose build --no-cache
   ```

### Executando Testes Passo a Passo

```bash
# 1. Instalar dependências
dart pub get

# 2. Gerar código (Isar schemas)
dart run build_runner build

# 3. Executar todos os testes
dart test

# 4. Executar teste específico
dart test test/native_package_test.dart

# 5. Executar com verbose
dart test --reporter=expanded

# 6. Executar sem testes que requerem sistema específico
dart test --exclude-tags=skip-ci
```

---

## Checklist de Migração

- [ ] Atualizar imports de `get_archicteture.dart` para `get_architecture.dart`
- [ ] Remover parâmetro `{bool a = true}` de implementações de `NativePackageManager.install()`
- [ ] Testar funcionalidade com `dart test`
- [ ] Verificar se novos adaptadores detectam corretamente seu sistema
- [ ] Testar novo comando `xpm info`

---

## Suporte

- **Issues:** https://github.com/verseles/xpm/issues
- **Documentação:** https://xpm.link

---

*Versão: 1.0.0*
*Data: 2025-11-23*
