# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"

inherit dotnet gac mono-pkg-config xbuild

SRC_URI="https://github.com/haf/DotNetZip.Semverd/archive/v1.9.3.tar.gz -> ${PV}.tar.gz
	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"

S="${WORKDIR}/DotNetZip.Semverd-${PV}"

HOMEPAGE="https://github.com/haf/DotNetZip.Semverd"
DESCRIPTION="create, extract, or update zip files with C# (=DotNetZip+SemVer)"
LICENSE="MS-PL" # https://github.com/haf/DotNetZip.Semverd/blob/master/LICENSE

IUSE="net45 +gac +nupkg developer debug doc"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

KEY2="${DISTDIR}/mono.snk"

function output_filename ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "src/Zip Reduced/bin/${DIR}/Ionic.Zip.Reduced.dll"
}

src_prepare() {
	eapply "${FILESDIR}/version-${PV}.patch"
	eapply_user
}

src_compile() {
	#exbuild "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${S}/src/Ionic.snk" "src/Zip Reduced/Zip Reduced.csproj"
	exbuild_strong "src/Zip Reduced/Zip Reduced.csproj"
	sn -R "$(output_filename)" "${KEY2}" || die
}

src_install() {
	egacinstall "$(output_filename)"
	einstall_pc_file "${PN}" "${PV}" "Ionic.Zip.Reduced"
}
