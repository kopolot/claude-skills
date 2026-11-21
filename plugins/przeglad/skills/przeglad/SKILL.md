---
name: przeglad
description: Jednorazowy przegląd kodu jak /code-review, ale z wyborem modelu, na którym działa przegląd (wybór zapamiętany jako domyślny). Tylko zgłasza błędy, niczego nie zmienia. Używaj, gdy ktoś prosi o „przegląd na opusie”, „code review innym modelem”, „/przeglad”.
argument-hint: "[low|medium|high|xhigh|max] [cel: PR#|gałąź|ścieżka] [--model=sonnet|opus|haiku|fable|sesja] [--poziom=sesja] [--comment|--max-findings <n>]"
---

# Przegląd z wyborem modelu

Argumenty: `$ARGUMENTS`
- **poziom**: `low|medium|high|xhigh|max`; podany jest zapamiętywany jako domyślny (patrz „Poziom przeglądu”; `max` nie),
  bez poziomu bierze się zapamiętany, a gdy go nie ma, `/code-review` bierze ostatnio użyty. `max` tylko, gdy podano
  wprost. `--poziom=sesja` kasuje zapamiętany wybór. `ultra` odrzucasz (przegląd w chmurze, płatny, uruchamia go tylko człowiek),
- **cel**: numer PR, gałąź albo ścieżka; bez celu bieżący diff,
- `--model=<sonnet|opus|haiku|fable|sesja>`: model przeglądu, patrz niżej,
- pozostałe flagi (`--comment`, `--max-findings <n>`) przekazujesz do `/code-review` bez zmian. Same z siebie ich nie
  dodajesz: `--comment` publikuje komentarze w PR, więc tylko na wyraźne życzenie. Bez `--fix` (od tego jest `/przeglad-fix`).

## Model przeglądu

Ustawienie: `~/.claude/przeglad-petla/model` (jedna linia: `sonnet|opus|haiku|fable`; brak pliku = model sesji).
Wspólne z pluginem `przeglad-petla`, osobiste, we wszystkich repo.

1. `--model=X`, `X` ∈ `sonnet|opus|haiku|fable` → `mkdir -p ~/.claude/przeglad-petla && printf '%s\n' X > ~/.claude/przeglad-petla/model`;
   użyj `X` teraz i napisz, że zapamiętano go jako domyślny.
2. `--model=sesja` → `rm -f ~/.claude/przeglad-petla/model`, przegląd na modelu sesji.
3. Inna wartość → stop, wypisz dozwolone, nic nie zapisuj.
4. Bez `--model` → `cat ~/.claude/przeglad-petla/model 2>/dev/null`. Pusty plik albo wartość spoza listy = brak ustawienia
   (napisz o tym).
5. Poza tym skill nie zmienia modelu sesji ani żadnej konfiguracji Claude Code.

## Poziom przeglądu

Ustawienie: `~/.claude/przeglad-petla/poziom` (jedna linia: `low|medium|high|xhigh`; brak pliku = ostatnio użyty
w `/code-review`). Wspólne z pozostałymi pluginami, osobiste, we wszystkich repo. Dotyczy tylko przeglądu;
poprawki i weryfikacja nie mają poziomu.

1. Podano poziom `X` ∈ `low|medium|high|xhigh` → `mkdir -p ~/.claude/przeglad-petla && printf '%s\n' X > ~/.claude/przeglad-petla/poziom`;
   użyj `X` teraz i napisz, że zapamiętano go jako domyślny.
2. Podano `max` → użyj go w tym uruchomieniu, **nie zapisuj** (najdroższy poziom, tylko na wyraźne życzenie za każdym razem).
3. `--poziom=sesja` → `rm -f ~/.claude/przeglad-petla/poziom`, bez poziomu (`/code-review` weźmie ostatnio użyty).
4. Nie podano nic → `cat ~/.claude/przeglad-petla/poziom 2>/dev/null` i przekaż odczytany poziom do `/code-review` wprost.
   Pusty plik albo wartość spoza listy = brak ustawienia (napisz o tym).
5. `ultra` odrzucasz. Poza tym skill nie zmienia żadnej konfiguracji Claude Code.

## Działanie

1. Ustal model i poziom przeglądu (wyżej).
2. **Brak modelu** → wywołaj Skill `code-review` z argumentami `<poziom> <cel> <przekazane flagi>` i oddaj wynik.
3. **Jest model** → uruchom Agent z `model: "<model>"` (bez `isolation`, ten sam checkout). Prompt: wywołaj Skill
   `code-review` z tymi argumentami i zwróć **tekstem** pełną listę zgłoszeń (plik:linia, opis, scenariusz awarii,
   werdykt, poziom); niczego nie poprawiaj, nie commituj, nie pisz do plików. Jeśli przekazano `--comment`, subagent
   publikuje komentarze sam, bo to część przeglądu.
4. Odpowiedź: model i poziom przeglądu, cel, zgłoszenia od najpoważniejszego (plik:linia, opis, scenariusz).
   Zgłoszeń z subagenta nie weryfikujesz i nie przerabiasz, to surowy wynik przeglądu wskazanego modelu.
   Jeśli użytkownik chce poprawek, wskaż `/przeglad-fix`.
