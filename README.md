# moje-skille

Marketplace pluginów Claude Code z moimi skillami.

| Plugin | Polecenie | Co robi |
|---|---|---|
| `przeglad-petla` | `/przeglad-petla [low\|medium\|high\|xhigh\|max] [gałąź] [--model=sonnet\|opus\|haiku\|fable\|sesja] [--poziom=sesja] [--max-rund=N] [--bez-testow]` | `/code-review` w pętli z weryfikacją zgłoszeń i poprawkami, aż runda nie da nowego ważnego zgłoszenia |
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

## Model i poziom do przeglądu

Działa tak samo w `/przeglad`, `/przeglad-fix` i `/przeglad-petla` (jedno wspólne ustawienie).

`--model=opus` (albo `sonnet`, `haiku`, `fable`) uruchamia sam przegląd na wskazanym modelu, a wybór zapisuje się
w `~/.claude/przeglad-petla/model` i obowiązuje domyślnie w kolejnych uruchomieniach, w każdym repo.
`--model=sesja` kasuje zapamiętany wybór (przegląd wraca na model bieżącej sesji). Weryfikacja zgłoszeń i poprawki
zawsze idą na modelu sesji.

Poziom działa tak samo: podany `low|medium|high|xhigh` zapisuje się w `~/.claude/przeglad-petla/poziom` i obowiązuje
domyślnie. Bez zapisanego poziomu `/code-review` bierze ostatnio użyty. `max` jest tylko na jedno uruchomienie
(nie zapisuje się), `--poziom=sesja` kasuje zapamiętany poziom.


## Globalna konfiguracja Claude Code (opcjonalna)

Repo zawiera także prywatny w zastosowaniu, ale publicznie wersjonowany zestaw ustawień globalnych:
- `config/CLAUDE.md` — workflow `opusplan`: Opus High planuje, Sonnet High implementuje, Opus Medium robi standardowe review na żądanie, a Opus High — review krytyczne. Haiku Explore zbiera fakty z codebase.
- `config/agents/Explore.md` — read-only Explore na modelu Haiku.
- `install.sh` — instalator symlinków do `~/.claude/`, z backupem istniejących plików. Przy pierwszej konfiguracji ustawia też preferencje review na Opus Medium, jeśli jeszcze ich nie ma.

Instalacja na Linuxie:

```bash
git clone https://github.com/kopolot/claude-skills.git ~/src/claude-skills
cd ~/src/claude-skills
bash install.sh
```

Jeżeli repo jest już sklonowane, wykonaj `git pull` i `bash install.sh`.

Instalator tworzy linki:
- `~/.claude/CLAUDE.md` -> `config/CLAUDE.md`
- `~/.claude/agents/Explore.md` -> `config/agents/Explore.md`

Zastane pliki/linki są przenoszone do katalogu `~/.claude/backups/claude-skills-...` przed instalacją. Instalator nie nadpisuje `settings.json`, nie zmienia effort głównej sesji, `opusplan` ani konfiguracji marketplace. Ustawia tylko brakujące pliki preferencji review na `opus` i `medium`; istniejące wybory pozostawia bez zmian. Uruchom go po przejrzeniu zawartości `config/` — globalne instrukcje mogą zastąpić wcześniejsze lokalne ustawienia `CLAUDE.md`.

Dla krytycznego review użyj np. `/przeglad high --model=opus` lub `/przeglad-petla high --model=opus`. **Uwaga:** zgodnie z zachowaniem tych skilli jawnie podany poziom `high` zostaje zapamiętany na przyszłość; aby wrócić do domyślnego Medium, wykonaj `/przeglad medium --model=opus` (lub użyj odpowiedniego wariantu pętli).

**Marketplace pozostaje niezależny:** nadal instaluj i aktualizuj skille przez `/plugin`, jak opisano wyżej. `bash install.sh` dotyczy tylko globalnych instrukcji i agenta, nie pluginów.

**Bezpieczeństwo:** nie dodawaj do repo sekretów, tokenów ani historii z `~/.claude/`; repo jest publiczne.
