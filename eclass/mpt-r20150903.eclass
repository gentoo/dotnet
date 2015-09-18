# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: mpt-r20150903.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: wrappers for mono-packaging-tools package
# @DESCRIPTION:
# This eclass include function wrappers

#inherit eutils versionator mono-env dotnet

TOOLS_PATH=/usr/bin

DEPEND+=" dev-util/mono-packaging-tools"

# @FUNCTION: empt-gitmodules
# @DESCRIPTION:  wraps mpt-gitmodules
empt-gitmodules() {
	"${TOOLS_PATH}/mpt-gitmodules" $@ || die
}

# @FUNCTION: empt-sln
# @DESCRIPTION:  wraps mpt-sln
empt-sln() {
	"${TOOLS_PATH}/empt-sln" $@ || die
}

# @FUNCTION: empt-csproj
# @DESCRIPTION:  wraps mpt-csproj
empt-csproj() {
	"${TOOLS_PATH}/empt-csproj" $@ || die
}

# @FUNCTION: empt-machine
# @DESCRIPTION:  wraps empt-machine
empt-machine() {
	"${TOOLS_PATH}/empt-machine" $@ || die
}

# @FUNCTION: empt-nuget
# @DESCRIPTION:  wraps empt-nuget
empt-nuget() {
	"${TOOLS_PATH}/empt-nuget" $@ || die
}
