# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit mono-env dotnet multilib versionator gac mono-pkg-config

DESCRIPTION="Nini - A configuration library for .NET"
HOMEPAGE="https://nini.sourceforge.net"
SRC_URI="mirror://sourceforge/nini/Nini-${PV}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"

RDEPEND=">=dev-lang/mono-4.0.2.5"
DEPEND="${RDEPEND}
	app-arch/sharutils
	sys-apps/sed"

S=${WORKDIR}/Nini/Source

src_prepare() {
	uudecode -o Nini.snk "${FILESDIR}"/Nini.snk.uue
	eapply_user
}

src_configure() {
	use debug&&DEBUG="-debug"
}

src_compile() {
	#See nini in Debian for info
	/usr/bin/mcs	${DEBUG} \
		-nowarn:1616 \
		-target:library \
		-out:Nini.dll \
		-define:STRONG \
		-r:System.dll \
		-r:System.Xml.dll \
		-keyfile:Nini.snk \
		AssemblyInfo.cs Config/*.cs Ini/*.cs Util/*.cs \
		|| die "Compilation failed"
}

src_install() {
	egacinstall Nini.dll nini
	einstall_pc_file "${PN}" "${PV}" "Nini"

	dodoc "${S}"/../CHANGELOG.txt "${S}"/../README.txt
}
