#!/bin/sh
set -eu

REPO="ahmed3mar/bit"
INSTALL_DIR="${BIT_INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${BIT_VERSION:-latest}"

fail() {
  printf 'bit installer: %s\n' "$*" >&2
  exit 1
}

command -v curl >/dev/null 2>&1 || fail "curl is required"
command -v tar >/dev/null 2>&1 || fail "tar is required"

case "$(uname -s)" in
  Darwin) platform="macos" ;;
  Linux) platform="linux" ;;
  *) fail "unsupported operating system: $(uname -s)" ;;
esac

case "$(uname -m)" in
  arm64|aarch64) arch="arm64" ;;
  x86_64|amd64) arch="x64" ;;
  *) fail "unsupported architecture: $(uname -m)" ;;
esac

if [ "$VERSION" = "latest" ]; then
  VERSION="$(
    curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" |
      sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p'
  )"
  [ -n "$VERSION" ] || fail "could not determine the latest release"
else
  VERSION="${VERSION#v}"
fi

archive="bit-${VERSION}-${platform}-${arch}.tar.gz"
url="https://github.com/$REPO/releases/download/v${VERSION}/${archive}"
tmp="$(mktemp -d 2>/dev/null || mktemp -d -t bit-install)"
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

printf 'Downloading bit v%s for %s-%s...\n' "$VERSION" "$platform" "$arch"
curl -fL "$url" -o "$tmp/$archive"
curl -fsSL "https://github.com/$REPO/releases/download/v${VERSION}/checksums.txt" \
  -o "$tmp/checksums.txt"

expected="$(sed -n "s/^\([0-9a-fA-F][0-9a-fA-F]*\)  ${archive}$/\1/p" "$tmp/checksums.txt")"
[ -n "$expected" ] || fail "checksum for $archive was not found"

if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$tmp/$archive" | awk '{print $1}')"
elif command -v shasum >/dev/null 2>&1; then
  actual="$(shasum -a 256 "$tmp/$archive" | awk '{print $1}')"
else
  fail "sha256sum or shasum is required to verify the download"
fi
[ "$actual" = "$expected" ] || fail "checksum verification failed"

tar -xzf "$tmp/$archive" -C "$tmp"
source="$tmp/bit-${VERSION}-${platform}-${arch}/bit"
[ -f "$source" ] || fail "release archive does not contain bit"

mkdir -p "$INSTALL_DIR"
install -m 755 "$source" "$INSTALL_DIR/bit"

printf 'Installed bit v%s to %s/bit\n' "$VERSION" "$INSTALL_DIR"
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    printf '\nAdd bit to your PATH by placing this in your shell profile:\n'
    printf '  export PATH="%s:$PATH"\n' "$INSTALL_DIR"
    ;;
esac
