# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools eutils dotnet

MY_P=${PN}-${PV#*_pre}

DESCRIPTION="a C# client implementation for Desktop Notifications"
HOMEPAGE="https://www.ndesk.org/NotifySharp"
#SRC_URI="mirror://gentoo/${MY_P}.tar.bz2"
SRC_URI="https://github.com/meebey/notify-sharp/archive/${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="doc"

RDEPEND=">=dev-lang/mono-4.0.2.5
	>=dev-dotnet/gtk-sharp-2.12.21:2
	>=dev-dotnet/dbus-sharp-0.7:2.0
	>=dev-dotnet/dbus-sharp-glib-0.5:2.0
	>=x11-libs/libnotify-0.4.5"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	sed -i "s@gmcs@mcs@g" configure.ac || die
	sed -i "s@dbus-sharp-1.0@dbus-sharp-2.0@g" configure.ac || die
	sed -i "s@dbus-sharp-glib-1.0@dbus-sharp-glib-2.0@g" configure.ac || die
	eautoreconf
	default
}

src_configure() {
	econf $(use_enable doc docs)
}
