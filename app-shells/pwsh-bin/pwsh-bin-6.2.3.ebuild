# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="PowerShell - binary precompiled for glibc"
HOMEPAGE="https://powershell.org/"
LICENSE="MIT"

SRC_URI="
amd64? ( https://github.com/PowerShell/PowerShell/releases/download/v${PV}/powershell-${PV}-linux-x64.tar.gz -> powershell-${PV}-linux-x64.tar.gz )
"

SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
"

S=${WORKDIR}

src_install() {
	local dest="opt/pwsh"
	dodir "${dest}"
	local ddest="${D}/${dest}"
	cp -a "${S}"/* "${ddest}/" || die
	fperms 0755 "/${dest}/pwsh"
	dosym "/${dest}/pwsh" "/usr/bin/pwsh"
}
