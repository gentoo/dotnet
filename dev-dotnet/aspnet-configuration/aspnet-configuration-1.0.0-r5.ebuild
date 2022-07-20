# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac developer debug doc"

inherit gac dotnet

SRC_URI="https://github.com/aspnet/Configuration/archive/1.0.0.tar.gz -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/Configuration-1.0.0"

HOMEPAGE="https://github.com/aspnet/Configuration"
DESCRIPTION="Interfaces and providers for accessing configuration files"
LICENSE="Apache-2.0" # https://github.com/aspnet/Configuration/blob/dev/LICENSE.txt
KEYWORDS="~amd64"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
	dev-dotnet/aspnet-common
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	tar xzvpf "${FILESDIR}/build-scripts-1.0.0.tar.gz" -C "${S}" || die
	eapply_user
}

SNK_FILENAME="${S}/tools/Key.snk"

src_compile() {
	exbuild_strong /p:TargetFrameworkVersion=v4.5 /p:VersionNumber=${PV} "src/src.sln"
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	sn -R "src/Microsoft.Extensions.Configuration.Abstractions/bin/${DIR}/Microsoft.Extensions.Configuration.Abstractions.dll" "${SNK_FILENAME}" || die
	sn -R "src/Microsoft.Extensions.Configuration/bin/${DIR}/Microsoft.Extensions.Configuration.dll" "${SNK_FILENAME}" || die
}

src_install() {
	if use debug; then
		DIR=Debug
	else
		DIR=Release
	fi
	egacinstall "src/Microsoft.Extensions.Configuration.Abstractions/bin/${DIR}/Microsoft.Extensions.Configuration.Abstractions.dll"
	egacinstall "src/Microsoft.Extensions.Configuration/bin/${DIR}/Microsoft.Extensions.Configuration.dll"
	einstall_pc_file "${PN}" "${PV}" "Microsoft.Extensions.Configuration.Abstractions" "Microsoft.Extensions.Configuration"
}
