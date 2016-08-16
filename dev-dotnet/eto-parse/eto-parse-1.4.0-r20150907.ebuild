# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit mono-env nuget dotnet gac

NAME="Eto.Parse"
HOMEPAGE="https://github.com/picoe/${NAME}"

EGIT_COMMIT="7d7884fb4f481e28dd24bc273fbd6615d0ba539a" # 2015-09-07
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${PF}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION="CLI parser with API, recursive descent, LL(k), for BNF, EBNF and Gold Grammars"
LICENSE="MIT" # https://raw.githubusercontent.com/picoe/Eto.Parse/master/LICENSE
KEYWORDS="~amd64 ~ppc ~x86"

# notes on testing, from https://devmanual.gentoo.org/ebuild-writing/functions/src_test/index.html
# FEATURES+="test"

IUSE="developer nupkg debug"

# there is no "test" in IUSE, because test project and solution are not build
# there is no "gac" in IUSE, because utilities for patching are not ready
# "Failure adding assembly Eto.Parse/bin/Release/net40/Eto.Parse.dll to the cache: Attempt to install an assembly without a strong name"

# notes from https://devmanual.gentoo.org/general-concepts/dependencies/
# DEPEND - dependencies which are required to unpack, patch, compile or install the package
# RDEPEND - dependencies which are required at runtime

COMMON_DEPENDENCIES=">=dev-lang/mono-4.2"
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

src_prepare() {
	rm -rf "${S}/.nuget"
	# notes on escaping, from
	# http://unix.stackexchange.com/questions/32907/what-characters-do-i-need-to-escape-when-using-sed-in-a-sh-script
	# \$ is for regexps in sed - internal layer of escaping
	# \\\$ is for bash - external layer of escaping

	#change version in .nuspec

	sed -e "s/\\\$id\\\$/${NAME}/g" \
	  -e "s/\\\$version\\\$/${PV}/g" \
	  -e "s/\\\$title\\\$/${P}/g" \
	  -e "s/\\\$author\\\$/Curtis Wensley/g" \
	  -e "s/\\\$description\\\$/${DESCRIPTION}/g" \
	  -i "${NUSPEC_FILE}" || die

	epatch "${FILESDIR}/nuspec.patch"

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
}

src_compile() {
	exbuild "${METAFILETOBUILD}"
	enuspec "${NUSPEC_FILE}"
}

src_test() {
	# ebuild is not ready for testing
	# nunit-console Eto.Parse.Tests/bin/Debug/Eto.Parse.Tests.dll
	true
}

src_install() {
	# ebuild is not ready for gac install
	#DIR=""
	#if use debug; then
	#	DIR="Debug"
	#else
	#	DIR="Release"
	#fi
	# egacinstall "Eto.Parse/bin/${DIR}/net40/Eto.Parse.dll"

	enupkg "${WORKDIR}/${NAME}.${PV}.nupkg"
}
