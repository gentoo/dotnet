# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils dotnet multilib java-pkg-2

DESCRIPTION="Java VM for .NET"
HOMEPAGE="https://www.ikvm.net/ http://weblog.ikvm.net/"
LICENSE="ZLIB GPL-2-with-linking-exception"

GITHUBNAME="mono/ikvm-fork"
EGIT_BRANCH="master"
EGIT_COMMIT="00252c18fc0a4a206e45461736a890acb785a9d8"
GITHUBACC=${GITHUBNAME%/*}
GITHUBREPO=${GITHUBNAME#*/}
GITFILENAME=${GITHUBREPO}-${GITHUBACC}-${PV}-${EGIT_COMMIT}
GITHUB_ZIP="https://api.github.com/repos/${GITHUBACC}/${GITHUBREPO}/zipball/${EGIT_COMMIT} -> ${GITFILENAME}.zip"
S="${WORKDIR}/${GITFILENAME}"

SRC_URI="https://www.frijters.net/openjdk-7u4-stripped.zip
	mirror://gentoo/mono.snk.bz2
	${GITHUB_ZIP}"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+net45"
USE_DOTNET="net45"

RDEPEND=">=dev-lang/mono-2
	dev-libs/glib:*"
DEPEND="${RDEPEND}
	!dev-dotnet/ikvm-bin
	dev-util/nant
	>=virtual/jdk-1.7
	app-arch/unzip
	virtual/pkgconfig
	app-arch/sharutils"

src_unpack() {
	default_src_unpack
	einfo '"'${WORKDIR}/${GITHUBACC}-${GITHUBREPO}-'"'*
	mv "${WORKDIR}/${GITHUBACC}-${GITHUBREPO}-"* "${WORKDIR}/${GITFILENAME}" || die
}

src_prepare() {
	eapply "${FILESDIR}/ikvm.build.patch"
	#cp "${FILESDIR}/ikvm.build" "${S}/ikvm.build" || die

	# We cannot rely on Mono Crypto Service Provider as it doesn't work inside
	# sandbox, we simply hard-code the path to a bundled key like Debian does.
	#epatch "${FILESDIR}"/${PN}-7.1.4532.2-key.patch
	#mkdir -p ../debian/ || die
	#uudecode < "${FILESDIR}"/mono.snk.uu -o ../debian/mono.snk || die

	# Ensures that we use Mono's bundled copy of SharpZipLib instead of relying
	# on ikvm-bin one
	#sed -i -e 's:../bin/ICSharpCode.SharpZipLib.dll:ICSharpCode.SharpZipLib.dll:' \
	#	ikvmc/ikvmc.build ikvmstub/ikvmstub.build || die

	#sed -i -e 's:pkg-config --cflags:pkg-config --cflags --libs:' \
	#	native/native.build || die

	mkdir -p "${T}"/home/test
	java-pkg-2_src_prepare
	eapply_user
}

src_configure() {
	:;
}

src_compile() {
	XDG_CONFIG_HOME="${T}/home/test" nant -t:mono-4.5 signed || die "ikvm build failed"
}

src_install() {
	local dll dllbase exe
	insinto /usr/$(get_libdir)/${PN}
#	doins bin/*.exe

	dodir /bin
	for exe in bin/*.exe
	do
		exebase=${exe##*/}
		ebegin "Generating wrapper for ${exebase} -> ${exebase%.exe}"
		make_wrapper ${exebase%.exe} "mono /usr/$(get_libdir)/${PN}/${exebase}"
		eend $? || die "Failed generating wrapper for ${exebase}"
	done

	for dll in bin/IKVM.*.dll
	do
		dllbase=${dll##*/}
		ebegin "Installing and registering ${dllbase}"
		gacutil -i bin/${dllbase} -root "${D}"/usr/$(get_libdir) \
			-gacdir /usr/$(get_libdir) -package IKVM &>/dev/null
		eend $? || die "Failed installing ${dllbase}"
	done

	#einstall_pc_file "${PN}" "7.2" ...
}
