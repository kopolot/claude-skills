# moje-skille

Marketplace pluginów Claude Code z moimi skillami.

| Plugin | Polecenie | Co robi |
|---|---|---|
| `przeglad-petla` | `/przeglad-petla [low\|medium\|high\|xhigh\|max] [gałąź] [--model=sonnet\|opus\|haiku\|fable\|sesja] [--max-rund=N] [--bez-testow]` | `/code-review` w pętli z weryfikacją zgłoszeń i poprawkami, aż runda nie da nowego ważnego zgłoszenia |
| `przeglad` | `/przeglad [poziom] [cel] [--model=...]` | jednorazowy `/code-review` z wyborem modelu przeglądu, tylko zgłasza |
| `przeglad` | `/przeglad-fix [poziom] [cel] [--model=...] [--bez-testow]` | jeden przegląd z wyborem modelu i od razu poprawki ważnych (bez commita) |

## Instalacja na komputerze

W Claude Code:

```
/plugin marketplace add kopolot/claude-skills
/plugin install przeglad-petla@moje-skille
/plugin install przeglad@moje-skille
```

Repo jest publiczne, więc instalacja nie wymaga logowania do GitHuba.
Aktualizacja po zmianach w repo: `/plugin marketplace update moje-skille`.

Bez pluginów (krótsza nazwa, bez aktualizacji przez `/plugin`):

```bash
git clone git@github.com:kopolot/claude-skills.git ~/src/claude-skills
ln -s ~/src/claude-skills/plugins/przeglad-petla/skills/przeglad-petla ~/.claude/skills/przeglad-petla
```

## Nakładka projektu

Skill jest ogólny. Zasady konkretnego repo (worktree, blokady, gdzie trzymać notatki z przeglądów, testy, tematy
zamknięte) opisujesz w `.claude/przeglad-petla.local.md` (osobiste, dopisz do `.git/info/exclude`)
albo `.claude/przeglad-petla.md` (wspólne, w repo). Przykład: `plugins/przeglad-petla/nakladka-przyklad.md`.

## Model do przeglądu

Działa tak samo w `/przeglad`, `/przeglad-fix` i `/przeglad-petla` (jedno wspólne ustawienie).

`--model=opus` (albo `sonnet`, `haiku`, `fable`) uruchamia sam przegląd na wskazanym modelu, a wybór zapisuje się
w `~/.claude/przeglad-petla/model` i obowiązuje domyślnie w kolejnych uruchomieniach, w każdym repo.
`--model=sesja` kasuje zapamiętany wybór (przegląd wraca na model bieżącej sesji). Weryfikacja zgłoszeń i poprawki
zawsze idą na modelu sesji.
