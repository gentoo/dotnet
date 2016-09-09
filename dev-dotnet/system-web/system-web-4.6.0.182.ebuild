# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

USE_DOTNET="net45"
inherit gac dotnet
IUSE+=" +net45 +pkg-config debug"

DESCRIPTION="Framework for developing web-applications"
HOMEPAGE="https://www.asp.net/"
SRC_URI="https://github.com/ArsenShnurkov/shnurise-tarballs/archive/dev-dotnet/system-web/system-web-4.6.0.182.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/shnurise-tarballs-${CATEGORY}-${PN}-${PF}"

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

CSPROJ=${NAME}.csproj

src_prepare()
{
	sed -i 's/public const string FxVersion = "4.0.0.0";/public const string FxVersion = "'${PV}'";/g' "${S}/mcs/build/common/Consts.cs" || die
	sed "s/4.6.0.150/4.6.0.182/g" "${FILESDIR}/policy.4.0.System.Web.config" > "${S}/policy.4.0.System.Web.config" || die
	eapply "${FILESDIR}/add-system-diagnostics-namespace.patch"
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
	egacinstall "${S}/policy.4.0.System.Web.dll"
	install_pc_file "${PN}" "${NAME}.dll"
}

# The file format contains predefined metadata keywords and freeform variables (like ${prefix} and ${exec_prefix})
# $1 = ${PN}
# $2 = myassembly.dll
install_pc_file()
{
	if use pkg-config; then
		dodir /usr/$(get_libdir)/pkgconfig
		ebegin "Installing ${PC_FILE_NAME}.pc file"
		sed \
			-e "s:@LIBDIR@:$(get_libdir):" \
			-e "s:@PACKAGENAME@:$1:" \
			-e "s:@DESCRIPTION@:${DESCRIPTION}:" \
			-e "s:@VERSION@:${PV}:" \
			-e 's*@LIBS@*-r:${libdir}'"/mono/$1/$2"'*' \
			<<-EOF >"${D}/usr/$(get_libdir)/pkgconfig/$1.pc" || die
				prefix=\${pcfiledir}/../..
				exec_prefix=\${prefix}
				libdir=\${exec_prefix}/@LIBDIR@
				Name: @PACKAGENAME@
				Description: @DESCRIPTION@
				Version: @VERSION@
				Libs: @LIBS@
			EOF

		einfo PKG_CONFIG_PATH="${D}/usr/$(get_libdir)/pkgconfig/" pkg-config --exists "$1"
		PKG_CONFIG_PATH="${D}/usr/$(get_libdir)/pkgconfig/" pkg-config --exists "$1" || die ".pc file failed to validate."
		eend $?
	fi
}
