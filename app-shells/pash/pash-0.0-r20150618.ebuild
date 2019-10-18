# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit dotnet

DESCRIPTION="An Open Source reimplementation of Windows PowerShell"

LICENSE="BSD || ( GPL-2+ )"   # LICENSE syntax is defined in https://wiki.gentoo.org/wiki/GLEP:23

SLOT="0"

IUSE="debug"

PROJECTNAME="Pash"
HOMEPAGE="https://github.com/Pash-Project/${PROJECTNAME}"
EGIT_COMMIT="33ffa8c6172175e678310598adcc261a4e3b22a0"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}-${PR}.zip"

KEYWORDS="~amd64 ~ppc ~x86"
DEPEND="|| ( >=dev-lang/mono-3.12.0 <dev-lang/mono-9999 )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

METAFILETOBUILD=${PROJECTNAME}.proj

src_compile() {
	# https://bugzilla.xamarin.com/show_bug.cgi?id=9340
	if use debug; then
		exbuild /p:DebugSymbols=True ${METAFILETOBUILD}
	else
		exbuild /p:DebugSymbols=False ${METAFILETOBUILD}
	fi
}

src_install() {
	elog "Installing assemblies"
	insinto /usr/lib/pash/
	doins Source/PashConsole/bin/Release/Pash.exe
	doins Source/PashConsole/bin/Release/*.dll
	if use debug; then
		doins Source/PashConsole/bin/Release/*.mdb
	fi
	make_wrapper pash "mono /usr/lib/pash/Pash.exe"
}
