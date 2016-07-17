# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit mono-env nuget dotnet

NAME="nunit"
HOMEPAGE="https://github.com/nunit/${NAME}"

EGIT_COMMIT="f8fe36f7aa806016a0d26e370774c7f5bb79d647"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${PF}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="3"

DESCRIPTION="NUnit test suite for mono applications"
LICENSE="MIT" # https://github.com/nunit/nunit/blob/master/LICENSE.txt
KEYWORDS="~amd64 ~ppc ~x86"
#USE_DOTNET="net20 net40 net45"
USE_DOTNET="net45"
IUSE="net45 developer debug nupkg doc"

RDEPEND=">=dev-lang/mono-4.0.2.5
	dev-util/nant[nupkg]
"
DEPEND="${RDEPEND}
"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
FILE_TO_BUILD=NUnit.proj
METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

src_prepare() {
	chmod -R +rw "${S}" || die
	#epatch "${FILESDIR}/removing-tests.patch"
	epatch "${FILESDIR}/removing-tests-from-nproj.patch"
	epatch "${FILESDIR}/removing-2.0-compatibiility.patch"
	enuget_restore "${METAFILETOBUILD}"
	default
}

src_compile() {
	exbuild "${METAFILETOBUILD}"
	enuspec "${FILESDIR}/${PN}.nuspec"
	# PN = Package name, for example vim.
}

src_install() {
	DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	SLOTTEDDIR="/usr/share/nunit-${SLOT}/"
	insinto "${SLOTTEDDIR}"
	doins bin/${DIR}/*.{config,dll,exe}
	# install: cannot stat 'bin/Release/*.mdb': No such file or directory
	if use developer; then
		doins bin/${DIR}/*.mdb
	fi

#	into /usr
#	dobin ${FILESDIR}/nunit-console
	make_wrapper nunit "mono ${SLOTTEDDIR}/nunit-console.exe"

	if use doc; then
#		dodoc ${WORKDIR}/doc/*.txt
#		dohtml ${WORKDIR}/doc/*.html
#		insinto /usr/share/${P}/samples
#		doins -r ${WORKDIR}/samples/*
		doins LICENSE.txt NOTICES.txt CHANGES.txt
	fi

	enupkg "${WORKDIR}/NUnit.3.0.0.nupkg"
}
