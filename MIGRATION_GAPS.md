# Migration Gaps: Dart → Rust

> **Status**: ✅ **ALL GAPS ADDRESSED** - Implemented on 2026-01-04

Análise realizada em: 2026-01-04

## 🟢 Implementáveis AGORA (Branch Atual) ✅ COMPLETED

Tarefas que podem ser desenvolvidas e testadas imediatamente na branch de desenvolvimento Rust, sem risco de conflito ou necessidade de estar em produção.

### Alta Prioridade

#### 1. Sistema de Settings (`crates/xpm-core/src/settings.rs`)
**Status**: Ausente
**Impacto**: 🔴 Crítico
**Esforço**: Médio (2-3h)

**O que fazer**:
- Criar módulo `settings.rs` em `xpm-core`
- Interface similar ao Dart: `get()`, `set()`, `delete()`, `deleteExpired()`
- Cache em memória com `lazy_static` ou `once_cell`
- Serialização JSON para valores
- Suporte a expiration timestamps

**Dependências**: Nenhuma

---

#### 2. updateCommand nos Scripts de Instalação
**Status**: Ausente
**Impacto**: 🔴 Crítico
**Esforço**: Baixo (30min)

**O que fazer**:
- Em `crates/xpm-cli/src/commands/install.rs`, função `build_install_script()`
- Adicionar lógica para definir `UPDATE_COMMAND` baseado no método:
  - apt: `sudo apt update || echo "Update failed, continuing..."`
  - pacman: `sudo pacman -Sy || echo "Update failed, continuing..."`
  - dnf: `sudo dnf check-update || echo "Update failed, continuing..."`
  - etc.
- Injetar comando no script antes de `install_{method}`

**Dependências**: Nenhuma

---

#### 3. Auto-instalação de Git
**Status**: Ausente
**Impacto**: 🟡 Médio
**Esforço**: Baixo (1h)

**O que fazer**:
- Em `crates/xpm-core/src/repo/mod.rs` ou onde Git é usado
- Detectar se `git` está disponível
- Se não, tentar instalar via `pkcon install -y git` (se pkcon disponível)
- Fallback para mensagem de erro clara

**Dependências**: Nenhuma

---

### Média Prioridade

#### 4. Flags Adicionais no Search
**Status**: Parcialmente implementado
**Impacto**: 🟢 Baixo
**Esforço**: Baixo (30min)

**O que fazer**:
- Adicionar flags `--exact/-e` e `--all/-a` ao comando search
- Em `crates/xpm-cli/src/main.rs` e `commands/search.rs`

**Dependências**: Nenhuma

---

#### 5. Rastrear Pacotes Nativos no DB
**Status**: Ausente
**Impacto**: 🟡 Médio
**Esforço**: Baixo (1h)

**O que fazer**:
- Em `install_via_native_pm()` (install.rs:60-76)
- Após instalação bem-sucedida, criar entrada no DB:
  ```rust
  let pkg = Package::new(package)
      .with_version(native_pkg.version.unwrap_or("native".to_string()))
      .with_installed(true)
      .with_is_native(true);
  db.upsert_package(pkg)?;
  ```

**Dependências**: Nenhuma

---

#### 6. Comando Shortcut - Flags Avançadas
**Status**: Implementação básica
**Impacto**: 🟢 Baixo
**Esforço**: Médio (2h)

**O que fazer**:
- Adicionar flags ao `main.rs`:
  - `--terminal/-t`
  - `--type/-y`
  - `--mime/-m`
  - `--startup/-u`
  - `--sudo/-s`
  - `--remove/-r`
  - `--description/-d`
- Expandir `shortcut.rs` para gerar .desktop file completo

**Dependências**: Nenhuma

---

#### 7. Mapeamento de Arquitetura Legacy
**Status**: Parcialmente implementado
**Impacto**: 🟢 Baixo
**Esforço**: Baixo (30min)

**O que fazer**:
- Em `crates/xpm-core/src/os/arch.rs`
- Adicionar mapa de aliases:
  ```rust
  "linux64" => "linux-x86_64",
  "win64" => "windows-x86_64",
  "macos64" => "darwin-x86_64",
  // etc.
  ```

**Dependências**: Nenhuma

---

#### 8. Melhorar Feedback de Reinstalação
**Status**: Parcialmente implementado
**Impacto**: 🟢 Baixo
**Esforço**: Trivial (5min)

**O que fazer**:
- Em `install.rs`, linha 49-52
- Mudar mensagem de warning para:
  ```rust
  Logger::info(&format!("Reinstalling {}...", package));
  // Continuar com instalação ao invés de return
  ```

**Dependências**: Nenhuma

---

#### 9. Validação de Remoção (lógica invertida)
**Status**: Implementado mas incompleto
**Impacto**: 🟢 Baixo
**Esforço**: Baixo (30min)

**O que fazer**:
- Em `remove.rs`, adicionar lógica que:
  - Sucesso na validação após remoção = ERRO (pacote ainda existe)
  - Falha na validação após remoção = SUCESSO (pacote foi removido)

**Dependências**: Nenhuma

---

## 🔵 Implementar DEPOIS (Requer Main)

Tarefas que dependem de infraestrutura em produção, testes extensivos em múltiplos ambientes, ou que modificam comportamento core.

### Alta Prioridade

#### 10. Auto-verificação de Versão do XPM
**Status**: Ausente
**Impacto**: 🟡 Médio
**Esforço**: Médio (2h)

**Por que depois**:
- Requer Settings implementado (tarefa #1)
- Requer API/endpoint para verificar última versão
- Pode depender de GitHub Releases estar configurado corretamente
- Precisa de testes em ambiente real para validar frequência (4 dias)

**O que fazer**:
- Implementar `VersionChecker` em `utils/version.rs`
- Consultar GitHub API: `https://api.github.com/repos/verseles/xpm/releases/latest`
- Comparar com `VERSION` atual
- Cachear resultado por 4 dias usando Settings
- Exibir mensagem no startup se nova versão disponível

**Dependências**:
- [x] Tarefa #1 (Settings)
- [ ] GitHub Releases configurado
- [ ] Testes em produção

---

#### 11. Auto-refresh Inteligente de Repositórios
**Status**: Ausente
**Impacto**: 🟡 Médio
**Esforço**: Baixo (1h)

**Por que depois**:
- Requer Settings implementado (tarefa #1)
- Deve ser testado em produção para validar timing
- Pode impactar performance do primeiro comando

**O que fazer**:
- Em `main.rs`, antes de executar comandos:
  ```rust
  let needs_refresh = Settings::get("needs_refresh", true).await?;
  if needs_refresh {
      commands::refresh::run().await?;
      Settings::set("needs_refresh", false, Some(Duration::days(7))).await?;
  }
  ```

**Dependências**:
- [x] Tarefa #1 (Settings)
- [ ] Testes de performance em produção

---

## 📊 Resumo

| Categoria | Implementado | Deferred | Total |
|-----------|-------|--------|-------|
| 🔴 Crítico | 2 ✅ | 0 | 2 |
| 🟡 Médio | 3 ✅ | 2 | 5 |
| 🟢 Baixo | 4 ✅ | 0 | 4 |
| **Total** | **9 ✅** | **2** | **11** |

### Ordem Sugerida de Implementação (AGORA)

1. **#2 - updateCommand** (30min, crítico, zero risco)
2. **#1 - Settings** (2-3h, crítico, base para outras features)
3. **#3 - Git auto-install** (1h, médio, melhora DX)
4. **#5 - Rastrear nativos** (1h, médio, melhora tracking)
5. **#4 - Search flags** (30min, baixo, quick win)
6. **#8 - Feedback reinstall** (5min, baixo, trivial)
7. **#9 - Validação remove** (30min, baixo, correção)
8. **#7 - Arch aliases** (30min, baixo, compatibilidade)
9. **#6 - Shortcut avançado** (2h, baixo, feature completa)

**Total estimado**: ~9-10 horas de desenvolvimento

### Ordem Sugerida de Implementação (DEPOIS)

1. **#10 - Auto-update check** (após #1 + testes)
2. **#11 - Auto-refresh repos** (após #1 + testes)

---

## Notas

- Todas as tarefas "AGORA" são não-destrutivas (adições ou correções)
- Podem ser desenvolvidas em parallel se necessário
- Cada uma tem branch isolada recomendada
- Testes unitários devem acompanhar cada implementação
