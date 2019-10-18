# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit mono-env dotnet autotools git-r3

HOMEPAGE="http://www.smuxi.org/page/Download"
EGIT_REPO_URI="https://github.com/meebey/SmartIrc4net"
# https://github.com/meebey/SmartIrc4net/releases/tag/1.1
EGIT_COMMIT="c00ddb2c5116c95015180150121e2f169b5a8a62"

SRC_URI="https://github.com/meebey/SmartIrc4net/archive/${PV}.tar.gz -> ${P}.tar.gz"
DESCRIPTION="Multi-threaded and thread-safe IRC library written in C#"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
LICENSE="|| ( LGPL-2.1 LGPL-3 )"

RDEPEND=">=dev-lang/mono-4.0.2.5
	sys-fs/fuse"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

#S="${WORKDIR}"
MY_PN="SmartIrc4net"

src_prepare() {
	default

	eapply_user
	# Cannot compile NUnit (2017-07-31)
	epatch "${FILESDIR}/${PV}-no-tests.patch"
	AT_M4DIR="${S}" eautoreconf
}

src_compile() {
	exbuild SmartIrc4net.sln
}
