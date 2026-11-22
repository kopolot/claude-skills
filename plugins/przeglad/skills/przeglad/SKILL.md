---
name: przeglad
description: Jednorazowy przegląd kodu jak /code-review, ale z wyborem modelu, na którym działa przegląd (wybór zapamiętany jako domyślny). Tylko zgłasza błędy, niczego nie zmienia. Używaj, gdy ktoś prosi o „przegląd na opusie”, „code review innym modelem”, „/przeglad”.
argument-hint: "[low|medium|high|xhigh|max] [cel: PR#|gałąź|ścieżka] [--model=sonnet|opus|haiku|fable|sesja] [--poziom=sesja] [--once] [--comment|--max-findings <n>]"
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

## Jednorazowe nadpisanie ustawień (`--once`)

`--once` oznacza **tylko to wywołanie skilla**, bez zmiany zapisanych preferencji modelu i poziomu.
- Dotyczy zarówno jawnego poziomu (`high`, `medium` itd.), jak i `--model=X`.
- Przy `--model=sesja --once` lub `--poziom=sesja --once` użyj ustawień sesji **tylko teraz**, nie usuwając zapisanych plików.
- Jeśli nie podano jawnego modelu/poziomu, odczytaj zapisane ustawienie tak jak zwykle.
- `--once` jest flagą samego skilla: **nie przekazuj jej do `/code-review` ani do argumentów jego wywołania**.
- W `/przeglad-petla` wybrane tymczasowo ustawienia obowiązują we **wszystkich rundach tego jednego uruchomienia**.
- Zweryfikuj poprawność argumentów modelu i poziomu przed zapisem jakichkolwiek preferencji; nieznane wartości oznaczają stop bez modyfikacji plików.

## Model przeglądu

Ustawienie: `~/.claude/przeglad-petla/model` (jedna linia: `sonnet|opus|haiku|fable`; brak pliku = model sesji).
Wspólne dla `przeglad`, `przeglad-fix` i `przeglad-petla`, osobiste, we wszystkich repo.

1. `--model=X`, `X` ∈ `sonnet|opus|haiku|fable` → użyj `X` jako modelu tego przeglądu.
   - Bez `--once`: `mkdir -p ~/.claude/przeglad-petla && printf '%s\n' X > ~/.claude/przeglad-petla/model`; napisz, że wybór zapisano jako domyślny.
   - Z `--once`: **nie zapisuj** pliku; napisz, że to wybór jednorazowy.
2. `--model=sesja` → przegląd na modelu sesji (bez osobnego wyboru modelu).
   - Bez `--once`: `rm -f ~/.claude/przeglad-petla/model`.
   - Z `--once`: pomiń zapisany model **tylko dla tego przeglądu**, nie usuwaj pliku.
3. Inna wartość modelu → stop, wypisz dozwolone, nic nie zapisuj.
4. Bez `--model` → `cat ~/.claude/przeglad-petla/model 2>/dev/null`; pusty plik albo wartość spoza listy = model sesji (zgłoś brak prawidłowego ustawienia).
5. Poza tym skill nie zmienia modelu sesji ani żadnej konfiguracji Claude Code.

## Poziom przeglądu

Ustawienie: `~/.claude/przeglad-petla/poziom` (jedna linia: `low|medium|high|xhigh`; brak pliku = ostatnio użyty
w `/code-review`). Wspólne dla trzech skilli, osobiste, we wszystkich repo. Dotyczy tylko przeglądu;
weryfikacja zgłoszeń i poprawki idą na modelu sesji.

1. Podano poziom `X` ∈ `low|medium|high|xhigh` → użyj `X` teraz.
   - Bez `--once`: `mkdir -p ~/.claude/przeglad-petla && printf '%s\n' X > ~/.claude/przeglad-petla/poziom`; napisz, że zapisano.
   - Z `--once`: **nie zapisuj** pliku; poziom obowiązuje tylko przy tym wywołaniu.
2. Podano `max` → użyj tylko teraz i **nigdy nie zapisuj** (najdroższy poziom).
3. `--poziom=sesja` → nie wymuszaj poziomu w argumentach `/code-review` (niech weźmie ostatnio użyty).
   - Bez `--once`: `rm -f ~/.claude/przeglad-petla/poziom`.
   - Z `--once`: **nie usuwaj** pliku, zignoruj jego wartość tylko podczas tego wywołania.
4. Nie podano poziomu → `cat ~/.claude/przeglad-petla/poziom 2>/dev/null` i przekaż poprawną wartość wprost do `/code-review`.
   Pusty plik albo wartość spoza listy = bez poziomu (napisz o tym).
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
