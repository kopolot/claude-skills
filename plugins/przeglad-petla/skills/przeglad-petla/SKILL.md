---
name: przeglad-petla
description: Pętla /code-review na gałęzi z poprawkami — przegląd na wybranym poziomie (domyślnie ostatnio użyty w /code-review), weryfikacja zgłoszeń w kodzie, poprawki ważnych, commit, kolejny przegląd, aż runda nie da żadnego nowego ważnego zweryfikowanego zgłoszenia. Działa w każdym repo; zasady projektu bierze z instrukcji repo i nakładki. Używaj, gdy ktoś prosi o „pętlę review”, „review do skutku”, „/przeglad-petla”.
argument-hint: "[low|medium|high|xhigh|max] [gałąź] [--model=sonnet|opus|haiku|fable|sesja] [--poziom=sesja] [--effort=low|medium|high|xhigh|max|sesja] [--once] [--max-rund=N] [--bez-testow]"
---

# Pętla code-review do czystej rundy

Argumenty: `$ARGUMENTS`
- **poziom**: `low|medium|high|xhigh|max`. Podany jest zapamiętywany jako domyślny (patrz „Poziom przeglądu”; `max` nie).
  Bez poziomu obowiązuje zapamiętany, a gdy go nie ma, ten, którego `/code-review` użył ostatnio
  (jak w samym `/code-review`). `max` tylko wtedy, gdy podano go wprost. `--poziom=sesja` kasuje zapamiętany wybór. `ultra` odrzucasz (przegląd w chmurze, płatny,
  uruchamia go tylko człowiek),
- **gałąź**: domyślnie bieżąca; gałąź domyślna repo (`main`/`master`) → zapytaj o gałąź,
- `--model=<sonnet|opus|haiku|fable>`: model, na którym działa **sam przegląd** (krok 1a). Wartość zostaje zapamiętana
  jako domyślna na kolejne uruchomienia (patrz „Model przeglądu”). `--model=sesja` kasuje zapamiętany wybór
  i wraca do modelu bieżącej sesji. Weryfikacja zgłoszeń i poprawki zawsze idą na modelu sesji,
- `--effort=<low|medium|high|xhigh|max|sesja>`: reasoning effort agenta przeglądu (patrz „Effort przeglądu”); obowiązuje we wszystkich rundach,
- `--max-rund=N`: limit rund, domyślnie 5,
- `--bez-testow`: bez testów na końcu.

Wywołanie pętli to zgoda na poprawki **błędów** wskazanych przez przegląd. Nie jest zgodą na zmianę tego, co użytkownik
może zrobić, ani na push, PR, zmianę stanu PR, squash czy rebase.

## Jednorazowe nadpisanie ustawień (`--once`)

`--once` oznacza **tylko to wywołanie skilla**, bez zmiany zapisanych preferencji modelu i poziomu.
- Dotyczy zarówno jawnego poziomu (`high`, `medium` itd.), jak i `--model=X` oraz `--effort=X`.
- Przy `--model=sesja --once`, `--poziom=sesja --once` lub `--effort=sesja --once` użyj ustawień sesji **tylko teraz**, nie usuwając zapisanych plików.
- Jeśli nie podano jawnego modelu/poziomu, odczytaj zapisane ustawienie tak jak zwykle.
- `--once` jest flagą samego skilla: **nie przekazuj jej do `/code-review` ani do argumentów jego wywołania**.
- W `/przeglad-petla` wybrane tymczasowo ustawienia obowiązują we **wszystkich rundach tego jednego uruchomienia**.
- Zweryfikuj poprawność argumentów modelu, poziomu i effortu przed zapisem jakichkolwiek preferencji; nieznane wartości oznaczają stop bez modyfikacji plików.

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

## Effort przeglądu

Ustawienie: `~/.claude/przeglad-petla/effort` (jedna linia: `low|medium|high|xhigh`; brak pliku = bez jawnego effortu,
agent przeglądu dziedziczy go z sesji). Wspólne dla trzech skilli, osobiste, we wszystkich repo. To reasoning effort
**agenta przeglądu** (parametr `effort` narzędzia Agent), a nie to samo co `poziom`: `poziom` to zakres `/code-review`
(ile zgłoszeń i finderów). Dotyczy tylko przeglądu przez Agenta (model przeglądu inny niż model sesji); gdy
`/code-review` wołasz bezpośrednio, obowiązuje effort sesji.

1. `--effort=X`, `X` ∈ `low|medium|high|xhigh` → użyj `X` jako `effort` agenta przeglądu.
   - Bez `--once`: `mkdir -p ~/.claude/przeglad-petla && printf '%s\n' X > ~/.claude/przeglad-petla/effort`; napisz, że zapisano.
   - Z `--once`: **nie zapisuj** pliku; effort obowiązuje tylko przy tym wywołaniu.
2. `--effort=max` → użyj tylko teraz i **nigdy nie zapisuj** (najdroższy effort).
3. `--effort=sesja` → agent bez jawnego `effort` (dziedziczy z sesji).
   - Bez `--once`: `rm -f ~/.claude/przeglad-petla/effort`.
   - Z `--once`: **nie usuwaj** pliku, zignoruj jego wartość tylko podczas tego wywołania.
4. Inna wartość → stop, wypisz dozwolone, nic nie zapisuj.
5. Bez `--effort` → `cat ~/.claude/przeglad-petla/effort 2>/dev/null`; pusty plik albo wartość spoza listy = bez
   jawnego effortu (napisz o tym).

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

**a) Przegląd.** `SHA=$(git rev-parse --short HEAD)`. Argumenty przeglądu to `<poziom> <gałąź>` (poziom z „Poziomu przeglądu”), a gdy poziomu
nie ma, samo `<gałąź>`: `/code-review` weźmie wtedy ostatnio użyty poziom. Bez `--fix`, `--comment`, `--post`.
- **Brak modelu przeglądu albo model tej samej rodziny co model sesji** (nazwa z promptu systemowego, np. „Opus 5.5” → `opus`;
  oceniasz to w każdej rundzie, bo `opusplan` może zmienić model między trybami) → wywołaj Skill `code-review` z tymi
  argumentami bezpośrednio, bez Agenta (effort sesji; jeśli `effort` był ustawiony, napisz raz, że go pominięto).
- **Inny model przeglądu** → uruchom Agent z `model: "<model przeglądu>"` i, gdy ustalono effort, `effort: "<effort>"` (bez `isolation`; subagent pracuje w tym samym
  checkoucie). Prompt: wywołaj Skill `code-review` z argumentami `<...>` i w odpowiedzi zwróć **tekstem** pełną listę
  zgłoszeń (plik:linia, opis, scenariusz awarii, werdykt, poziom `level`), niczego nie poprawiaj, nie commituj
  i nie pisz do plików. Weryfikacja i poprawki dalej robisz sam, na modelu sesji.
- Poziom faktycznie użyty w rundzie odczytaj z wyniku przeglądu (pole `level` zgłoszeń) i użyj go w notatce i raporcie.
  Wszystkie rundy idą na tym samym poziomie; gdy poziomu nie podano, a pierwsza runda go ujawniła, kolejne wołaj
  już z nim wprost (subagent nie musi znać ostatnio użytego poziomu sesji).

**b) Weryfikacja każdego zgłoszenia samodzielnie, w kodzie tego commita.** Prześledź wywołania, dane wejściowe
i istniejące zabezpieczenia; werdykt przeglądu (CONFIRMED/PLAUSIBLE) to wskazówka, nie dowód. Jedna klasa na zgłoszenie:

| Klasa | Kiedy | Co robisz |
|---|---|---|
| **ważne** | potwierdzony błąd poprawności, bezpieczeństwa, utraty albo zepsucia danych, pieniędzy, awaria na realnej ścieżce, złamanie zasady repo, która wywali CI | poprawiasz w tej rundzie |
| **do decyzji** | potwierdzone, ale naprawa zmienia zachowanie widoczne dla użytkownika, zakres zadania, uprawnienia, schemat bazy albo wymaga wyboru kierunku | **nie poprawiasz**; do raportu |
| **drobne** | prawda, ale kosmetyka, nazewnictwo, wydajność bez realnego skutku, opinia o architekturze, brak testu przypadku bez błędu | bez zmian (wyjątek: 1–2 linie w pliku i tak zmienianym w tej rundzie) |
| **fałszywe** | scenariusz nie zachodzi albo jest już obsłużony | bez zmian, z krótkim powodem |

Najpierw odsiej zgłoszenia z rejestru odrzuconych i tematów zamkniętych (niżej), potem weryfikuj resztę.

**Głębokość weryfikacji** (koszt, nie pomijanie):
- werdykt PLAUSIBLE albo brak werdyktu → pełne śledzenie w kodzie, jak wyżej,
- CONFIRMED, które wygląda na **ważne** → i tak czytasz to miejsce, żeby je poprawić; przed edycją sprawdź scenariusz
  i istniejące zabezpieczenia,
- CONFIRMED, które z samego opisu jest **drobne** albo **do decyzji** (kosmetyka, nazewnictwo, uproszczenie,
  zmiana zachowania lub zakresu) → klasyfikujesz z opisu, bez ponownego śledzenia kodu,
- wyjątek: bezpieczeństwo, autoryzacja, dane, pieniądze i migracje zawsze przechodzą pełną weryfikację.

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
commit z poprawkami, model przeglądu) i tabelą `# | Zgłoszenie | Weryfikacja | Decyzja` dla wszystkich zgłoszeń. Bez danych osobowych
i sekretów.

Wróć do a) na nowym HEAD.

## 2. Zakończenie

1. Testy według nakładki, tylko gdy w pętli był commit i nie podano `--bez-testow`. Bez nakładki: testy obszaru
   zmienionych plików, jeśli repo ma szybkie i bezpieczne lokalne uruchomienie; inaczej pomiń i napisz to.
   Czerwone przez poprawki z pętli → napraw, commit i jeszcze jedna runda przeglądu.
2. Zapisy po zakończeniu z nakładki (decyzje, stan tematu).
3. Zwolnij blokady, które wziąłeś (tylko własne).
4. Raport, krótko:
   - poziom, model i effort przeglądu (oraz czy zapamiętano je właśnie teraz, czy wzięto z ustawienia; ewentualnie że rundy poszły bez Agenta), liczba rund,
     SHA każdej, czy pętla zbiegła,
   - commity z poprawkami, jednym zdaniem każdy,
   - **do decyzji**: każda pozycja jednym zdaniem z propozycją kierunku,
   - wynik testów albo że ich nie było,
   - ścieżki notatek, zwolnione blokady, i że nic nie zostało wypchnięte.
