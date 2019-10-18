# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit fdo-mime gnome2-utils dotnet versionator eutils git-r3

DESCRIPTION="Integrated Development Environment for .NET"
HOMEPAGE="https://www.monodevelop.com/"
LICENSE="LGPL-2 MIT"
LICENSE+=" Apache-2.0" # fsharpbinding, monomac
LICENSE+=" GPL-2" # ikvm, mono-tools
LICENSE+=" GPL-2-with-classpath-exception" # ikvm
LICENSE+=" GPL-2-with-linking-exception" # libgit2

KEYWORDS="~amd64 ~x86"
SLOT="0"

EGIT_COMMIT="${P}"
EGIT_REPO_URI="git://github.com/mono/monodevelop.git"
EGIT_SUBMODULES=( '*' ) # todo: replace certain submodules with system packages

if [ "${PV}" == "9999" ]; then
	EGIT_COMMIT="HEAD"
	KEYWORDS=""
fi

USE_DOTNET="net45" # todo: necessary?
IUSE="${USE_DOTNET} +subversion +git qtcurve test"

COMMON_DEPEND="
	>=dev-lang/mono-4.4.1
	>=dev-dotnet/gtk-sharp-2.12.21:2
	>=dev-dotnet/nuget-2.8.7
	dev-dotnet/referenceassemblies-pcl
	>=dev-lang/fsharp-4.0.1.15
	net-libs/libssh2"
RDEPEND="${COMMON_DEPEND}
	dev-util/ctags
	sys-apps/dbus[X]
	>=www-servers/xsp-2
	git? ( dev-vcs/git )
	subversion? ( dev-vcs/subversion )"
DEPEND="${COMMON_DEPEND}
	dev-util/intltool
	virtual/pkgconfig
	sys-devel/gettext
	x11-misc/shared-mime-info
	x11-terms/xterm
	app-arch/unzip"

S="${WORKDIR}/${P}/main"

src_unpack() {
	git-r3_fetch
	git-r3_checkout
	nuget restore "${S}"
	default
}

src_prepare() {
	# use system nuget
	find "${S}" -name 'Makefile*' -exec sed -i 's|mono .nuget/NuGet.exe|nuget|g' {} + || die

	# prevent binding problem when gtk#-3 is installed alongside gtk#-2
	find "${S}" -name '*.csproj' -exec sed -i 's#<SpecificVersion>.*</SpecificVersion>#<SpecificVersion>True</SpecificVersion>#' {} + || die

	# this fsharpbinding test won't build
	sed -i 's|<Compile Include="TemplateTests.fs" />|<None Include="TemplateTests.fs" />|g' "${S}"/external/fsharpbinding/MonoDevelop.FSharp.Tests/MonoDevelop.FSharp.Tests.fsproj || die

	use qtcurve && epatch -p2 "${FILESDIR}/kill-qtcurve-warning.patch"

	# generate configure script but don't execute yet
	NOCONFIGURE=1 ./autogen.sh

	default
}

src_configure() {
	# env vars are added as the fix for https://github.com/gentoo/dotnet/issues/29
	MCS=/usr/bin/dmcs CSC=/usr/bin/dmcs GMCS=/usr/bin/dmcs econf \
		--disable-update-mimedb \
		--disable-update-desktopdb \
		--enable-monoextensions \
		--enable-gnomeplatform \
		--enable-release \
		$(use_enable test tests) \
		$(use_enable subversion) \
		$(use_enable git)

	# Main.sln file was created on the fly during econf

	# https://github.com/mrward/xdt/issues/4
	epatch -p2 "${FILESDIR}/mrward-xdt-issue-4.patch"

	# https://github.com/gentoo/dotnet/issues/38
	sed -i -E -e 's#(EXE_PATH=")(.*)(/lib/monodevelop/bin/MonoDevelop.exe")#\1'${EPREFIX}'/usr\3#g' "${S}/monodevelop" || die
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
}
