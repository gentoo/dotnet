# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS="~amd64"
RESTRICT="mirror"
USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac +nupkg +pkg-config debug developer"

inherit dotnet gac nupkg versionator

SLOT="0"

HOMEPAGE="https://projects.qnetp.net/projects/show/monotorrent"
DESCRIPTION="Monotorrent is an open source C# bittorrent library"
LICENSE="MIT"

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
#RESTRICT+="test"

FILE_TO_BUILD=./src/MonoTorrent.sln

METAFILETOBUILD="src/MonoTorrent/MonoTorrent.csproj"

COMMIT_DATE_INDEX="$(get_version_component_count ${PV} )"
COMMIT_DATEANDSEQ="$(get_version_component_range $COMMIT_DATE_INDEX ${PV} )"
NUSPEC_VERSION=$(get_version_component_range 1-3)"${COMMIT_DATEANDSEQ//p/.}"

src_prepare() {
	sed -i	\
		-e "/InternalsVisibleTo/d" \
		./src/MonoTorrent/AssemblyInfo.cs* || die

	epatch "${FILESDIR}/downgrade-from-4.6-to-4.5.patch"

	enuget_restore "${METAFILETOBUILD}"

	# leafpad /var/tmp/portage/dev-dotnet/monotorrent-1.0.0_p2015101302/work/MonoTorrent-master/monotorrent.nuspec &
	create_nuspec_file "${S}/${PN}.nuspec"
	eapply_user
}

src_configure() {
	:;
}

src_compile() {
	exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk" "${METAFILETOBUILD}"

	# run nuget_pack
	NUSPEC_PROPERTIES="id=${PN};version=${NUSPEC_VERSION}"
	enuspec ./${PN}.nuspec
}

src_install() {
	egacinstall $(find . -name "MonoTorrent.dll")

	enupkg "${WORKDIR}/monotorrent.${NUSPEC_VERSION}.nupkg"

	einstall_pc_file "${PN}" "1.0" "MonoTorrent"
}

create_nuspec_file()
{
	if use nupkg; then
		if use debug; then
			DIR="Debug"
		else
			DIR="Release"
		fi
		cat <<-EOF >$1 || die
		<?xml version="1.0"?>
		<package>
		  <metadata>
		    <id>\$id\$</id>
		    <version>\$version\$</version>
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
