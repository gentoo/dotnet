# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

USE_DOTNET="net45"
inherit gac nupkg
IUSE+=" +net45 debug"

DESCRIPTION="assembly that lets you dynamically register HTTP modules at run time"
HOMEPAGE="https://www.asp.net/"
SRC_URI="http://download.mono-project.com/sources/mono/mono-4.6.0.150.tar.bz2"

NAME=System.Web

LICENSE="Apache-2.0"
SLOT="0"

KEYWORDS="~amd64 ~x86"

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
	gunzip --decompress --stdout "${FILESDIR}/${CSPROJ}.gz" >"${S}/mcs/class/${NAME}/${CSPROJ}" || die
	sed -i 's/public const string FxVersion = "4.0.0.0";/public const string FxVersion = "'${PV}'";/g' "${S}/mcs/build/common/Consts.cs" || die
	eapply_user
}

src_configure()
{
	:;
}

src_compile()
{
	exbuild "${S}/mcs/class/${NAME}/${CSPROJ}"
	sn -R "${S}/mcs/class/${NAME}/${NAME}.dll" "${S}/mcs/class/mono.snk" || die
}

src_install()
{
	# installation to GAC will cause file collision with mono package
	egacinstall "${S}/mcs/class/${NAME}/${NAME}.dll"
}
