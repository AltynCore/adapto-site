#!/usr/bin/env bash
# One-command install or update of Adapto OS from the GitHub releases:
#   curl -fsSL https://adapto.kz/install.sh | sudo bash
# Options through the environment, e.g. curl ... | sudo BOX_HOST=box.center.kz bash
#   BOX_HOST        name users type in the browser (default: the server's first IP address)
#   BOX_PORT        port (default 80)
#   ADAPTO_VERSION  release to install, e.g. 0.26.0 (default: the latest)
#   ADAPTO_DIR      where the box lives (default /opt/adapto)
#   ADAPTO_KEY      the label from our letter; it only shows in our download log (default: site)
# A second run on the same server updates the box and keeps its settings and data.
# For a server without internet use the offline package: https://adapto.kz/install
set -euo pipefail

REPO=AltynCore/adapto-os
# Downloads go through adapto.kz/download/<key>/..., which redirects to the GitHub releases of $REPO.
DOWNLOAD="https://adapto.kz/download/${ADAPTO_KEY:-site}"
DIR=${ADAPTO_DIR:-/opt/adapto}

fail() { echo "Error: $*" >&2; exit 1; }

# Everything runs from main: with "curl | bash" bash reads the whole script before the first command.
main() {
  [ "$(id -u)" = 0 ] || fail "run as root: curl -fsSL https://adapto.kz/install.sh | sudo bash"
  [ "$(uname -s)" = Linux ] && [ "$(uname -m)" = x86_64 ] || fail "Linux x86_64 is required"
  command -v curl >/dev/null || fail "curl is not installed (apt install curl)"
  command -v sha256sum >/dev/null || fail "sha256sum is not installed"
  memory_mb=$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)
  [ "$memory_mb" -ge 3500 ] || fail "at least 4 GB of memory is required, this server has ${memory_mb} MB"
  mkdir -p "$DIR"
  free_gb=$(df -Pk "$DIR" | awk 'NR==2 {print int($4/1024/1024)}')
  [ "$free_gb" -ge 10 ] || fail "at least 10 GB of free disk is required in $DIR, there are ${free_gb} GB"

  version=${ADAPTO_VERSION:-}
  if [ -z "$version" ]; then
    latest=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "$DOWNLOAD/latest")
    version=${latest##*/v}
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "could not find the latest release at github.com/$REPO"
  fi
  base="$DOWNLOAD/v$version"
  echo "Adapto OS $version -> $DIR"

  download=$DIR/.download
  rm -rf "$download"; mkdir -p "$download"
  trap 'rm -rf "$download"' EXIT
  curl -fL --retry 3 --progress-bar -o "$download/adapto-os-$version.tar" "$base"
  curl -fsSL --retry 3 -o "$download/SHA256SUMS" "$base/SHA256SUMS"
  (cd "$download" && grep " adapto-os-$version.tar\$" SHA256SUMS | sha256sum -c --quiet -) \
    || fail "the downloaded file is damaged (checksum mismatch); run the command again"
  tar -xf "$download/adapto-os-$version.tar" -C "$download"
  rm "$download/adapto-os-$version.tar"

  # The package's own files replace the old ones; .env and backups/ stay.
  cp -a "$download/box-package-$version/." "$DIR/"
  cd "$DIR"

  if [ -f .env ]; then
    echo "An installed box found: updating, settings and data stay."
    ./update.sh </dev/null
  else
    host=${BOX_HOST:-$(hostname -I 2>/dev/null | awk '{print $1}')}
    port=${BOX_PORT:-80}
    [ -n "$host" ] || fail "could not find the server's address; set it: curl ... | sudo BOX_HOST=box.center.kz bash"
    cp env.example .env
    sed -i "s/^BOX_HOST=.*/BOX_HOST=$host/; s/^BOX_PORT=.*/BOX_PORT=$port/" .env
    if [ "$port" = 80 ]; then url="http://$host"; else url="http://$host:$port"; fi
    sed -i "s|^BOX_URL=.*|BOX_URL=$url|" .env
    ./install.sh </dev/null
    echo
    echo "Open $url and sign in as Administrator with the password above (it is also in $DIR/.env)."
    echo "Administrator guide: $DIR/guide.html"
  fi
  rm -f images.tar.gz
}

main "$@"
