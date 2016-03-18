# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit mono-env nuget dotnet

NAME="nant"
HOMEPAGE="https://github.com/nant/${NAME}"

EGIT_COMMIT="45ec8aa9ad3247f340731f4e8b953c498ad3019e"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${PF}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION=".NET build tool"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="developer nupkg debug"

RDEPEND=">=dev-lang/mono-4.0.2.5"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
SLN_FILE=NAnt.sln
METAFILETOBUILD="${S}/${SLN_FILE}"

# This build is not parallel build friendly
#MAKEOPTS="${MAKEOPTS} -j1"

src_compile() {
	exbuild "${METAFILETOBUILD}"
	enuspec "${FILESDIR}/${SLN_FILE}.nuspec"
}

src_install() {
	DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	insinto "/usr/share/nant/"
	doins build/${DIR}/*

	make_wrapper nant "mono /usr/share/nant/NAnt.exe"

	enupkg "${WORKDIR}/NAnt.0.93.5019.nupkg"

	dodoc README.txt
}
