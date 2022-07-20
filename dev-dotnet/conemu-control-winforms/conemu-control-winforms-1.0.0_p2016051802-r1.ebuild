# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

USE_DOTNET="net45"
inherit gac dotnet
IUSE+=" +net45 +pkg-config debug"

KEYWORDS="~amd64"

DESCRIPTION="console emulator control, embeds a console view in a Windows Forms window"

NAME="conemu-inside"
#HOMEPAGE="https://github.com/Maximus5/${NAME}"
HOMEPAGE="https://conemu.github.io/"

EGIT_COMMIT="b4800195f09b86eca14c4b96141a78136ee1d872"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

LICENSE="BSD" # https://github.com/Maximus5/ConEmu/blob/master/Release/ConEmu/License.txt
SLOT="0"

src_prepare() {
	eapply "${FILESDIR}/add-release-configuration.patch"
	eapply "${FILESDIR}/make-CommandLineBuilder-class-public.patch"
	eapply_user
}

src_compile() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi
	exbuild_raw /p:SignAssembly=true /p:AssemblyOriginatorKeyFile="${S}/ConEmuWinForms/Snk.Snk" /p:VersionNumber=1.0.0.2016051802 /p:Configuration=${CONFIGURATION} ConEmuWinForms/ConEmuWinForms.csproj
}

src_install() {
	if use debug; then
		DIR=Debug
	else
		DIR=Release
	fi
	egacinstall "${S}/ConEmuWinForms/bin/${DIR}/ConEmu.WinForms.dll"
	einstall_pc_file "${PN}" "${PV}" "ConEmu.WinForms"
}
