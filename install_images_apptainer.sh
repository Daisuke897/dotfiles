#!/bin/bash

mkdir -p images/

apptainer build \
          -F \
	  images/julia_language_server.sif \
	  def_files/julia_language_server.def

apptainer build \
          -F \
	  images/fortran_language_server.sif \
	  def_files/fortran_language_server.def

apptainer build \
          -F \
	  images/latex_language_server.sif \
	  def_files/latex_language_server.def

apptainer build \
          -F \
	  images/rust_language_server.sif \
	  def_files/rust_language_server.def

apptainer build \
          -F \
	  ./images/python_pyright.sif \
	  ./def_files/python_pyright.def

apptainer build \
          -F \
	  ./images/python_ruff.sif \
	  ./def_files/python_ruff.def

apptainer build \
          -F \
          ./images/eslint_language_server.sif \
          ./def_files/eslint_language_server.def

apptainer build \
          -F \
          ./images/vue_language_server.sif \
          ./def_files/vue_language_server.def

apptainer build \
          -F \
          ./images/typescript_language_server.sif \
          ./def_files/typescript_language_server.def

apptainer build \
          -F \
          ./images/aws-cli.sif \
          ./def_files/awscli.def

apptainer build \
          -F \
          ./images/cfn-lint.sif \
          ./def_files/cfn_lint.def

apptainer build \
          -F \
          ./images/ffmpeg.sif \
          ./def_files/ffmpeg.def

apptainer build \
          -F \
          ./images/marksman_x64.sif \
          ./def_files/marksman_x64.def

apptainer build \
          -F \
          ./images/json_language_server.sif \
          ./def_files/json_language_server.def

apptainer build \
          -F \
          ./images/css_language_server.sif \
          ./def_files/css_language_server.def

apptainer build \
          -F \
          ./images/astro_language_server.sif \
          ./def_files/astro_language_server.def
