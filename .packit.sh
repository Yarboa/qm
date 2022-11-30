#!/usr/bin/env bash

# Packit's default fix-spec-file often doesn't fetch version string correctly.
# This script handles any custom processing of the dist-git spec file and gets used by the
# fix-spec-file action in .packit.yaml

set -eo pipefail

# Get Version from HEAD
HEAD_VERSION=$(grep '^policy_module' qm.te | sed 's/[^0-9.]//g')

# Generate source tarball
git archive --prefix=qm-selinux-$HEAD_VERSION/ -o qm-selinux-$HEAD_VERSION.tar.gz HEAD

# RPM Spec modifications

# Fix Version
sed -i "s/^Version:.*/Version: $HEAD_VERSION/" qm-selinux.spec

# Fix Release
sed -i "s/^Release: %autorelease/Release: $PACKIT_RPMSPEC_RELEASE%{?dist}/" qm-selinux.spec

# Fix Source0
sed -i "s/^Source0:.*.tar.gz/Source0: %{name}-$HEAD_VERSION.tar.gz/" qm-selinux.spec

# Fix autosetup
sed -i "s/^%autosetup.*/%autosetup -Sgit -n %{name}-$HEAD_VERSION/" qm-selinux.spec
