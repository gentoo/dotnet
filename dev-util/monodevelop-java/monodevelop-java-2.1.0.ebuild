# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/monodevelop-java/monodevelop-java-2.0.ebuild,v 1.1 2009/03/30 18:58:29 loki_val Exp $

EAPI=2

inherit mono multilib

DESCRIPTION="Java Extension for MonoDevelop"
HOMEPAGE="http://www.monodevelop.com/"
SRC_URI="http://ftp.novell.com/pub/mono/sources/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

RDEPEND=">=dev-lang/mono-2.4
	>=dev-dotnet/gtk-sharp-2.12.9
	>=dev-dotnet/glade-sharp-2.12.9
	>=dev-dotnet/mono-addins-0.3.1
	=dev-util/monodevelop-${PV}*
	>=dev-dotnet/ikvm-0.36.0.11"

DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.19"

src_configure() {
	MD_JAVA_CONFIG=""
	if use debug; then
		MD_JAVA_CONFIG="--config=DEBUG"
	else
		MD_JAVA_CONFIG="--config=RELEASE"
	fi

	./configure \
		--prefix=/usr		\
		${MD_JAVA_CONFIG}	\
	|| die "configure failed"
}

src_compile() {
	emake -j1 || die "make failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "install failed"
	mono_multilib_comply
}
