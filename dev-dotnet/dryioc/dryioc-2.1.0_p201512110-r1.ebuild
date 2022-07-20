# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
# !!! Unable to do any operations on 'dev-dotnet/dryioc-2.1.0-r201512110',
# !!! since its EAPI is higher than this portage version's. Please upgrade
# !!! to a portage version that supports EAPI '6'.
# 2015-11-17, portage-2.2.25 has been committed and it comes with complete EAPI 6 support
# https://archives.gentoo.org/gentoo-dev/message/73cc181e4949b88abfbd68f8a8ca9254

inherit versionator vcs-snapshot gac nupkg

HOMEPAGE="https://bitbucket.org/dadhi/dryioc"
DESCRIPTION="fast, small, full-featured IoC Container for .NET"
LICENSE="MIT"
LICENSE_URL="https://bitbucket.org/dadhi/dryioc/src/tip/LICENSE.txt"
SLOT="0"
KEYWORDS="~amd64"

# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# test = allow NUnit tests to run
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
IUSE="net45 debug developer test +nupkg +pkg-config"
USE_DOTNET="net45"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"

RDEPEND="${COMMON_DEPEND}
"

DEPEND="${COMMON_DEPEND}
	test? ( dev-util/nunit:2[nupkg] )
	virtual/pkgconfig
"

NAME=DryIoc
REPOSITORY_NAME="dadhi/dryioc"
REPOSITORY_URL="https://bitbucket.org/dadhi/dryioc"
EHG_REVISION="9f1954dd921acc432c22f1feff108c4d7ff87ffd"
HG_COMMIT="${EHG_REVISION:0:8}"

# PF 	Full package name, ${PN}-${PVR}, for example vim-6.3-r1
SRC_URI="${REPOSITORY_URL}/get/${HG_COMMIT}.tar.gz -> ${PF}.tar.gz
	nupkg? ( https://raw.githubusercontent.com/ArsenShnurkov/dotnet/dryioc/dev-dotnet/dryioc/files/icon.png -> ${PF}.icon.png )
	gac? ( mirror://gentoo/mono.snk.bz2 )
	"
#RESTRICT="mirror"

#METAFILETOBUILD="DryIoc.sln"
METAFILETOBUILD="DryIoc/DryIoc.csproj"
NUSPEC_ID=DryIoc
NUSPEC_FILE_NAME=DryIoc.nuspec

# get_version_component_range is from inherit versionator
# PR 	Package revision, or r0 if no revision exists.
NUSPEC_VERSION=$(get_version_component_range 1-3)"${PR//r/.}"
#ICON_URL="https://bitbucket.org/account/dadhi/avatar/256/?ts=1451481107"
#ICON_URL=""
ICON_URL="https://raw.githubusercontent.com/gentoo/dotnet/master/dev-dotnet/dryioc/files/icon.png"

# rm -rf /var/tmp/portage/dev-dotnet/dryioc-*
# emerge -v =dryioc-2.1.0-r201512110
# leafpad /var/tmp/portage/dev-dotnet/dryioc-2.1.0-r201512110/temp/build.log &

S=${WORKDIR}/dadhi-dryioc-${EHG_REVISION:0:12}

src_unpack()
{
	default
	rm "${S}/.nuget/NuGet.exe" || die
}

src_prepare() {
	default
	# /var/tmp/portage/dev-dotnet/dryioc-2.1.0-r201512110/work/dadhi-dryioc-9f1954dd921a
	einfo "patching project files"
	sed -i 's=\r$==g' "${METAFILETOBUILD}" || die
	eapply "${FILESDIR}/DryIoc.csproj.patch"
	if ! use test ; then
		einfo "removing unit tests from solution"
	fi

	einfo "restoring packages (NUnit)"
	enuget_restore "${METAFILETOBUILD}"

	cp "${FILESDIR}/${NUSPEC_FILE_NAME}" "${S}/${NUSPEC_FILE_NAME}" || die
	patch_nuspec_file "${S}/${NUSPEC_FILE_NAME}"
}

src_configure() {
	:;
}

src_compile() {
	exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk" "${METAFILETOBUILD}"

	# run nuget_pack
	einfo "setting .nupkg version to ${NUSPEC_VERSION}"
	enuspec -Prop "version=${NUSPEC_VERSION};package_iconUrl=${ICON_URL}" "${S}/${NUSPEC_FILE_NAME}"
}

src_test() {
	default
}

src_install() {
	enupkg "${WORKDIR}/${NAME}.${NUSPEC_VERSION}.nupkg"

	egacinstall "bin/${DIR}/DryIoc.dll"

	if use nupkg; then
		insinto "$(get_nuget_trusted_icons_location)"
		newins "${DISTDIR}/${PF}.icon.png" "${NUSPEC_ID}.${NUSPEC_VERSION}.png"
	fi

	einstall_pc_file "${PN}" "2.1" "DryIoc"
}

patch_nuspec_file()
{
	if use nupkg; then
		if use debug; then
			DIR="Debug"
			FILES_STRING=`sed 's/[\/&]/\\\\&/g' <<-EOF || die "escaping replacement string characters"
			  <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
			    <file src="bin/${DIR}/DryIoc.dll" target="lib\net45\" />
			    <file src="bin/${DIR}/DryIoc.dll.mdb" target="lib\net45\" />
			  </files>
			EOF
			`
		else
			DIR="Release"
			FILES_STRING=`sed 's/[\/&]/\\\\&/g' <<-EOF || die "escaping replacement string characters"
			  <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
			    <file src="bin/${DIR}/DryIoc.dll" target="lib\net45\" />
			  </files>
			EOF
			`
		fi
		sed -i 's/<\/package>/'"${FILES_STRING//$'\n'/\\$'\n'}"'\n&/g' $1 || die "escaping line endings"
	fi
}
