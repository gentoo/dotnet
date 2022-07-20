# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
# !!! Unable to do any operations on 'dev-dotnet/DeveelDB-2.0_prealpha-r201601010',
# !!! since its EAPI is higher than this portage version's. Please upgrade
# !!! to a portage version that supports EAPI '6'.
# 2015-11-17, portage-2.2.25 has been committed and it comes with complete EAPI 6 support
# https://archives.gentoo.org/gentoo-dev/message/73cc181e4949b88abfbd68f8a8ca9254

# to create version number for passing to nuspec file
inherit versionator

# contain functions for compiling with xbuild
inherit dotnet

# contain functions for creating .nupkg package
inherit nupkg

# Package's homepage. Mandatory (except for virtuals).
# Never refer to a variable name in the string; include only raw text. 
# (q) https://devmanual.gentoo.org/ebuild-writing/variables/
HOMEPAGE=https://deveel.github.io/deveeldb/

DESCRIPTION="DeveelDB is a complete SQL DBMS, primarly developed for CLR/CLI frameworks"
LICENSE="Apache-2.0"
LICENSE_URL="https://www.apache.org/licenses/LICENSE-2.0"
SLOT="0"
KEYWORDS="~amd64"

# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# test = allow NUnit tests to run
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
IUSE="net45 debug developer test +nupkg +gac +pkg-config"
USE_DOTNET="net45"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"

RDEPEND="${COMMON_DEPEND}
"

DEPEND="${COMMON_DEPEND}
	test? ( dev-util/nunit:2[nupkg] )
	dev-dotnet/deveel-irony[nupkg]
	dev-dotnet/deveel-math[nupkg]
	dev-dotnet/dryioc[nupkg]
	virtual/pkgconfig
"

REPOSITORY_URL="https://github.com/ArsenShnurkov/deveeldb"
EGIT_COMMIT="7ad0b1563ae111535715dbf6d1f25034887720c5"

# SRC_URI 	A list of source URIs for the package.
# Can contain USE-conditional parts, see https://devmanual.gentoo.org/ebuild-writing/variables/index.html#src_uri
# PF 	Full package name, ${PN}-${PVR}, for example vim-6.3-r1
SRC_URI="${REPOSITORY_URL}/archive/${EGIT_COMMIT}.zip -> ${PN}-${PV}.zip
	mirror://gentoo/mono.snk.bz2"

NAME=${PN}
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

#EGIT_BRANCH="mono-attempt-3"

METAFILETOBUILD="src/deveeldb/deveeldb.csproj"
NUSPEC_FILE_NAME=deveeldb.nuspec

#https://raw.githubusercontent.com/ArsenShnurkov/dotnet/deveeldb/dev-dotnet/deveeldb/files/color.png
EBUILD_REPOSITORY_NAME="ArsenShnurkov/dotnet"
EBUILD_BRANCH="deveeldb"
#https://raw.githubusercontent.com/ArsenShnurkov/dotnet/deveeldb/dev-dotnet/deveeldb/files/color.png
ICON_URL="https://raw.githubusercontent.com/${EBUILD_REPOSITORY_NAME}/${EBUILD_BRANCH}/${CATEGORY}/${PN}/files/color.png"

# rm -rf rm -rf /var/tmp/portage/dev-dotnet/deveeldb-*
# emerge -v =deveeldb-2.0_pre_alpha_p20160101-r0
# leafpad /var/tmp/portage/dev-dotnet/deveeldb-2.0_pre_alpha_p20160101-r0/temp/build.log &

# get_version_component_range is from inherit versionator
# PR 	Package revision, or r0 if no revision exists.
COMMIT_DATE_INDEX=$(get_version_component_count ${PV} )
COMMIT_DATE=$(get_version_component_range $COMMIT_DATE_INDEX ${PV} )
NUSPEC_VERSION=$(get_version_component_range 1-2)"${COMMIT_DATE//p/.}${PR//r/.}"

src_unpack()
{
	default

	# delete untrusted executables
	find "${S}" -iname "*.exe" -delete || die
	# ./util/ilrepack/ILRepack.exe
	# ./src/.nuget/NuGet.exe
	find "${S}" -iname "*.dll" -delete || die
	# ./lib/irony.net35/Irony.dll
	# ./lib/irony.pcl/Irony.Shared.dll
	# ./lib/xpathreader/XPathReader.dll
	# ./lib/iqtoolkit-1.0.0.0/anycpu/IQToolkit.dll
	# ./lib/iqtoolkit-1.0.0.0/anycpu/IQToolkit.Data.dll
	# ./lib/antlr3.pcl/Antlr3.Runtime.dll

	# rename folder to disable line
	# <Import Project="$(SolutionDir)\.nuget\NuGet.targets" Condition="Exists('$(SolutionDir)\.nuget\NuGet.targets')" />
	# in .csproj file, see https://bartwullems.blogspot.ru/2012/08/disable-nuget-package-restore.html
	mv "${S}/src/.nuget" "${S}/src/nuget-config" || die
	# NuGet.Config NuGet.targets packages.config
}

src_prepare() {
	default
	# /var/tmp/portage/dev-dotnet/deveeldb-2.0_pre_alpha_p20160101-r0/work/deveeldb-7ad0b1563ae111535715dbf6d1f25034887720c5

	einfo "patching project files"
	eapply "${FILESDIR}/repositories.config.patch"
	eapply "${FILESDIR}/packages.deveeldb.config.patch"
	eapply "${FILESDIR}/deveeldb.csproj.patch"

	if use test ; then
		eapply "${FILESDIR}/packages.deveeldb-nunit.config.patch"
		eapply "${FILESDIR}/deveeldb-nunit.csproj.patch"
		eapply "${FILESDIR}/deveeldb-nunit.sln.patch"
	fi

	einfo "restoring packages (Deveel.Math, DryIoc)"
	enuget_restore "${METAFILETOBUILD}"
	if use test ; then
		enuget_restore "src/deveeldb-nunit.sln"
	fi

	#enuget_restore "src/nuget-config/packages.config"
	#<package id="coveralls.net" version="0.5.0" />
	#<package id="ILRepack" version="1.25.0" />
	#<package id="OpenCover" version="4.6.166" />

	# irony-framework should be packaged before continuing with this ebuild

	cp "${FILESDIR}/${NUSPEC_FILE_NAME}" "${S}/${NUSPEC_FILE_NAME}" || die
	patch_nuspec_file "${S}/${NUSPEC_FILE_NAME}"
	default
}

src_configure() {
	:;
}

src_compile() {
	if use test ; then
		exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk" "src/deveeldb-nunit.sln"
	else
		exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${WORKDIR}/mono.snk" "${METAFILETOBUILD}"
	fi

	# run nuget_pack
	einfo "setting .nupkg version to ${NUSPEC_VERSION}"
	enuspec -Prop "version=${NUSPEC_VERSION};package_iconUrl=${ICON_URL}" "${S}/${NUSPEC_FILE_NAME}"
}

src_test() {
	default
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	/usr/bin/nunit264 "${S}/src/deveeldb-nunit/bin/${DIR}/deveeldb-nunit.dll" || die
}

src_install() {
	enupkg "${WORKDIR}/${NAME}.${NUSPEC_VERSION}.nupkg"

	egacinstall "src/deveeldb/bin/${DIR}/deveeldb.dll"

	einstall_pc_file "${PN}" "2.0" "deveeldb"
}

patch_nuspec_file()
{
	if use nupkg; then
		if use debug; then
			DIR="Debug"
			FILES_STRING=`sed 's/[\/&]/\\\\&/g' <<-EOF || die "escaping replacement string characters"
			  <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
			    <file src="src/deveeldb/bin/${DIR}/deveeldb.dll" target="lib\net45\" />
			    <file src="src/deveeldb/bin/${DIR}/deveeldb.dll.mdb" target="lib\net45\" />
			  </files>
			EOF
			`
		else
			DIR="Release"
			FILES_STRING=`sed 's/[\/&]/\\\\&/g' <<-EOF || die "escaping replacement string characters"
			  <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
			    <file src="src/deveeldb/bin/${DIR}/deveeldb.dll" target="lib\net45\" />
			  </files>
			EOF
			`
		fi

		sed -i 's/<\/package>/'"${FILES_STRING//$'\n'/\\$'\n'}"'\n&/g' $1 || die "escaping line endings"
	fi
}
