# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit mono-env nuget dotnet

NAME="mono-packaging-tools"
HOMEPAGE="https://github.com/ArsenShnurkov/${NAME}"

EGIT_COMMIT="50b799d3bcfd12fd4d1c651f55f8dcf81d6ac2d2"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PF}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION="mono packaging helpers"
LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
IUSE="developer nupkg debug"

COMMON_DEPENDENCIES=">=dev-lang/mono-4.2
	dev-dotnet/mono-options[gac]
	>=dev-dotnet/eto-parse-1.4.0[nupkg]
	"
DEPEND="${COMMON_DEPENDENCIES}
	"
RDEPEND="${COMMON_DEPENDENCIES}
	"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
# PN = Package name, for example vim.
SLN_FILE=${PN}.sln
METAFILETOBUILD="${S}/${SLN_FILE}"
NUSPEC_ID="${NAME}"
NUSPEC_VERSION=$(get_version_component_range 1-3)"${PR//r/.}"

src_prepare() {
	#change version in .nuspec
	# PV = Package version (excluding revision, if any), for example 6.3.
	# It should reflect the upstream versioning scheme
	sed "s/@VERSION@/${NUSPEC_VERSION}/g" "${FILESDIR}/${NUSPEC_ID}.nuspec" >"${S}/${NUSPEC_ID}.nuspec" || die

	enuget_restore "${METAFILETOBUILD}"
	default
}

src_compile() {
	exbuild "${METAFILETOBUILD}"
	enuspec "${NUSPEC_ID}.nuspec"
}

install_tool() {
	MONO=/usr/bin/mono
	doins $1/bin/${DIR}/*
	if use developer; then
		make_wrapper $1 "${MONO} --debug /usr/share/${PN}/$1.exe"
	else
		make_wrapper $1 "${MONO} /usr/share/${PN}/$1.exe"
	fi;
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
	install_tool mpt-nuget

	enupkg "${WORKDIR}/${NUSPEC_ID}.${NUSPEC_VERSION}.nupkg"

	dodoc README.md
}
