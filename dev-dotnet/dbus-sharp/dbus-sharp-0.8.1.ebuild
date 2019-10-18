# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit autotools mono-env dotnet eutils

DESCRIPTION="D-Bus for .NET"
HOMEPAGE="https:://github.com/mono/dbus-sharp"
SRC_URI="mirror://github/mono/${PN}/${P}.tar.gz"
SRC_URI="https:://github.com/mono/dbus-sharp/archive/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

RDEPEND=">=dev-lang/mono-4.0.2.5
	sys-apps/dbus"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

pkg_setup() {
	DOCS="AUTHORS README"
}

src_prepare() {
	# Fix signals, bug #387097
#	epatch "${FILESDIR}/dbus-sharp-0.7.0-fix-signals.patch"
#	epatch "${FILESDIR}/dbus-sharp-0.7.0-fix-signals2.patch"
	sed -i "s@gmcs@mcs@g" configure.ac || die
	find . -iname "*.csproj" | xargs sed -i "s@v3.5@v4.5@g" || die
	eautoreconf
	default
}

src_compile() {
    default
    # https:://github.com/gentoo/dotnet/issues/305
    sn -R src/dbus-sharp.dll dbus-sharp.snk
}
