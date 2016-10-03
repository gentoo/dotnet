# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
SLOT="3"

KEYWORDS="~amd64 ~ppc ~x86"
USE_DOTNET="net45"

inherit gac dotnet

NAME="Autofac.Configuration"
HOMEPAGE="https://github.com/Autofac/${NAME}"

EGIT_COMMIT="ce3c12c67600a145ba31a21f3b3be27c4473f2f3"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/autofac/Autofac.Configuration"
DESCRIPTION="Configuration support for Autofac IoC"
LICENSE="MIT" # https://github.com/autofac/Autofac.Configuration/blob/develop/LICENSE

IUSE="+${USE_DOTNET} +debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
	dev-dotnet/autofac:3
	dev-dotnet/aspnet-configuration
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	eapply "${FILESDIR}/Autofac.Configuration.csproj-3.5.2.patch"
	eapply_user
}

src_compile() {
	exbuild_strong /p:VersionNumber=${PV} "Autofac.Configuration.csproj"
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	egacinstall "bin/${DIR}/Autofac.Configuration.dll"
	einstall_pc_file "${PN}" "${PV}" "Autofac.Configuration.dll"
}
