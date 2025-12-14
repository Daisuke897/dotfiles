#!/usr/bin/env bash
set -euo pipefail

mkdir -p images/i

IMAGES_DIR="images"
DEF_DIR="def_files"

mkdir -p "$IMAGES_DIR"

build() {
  local name="$1"
  local image="$IMAGES_DIR/${name}.sif"
  local def="$DEF_DIR/${name}.def"

  if [[ -f "$image" ]]; then
    echo "==> Skipping $name (image already exists)"
    return 0
  fi

  echo "==> Building $name"
  apptainer build "$image" "$def"
}

build julia_language_server
build fortran_language_server
build latex_language_server
build rust_language_server
build python_pyright
build python_ruff
build eslint_language_server
build vue_language_server
build typescript_language_server
build aws-cli
build cfn_lint
build marksman_x64
build json_language_server
build css_language_server
build astro_language_server
