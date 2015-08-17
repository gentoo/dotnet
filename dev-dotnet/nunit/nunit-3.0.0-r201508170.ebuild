# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit mono-env nuget dotnet

NAME="nunit"
HOMEPAGE="https://github.com/nunit/${NAME}"

EGIT_COMMIT="f23c6a0c27c37472e12dfc6703998fbab7ed6505"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${PF}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION="NUnit test suite for mono applications"
LICENSE="MIT" # https://github.com/nunit/nunit/blob/master/LICENSE.txt
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="developer nupkg debug"

RDEPEND=">=dev-lang/mono-4.0.2.5
	dev-dotnet/nant[nupkg]
"
DEPEND="${RDEPEND}
"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
SLN_FILE=nunit.linux.sln
METAFILETOBUILD="${S}/${SLN_FILE}"

src_prepare() {
	enuget_restore "${METAFILETOBUILD}"
}

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

	insinto "/usr/share/nunit/"
	doins build/${DIR}/*

	make_wrapper nunit "mono /usr/share/nunit/NUnit.exe"

	enupkg "${WORKDIR}/NUnit.3.0.0.nupkg"
}
