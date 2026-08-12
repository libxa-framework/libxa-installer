#!/usr/bin/env sh
#
# Install the LibxaFrame installer and put `libxa` on your PATH.
#
#   curl -fsSL https://raw.githubusercontent.com/libxa-framework/libxa-installer/main/scripts/install.sh | sh
#
# Downloads the `libxa` executable for this machine and installs it for the
# current user. Nothing needs sudo, and nothing outside your home directory is
# written to.
#
# There is no Python or PHP requirement for the installer itself. The
# applications it creates need PHP and Composer.
#
# Set LIBXA_VERSION to install a specific version:
#   LIBXA_VERSION=1.0.0 sh install.sh

set -eu

REPOSITORY='libxa-framework/libxa-installer'
INSTALL_DIR="${LIBXA_INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${LIBXA_VERSION:-}"

printf '\n  \033[1;33mLibxaFrame\033[0m installer setup\n\n'

step() { printf '  \033[2m%s\033[0m\n' "$1"; }
ok()   { printf '  \033[32m%s\033[0m\n' "$1"; }
warn() { printf '  \033[33m%s\033[0m\n' "$1"; }
fail() { printf '\n  \033[31m%s\033[0m\n\n' "$1"; exit 1; }

# ── Which build ──────────────────────────────────────────────────────────

os="$(uname -s)"
arch="$(uname -m)"

case "$os" in
    Darwin) platform='macos' ;;
    Linux)  platform='linux' ;;
    *)      fail "$os is not supported. Windows users should run scripts/install.ps1." ;;
esac

case "$arch" in
    x86_64|amd64)  cpu='x64' ;;
    arm64|aarch64) cpu='arm64' ;;
    *)             fail "$arch is not supported." ;;
esac

ASSET="libxa-${platform}-${cpu}"

if [ -n "$VERSION" ]; then
    URL="https://github.com/$REPOSITORY/releases/download/v${VERSION}/${ASSET}"
else
    URL="https://github.com/$REPOSITORY/releases/latest/download/${ASSET}"
fi

# ── Download ─────────────────────────────────────────────────────────────
#
# To a temporary file first. Writing straight over the installed command means
# an interrupted download replaces a working install with a truncated one, and
# the next run fails in a way that looks nothing like a network problem.

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT INT TERM

step "Downloading $ASSET"

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$URL" -o "$TMP" || fail "Could not download $ASSET. Check https://github.com/$REPOSITORY/releases"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$TMP" "$URL" || fail "Could not download $ASSET. Check https://github.com/$REPOSITORY/releases"
else
    fail 'Neither curl nor wget is available.'
fi

[ -s "$TMP" ] || fail 'The download produced an empty file.'

# ── Install ──────────────────────────────────────────────────────────────

mkdir -p "$INSTALL_DIR"

TARGET="$INSTALL_DIR/libxa"

chmod +x "$TMP"
mv "$TMP" "$TARGET" || fail "Could not write to $INSTALL_DIR."
trap - EXIT INT TERM

# macOS quarantines anything downloaded, and an unsigned binary is then refused
# with a message about an unidentified developer rather than about quarantine.
if [ "$platform" = 'macos' ] && command -v xattr >/dev/null 2>&1; then
    xattr -d com.apple.quarantine "$TARGET" 2>/dev/null || true
fi

ok "Installed to $TARGET"

# ── PATH ─────────────────────────────────────────────────────────────────

case ":${PATH}:" in
    *":${INSTALL_DIR}:"*)
        step 'Already on your PATH.'
        ;;
    *)
        # Append to the file the user's shell actually reads. A line added to
        # .bashrc does nothing under zsh, which is the default on macOS.
        case "${SHELL:-}" in
            */zsh)  PROFILE="$HOME/.zshrc" ;;
            */fish) PROFILE="$HOME/.config/fish/config.fish" ;;
            *)      PROFILE="$HOME/.profile" ;;
        esac

        if [ "${PROFILE##*/}" = 'config.fish' ]; then
            mkdir -p "$(dirname "$PROFILE")"
            printf '\n# Added by the LibxaFrame installer\nfish_add_path %s\n' "$INSTALL_DIR" >> "$PROFILE"
        else
            printf '\n# Added by the LibxaFrame installer\nexport PATH="%s:$PATH"\n' "$INSTALL_DIR" >> "$PROFILE"
        fi

        ok "Added $INSTALL_DIR to your PATH via $PROFILE."
        warn 'Open a new terminal, or source that file, before using it.'
        ;;
esac

printf '\n'

if reported="$("$TARGET" --version 2>&1)"; then
    ok "Installed $reported"
else
    warn 'Installed, but the command did not run. Report this at:'
    warn "https://github.com/$REPOSITORY/issues"
fi

printf '\n  \033[2mTry it:\033[0m\n    \033[33mlibxa new my-app\033[0m\n\n'
