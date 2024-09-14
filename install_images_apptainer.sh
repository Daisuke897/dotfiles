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
          docker://public.ecr.aws/aws-cli/aws-cli

apptainer build \
          -F \
          ./images/cfn-lint.sif \
          ./def_files/cfn_lint.def
