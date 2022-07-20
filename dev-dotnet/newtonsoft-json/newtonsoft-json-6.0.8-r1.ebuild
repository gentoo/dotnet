# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS="~amd64"
SLOT="0"
RESTRICT="mirror"

USE_DOTNET="net45"

# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# test = allow NUnit tests to run
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
IUSE="${USE_DOTNET} debug developer +gac pkg-config nupkg test"

inherit dotnet gac xbuild versionator

NAME="Newtonsoft.Json"
HOMEPAGE="https://github.com/JamesNK/${NAME}"

EGIT_COMMIT="1497343173a181d678b4c9bbf60250a12f783f1c"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}.zip
	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="Json.NET is a popular high-performance JSON framework for .NET"
LICENSE="MIT"
LICENSE_URL="https://raw.github.com/JamesNK/Newtonsoft.Json/master/LICENSE.md"

COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )"
RDEPEND="${COMMON_DEPENDENCIES}
"
DEPEND="${COMMON_DEPENDENCIES}
"

PDEPEND="test? ( dev-dotnet/newtonsoft-json-test )
	nupkg? ( dev-dotnet/newtonsoft-json-testdev-nupkg )
	pkg-config? ( dev-dotnet/newtonsoft-json-testdev-pkg-config )
"

METAFILETOBUILD=Src/Newtonsoft.Json/Newtonsoft.Json.csproj

src_prepare() {
	if use gac; then
		find . -iname "*.csproj" -print0 | xargs -0 \
		sed -i 's/<DefineConstants>/<DefineConstants>SIGNED;/g' || die
		find . -iname "AssemblyInfo.cs" -print0 | xargs -0 sed -i "/InternalsVisibleTo/d" || die
	fi

	if use test; then
		echo '[assembly: InternalsVisibleTo("Newtonsoft.Json.Tests, PublicKey=002400000480000094000000060200000024000052534131000400000100010079159977d2d03a8e6bea7a2e74e8d1afcc93e8851974952bb480a12c9134474d04062447c37e0e68c080536fcf3c3fbe2ff9c979ce998475e506e8ce82dd5b0f350dc10e93bf2eeecf874b24770c5081dbea7447fddafa277b22de47d6ffea449674a4f9fccf84d15069089380284dbdd35f46cdff12a1bd78e4ef0065d016df")]' >>${S}/Src/Newtonsoft.Json/Properties/AssemblyInfo.cs
	fi

	default
}

KEY2="${DISTDIR}/mono.snk"

src_compile() {
	exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${KEY2}" "${METAFILETOBUILD}"

	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	FINAL_DLL=Src/Newtonsoft.Json/bin/${DIR}/Net45/Newtonsoft.Json.dll

	sn -R "${FINAL_DLL}" "${KEY2}" || die
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	FINAL_DLL=Src/Newtonsoft.Json/bin/${DIR}/Net45/Newtonsoft.Json.dll

	if use gac; then
		egacinstall "${FINAL_DLL}"
	fi
}
