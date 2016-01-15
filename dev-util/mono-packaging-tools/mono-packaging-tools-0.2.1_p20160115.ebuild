# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6 # >=portage-2.2.25
KEYWORDS="~x86 ~amd64"

USE_DOTNET="net45"
# debug = debug configuration (symbols and defines for debugging)
# test = allow NUnit tests to run
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# aot = compile to machine code and store to disk during install, to save time later during startups
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
IUSE="${USE_DOTNET} debug test +developer +aot +nupkg +gac +pkg-config"

inherit nupkg

HOMEPAGE="http://arsenshnurkov.github.io/mono-packaging-tools"
DESCRIPTION="mono packaging helpers"
LICENSE="GPL-3"
LICENSE_URL="https://raw.githubusercontent.com/ArsenShnurkov/mono-packaging-tools/master/LICENSE"

SLOT="0"

REPOSITORY_NAME="mono-packaging-tools"
REPOSITORY_URL="https://github.com/ArsenShnurkov/${REPOSITORY_NAME}"
EGIT_COMMIT="17bfa8a2c3a7c3f6507e0226764066750ef91f03"
SRC_URI="${REPOSITORY_URL}/archive/${EGIT_COMMIT}.zip -> ${P}.zip
	mirror://gentoo/mono.snk.bz2"
S="${WORKDIR}/${REPOSITORY_NAME}-${EGIT_COMMIT}"

COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )
	>=dev-dotnet/eto-parse-1.4.0[nupkg]
	"
DEPEND="${COMMON_DEPENDENCIES}
	"
RDEPEND="${COMMON_DEPENDENCIES}
	"

METAFILETOBUILD="${S}/${SLN_FILE}"

METAFILETOBUILD="mono-packaging-tools.sln"
NUSPEC_FILENAME="${PN}.nuspec"
NUSPEC_ID="${REPOSITORY_NAME}"
COMMIT_DATE_INDEX="$(get_version_component_count ${PV} )"
COMMIT_DATE="$(get_version_component_range $COMMIT_DATE_INDEX ${PV} )"
NUSPEC_VERSION="$(get_version_component_range 1-3)${COMMIT_DATE//p/.}${PR//r/}"
ICON_FILENAME="${PN}.png"
ICON_FINALNAME="${NUSPEC_ID}.${NUSPEC_VERSION}.png"
ICON_PATH="$(get_nuget_trusted_icons_location)/${ICON_FINALNAME}"

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
	MONO=/usr/bin/mono
	doins $1/bin/${DIR}/*
	if use developer; then
		make_wrapper $1 "${MONO} --debug /usr/share/${PN}/$1.exe"
	else
		make_wrapper $1 "${MONO} /usr/share/${PN}/$1.exe"
	fi;
}

src_install() {
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

	enupkg "${WORKDIR}/${PN}.${PV}.nupkg"

	dodoc README.md
}
