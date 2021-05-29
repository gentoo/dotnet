# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"

inherit dotnet xbuild

NAME="roslyn"
HOMEPAGE="https://github.com/dotnet/${NAME}"
EGIT_COMMIT="ec1cde8b77c7bca654888681037f55aa0e62dd19"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${NAME}-${PV}.tar.gz
	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="C# compiler with rich code analysis APIs"
LICENSE="Apache-2.0" # https://github.com/dotnet/roslyn/blob/master/License.txt

IUSE="+${USE_DOTNET} +debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
	dev-dotnet/msbuild-tasks-api developer? ( dev-dotnet/msbuild-tasks-api[developer] )
	dev-dotnet/msbuild-defaulttasks developer? ( dev-dotnet/msbuild-defaulttasks[developer] )
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

KEY2="${DISTDIR}/mono.snk"

METAFILE_FO_BUILD="${S}/src/Compilers/Core/MSBuildTask/mono-MSBuildTask.csproj"

function output_filename ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "src/Compilers/Core/MSBuildTask/bin/${DIR}/Microsoft.Build.Tasks.CodeAnalysis.dll"
}

src_prepare() {
	cp "${FILESDIR}/mono-MSBuildTask.csproj" "${METAFILE_FO_BUILD}" || die
	eapply "${FILESDIR}/Initialize_Guid.patch"
	eapply_user
}

src_compile() {
	exbuild /p:TargetFrameworkVersion=v4.6 "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" "${METAFILE_FO_BUILD}"
	sn -R "${S}/$(output_filename)" "${KEY2}" || die
}

src_install() {
	insinto "/usr/share/msbuild/Roslyn/"
	doins "${S}/src/Compilers/Core/MSBuildTask/Microsoft.CSharp.Core.targets"
	doins "${S}/src/Compilers/Core/MSBuildTask/Microsoft.VisualBasic.Core.targets"
	doins "${S}/$(output_filename)"
}
