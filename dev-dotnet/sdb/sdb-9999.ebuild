# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
KEYWORDS="~amd64 ~x86"
USE_DOTNET="net40"
IUSE="${USE_DOTNET}"
inherit git-r3 dotnet gac

HOMEPAGE="https://github.com/mono/${PN}"

EGIT_REPO_URI="${HOMEPAGE}.git"

RESTRICT="mirror"

SLOT=0

DESCRIPTION="A command line client for the Mono soft debugger."
LICENSE="MIT"

RDEPEND=">=dev-lang/mono-4.0.2.5"
DEPEND="${RDEPEND}"

src_configure() {
	:
}

src_compile() {
	emake PREFIX=/usr
}

src_install() {
	emake PREFIX="${D}/usr" install
}
