# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:  $

EAPI="5"

inherit dotnet multilib autotools-utils

DESCRIPTION="A generic framework for creating extensible applications"
HOMEPAGE="http://www.mono-project.com/Mono.Addins"
SRC_URI="https://github.com/mono/mono-addins/archive/mono-addins-1.0.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="+gtk"

RDEPEND=">=dev-lang/mono-3
	gtk? ( >=dev-dotnet/gtk-sharp-2.12.21 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"
MAKEOPTS="${MAKEOPTS} -j1" #nowarn

S=${WORKDIR}/${PN}-${P}

src_prepare() {
	eautoreconf
	autotools-utils_src_prepare
	sed -i "s;Mono.Cairo;Mono.Cairo, Version=4.0.0.0, Culture=neutral, PublicKeyToken=0738eb9f132ed756;g" Mono.Addins.Gui/Mono.Addins.Gui.csproj || die "sed failed"
}

src_configure() {
	econf $(use_enable gtk gui)
}

src_compile() {
	default
}

src_install() {
	default
	dotnet_multilib_comply
}
