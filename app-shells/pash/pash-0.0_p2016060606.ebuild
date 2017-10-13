# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"
KEYWORDS="~x86 ~amd64 ~ppc"
RESTRICT="mirror"
SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET}"

inherit msbuild eutils

DESCRIPTION="An Open Source reimplementation of Windows PowerShell"

LICENSE="BSD || ( GPL-2+ )"   # LICENSE syntax is defined in https://wiki.gentoo.org/wiki/GLEP:23

PROJECTNAME="Pash"
HOMEPAGE="https://github.com/Pash-Project/${PROJECTNAME}"
EGIT_COMMIT="8d6a48f5ed70d64f9b49e6849b3ee35b887dc254"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${P}-${PR}.tar.gz"
S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

CDEPEND="|| ( >=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999 )"
RDEPEND="${CDEPEND}"
DEPEND="${CDEPEND}"


METAFILETOBUILD=${PROJECTNAME}.proj

src_compile() {
	emsbuild "${METAFILETOBUILD}"
}

src_install() {
	insinto /usr/lib/pash/
	doins Source/PashConsole/bin/Release/Pash.exe
	doins Source/PashConsole/bin/Release/*.dll
	if use developer; then
		doins Source/PashConsole/bin/Release/*.pdb
	fi
	make_wrapper pash "mono /usr/lib/pash/Pash.exe"
}
