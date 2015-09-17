# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit mono-env nuget dotnet

NAME="mono-packaging-tools"
HOMEPAGE="https://github.com/ArsenShnurkov/${NAME}"

EGIT_COMMIT="ee72ffc532722db0c77778f9429cef5727ae81cc"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${PF}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION="mono packaging helpers"
LICENSE="GPL-3"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="developer nupkg debug"

COMMON_DEPENDENCIES=">=dev-lang/mono-4.2"
RDEPEND="${COMMON_DEPENDENCIES}"
DEPEND="${COMMON_DEPENDENCIES}"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
# PN = Package name, for example vim.
SLN_FILE=${PN}.sln
METAFILETOBUILD="${S}/${SLN_FILE}"
NUGET_PACKAGE_ID="${NAME}"

src_prepare() {
	#change version in .nuspec
	# PV = Package version (excluding revision, if any), for example 6.3.
	# It should reflect the upstream versioning scheme
	sed "s/@VERSION@/${PV}/g" "${FILESDIR}/${NUGET_PACKAGE_ID}.nuspec" >"${S}/${NUGET_PACKAGE_ID}.nuspec" || die

	enuget_restore "${METAFILETOBUILD}"
}

src_compile() {
	exbuild "${METAFILETOBUILD}"
	enuspec "${NUGET_PACKAGE_ID}.nuspec"
}

install_tool() {
	doins $1/bin/${DIR}/*
	make_wrapper $1 "mono /usr/share/${PN}/$1.exe"
}

src_install() {
	DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	insinto "/usr/share/${PN}/"
	install_tool mpt-gitmodules
	install_tool mpt-sln
	install_tool mpt-csproj
	install_tool mpt-machine

	enupkg "${WORKDIR}/${PN}.${PV}.nupkg"

	dodoc README.md
}
