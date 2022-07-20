# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

USE_DOTNET="net45"
inherit mono-env gac nupkg versionator

IUSE="${USE_DOTNET} developer nupkg debug"

NAME="Eto.Parse"
HOMEPAGE="https://github.com/picoe/${NAME}"

EGIT_COMMIT="7d7884fb4f481e28dd24bc273fbd6615d0ba539a" # 2015-09-07
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${PN}-${PV}.zip"
RESTRICT="mirror"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION="CLI parser with API, recursive descent, LL(k), for BNF, EBNF and Gold Grammars"
LICENSE="MIT" # https://raw.githubusercontent.com/picoe/Eto.Parse/master/LICENSE
KEYWORDS="~amd64"

# notes on testing, from https://devmanual.gentoo.org/ebuild-writing/functions/src_test/index.html
# FEATURES+="test"

# there is no "test" in IUSE, because test project and solution are not build
# there is no "gac" in IUSE, because utilities for patching are not ready
# "Failure adding assembly Eto.Parse/bin/Release/net40/Eto.Parse.dll to the cache: Attempt to install an assembly without a strong name"

# notes from https://devmanual.gentoo.org/general-concepts/dependencies/
# DEPEND - dependencies which are required to unpack, patch, compile or install the package
# RDEPEND - dependencies which are required at runtime

COMMON_DEPENDENCIES=">=dev-lang/mono-4.2
	nupkg? ( dev-dotnet/nuget )
	"
DEPEND="${COMMON_DEPENDENCIES}
	"
#	test? ( >=dev-util/nunit-2.6.4-r201501110:2[nupkg] )
RDEPEND="${COMMON_DEPENDENCIES}
	"

# Notes on Gentoo variables, from https://devmanual.gentoo.org/ebuild-writing/variables/
# PN = Package name, for example vim.
# PV = Package version (excluding revision, if any), for example 6.3.
# P = Package name and version (excluding revision, if any), for example vim-6.3.
# PVR = Package version and revision (if any), for example 6.3, 6.3-r1.
# PF = Full package name, ${PN}-${PVR}, for example vim-6.3-r1

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
METAFILETOBUILD="${S}/Eto.Parse/Eto.Parse.csproj" # building .csproj instead of .sln to avoid building test projects
# NUSPEC_FILE=${FILESDIR}/nuget-2.8.3.nuspec
NUSPEC_FILE=Eto.Parse/Eto.Parse.nuspec

COMMIT_DATESTAMP_INDEX=$(get_version_component_count ${PV} )
COMMIT_DATESTAMP=$(get_version_component_range $COMMIT_DATESTAMP_INDEX ${PV} )
NUSPEC_VERSION=$(get_version_component_range 1-3)"${COMMIT_DATESTAMP//p/.}${PR//r/}"

src_prepare() {
	rm -rf "${S}/.nuget"
	# notes on escaping, from
	# https://unix.stackexchange.com/questions/32907/what-characters-do-i-need-to-escape-when-using-sed-in-a-sh-script
	# \$ is for regexps in sed - internal layer of escaping
	# \\\$ is for bash - external layer of escaping

	#change version in .nuspec

	sed -e "s/\\\$id\\\$/${NAME}/g" \
	  -e "s/\\\$version\\\$/${NUSPEC_VERSION}/g" \
	  -e "s/\\\$title\\\$/${P}/g" \
	  -e "s/\\\$author\\\$/Curtis Wensley/g" \
	  -e "s/\\\$description\\\$/${DESCRIPTION}/g" \
	  -i "${NUSPEC_FILE}" || die

	eapply "${FILESDIR}/nuspec.patch"

#	if use test; then
#
#		# ${S}/Eto.Parse.TestSpeed/packages.config
#		# Installing 'NUnit 2.6.2'.
#		# Installing 'Newtonsoft.Json 5.0.6'.
#		# Installing 'MarkdownSharp 1.13.0.0'.
#		# Installing 'ServiceStack.Text 3.9.64'.
#		# Installing 'MarkdownDeep.NET 1.5'.
#		# Successfully installed 'MarkdownSharp 1.13.0.0'.
#
#		enuget_restore "${METAFILETOBUILD}"
#	fi ;

	default
}

src_compile() {
	exbuild_strong "${METAFILETOBUILD}"
	enuspec "${NUSPEC_FILE}"
}

src_test() {
	# ebuild is not ready for testing
	# nunit-console Eto.Parse.Tests/bin/Debug/Eto.Parse.Tests.dll
	true
}

src_install() {
	DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	egacinstall "Eto.Parse/bin/${DIR}/net40/Eto.Parse.dll"
	einstall_pc_file "${PN}" "${PV}" "Eto.Parse"

	enupkg "${WORKDIR}/${NAME}.${NUSPEC_VERSION}.nupkg"
}
