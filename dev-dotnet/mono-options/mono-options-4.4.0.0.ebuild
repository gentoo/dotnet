# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Watch the order of these!
inherit nupkg

KEYWORDS="~amd64"
IUSE="+gac +nupkg"
SLOT="0"

DESCRIPTION="A Getopt::Long-inspired option parsing library for C#"
HOMEPAGE="https://tirania.org/blog/archive/2008/Oct-14.html"
LICENSE="MIT"

S="${WORKDIR}/mono-4.5.2"
SRC_URI="https://github.com/ArsenShnurkov/shnurise-tarballs/raw/master/mono-4.5.2_p2016061606.tar.bz2
	"
RESTRICT="mirror"

CDEPEND=""
DEPEND="${CDEPEND}
	nupkg? ( dev-dotnet/nuget )
	"
RDEPEND="${CDEPEND}
	"

src_configure() {
	# dont' call default configure for the whole mono package, because it is slow
	cat <<-METADATA >AssemblyInfo.cs || die
			[assembly: System.Reflection.AssemblyVersion("4.4.0.0")]
		METADATA
}

src_compile() {
	# exbuild_strong "mcs/class/Mono.Options/Mono.Options-net_4_x.csproj" # csproj is created during configure
	if use gac; then
		PARAMETERS=-keyfile:mcs/class/mono.snk
	else
		PARAMETERS=
	fi
	mcs ${PARAMETERS} -r:System.Core mcs/class/Mono.Options/Mono.Options/Options.cs AssemblyInfo.cs -t:library -out:"Mono.Options.dll" || die "compilation failed"
	enuspec "${FILESDIR}/Mono.Options.nuspec"
}

src_install() {
	insinto "${libdir}"
	doins "Mono.Options.dll"

	enupkg "${WORKDIR}/Mono.Options.4.4.0.0.nupkg"
}

pkg_postinst() {
	if use gac; then
		einfo "adding to GAC"
		gacutil -i "${libdir}/Mono.Options.dll" || die
	fi
}

pkg_prerm() {
	if use gac; then
		einfo "removing from GAC"
		gacutil -u Mono.Options
		# don't die, it there is no such assembly in GAC
	fi
}
