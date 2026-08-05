# Git-Workflow

BikeDrop nutzt **GitHub Flow**: `main` ist der einzige dauerhafte Branch, alles
andere sind kurzlebige Branches pro Aufgabe, die per Pull Request gemergt und
danach automatisch gelöscht werden.

## main ist geschützt

- Direktes Pushen auf `main` ist nicht möglich, es braucht immer einen Pull
  Request.
- Repo-Einstellung *"Automatically delete head branches"* ist aktiv: der
  Remote-Branch verschwindet automatisch, sobald sein PR gemergt wurde.

## Branch-Präfixe

| Präfix | Wofür | Beispiel |
|---|---|---|
| `feature/` | Neue Funktionalität | `feature/login-screen` |
| `fix/` | Bugfix | `fix/button-color` |
| `chore/` | Wartung, Dependencies, Config, kein Feature/Fix | `chore/update-deps` |
| `docs/` | Nur Dokumentation | `docs/readme` |

## Git-Aliase

Global eingerichtet (gelten für alle Repos auf diesem Rechner), setzen das
passende Präfix automatisch vor den Branch-Namen:

```
git feature <name>   # → checkout -b feature/<name>
git fix <name>        # → checkout -b fix/<name>
git chore <name>      # → checkout -b chore/<name>
git docs <name>       # → checkout -b docs/<name>
```

Beispiel: `git feature login-screen` legt `feature/login-screen` an und
wechselt direkt dorthin.

Aliase ansehen: `git config --global --get-regexp alias`
Alias entfernen: `git config --global --unset alias.<name>`

## Ablauf für eine neue Aufgabe

```
git checkout main
git pull

git feature meine-aufgabe        # oder fix/chore/docs

# ... Änderungen machen ...

git add <dateien>
git commit -m "..."
git push -u origin feature/meine-aufgabe

gh pr create
gh pr merge --squash             # löscht den Remote-Branch automatisch

git checkout main
git pull
git fetch --prune                # lokale Referenzen auf gelöschte Branches aufräumen
```
