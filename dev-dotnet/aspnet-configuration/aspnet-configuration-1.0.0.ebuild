# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

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
KEYWORDS="~amd64 ~ppc ~x86"

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

src_compile() {
	exbuild_strong /p:VersionNumber=${PV} "src/src.sln"
}

src_install() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi
	egacinstall "src/Microsoft.Extensions.Configuration.Abstractions/bin/${CONFIGURATION}/Microsoft.Extensions.Configuration.Abstractions.dll"
	egacinstall "src/Microsoft.Extensions.Configuration/bin/${CONFIGURATION}/Microsoft.Extensions.Configuration.dll"
	einstall_pc_file "${PN}" "${PV}" "Microsoft.Extensions.Configuration.Abstractions" "Microsoft.Extensions.Configuration"
}
