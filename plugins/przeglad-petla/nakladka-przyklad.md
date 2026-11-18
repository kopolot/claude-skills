# Nakładka pętli przeglądu: <nazwa projektu>

Skopiuj do `<repo>/.claude/przeglad-petla.local.md` i dopasuj. Puste sekcje usuń; wtedy obowiązują domyślne ze skilla.

## Izolacja
- np. zawsze worktree w `../<repo>-wt/<nazwa>`, blokada `mkdir .git/worktrees/<nazwa>/agent.lock`

## Notatki z przeglądów
- np. `notes/<id zadania>/przeglad/` (rejestr odrzuconych = wcześniejsze pliki z tego katalogu)

## Commit
- np. `fix(<obszar>): poprawki z code-review <poziom>, runda <N> <ID-ZADANIA>`, bez `Co-Authored-By`

## Kontrole po poprawce
- np. `php -l`, `npm run lint -- <pliki>`, `tsc --noEmit`

## Testy na końcu
- np. `npm test -- <obszar>`; czego nie uruchamiać lokalnie

## Tematy zamknięte (nie są ważne)
- np. świadome decyzje, do których przegląd wraca

## Po zakończeniu
- np. wpis w `notes/<id>/decyzje.md`, stan w `notes/<id>/README.md`
