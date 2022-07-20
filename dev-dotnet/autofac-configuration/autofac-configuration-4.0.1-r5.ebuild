# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
SLOT="4"

KEYWORDS="~amd64"
USE_DOTNET="net45"

inherit gac dotnet

SRC_URI="https://github.com/autofac/Autofac.Configuration/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/Autofac.Configuration-${PV}"

HOMEPAGE="https://github.com/autofac/Autofac.Configuration"
DESCRIPTION="Configuration support for Autofac IoC"
LICENSE="MIT" # https://github.com/autofac/Autofac.Configuration/blob/develop/LICENSE

IUSE="+${USE_DOTNET} +debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
	dev-dotnet/autofac:4
	dev-dotnet/aspnet-configuration
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_unpack() {
	default
	tar xzvpf "${FILESDIR}/Autofac.Configuration.csproj-${PV}.tar.gz" -C "${S}" || die
}

src_prepare() {
	eapply_user
}

SNK_FILENAME="${S}/Autofac.snk"

src_compile() {
	exbuild_strong /p:TargetFrameworkVersion=v4.5 /p:VersionNumber=${PV} "src/Autofac.Configuration/Autofac.Configuration.csproj"
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	sn -R "src/Autofac.Configuration/bin/${DIR}/Autofac.Configuration.dll" "${SNK_FILENAME}" || die
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	egacinstall "src/Autofac.Configuration/bin/${DIR}/Autofac.Configuration.dll"
	einstall_pc_file "${PN}" "${PV}" "Autofac.Configuration.dll"
}
