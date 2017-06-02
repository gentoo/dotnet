# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: mpt-r20150903.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: wrappers for mono-packaging-tools package
# @DESCRIPTION:
# This eclass include function wrappers

#inherit eutils versionator mono-env dotnet

TOOLS_PATH=/usr/bin

DEPEND+=" >=dev-util/mono-packaging-tools-1.4.3"

# @FUNCTION: empt-gitmodules
# @DESCRIPTION:  wraps mpt-gitmodules
empt-gitmodules() {
	"${TOOLS_PATH}/mpt-gitmodules" $@ || die
}

# @FUNCTION: empt-sln
# @DESCRIPTION:  wraps mpt-sln
empt-sln() {
	"${TOOLS_PATH}/mpt-sln" $@ || die
}

# @FUNCTION: empt-csproj
# @DESCRIPTION:  wraps mpt-csproj
empt-csproj() {
	"${TOOLS_PATH}/mpt-csproj" $@ || die
}

# @FUNCTION: empt-machine
# @DESCRIPTION:  wraps mpt-machine
empt-machine() {
	"${TOOLS_PATH}/mpt-machine" $@ || die
}

# @FUNCTION: empt-nuget
# @DESCRIPTION:  wraps empt-nuget
empt-nuget() {
	"${TOOLS_PATH}/mpt-nuget" $@ || die
}
