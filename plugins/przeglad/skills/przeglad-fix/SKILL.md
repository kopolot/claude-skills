---
name: przeglad-fix
description: Jeden przegląd kodu z wyborem modelu (zapamiętywanym jako domyślny) i od razu poprawki ważnych zgłoszeń po samodzielnej weryfikacji w kodzie. Bez pętli, bez commita, bez pusha. Używaj, gdy ktoś prosi o „przegląd z poprawkami”, „review i napraw”, „/przeglad-fix”.
argument-hint: "[low|medium|high|xhigh|max] [cel: PR#|gałąź|ścieżka] [--model=sonnet|opus|haiku|fable|sesja] [--poziom=sesja] [--once] [--bez-testow]"
---

# Przegląd z poprawkami (jedna runda)

Argumenty: `$ARGUMENTS`
- **poziom**: `low|medium|high|xhigh|max`; podany jest zapamiętywany jako domyślny (patrz „Poziom przeglądu”; `max` nie),
  bez poziomu bierze się zapamiętany, a gdy go nie ma, `/code-review` bierze ostatnio użyty. `max` tylko, gdy podano
  wprost. `--poziom=sesja` kasuje zapamiętany wybór. `ultra` odrzucasz,
- **cel**: gałąź, numer PR albo ścieżka; bez celu bieżący diff. Poprawki idą do bieżącego checkoutu, więc cel inny
  niż bieżąca zmiana → zapytaj, zanim cokolwiek zmienisz,
- `--model=<sonnet|opus|haiku|fable|sesja>`: model **przeglądu**, patrz niżej. Weryfikacja i poprawki idą na modelu sesji,
- `--bez-testow`: bez uruchamiania testów po poprawkach.

Wywołanie to zgoda na poprawki **błędów** wskazanych przez przegląd. Nie jest zgodą na zmianę zachowania widocznego dla
użytkownika, commit, push, PR, squash ani rebase.

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

1. **Start.** Przeczytaj instrukcje repo (`CLAUDE.md`, `AGENTS.md`, `CLAUDE.local.md`, jeśli są). `git status`: cudze,
   niezwiązane zmiany w plikach, które miałyby być poprawiane → pytaj, nie nadpisuj.
2. **Przegląd.** Poziom ustalony wyżej, jeśli jest, przekaż wprost. Bez modelu: Skill `code-review` z `<poziom> <cel>`. Z modelem: Agent z `model: "<model>"` (bez
   `isolation`), prompt: wywołaj Skill `code-review` z `<poziom> <cel>` i zwróć **tekstem** pełną listę zgłoszeń
   (plik:linia, opis, scenariusz awarii, werdykt, poziom); niczego nie poprawiaj, nie commituj, nie pisz do plików.
   Bez `--fix`, `--comment`, `--post`.
3. **Weryfikacja każdego zgłoszenia samodzielnie, w kodzie.** Prześledź wywołania, dane wejściowe i istniejące
   zabezpieczenia; werdykt przeglądu to wskazówka, nie dowód. Jedna klasa na zgłoszenie:

   | Klasa | Kiedy | Co robisz |
   |---|---|---|
   | **ważne** | potwierdzony błąd poprawności, bezpieczeństwa, utraty/zepsucia danych, awaria na realnej ścieżce, złamana zasada repo wywalająca CI | poprawiasz |
   | **do decyzji** | potwierdzone, ale naprawa zmienia zachowanie widoczne dla użytkownika, zakres, uprawnienia, schemat bazy albo wymaga wyboru kierunku | nie poprawiasz; do raportu z propozycją |
   | **drobne** | kosmetyka, nazewnictwo, wydajność bez skutku, opinia o architekturze, brak testu przypadku bez błędu | bez zmian |
   | **fałszywe** | scenariusz nie zachodzi albo jest obsłużony | bez zmian, z powodem |

4. **Poprawki ważnych.** Styl edytowanego pliku, zasady repo. Zmiana zachowania opisanego testem → popraw test;
   tania asercja na naprawiony błąd → dopisz. Po edycji kontrole, które repo ma tanie i lokalne (składnia, linter,
   typy dla zmienionych plików), a bez `--bez-testow` także szybkie testy obszaru zmian, jeśli repo je ma.
   Czerwone przez twoją poprawkę → napraw; nie da się → cofnij tę poprawkę i opisz w raporcie.
5. **Bez commita i pusha.** Zmiany zostają w working tree do przejrzenia (`git diff`).
6. **Raport**, krótko:
   - model i poziom przeglądu (zapamiętane teraz czy z ustawienia), cel,
   - poprawione (plik:linia, jedno zdanie co i dlaczego),
   - **do decyzji** (jedno zdanie + propozycja kierunku),
   - drobne i fałszywe: sama liczba i powody fałszywych,
   - wynik kontroli i testów albo że ich nie było,
   - że nic nie zostało zacommitowane ani wypchnięte. Po jednej rundzie mogą wyjść nowe błędy;
     do zbiegu użyj `/przeglad-petla`.
