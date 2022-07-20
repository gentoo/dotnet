# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
SLOT="0"

KEYWORDS="~amd64"
USE_DOTNET="net45"

inherit gac dotnet

SRC_URI="https://github.com/aspnet/Common/archive/1.0.0.tar.gz -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/Common-${PV}"

HOMEPAGE="https://github.com/aspnet/Common"
DESCRIPTION="A repository for shared files to be consumed across the ASPNET repos"
LICENSE="Apache-2.0" # https://github.com/aspnet/Common/blob/dev/LICENSE.txt

IUSE="+${USE_DOTNET} +debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_unpack() {
	default
	gunzip --decompress --stdout "${FILESDIR}/Microsoft.Extensions.Primitives.csproj-${PV}.gz" >"${S}/src/Microsoft.Extensions.Primitives/Microsoft.Extensions.Primitives.csproj" || die
}

src_prepare() {
	eapply_user
}

SNK_FILENAME="${S}/tools/Key.snk"

src_compile() {
	exbuild_strong /p:VersionNumber=${PV} "src/Microsoft.Extensions.Primitives/Microsoft.Extensions.Primitives.csproj"
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	sn -R "src/Microsoft.Extensions.Primitives/bin/${DIR}/Microsoft.Extensions.Primitives.dll" "tools/Key.snk" || die
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	egacinstall "src/Microsoft.Extensions.Primitives/bin/${DIR}/Microsoft.Extensions.Primitives.dll"
	einstall_pc_file "${PN}" "${PV}" "Microsoft.Extensions.Primitives"
}
