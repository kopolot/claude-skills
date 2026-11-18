# moje-skille

Marketplace pluginów Claude Code z moimi skillami.

| Plugin | Polecenie | Co robi |
|---|---|---|
| `przeglad-petla` | `/przeglad-petla [low\|medium\|high\|xhigh\|max] [gałąź] [--max-rund=N] [--bez-testow]` | `/code-review` w pętli z weryfikacją zgłoszeń i poprawkami, aż runda nie da nowego ważnego zgłoszenia |

## Instalacja na komputerze

W Claude Code:

```
/plugin marketplace add <konto>/claude-skills
/plugin install przeglad-petla@moje-skille
```

Prywatne repo: Claude Code pobiera je przez gita, więc wystarczy działający `gh auth login` albo klucz SSH do GitHuba.
Aktualizacja po zmianach w repo: `/plugin marketplace update moje-skille`.

Bez pluginów (krótsza nazwa, bez aktualizacji przez `/plugin`):

```bash
git clone git@github.com:<konto>/claude-skills.git ~/src/claude-skills
ln -s ~/src/claude-skills/plugins/przeglad-petla/skills/przeglad-petla ~/.claude/skills/przeglad-petla
```

## Nakładka projektu

Skill jest ogólny. Zasady konkretnego repo (worktree, blokady, gdzie trzymać notatki z przeglądów, testy, tematy
zamknięte) opisujesz w `.claude/przeglad-petla.local.md` (osobiste, dopisz do `.git/info/exclude`)
albo `.claude/przeglad-petla.md` (wspólne, w repo). Przykład: `plugins/przeglad-petla/nakladka-przyklad.md`.
