---
name: przeglad-petla
description: Pętla /code-review na gałęzi z poprawkami — przegląd na wybranym poziomie (domyślnie xhigh), weryfikacja zgłoszeń w kodzie, poprawki ważnych, commit, kolejny przegląd, aż runda nie da żadnego nowego ważnego zweryfikowanego zgłoszenia. Działa w każdym repo; zasady projektu bierze z instrukcji repo i nakładki. Używaj, gdy ktoś prosi o „pętlę review”, „review do skutku”, „/przeglad-petla”.
argument-hint: "[low|medium|high|xhigh|max] [gałąź] [--max-rund=N] [--bez-testow]"
---

# Pętla code-review do czystej rundy

Argumenty: `$ARGUMENTS`
- **poziom**: `low|medium|high|xhigh|max`, domyślnie `xhigh`. `max` tylko wtedy, gdy podano go wprost.
  `ultra` odrzucasz (przegląd w chmurze, płatny, uruchamia go tylko człowiek),
- **gałąź**: domyślnie bieżąca; gałąź domyślna repo (`main`/`master`) → zapytaj o gałąź,
- `--max-rund=N`: limit rund, domyślnie 5,
- `--bez-testow`: bez testów na końcu.

Wywołanie pętli to zgoda na poprawki **błędów** wskazanych przez przegląd. Nie jest zgodą na zmianę tego, co użytkownik
może zrobić, ani na push, PR, zmianę stanu PR, squash czy rebase.

## 0. Przygotowanie (raz)

1. **Zasady projektu.** Przeczytaj instrukcje repo (`CLAUDE.md`, `AGENTS.md`, `CLAUDE.local.md`, `CONTRIBUTING`, jeśli są)
   i **nakładkę** pętli: pierwszy istniejący plik z listy, w katalogu głównego checkoutu
   (`dirname "$(git rev-parse --path-format=absolute --git-common-dir)"`):
   `.claude/przeglad-petla.local.md` (osobista; wyłącz z gita przez `.git/info/exclude`),
   `.claude/przeglad-petla.md` (wspólna dla zespołu).
   Nakładka ma pierwszeństwo przed domyślnymi z tego pliku. Może określać: izolację (worktree, blokady),
   gdzie leżą notatki z przeglądów i rejestr odrzuconych, format commita, kontrole po poprawce, testy na końcu,
   tematy zamknięte, których nie traktujesz jako ważne, i co zapisać po zakończeniu.
2. **Rejestr odrzuconych.** Wczytaj wcześniejsze notatki z przeglądów tej gałęzi (miejsce z nakładki, domyślnie
   `<git-common-dir>/przeglad-petla/<gałąź z „/” zamienionym na „-”>/`). Zgłoszenia ocenione tam jako drobne, fałszywe
   albo „zostaje” nie wracają jako nowe.
3. **Izolacja.** Według nakładki. Bez nakładki: pracujesz w bieżącym checkoucie, jeśli jest na tej gałęzi;
   inaczej zakładasz worktree obok repo (`git worktree add ../<repo>-wt/<krótka-nazwa> <gałąź>`). Nie przełączasz gałęzi
   w checkoucie, w którym ktoś pracuje.
4. `git status` czysty; zmiany, których nie zrobiłeś → stop i pytaj.
5. Sprawdź od razu, że możesz pisać do miejsca notatek. Zapis zablokowany → zbierasz treść i oddajesz ją w raporcie,
   blokady nie obchodzisz.

## 1. Runda (powtarzaj)

**a) Przegląd.** `SHA=$(git rev-parse --short HEAD)`. Wywołaj Skill `code-review` z argumentami `<poziom> <gałąź>`.
Bez `--fix`, `--comment`, `--post`.

**b) Weryfikacja każdego zgłoszenia samodzielnie, w kodzie tego commita.** Prześledź wywołania, dane wejściowe
i istniejące zabezpieczenia; werdykt przeglądu (CONFIRMED/PLAUSIBLE) to wskazówka, nie dowód. Jedna klasa na zgłoszenie:

| Klasa | Kiedy | Co robisz |
|---|---|---|
| **ważne** | potwierdzony błąd poprawności, bezpieczeństwa, utraty albo zepsucia danych, pieniędzy, awaria na realnej ścieżce, złamanie zasady repo, która wywali CI | poprawiasz w tej rundzie |
| **do decyzji** | potwierdzone, ale naprawa zmienia zachowanie widoczne dla użytkownika, zakres zadania, uprawnienia, schemat bazy albo wymaga wyboru kierunku | **nie poprawiasz**; do raportu |
| **drobne** | prawda, ale kosmetyka, nazewnictwo, wydajność bez realnego skutku, opinia o architekturze, brak testu przypadku bez błędu | bez zmian (wyjątek: 1–2 linie w pliku i tak zmienianym w tej rundzie) |
| **fałszywe** | scenariusz nie zachodzi albo jest już obsłużony | bez zmian, z krótkim powodem |

Tematy zamknięte z nakładki, z pamięci i z decyzji zapisanych w repo albo notatkach nie są ważne. Zgłoszenie z rejestru
odrzuconych jest nowe tylko wtedy, gdy przegląd pokazuje konkretny scenariusz awarii, którego poprzednia ocena nie objęła.

**c) Stop.**
- Zero nowych **ważnych** → koniec pętli, krok 2.
- Osiągnięty `--max-rund` → koniec; w raporcie, że pętla nie zbiegła, i co zostało.
- To samo zgłoszenie wraca jako ważne po dwóch poprawkach → stop i opisz, czemu poprawka nie domyka sprawy.

**d) Poprawki ważnych.** Styl edytowanego pliku, zasady repo. Zmiana zachowania opisanego testem → popraw test
w tej samej rundzie; tania asercja na naprawiony błąd → dopisz. Po edycji kontrole z nakładki, a bez niej to, co repo
ma tanie i lokalne (składnia, linter, typy dla zmienionych plików).

**e) Commit.** `git status` (cudzy plik → stop), potem `git commit -- <twoje pliki>`, w formacie commitów repo
(nakładka, instrukcje repo, `git log`). Treść: po co (jakie błędy z przeglądu usuwa) i lista zmian.
Bez stopek narzędzi i bez `Co-Authored-By` agenta, jeśli repo tego zabrania. Bez push.

**f) Notatka rundy** w miejscu notatek: plik `code-review-<poziom>-<RRRR-MM-DD>-<SHA>.md` z nagłówkiem (gałąź, checkout,
commit z poprawkami) i tabelą `# | Zgłoszenie | Weryfikacja | Decyzja` dla wszystkich zgłoszeń. Bez danych osobowych
i sekretów.

Wróć do a) na nowym HEAD.

## 2. Zakończenie

1. Testy według nakładki, tylko gdy w pętli był commit i nie podano `--bez-testow`. Bez nakładki: testy obszaru
   zmienionych plików, jeśli repo ma szybkie i bezpieczne lokalne uruchomienie; inaczej pomiń i napisz to.
   Czerwone przez poprawki z pętli → napraw, commit i jeszcze jedna runda przeglądu.
2. Zapisy po zakończeniu z nakładki (decyzje, stan tematu).
3. Zwolnij blokady, które wziąłeś (tylko własne).
4. Raport, krótko:
   - poziom, liczba rund, SHA każdej, czy pętla zbiegła,
   - commity z poprawkami, jednym zdaniem każdy,
   - **do decyzji**: każda pozycja jednym zdaniem z propozycją kierunku,
   - wynik testów albo że ich nie było,
   - ścieżki notatek, zwolnione blokady, i że nic nie zostało wypchnięte.
