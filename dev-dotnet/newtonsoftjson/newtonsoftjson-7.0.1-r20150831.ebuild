# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit mono-env nuget dotnet

NAME="Newtonsoft.Json"
HOMEPAGE="https://github.com/JamesNK/${NAME}"

EGIT_COMMIT="05710874cd61adabfb635085b1b45cf31882df3d"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${PF}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION="NewtonSoft.JSon library"
LICENSE="MIT"

KEYWORDS="~amd64 ~ppc ~x86"
COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )"
RDEPEND="${COMMON_DEPENDENCIES}
"
DEPEND="${COMMON_DEPENDENCIES}
	>=dev-dotnet/nunit-2.6.4-r201501110:2[nupkg]
"

USE_DOTNET="net45"
IUSE="${USE_DOTNET} gac nupkg"
# if you remove these flags where will be the error:
# USE Flag 'gac' not in IUSE for dev-dotnet/newtonsoftjson-0.0.0-r20150831

METAFILETOBUILD=Src/Newtonsoft.Json.sln

# https://devmanual.gentoo.org/ebuild-writing/variables/
#
# PN = Package name, for example vim.
# P = Package name and version (excluding revision, if any), for example vim-6.3.
# FILESDIR = Path to the ebuild's files/ directory, commonly used for small patches and files. Value: "${PORTDIR}/${CATEGORY}/${PN}/files"
# WORKDIR = Path to the ebuild's root build directory. Value: "${PORTAGE_BUILDDIR}/work"
# S = Path to the temporary build directory, used by src_compile and src_install. Default: "${WORKDIR}/${P}".

NUSPEC_FILENAME="Newtonsoft.Json.nuspec"

# ${SNK_FILENAME} is used inside exbuild() to sign assemblies
#SNK_FILENAME="${S}/Src/Newtonsoft.Json/Dynamic.snk"

src_prepare() {
	elog "${S}/Build/${NUSPEC_FILENAME}"
	sed "s/@Version@/${PV}/g" "${FILESDIR}/${NUSPEC_FILENAME}" >"${S}/Build/${NUSPEC_FILENAME}" || die

	egrep -lRZ '2\.6\.2' "${S}" | xargs -0 sed -i 's/2\.6\.2/2\.6\.4/g'  || die

	enuget_restore "${METAFILETOBUILD}"
	# Installing 'Autofac 3.5.0'.
	# Installing 'NUnit 2.6.2'.
	# Installing 'System.Collections.Immutable 1.1.36'.
	# Installing 'FSharp.Core 4.0.0'.
	epatch "${FILESDIR}/removing-tests.patch"

	if use gac; then
		find . -iname "*.csproj" -print0 | xargs -0 \
		sed -i 's/<DefineConstants>/<DefineConstants>SIGNED;/g' || die
		#PUBLIC_KEY=`sn -q -p ${SNK_FILENAME} /dev/stdout | hexdump -e '"%02x"'`
		#find . -iname "AssemblyInfo.cs" -print0 | xargs -0 sed -i "s/PublicKey=[0-9a-fA-F]*/PublicKey=${PUBLIC_KEY}/g" || die
		find . -iname "AssemblyInfo.cs" -print0 | xargs -0 sed -i "/InternalsVisibleTo/d" || die
	fi
}

src_compile() {
	exbuild "${METAFILETOBUILD}"
	enuspec "Build/${NUSPEC_FILENAME}"
}

src_install() {
	DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	FINAL_DLL=Src/Newtonsoft.Json/bin/${DIR}/Net45/Newtonsoft.Json.dll

	if use gac; then
		egacinstall "${FINAL_DLL}"
	fi

	enupkg "${WORKDIR}/Newtonsoft.Json.${PV}.nupkg"
}
