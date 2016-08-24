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
IUSE="${USE_DOTNET} debug test +developer +aot +nupkg +gac +pkg-config doc"

inherit nupkg

NAME="mono-packaging-tools"
HOMEPAGE="http://arsenshnurkov.github.io/mono-packaging-tools"

REPOSITORY_URL="https://github.com/ArsenShnurkov/${NAME}"

EGIT_COMMIT="2420590310aa420e9b5d6edc170660ae496cd004"
SRC_URI="${REPOSITORY_URL}/archive/${EGIT_COMMIT}.tar.gz -> ${PF}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION="mono packaging helpers"
LICENSE="GPL-3"
LICENSE_URL="https://raw.githubusercontent.com/ArsenShnurkov/mono-packaging-tools/master/LICENSE"

COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )
	dev-dotnet/mono-options[gac]
	>=dev-dotnet/slntools-1.1.3_p201508170-r1[gac]
	>=dev-dotnet/eto-parse-1.4.0[gac]
	"
DEPEND="${COMMON_DEPENDENCIES}
	sys-apps/sed"
RDEPEND="${COMMON_DEPENDENCIES}
	"

SLN_FILE="mono-packaging-tools.sln"
METAFILETOBUILD="${S}/${SLN_FILE}"
NUSPEC_ID="${NAME}"
COMMIT_DATE_INDEX="$(get_version_component_count ${PV} )"
COMMIT_DATE="$(get_version_component_range $COMMIT_DATE_INDEX ${PV} )"
NUSPEC_VERSION="$(get_version_component_range 1-3)${COMMIT_DATE//p/.}"
NUSPEC_FILENAME="${PN}.nuspec"
#ICON_FILENAME="${PN}.png"
#ICON_FINALNAME="${NUSPEC_ID}.${NUSPEC_VERSION}.png"
#ICON_PATH="$(get_nuget_trusted_icons_location)/${ICON_FINALNAME}"

src_prepare() {
	#change version in .nuspec
	# PV = Package version (excluding revision, if any), for example 6.3.
	# It should reflect the upstream versioning scheme
	sed "s/@VERSION@/${NUSPEC_VERSION}/g" "${FILESDIR}/${NUSPEC_ID}.nuspec" >"${S}/${NUSPEC_ID}.nuspec" || die

	# restoring is not necessary after switching to GAC references
	# enuget_restore "${METAFILETOBUILD}"
	default
}

src_compile() {
	exbuild "${METAFILETOBUILD}"
	enuspec "${NUSPEC_ID}.nuspec"
}

install_tool() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	MONO=/usr/bin/mono

	# installs .exe, .dll, .mdb (if exists), .exe.config (if any)
	doins "$1"/bin/${DIR}/*
	if use developer; then
		make_wrapper "$1" "${MONO} --debug /usr/share/${PN}-${SLOT}/$1.exe"
	else
		make_wrapper "$1" "${MONO} /usr/share/${PN}-${SLOT}/$1.exe"
	fi;
}

src_install() {
	insinto "/usr/share/${PN}-${SLOT}/"
	install_tool mpt-gitmodules
	install_tool mpt-sln
	install_tool mpt-csproj
	install_tool mpt-machine
	install_tool mpt-nuget

	enupkg "${WORKDIR}/${NUSPEC_ID}.${NUSPEC_VERSION}.nupkg"

	if use doc; then
		dodoc README.md
	fi
}
