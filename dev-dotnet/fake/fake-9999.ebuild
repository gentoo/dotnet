# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
USE_DOTNET="net40"

inherit git-2 mono

#-> Official repo
#EGIT_REPO_URI="git://github.com/fsharp/FAKE.git"

#-> Own fork
#EGIT_REPO_URI="git://github.com/Cynede/FAKE.git"

#-> Mono 3 fixes
EGIT_REPO_URI="git://github.com/intellifactory/FAKE.git"

EGIT_MASTER="develop"

DESCRIPTION="FAKE - F# Make"
HOMEPAGE="https://github.com/fsharp/FAKE"
SRC_URI=""

LICENSE="MS-PL"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="dev-lang/mono
dev-lang/fsharp"
RDEPEND="${DEPEND}"

src_prepare() {
	./build.sh
}

src_install() {
	elog "Installing libraries"
	insinto /usr/lib/mono/FAKE/"${FRAMEWORK}"/
	doins build/FAKE.exe || die
	doins build/FakeLib.dll || die
}

pkg_postinst() {
	echo "mono /usr/lib/mono/FAKE/${FRAMEWORK}/FAKE.exe \"\$@\"" > /usr/bin/fake
	chmod 777 /usr/bin/fake
}
