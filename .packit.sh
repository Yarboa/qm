#!/usr/bin/env bash

# Packit's default fix-spec-file often doesn't fetch version string correctly.
# This script handles any custom processing of the dist-git spec file and gets used by the
# fix-spec-file action in .packit.yaml

set -eo pipefail

# Get Version from HEAD
HEAD_VERSION=$(grep '^policy_module' qm.te | sed 's/[^0-9.]//g')

# Generate source tarball
git archive --prefix=qm-$HEAD_VERSION/ -o qm-$HEAD_VERSION.tar.gz HEAD

# RPM Spec modifications

# Update Version in spec with Version from qm.te
sed -i "s/^Version:.*/Version: $HEAD_VERSION/" qm.spec

# Update Release in spec with Packit's release envvar
sed -i "s/^Release:.*/Release: $PACKIT_RPMSPEC_RELEASE%{?dist}/" qm.spec

# Update Source tarball name in spec
sed -i "s/^Source:.*.tar.gz/Source: %{name}-$HEAD_VERSION.tar.gz/" qm.spec

# Update setup macro to use the correct build dir
sed -i "s/^%setup.*/%autosetup -Sgit -n %{name}-$HEAD_VERSION/" qm.spec
