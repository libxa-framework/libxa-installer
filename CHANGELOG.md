# Changelog

All notable changes to the LibxaFrame installer are recorded here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.0.0] - 2026-08-12

First release.

### Added

- **`libxa new <name>`**, which runs `composer create-project libxa/libxa` and
  everything around it: a database chosen up front rather than edited
  afterwards, front-end dependencies installed, a git repository with a first
  commit, and a summary of what to run next.
- **Database selection**: SQLite, MySQL, MariaDB or PostgreSQL, asked for
  interactively or given with `--database`. Anything other than SQLite rewrites
  `DB_DRIVER`, `DB_PORT` and `DB_DATABASE` in `.env`, and only those keys, so
  the `APP_KEY` the skeleton generates survives.
- **`--git`** and **`--branch`**, defaulting to the user's own
  `init.defaultBranch` rather than imposing a name.
- **`--github[=VISIBILITY]`** and **`--organization`**, which create the
  repository through the GitHub CLI and push. Private unless told otherwise: a
  project one command old is not ready to be public, and making it public later
  is easier than unpublishing it.
- **`--npm`**, which installs front-end dependencies and builds the assets.
- **`--dev`** to install the development branch, and **`--force`** to replace a
  directory that already exists.
- **Install scripts** for Windows (`install.ps1`) and macOS and Linux
  (`install.sh`). Each downloads the executable for the machine it is running
  on, installs it for the current user and adds it to the per-user PATH.
  Neither needs administrator rights.
- **Self-contained executables** for Windows, macOS and Linux, so the installer
  needs nothing installed to run. What it creates still needs PHP and Composer.

### Notes

- No runtime dependencies. This is the first thing a new user installs, so
  every dependency is a way for that install to fail on a machine nobody has
  tested, and it also lets the whole tool be frozen into one executable with
  nothing to resolve.
- Every prompt has a non-interactive answer, so the same commands run in CI
  without hanging on a question nothing can answer.
- Distribution is the executable rather than a Python package. A wheel and an
  sdist both contain the `.py` files, and the source for this tool is not
  public.

[Unreleased]: https://github.com/libxa-framework/libxa-installer/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/libxa-framework/libxa-installer/releases/tag/v1.0.0
