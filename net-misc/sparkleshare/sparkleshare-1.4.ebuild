# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
GCONF_DEBUG="no" # --enable-debug does not do anything
AT_M4DIR="build/m4/sparkleshare build/m4/shamrock build/m4/shave"

inherit gnome2 mono-env autotools

MY_PN="SparkleShare"
MY_P="SparkleShare-${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="Git-based collaboration and file sharing tool"
HOMEPAGE="https://www.sparkleshare.org"
SRC_URI="https://github.com/hbons/${MY_PN}/archive/${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="" # ayatana

COMMON_DEPEND=">=dev-lang/mono-2.8
	>=dev-dotnet/gtk-sharp-2.99.1
	>=dev-dotnet/notify-sharp-3.0
	dev-dotnet/webkitgtk-sharp
	>=dev-dotnet/referenceassemblies-pcl-4.6
"
RDEPEND="${COMMON_DEPEND}
	>=dev-vcs/git-1.8
	net-misc/curl[ssl]
	net-misc/openssh
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"

src_prepare() {
	sed -i "/^SHAVE_INIT/d" configure.ac
	epatch "${FILESDIR}/${P}-mono-path.patch"
	eautoreconf
}

src_configure() {
	DOCS="News.txt legal/Authors.txt README.md"
	gnome2_src_configure --disable-appindicator
	#       $(use_enable ayatana appindicator)
	# requires >=appindicator-sharp-0.0.7
}
