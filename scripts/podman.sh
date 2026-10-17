#!/usr/bin/env bash
# Creates and starts the Podman VM (Docker-compatible containers).
source "$(dirname "$0")/../lib/common.sh"
step "Podman"

if ! podman machine inspect >/dev/null 2>&1; then
  cpus=$(( $(sysctl -n hw.ncpu) / 2 ))
  mem_mb=$(( $(sysctl -n hw.memsize) / 1048576 / 2 )); (( mem_mb > 8192 )) && mem_mb=8192
  podman machine init --cpus "$cpus" --memory "$mem_mb" --disk-size 100
  ok "Created VM: $cpus CPUs, $mem_mb MB RAM, 100 GB disk"
fi

state="$(podman machine inspect --format '{{.State}}')"
[[ "$state" == "running" ]] || podman machine start

podman run --rm quay.io/podman/hello >/dev/null && ok "Test container ran"

if [[ ! -e /var/run/docker.sock ]] && confirm "Install podman-mac-helper so Docker-only tools find Podman? (needs password)"; then
  sudo "$(brew --prefix podman)/bin/podman-mac-helper" install
  podman machine stop && podman machine start
fi
