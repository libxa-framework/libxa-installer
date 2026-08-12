# LibxaFrame Installer

Create a new LibxaFrame application with one command.

```bash
libxa new my-app
```

This repository distributes the installer. **The source lives in a private
repository**; what is published here are the install scripts and the built
executables attached to each [release](https://github.com/libxa-framework/libxa-installer/releases).

---

## Installing

### Windows

```powershell
irm https://raw.githubusercontent.com/libxa-framework/libxa-installer/main/scripts/install.ps1 | iex
```

### macOS and Linux

```bash
curl -fsSL https://raw.githubusercontent.com/libxa-framework/libxa-installer/main/scripts/install.sh | sh
```

Both install for the current user and add the command to your PATH. Neither
needs administrator rights or sudo. Open a new terminal afterwards:

```bash
libxa --version
```

### By hand

Download the executable for your machine from the
[latest release](https://github.com/libxa-framework/libxa-installer/releases/latest),
put it somewhere on your PATH, and name it `libxa`.

| Platform | File |
|---|---|
| Windows x64 | `libxa-windows-x64.exe` |
| macOS Apple Silicon | `libxa-macos-arm64` |
| macOS Intel | `libxa-macos-x64` |
| Linux x64 | `libxa-linux-x64` |

On macOS and Linux, `chmod +x libxa` first.

### A specific version

```powershell
irm https://raw.githubusercontent.com/libxa-framework/libxa-installer/main/scripts/install.ps1 -OutFile install.ps1
.\install.ps1 -Version 1.0.0
```

```bash
LIBXA_VERSION=1.0.0 sh install.sh
```

## Requirements

The installer is a self-contained executable. It needs nothing installed to
run.

What it *creates* needs:

| | |
|---|---|
| PHP | 8.3 or newer |
| Composer | 2.x, [getcomposer.org](https://getcomposer.org) |
| Node.js | Only for `--npm` |
| git | Only for `--git` |
| GitHub CLI | Only for `--github` |

### `libxa: command not found`

Open a **new** terminal: a PATH change does not reach terminals that were
already open.

If it still is not found, the command is at
`%LOCALAPPDATA%\Programs\libxa\libxa.exe` on Windows and `~/.local/bin/libxa`
elsewhere, and you can run it by full path while you sort the PATH out.

---

## Using it

```bash
libxa new my-app
```

```
  LibxaFrame installer 1.0.0

  Which database will it use?
    1. SQLite (no server required) (default)
    2. MySQL
    3. MariaDB
    4. PostgreSQL
  › 1

  Creating the application…
  Initialised a git repository on main.

   DONE  Your application is ready.

  Next:
    › cd my-app
    › php libxa migrate
    › npm install && npm run build
    › php libxa serve
```

### Options

| Option | What it does |
|---|---|
| `--database=DRIVER` | `sqlite`, `mysql`, `mariadb` or `pgsql`. Asked for when omitted. |
| `--dev` | Install the development branch instead of the latest release. |
| `--force`, `-f` | Replace the directory if it already exists. |
| `--git` | Initialise a repository and make the first commit. |
| `--branch=NAME` | Branch for that commit. Defaults to your `init.defaultBranch`. |
| `--github[=VISIBILITY]` | Create a GitHub repository and push. `private` unless you say otherwise. |
| `--organization=NAME` | Create it in an organization rather than your account. |
| `--npm` | Install front-end dependencies and build the assets. |
| `--no-scripts` | Skip the skeleton's post-install scripts. |
| `--no-color` | Plain output. |

### Examples

```bash
libxa new my-app --database=mysql --git --npm
```

Into the directory you are already in:

```bash
mkdir my-app && cd my-app
libxa new .
```

Straight onto GitHub, in an organization, public:

```bash
libxa new my-app --github=public --organization=my-team
```

## What it does

1. Checks the PHP on your PATH and warns if it is missing or older than 8.3. It
   warns rather than stops: Composer enforces the requirement, and it can be
   told to ignore the platform check.
2. Runs `composer create-project libxa/libxa`, which installs the skeleton and
   runs its post-install scripts: `.env` is copied from `.env.example`, the
   SQLite file is created, and `php libxa key:generate` sets `APP_KEY`.
3. Rewrites `DB_DRIVER`, `DB_PORT` and `DB_DATABASE` in `.env` if you chose
   something other than SQLite. Only those keys, so the generated `APP_KEY`
   survives.
4. `npm install && npm run build`, with `--npm`.
5. `git init` and a first commit, with `--git`.
6. `gh repo create --source=. --push`, with `--github`.

Nothing is hidden: every command runs with its output on your terminal.

## After it finishes

```bash
cd my-app
php libxa migrate
php libxa serve
```

Then open <http://localhost:8000>.

If you chose MySQL, MariaDB or PostgreSQL, set `DB_USERNAME` and `DB_PASSWORD`
in `.env` and create the database before migrating. The installer has no
credentials, and guessing at them would be worse than asking.

### Deploying

Point the web server at **`src/public/`** and send anything that is not a real
file to `index.php`. Your new project ships the Apache `.htaccess` files that
do this, and a `DEPLOYMENT.md` covering Apache, nginx, Caddy and shared
hosting.

If the home page works and every other route 404s, that is this setting.

## Verifying a download

Every release publishes `SHA256SUMS` alongside the executables.

```bash
sha256sum -c SHA256SUMS --ignore-missing
```

```powershell
Get-FileHash .\libxa-windows-x64.exe -Algorithm SHA256
```

The executables are not code-signed, so Windows SmartScreen warns on first run
and macOS Gatekeeper may need `xattr -d com.apple.quarantine libxa` (the
install script does this for you).

## Uninstalling

Delete the executable and remove the PATH entry:

- **Windows**: delete `%LOCALAPPDATA%\Programs\libxa`, then remove it from
  *Edit environment variables for your account*.
- **macOS and Linux**: `rm ~/.local/bin/libxa`, then remove the line the
  install script added to your shell profile.

Nothing else was written anywhere.

## Reporting a problem

[Open an issue](https://github.com/libxa-framework/libxa-installer/issues).
Include `libxa --version`, your platform, and what you ran.

## Licence

MIT. See [LICENSE](LICENSE).
