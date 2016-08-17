# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit mono-env nuget dotnet gac

NAME="SharpZipLib"
HOMEPAGE="https://github.com/icsharpcode/${NAME}"

EGIT_COMMIT="e01215507cf25a5978a0bd850c9e67dbabf515b7"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${PF}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION="Zip, GZip, Tar and BZip2 library written entirely in C# for the .NET platform"
LICENSE="MIT" # Actually not, it is GPL with exception - http://icsharpcode.github.io/SharpZipLib/

KEYWORDS="~amd64 ~ppc ~x86"
COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )"
RDEPEND="${COMMON_DEPENDENCIES}
"
DEPEND="${COMMON_DEPENDENCIES}
"

USE_DOTNET="net45"
IUSE="${USE_DOTNET} gac nupkg"

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
