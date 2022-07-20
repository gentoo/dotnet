# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6 # >=portage-2.2.25
KEYWORDS="~amd64"
RESTRICT="mirror"

USE_DOTNET="net45"
# debug = debug configuration (symbols and defines for debugging)
# test = allow NUnit tests to run
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# aot = compile to machine code and store to disk during install, to save time later during startups
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
IUSE="+${USE_DOTNET} debug +developer test +aot doc"

TOOLS_VERSION=14.0

inherit gac nupkg versionator

get_revision()
{
	git rev-list --count $2..$1
}

get_dlldir() {
	echo /usr/lib64/mono/${PN}
}

NAME="mono-packaging-tools"
HOMEPAGE="https://arsenshnurkov.github.io/mono-packaging-tools"

REPOSITORY_URL="https://github.com/ArsenShnurkov/${NAME}"

EGIT_COMMIT="98dfea6ddcc47de78a59014728f823bfe773fb25"
SRC_URI="${REPOSITORY_URL}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION="Command line utilities for packaging mono assemblies with portage"
LICENSE="GPL-3"
LICENSE_URL="https://raw.githubusercontent.com/ArsenShnurkov/mono-packaging-tools/master/LICENSE"

COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )
	dev-dotnet/mono-options[gac]
	>=dev-dotnet/slntools-1.1.3_p201508170-r1[gac]
	>=dev-dotnet/eto-parse-1.4.0[gac]
	"
DEPEND="${COMMON_DEPENDENCIES}
	dev-dotnet/msbuildtasks
	sys-apps/sed"
RDEPEND="${COMMON_DEPENDENCIES}
	"

NUSPEC_VERSION=${PV}
ASSEMBLY_VERSION=${PV}

SLN_FILE="mono-packaging-tools.sln"
METAFILETOBUILD="${S}/${SLN_FILE}"
NUSPEC_ID="${NAME}"
COMMIT_DATE_INDEX="$(get_version_component_count ${PV} )"
COMMIT_DATE="$(get_version_component_range $COMMIT_DATE_INDEX ${PV} )"
NUSPEC_FILENAME="${PN}.nuspec"
#ICON_FILENAME="${PN}.png"
#ICON_FINALNAME="${NUSPEC_ID}.${NUSPEC_VERSION}.png"
#ICON_PATH="$(get_nuget_trusted_icons_location)/${ICON_FINALNAME}"

src_prepare() {
	eapply "${FILESDIR}/MSBuildExtensionsPath.patch"

	#change version in .nuspec
	# PV = Package version (excluding revision, if any), for example 6.3.
	# It should reflect the upstream versioning scheme
	sed "s/@VERSION@/${NUSPEC_VERSION}/g" "${FILESDIR}/${NUSPEC_ID}.nuspec" >"${S}/${NUSPEC_ID}.nuspec" || die

	# restoring is not necessary after switching to GAC references
	# enuget_restore "${METAFILETOBUILD}"
	default
}

src_compile() {
	exbuild_strong /p:VersionNumber="${ASSEMBLY_VERSION}" "${METAFILETOBUILD}"
	enuspec "${NUSPEC_ID}.nuspec"
}

src_install() {
	# install dlls
	insinto "$(get_dlldir)/slot-${SLOT}"
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	doins mpt-core/bin/${DIR}/mpt-core.dll
	dosym slot-${SLOT}/mpt-core.dll $(get_dlldir)/mpt-core.dll
	einstall_pc_file ${PN} ${ASSEMBLY_VERSION} mpt-core

	insinto "/usr/share/${PN}/slot-${SLOT}"
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

pkg_prerm() {
	if use gac; then
		# TODO determine version for uninstall from slot-N dir
		einfo "removing from GAC"
		gacutil -u mpt-core
		# don't die, it there is no such assembly in GAC
	fi
}

pkg_postinst() {
	if use gac; then
		einfo "adding to GAC"
		gacutil -i "$(get_dlldir)/slot-${SLOT}/mpt-core.dll" || die
	fi
}

install_tool() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	# installs .exe, .exe.config (if any), .mdb (if exists)
	doins "$1"/bin/${DIR}/*.exe
	if [ -f "$1"/bin/${DIR}/*.exe.config ]; then
		doins "$1"/bin/${DIR}/*.exe.config
	fi
	if use developer; then
		doins "$1"/bin/${DIR}/*.mdb
	fi

	MONO=/usr/bin/mono

	if use debug; then
		make_wrapper "$1" "${MONO} --debug /usr/share/${PN}/slot-${SLOT}/$1.exe"
	else
		make_wrapper "$1" "${MONO} /usr/share/${PN}/slot-${SLOT}/$1.exe"
	fi;
}
