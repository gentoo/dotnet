# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

USE_DOTNET="net45"
inherit gac nupkg
IUSE+=" +net45 debug"

DESCRIPTION="assembly that lets you dynamically register HTTP modules at run time"
HOMEPAGE="https://www.asp.net/"
SRC_URI="https://download.mono-project.com/sources/mono/mono-4.6.0.150.tar.bz2"

NAME=Microsoft.Web.Infrastructure

LICENSE="Apache-2.0"
SLOT="0"

KEYWORDS="~amd64"

# dependency on mono is included in dotnet.eclass which is inherited with nupkg.eclass (so no need to include >=dev-lang/mono-4.0.2.5 here)
# dependency on nuget is included in nupkg.eclass when USE="nupkg" is set
COMMONDEPEND="
"
RDEPEND="${COMMONDEPEND}
"
DEPEND="${COMMONDEPEND}
"

S="${WORKDIR}/mono-4.6.0"

CSPROJ=${NAME}.csproj

src_prepare()
{
	cp "${FILESDIR}/${CSPROJ}" "${S}/mcs/class/${NAME}/${CSPROJ}" || die
	cp "${FILESDIR}/${NAME}.nuspec" "${S}/mcs/class/${NAME}/${NAME}.nuspec" || die
	eapply_user
}

src_configure()
{
	:;
}

src_compile()
{
	exbuild "${S}/mcs/class/${NAME}/${CSPROJ}"
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	sn -R "${S}/mcs/class/${NAME}/bin/${DIR}/${NAME}.dll" "${S}/mcs/class/mono.snk" || die
	sed -i "s~\\\$PATH\\\$~mcs/class/${NAME}/bin/${DIR}~g" "${S}/mcs/class/${NAME}/${NAME}.nuspec" || die
	enuspec "${S}/mcs/class/${NAME}/${NAME}.nuspec"
}

src_install()
{
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	# installation to GAC will cause file collision with mono package
	#egacinstall "${S}/mcs/class/${NAME}/bin/${DIR}/${NAME}.dll"
	enupkg "${WORKDIR}/${NAME}.1.0.0.0.nupkg"
}
