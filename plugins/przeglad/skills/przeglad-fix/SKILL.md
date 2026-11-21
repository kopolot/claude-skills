---
name: przeglad-fix
description: Jeden przegląd kodu z wyborem modelu (zapamiętywanym jako domyślny) i od razu poprawki ważnych zgłoszeń po samodzielnej weryfikacji w kodzie. Bez pętli, bez commita, bez pusha. Używaj, gdy ktoś prosi o „przegląd z poprawkami”, „review i napraw”, „/przeglad-fix”.
argument-hint: "[low|medium|high|xhigh|max] [cel: PR#|gałąź|ścieżka] [--model=sonnet|opus|haiku|fable|sesja] [--bez-testow]"
---

# Przegląd z poprawkami (jedna runda)

Argumenty: `$ARGUMENTS`
- **poziom**: `low|medium|high|xhigh|max`; bez poziomu `/code-review` bierze ostatnio użyty. `max` tylko, gdy podano
  wprost. `ultra` odrzucasz,
- **cel**: gałąź, numer PR albo ścieżka; bez celu bieżący diff. Poprawki idą do bieżącego checkoutu, więc cel inny
  niż bieżąca zmiana → zapytaj, zanim cokolwiek zmienisz,
- `--model=<sonnet|opus|haiku|fable|sesja>`: model **przeglądu**, patrz niżej. Weryfikacja i poprawki idą na modelu sesji,
- `--bez-testow`: bez uruchamiania testów po poprawkach.

Wywołanie to zgoda na poprawki **błędów** wskazanych przez przegląd. Nie jest zgodą na zmianę zachowania widocznego dla
użytkownika, commit, push, PR, squash ani rebase.

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

## Działanie

1. **Start.** Przeczytaj instrukcje repo (`CLAUDE.md`, `AGENTS.md`, `CLAUDE.local.md`, jeśli są). `git status`: cudze,
   niezwiązane zmiany w plikach, które miałyby być poprawiane → pytaj, nie nadpisuj.
2. **Przegląd.** Bez modelu: Skill `code-review` z `<poziom> <cel>`. Z modelem: Agent z `model: "<model>"` (bez
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
   - model i poziom przeglądu (zapamiętany teraz czy z ustawienia), cel,
   - poprawione (plik:linia, jedno zdanie co i dlaczego),
   - **do decyzji** (jedno zdanie + propozycja kierunku),
   - drobne i fałszywe: sama liczba i powody fałszywych,
   - wynik kontroli i testów albo że ich nie było,
   - że nic nie zostało zacommitowane ani wypchnięte. Po jednej rundzie mogą wyjść nowe błędy;
     do zbiegu użyj `/przeglad-petla`.
