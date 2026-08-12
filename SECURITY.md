# Security

## Reporting

Email **security@vyloxi.com**. Do not open a public issue for a vulnerability.

Include what you did, what happened, and the version (`libxa --version`) and
platform. You will get an acknowledgement within three working days.

## What this tool does with your machine

Worth stating plainly, because installers are asked to do a lot and this one is
often run from a piped script.

**It runs other programs.** `composer`, and with the relevant flags `git`, `gh`
and `npm`. Each is resolved on your PATH and invoked with an argument list, so
nothing is passed through a shell and a project name containing a space or a
quote cannot become part of a command.

**It writes to two places**: the project directory you named, and nothing else.
The install scripts additionally write the per-user PATH entry and a line in
your shell profile.

**It never asks for elevation.** The install scripts are per-user by design:
`pip install --user` on the one hand, and the *user* PATH rather than the
machine PATH on the other. Anything claiming to be this installer and asking
for administrator or sudo is not.

**It does not phone home.** No telemetry, no analytics, no version check. The
only network traffic is Composer fetching packages, npm fetching dependencies
and gh talking to GitHub, each with its own configuration and its own trust.

**It does not handle your credentials.** Pushing to GitHub goes through `gh`,
which holds its own authentication. This tool never sees a token, and never
writes one anywhere.

## Verifying an install

Every release publishes a `SHA256SUMS` file alongside the executables on the
[releases page](https://github.com/libxa-framework/libxa-installer/releases).

```bash
sha256sum -c SHA256SUMS --ignore-missing
```

```powershell
Get-FileHash .\libxa-windows-x64.exe -Algorithm SHA256
```

The install scripts are served from the repository over HTTPS and download the
executable from the release. Piping a script from the internet into a shell is
a real trust decision. If you would rather not make it, download the executable
from the releases page, check its hash against `SHA256SUMS`, and put it on your
PATH yourself: that is all the script does.

The executables are not code-signed, so Windows SmartScreen warns on first run
and macOS quarantines the download.

## Supported versions

The latest minor release receives security fixes. Before 1.0 that means the
newest version only.
