# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit mono-env dotnet nupkg

HOMEPAGE="http://projects.qnetp.net/projects/show/monotorrent"
DESCRIPTION="Monotorrent is an open source C# bittorrent library"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="net45 +gac +nupkg pkg-config debug developer"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"

RDEPEND="${COMMON_DEPEND}
"

DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"

NAME="monotorrent"
REPOSITORY="https://github.com/ArsenShnurkov/${NAME}"
LICENSE_URL="${REPOSITORY}/blob/master/src/LICENSE"
ICONMETA="https://openclipart.org/detail/198771/mono-torrent"
ICON_URL="https://openclipart.org/download/198771/mono-torrent.svg"

# monotorrent-1.0.0-r201510130
EGIT_BRANCH="longpath"
EGIT_COMMIT="e78d386d0785a9a42eeb5865bd58a8887e14b8f2"
SRC_URI="${REPOSITORY}/archive/${EGIT_BRANCH}/${EGIT_COMMIT}.zip -> ${PF}.zip
	mirror://gentoo/mono.snk.bz2"
#S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
S="${WORKDIR}/${NAME}-${EGIT_BRANCH}"

# The hack we do to get the dll installed in the GAC makes the unit-tests
# defunct.
RESTRICT="test"

FILE_TO_BUILD=./src/MonoTorrent.sln
METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

src_prepare() {
	#enuget_restore "${METAFILETOBUILD}"

	sed -i	\
		-e "/InternalsVisibleTo/d" \
		MonoTorrent/AssemblyInfo.cs* || die
}

src_compile() {
	# emake -j1 ASSEMBLY_COMPILER_COMMAND="/usr/bin/gmcs" -keyfile:${WORKDIR}/mono.snk
	exbuild "${METAFILETOBUILD}"

	create_nuspec_file
}

src_install() {
	egacinstall $(find . -name "MonoTorrent.dll")
	if use pkg-config; then
		install_pc_file
	fi
}

# replace underscore to dash
NUGET_VERSION="${PV//_/-}"

create_nuspec_file()
{
	REPLACEMENT_TOKENS+="s~$id$~${PN}~g;"
	REPLACEMENT_TOKENS+="s~$version$~${NUGET_VERSION}~g;"
	REPLACEMENT_TOKENS+="s~$author$~leaves project~g;"
	REPLACEMENT_TOKENS+="s~$package_owners$~lasy monkeys~g;"
	REPLACEMENT_TOKENS+="s~$package_licenseUrl$~${LICENSE_URL}~g;"
	REPLACEMENT_TOKENS+="s~$package_ProjectUrl$~${HOMEPAGE}~g;"
	REPLACEMENT_TOKENS+="s~$package_iconUrl$~${ICON_URL}~g;"
	REPLACEMENT_TOKENS+="s~$description$~${DESCRIPTION}~g;"
	sed "${REPLACEMENT_TOKENS}" <<EOF >"${S}/${PN}.nuspec" || die
<?xml version="1.0"?>
<package >
	<metadata>
	<id>$id$</id>
	<version>$version$</version>
	<authors>$author$</authors>
	<owners>$package_owners$</owners>
	<licenseUrl>$package_licenseUrl$</licenseUrl>
	<projectUrl>$package_ProjectUrl$</projectUrl>
	<iconUrl>$package_iconUrl$</iconUrl>
	<requireLicenseAcceptance>false</requireLicenseAcceptance>
	<description>$description$</description>
	<!--
	<releaseNotes>$package_releaseNotes$</releaseNotes>
	<copyright>$package_copyright$</copyright>
	<tags>$package_tags$</tags>
	-->
	<!--
	<dependencies>
		<dependency id="SampleDependency" version="1.0" />
	</dependencies>
	-->
	</metadata>
	<files> <!-- https://docs.nuget.org/create/nuspec-reference -->
		<file src="bin/$configuration$/*.dll" target="lib\net40\" />
	</files>

</package>
EOF
	# run nuget_pack
	enuspec -Prop version=${NUGET_VERSION} ./${PN}.nuspec
}

install_pc_file()
{
	dodir /usr/$(get_libdir)/pkgconfig
	ebegin "Installing .pc file"
	sed  \
		-e "s:@LIBDIR@:$(get_libdir):" \
		-e "s:@PACKAGENAME@:${PN}:" \
		-e "s:@DESCRIPTION@:${DESCRIPTION}:" \
		-e "s:@VERSION@:${PV}:" \
		-e 's;@LIBS@;-r:${libdir}/mono/monotorrent/MonoTorrent.dll;' \
		"${FILESDIR}"/${PN}.pc.in > "${D}"/usr/$(get_libdir)/pkgconfig/${PN}.pc
	PKG_CONFIG_PATH="${D}/usr/$(get_libdir)/pkgconfig/" pkg-config --exists monotorrent || die ".pc file failed to validate."
	eend $?
}
