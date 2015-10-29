# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit nupkg

HOMEPAGE="http://projects.qnetp.net/projects/show/monotorrent"
DESCRIPTION="Monotorrent is an open source C# bittorrent library"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="net45 +gac +nupkg +pkg-config debug developer"
USE_DOTNET="net45"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"

RDEPEND="${COMMON_DEPEND}
"

DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"

NAME="MonoTorrent"
REPOSITORY="https://github.com/ArsenShnurkov/${NAME}"
LICENSE_URL="${REPOSITORY}/blob/master/src/LICENSE"
ICONMETA="https://openclipart.org/detail/198771/mono-torrent"
ICON_URL="https://openclipart.org/download/198771/mono-torrent.svg"

EGIT_BRANCH="master"
EGIT_COMMIT="a76e4cd552d0fff51e47a25fe050efff672f34b2"
SRC_URI="${REPOSITORY}/archive/${EGIT_BRANCH}/${EGIT_COMMIT}.zip -> ${PF}.zip
	mirror://gentoo/mono.snk.bz2"
S="${WORKDIR}/${NAME}-${EGIT_BRANCH}"

# The hack we do to get the dll installed in the GAC makes the unit-tests
# defunct.
RESTRICT="test"

FILE_TO_BUILD=./src/MonoTorrent.sln

METAFILETOBUILD="src/MonoTorrent/MonoTorrent.csproj"

NUGET_VERSION="${PVR//-r/.}"

src_prepare() {
	sed -i	\
		-e "/InternalsVisibleTo/d" \
		./src/MonoTorrent/AssemblyInfo.cs* || die

	epatch "${FILESDIR}/NoStdLib-NoConfig.patch"
	epatch "${FILESDIR}/downgrade-from-4.6-to-4.5.patch"

	enuget_restore "${METAFILETOBUILD}"

	# leafpad /var/tmp/portage/dev-dotnet/monotorrent-1.0.0-r201510130/work/monotorrent-master/monotorrent.nuspec &
	create_nuspec_file "${S}/${PN}.nuspec"
}

src_configure() {
	:;
}

src_compile() {
	exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk" "${METAFILETOBUILD}"

	# run nuget_pack
	enuspec -Prop version=${NUGET_VERSION} ./${PN}.nuspec
}

src_install() {
	egacinstall $(find . -name "MonoTorrent.dll")

	enupkg "${WORKDIR}/monotorrent.${NUGET_VERSION}.nupkg"

	install_pc_file
}

create_nuspec_file()
{
	if use nupkg; then
		if use debug; then
			DIR="Debug"
		else
			DIR="Release"
		fi
		cat <<EOF >$1 || die
<?xml version="1.0"?>
<package>
	<metadata>
		<id>${PN}</id>
		<version>${NUGET_VERSION}</version>
		<authors>unknown</authors>
		<owners>unknown</owners>
		<licenseUrl>${LICENSE_URL}</licenseUrl>
		<projectUrl>${HOMEPAGE}</projectUrl>
		<iconUrl>${ICON_URL}</iconUrl>
		<requireLicenseAcceptance>false</requireLicenseAcceptance>
		<description>${DESCRIPTION}</description>
	</metadata>
	<files> <!-- https://docs.nuget.org/create/nuspec-reference -->
		<file src="build/MonoTorrent/${DIR}/*.dll" target="lib\net45\" />
		<file src="build/MonoTorrent/${DIR}/*.mdb" target="lib\net45\" />
	</files>
</package>
EOF
	fi
}

install_pc_file()
{
	if use pkg-config; then
		dodir /usr/$(get_libdir)/pkgconfig
		ebegin "Installing .pc file"
		sed  \
			-e "s:@LIBDIR@:$(get_libdir):" \
			-e "s:@PACKAGENAME@:${PN}:" \
			-e "s:@DESCRIPTION@:${DESCRIPTION}:" \
			-e "s:@VERSION@:${PV}:" \
			-e 's;@LIBS@;-r:${libdir}/mono/monotorrent/MonoTorrent.dll;' \
			"${FILESDIR}"/${PN}.pc.in > "${D}"/usr/$(get_libdir)/pkgconfig/${PN}.pc || die
		PKG_CONFIG_PATH="${D}/usr/$(get_libdir)/pkgconfig/" pkg-config --exists monotorrent || die ".pc file failed to validate."
		eend $?
	fi
}
