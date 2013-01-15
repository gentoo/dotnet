# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

EGIT_REPO_URI="git://github.com/Cynede/FAKE.git"
EGIT_MASTER="develop"

inherit git-2

DESCRIPTION="FAKE - F# Make"
HOMEPAGE="https://github.com/Cynede/FAKE"
SRC_URI=""

LICENSE="MS-PL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="dev-lang/mono
dev-lang/fsharp"
RDEPEND="${DEPEND}"

src_prepare() {
	./mono_build.sh
}

src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/4.0/
	doins build/FAKE.exe || die
	doins build/FakeLib.dll || die
}

pkg_postinst() {
	echo "mono /usr/lib/mono/4.0/FAKE.exe" > /usr/bin/fake
	chmod 777 /usr/bin/fake
}
