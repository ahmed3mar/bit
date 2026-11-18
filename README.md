# Bit

Bit is a coding agent with a command-line interface, a terminal UI, a server shared by every client, and a desktop application.

The public repository hosts downloads and release automation. Application source is maintained separately.

## Supported platforms

| Platform | Architectures | CLI | Desktop |
| --- | --- | --- | --- |
| macOS | Apple Silicon, Intel | Yes | Yes (`.dmg`) |
| Linux | ARM64, x86-64 | Yes | Yes (`.tar.gz`, `.deb`, `.rpm`) |
| Windows | — | Not yet | Not yet |

## Install the CLI

### Installer for macOS and Linux

Detects the platform and architecture, verifies the release checksum, and installs `bit` into `~/.local/bin`:

```bash
curl -fsSL https://raw.githubusercontent.com/ahmed3mar/bit/main/install.sh | sh
```

A specific version, or another directory:

```bash
curl -fsSL https://raw.githubusercontent.com/ahmed3mar/bit/main/install.sh | BIT_VERSION=0.1.0 sh
curl -fsSL https://raw.githubusercontent.com/ahmed3mar/bit/main/install.sh | BIT_INSTALL_DIR=/usr/local/bin sh
```

Ensure `~/.local/bin` is on your `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Homebrew on macOS or Linux

```bash
brew install ahmed3mar/tap/bit
brew update && brew upgrade bit
```

### Manual

Download `bit-<version>-<platform>-<arch>.tar.gz` (`macos` or `linux`, `arm64` or `x64`) from the [latest release](https://github.com/ahmed3mar/bit/releases/latest), then:

```bash
tar -xzf bit-<version>-<platform>-<arch>.tar.gz
sudo install -m 755 bit-<version>-<platform>-<arch>/bit /usr/local/bin/bit
```

## Run Bit

```bash
export ANTHROPIC_API_KEY=...
bit -p "list the Go files and what each does"   # print mode
bit serve                                       # the server, for every client
```

## Install the desktop application

Desktop downloads are published as `bit-desktop-*` on the [releases page](https://github.com/ahmed3mar/bit/releases/latest).

### macOS

Open `bit-desktop-<version>-macos-<arch>.dmg` and drag **Bit** into Applications.

If macOS says **"Bit" is damaged and can't be opened**, that release is not notarized and the browser quarantined the download. Choose **Cancel** and run:

```bash
xattr -dr com.apple.quarantine /Applications/Bit.app
```

### Linux

Install the `.deb` or `.rpm` package with your package manager, or extract `bit-desktop-<version>-linux-<arch>.tar.gz` and run its `install.sh`, which installs Bit for the current user in `~/.local`.

## Verify downloads

Every release includes `checksums.txt`:

```bash
curl -fLO https://github.com/ahmed3mar/bit/releases/download/v<version>/checksums.txt
sha256sum -c checksums.txt --ignore-missing   # macOS: shasum -a 256 -c checksums.txt --ignore-missing
```

## Uninstall

```bash
brew uninstall bit                 # Homebrew
rm -f "$HOME/.local/bin/bit"       # installer
rm -rf /Applications/Bit.app       # macOS desktop
```
