# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
inherit msbuild gac
IUSE="+${USE_DOTNET}"

NAME="SharpZipLib"
HOMEPAGE="https://github.com/icsharpcode/${NAME}"

EGIT_COMMIT="cfc69a68fefbc5858fe70b35f7b69fc505b8c2d6"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PF}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="Zip, GZip, Tar and BZip2 library written entirely in C# for the .NET platform"
LICENSE="MIT" # Actually not, it is GPL with exception - http://icsharpcode.github.io/SharpZipLib/

COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )"
RDEPEND="${COMMON_DEPENDENCIES}
"
DEPEND="${COMMON_DEPENDENCIES}
"

#METAFILETOBUILD=SharpZipAll.sln
METAFILETOBUILD=ICSharpCode.SharpZLib.sln

NUGET_PACKAGE_ID="SharpZipLib"

src_prepare() {
	elog "${S}/${NUGET_PACKAGE_ID}"
	sed "s/@Version@/${PV}/g" "${FILESDIR}/${NUGET_PACKAGE_ID}.nuspec" >"${S}/${NUGET_PACKAGE_ID}.nuspec" || die

	epatch "${FILESDIR}/ICSharpCode.SharpZLib.csproj.patch"
	epatch "${FILESDIR}/SharpZipLibTests.csproj.patch"

	enuget_restore "${METAFILETOBUILD}"
}

# SNK_FILENAME=ICSharpCode.SharpZipLib.key
#TOOLS_VERSION=12.0
TOOLS_VERSION=4.0

src_compile() {
	exbuild_strong "${METAFILETOBUILD}"
	enuspec "${NUGET_PACKAGE_ID}.nuspec"
}

# /usr/lib/mono/xbuild/12.0/bin/Microsoft.CSharp.targets
# /usr/lib/mono/xbuild/14.0/bin/Microsoft.CSharp.targets
# /usr/lib/mono/4.5/Microsoft.CSharp.targets

src_install() {
	FINAL_DLL=bin/ICSharpCode.SharpZipLib.dll

	if use gac; then
		egacinstall "${FINAL_DLL}"
	fi

	enupkg "${WORKDIR}/${NUGET_PACKAGE_ID}.${PV}.nupkg"
}
