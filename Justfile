default:
    just --list

test:
    #!/usr/bin/env sh

    set -euo pipefail

    root="$PWD"
    cd test
    nix flake lock --override-input profile-parts $root

    nix flake show --all-systems
    nix flake check
