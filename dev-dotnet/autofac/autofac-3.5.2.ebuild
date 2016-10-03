# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
SLOT="3"

KEYWORDS="~amd64 ~ppc ~x86"
USE_DOTNET="net45"

inherit gac dotnet

NAME="Autofac"
HOMEPAGE="https://github.com/Autofac/${NAME}"

EGIT_COMMIT="c985cda5483dcd4d2fbc395a4001be12cc07ee84"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/autofac/Autofac"
DESCRIPTION="An addictive .NET IoC container"
LICENSE="MIT" # https://github.com/autofac/Autofac/blob/develop/LICENSE

IUSE="+${USE_DOTNET} +debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	eapply "${FILESDIR}/Autofac.csproj-3.5.2.patch"
	eapply "${FILESDIR}/reflection-extension-3.5.2.patch"
	eapply_user
}

src_compile() {
	exbuild_strong /p:VersionNumber=${PV} "Core/Source/Autofac/Autofac.csproj"
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	egacinstall "Core/Source/Autofac/bin/${DIR}/Autofac.dll"
	einstall_pc_file "${PN}" "${PV}" "Autofac"
}
