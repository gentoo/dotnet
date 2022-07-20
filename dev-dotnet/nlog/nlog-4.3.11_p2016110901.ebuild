# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS="~amd64"
RESTRICT="mirror"
USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac +nupkg developer debug doc"

SLOT="0"

inherit mono-env gac nupkg versionator

NAME="NLog"
HOMEPAGE="https://github.com/NLog/${NAME}"

EGIT_COMMIT="71c8b60b25cab4cdb56c58ab042c68502e9dbbb0"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION=" NLog - Advanced .NET and Silverlight Logging"
LICENSE="BSD" # https://github.com/NLog/NLog/blob/master/LICENSE.txt

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
	>=dev-dotnet/msbuildtasks-1.5.0.196
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

FILE_TO_BUILD=./src/NLog.mono.sln
METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

COMMIT_DATE_INDEX="$(get_version_component_count ${PV} )"
COMMIT_DATEANDSEQ="$(get_version_component_range $COMMIT_DATE_INDEX ${PV} )"
NUSPEC_VERSION=$(get_version_component_range 1-3)"${COMMIT_DATEANDSEQ//p/.}"
ASSEMBLY_VERSION=$(get_version_component_range 1-3).$((${COMMIT_DATEANDSEQ//p/} % 65535))

src_prepare() {
	chmod -R +rw "${S}" || die

	eapply "${FILESDIR}/NLog.nuspec.patch"
	eapply "${FILESDIR}/csproj.patch"

	cd "${S}"
	mpt-sln --sln-file "${METAFILETOBUILD}" --remove-proj "NLog.UnitTests.mono" || die

	eapply_user
}

src_compile() {
	exbuild_strong /p:VersionNumber=${ASSEMBLY_VERSION} "${METAFILETOBUILD}"

	NUSPEC_PROPERTIES="BuildVersion=${NUSPEC_VERSION};platform=Mono*"
	enuspec -Prop ${NUSPEC_PROPERTIES} ./src/NuGet/NLog/NLog.nuspec
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	egacinstall "${S}/build/bin/${DIR}/Mono 2.x/NLog.dll"
	egacinstall "${S}/build/bin/${DIR}/Mono 2.x/NLog.Extended.dll"
	einstall_pc_file ${PN} ${ASSEMBLY_VERSION} NLog NLog.Extended

	if use doc; then
#		doins xml comments file
		doins LICENSE.txt
	fi

	enupkg "${WORKDIR}/NLog.${NUSPEC_VERSION}.nupkg"
}
