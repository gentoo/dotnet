# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

USE_DOTNET="net45"
inherit gac dotnet
IUSE+=" +net45 +pkg-config debug"

DESCRIPTION="Framework for developing web-applications"
HOMEPAGE="https://www.asp.net/"
SRC_URI="https://github.com/ArsenShnurkov/shnurise-tarballs/archive/dev-dotnet/system-web/system-web-4.6.0.182.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/shnurise-tarballs-${CATEGORY}-${PN}-${PN}-${PV}"

NAME=System.Web

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

CSPROJ=${NAME}.csproj

src_prepare()
{
	sed -i 's/public const string FxVersion = "4.0.0.0";/public const string FxVersion = "'${PV}'";/g' "${S}/mcs/build/common/Consts.cs" || die
	sed "s/4.6.0.150/4.6.0.182/g" "${FILESDIR}/policy.4.0.System.Web.config" > "${S}/policy.4.0.System.Web.config" || die
	eapply "${FILESDIR}/add-system-diagnostics-namespace.patch"
	eapply "${FILESDIR}/autofac.patch"
	eapply_user
}

src_configure()
{
	:;
}

KEYFILE1=${S}/mcs/class/msfinal.pub
KEYFILE2=${S}/mcs/class/mono.snk

src_compile()
{
	# System.Web.dll
	exbuild /p:SignAssembly=true /p:AssemblyOriginatorKeyFile=${KEYFILE1} /p:DelaySign=true "${S}/mcs/class/${NAME}/${CSPROJ}"
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	sn -R "${S}/mcs/class/${NAME}/obj/${DIR}/${NAME}.dll" ${KEYFILE2} || die

	# Policy file
	al "/link:${S}/policy.4.0.System.Web.config" "/out:${S}/policy.4.0.System.Web.dll" "/keyfile:${KEYFILE1}" /delaysign+ || die
	sn -R "${S}/policy.4.0.System.Web.dll" ${KEYFILE2} || die
}

src_install()
{
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	egacinstall "${S}/mcs/class/${NAME}/obj/${DIR}/${NAME}.dll"
	einfo "rewring symlink for System.Web.dll"
	dosym  "../gac/System.Web/${PV}__b03f5f7f11d50a3a/System.Web.dll" "/usr/lib64/mono/4.5/System.Web.dll"
	egacinstall "${S}/policy.4.0.System.Web.dll"
	einstall_pc_file "${PN}" "${PV}" "${NAME}"
}
