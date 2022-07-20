# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac +nupkg developer debug doc"

inherit gac dotnet nupkg versionator

NAME="Pliant"
HOMEPAGE="https://github.com/patrickhuber/${NAME}"
EGIT_COMMIT="19ecea89bf35cd2ba9426cdd862773dab3b0af6d"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="modified Earley parser in C# inspired by the Marpa Parser project"
LICENSE="MIT" # https://github.com/patrickhuber/Pliant/blob/master/LICENSE.md

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	>=dev-dotnet/msbuildtasks-1.5.0.196
"

src_prepare() {
	eapply "${FILESDIR}/csproj.patch"
	patch_nuspec_file "libraries/Pliant/Pliant.nuspec"
	eapply_user
}

COMMIT_DATE_INDEX="$(get_version_component_count ${PV} )"
COMMIT_DATEANDSEQ="$(get_version_component_range $COMMIT_DATE_INDEX ${PV} )"
NUSPEC_VERSION=$(get_version_component_range 1-3)"${COMMIT_DATEANDSEQ//p/.}"
ASSEMBLY_VERSION=$(get_version_component_range 1-3).$((${COMMIT_DATEANDSEQ//p/} % 65535))

get_bin_dir()
{
	echo "libraries/Pliant/bin"
}

get_output_dir()
{
	local OUTPUT_DIR="$(get_bin_dir)/"
	if use debug; then
		OUTPUT_DIR+="Debug"
	else
		OUTPUT_DIR+="Release"
	fi
	echo "${OUTPUT_DIR}"
}

DLL_NAME="${NAME}"

get_output_filepath()
{
	echo "$(get_output_dir)/${DLL_NAME}.dll"
}

patch_nuspec_file()
{
	if use nupkg; then
		FILES_STRING=`sed 's/[\/&]/\\\\&/g' <<-EOF || die "escaping replacement string characters"
		  <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
		    <file src="$(get_output_dir)/${DLL_NAME}.*" target="lib/net45/" />
		  </files>
		EOF
		`
		sed -i 's/<\/package>/'"${FILES_STRING//$'\n'/\\$'\n'}"'\n&/g' $1 || die "escaping line endings"
	fi
}

src_compile() {
	exbuild_strong /p:VersionNumber=${ASSEMBLY_VERSION} "libraries/Pliant/Pliant.csproj"

	NUSPEC_VERSION="${PV/_p/.}"
	NUSPEC_PROPERTIES="id=${NAME};version=${NUSPEC_VERSION};author=Patrick Huber;description=${DESCRIPTION}"
	enuspec "libraries/Pliant/Pliant.nuspec"
}

src_install() {
	einfo ${ASSEMBLY_VERSION}

	enupkg "${WORKDIR}/${NAME}.${NUSPEC_VERSION}.nupkg"

#	egacinstall "$(get_output_filepath)"
	insinto "/usr/lib/mono/${EBUILD_FRAMEWORK}"
	doins "$(get_output_filepath)"
	einstall_pc_file "${PN}" ${ASSEMBLY_VERSION} "Pliant"
}

pkg_postinst()
{
	egacadd "/usr/lib/mono/${EBUILD_FRAMEWORK}/${DLL_NAME}.dll"
}

pkg_prerm()
{
	egacdel "${DLL_NAME}"
}
