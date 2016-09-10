# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: gac.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: functions for registring in gac
# @DESCRIPTION:
# binary packages should be able to be registred in gac too

case ${EAPI:-0} in
	0|1|2|3|4|5) die "this eclass doesn't support EAPI ${EAPI:-0}" ;;
	6) ;;
esac

IUSE+=" +gac"

DEPEND+=" dev-lang/mono"
RDEPEND+=" dev-lang/mono"

# SRC_URI+=" https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
# I was unable to setup it this ^^ way

# @FUNCTION: egacinstall
# @DESCRIPTION:  install package to GAC
egacinstall() {
	if use gac; then
		use !prefix && has "${EAPI:-0}" 0 1 2 && ED="${D}"
		gacutil -i "${1}" \
			-root "${ED}"/usr/$(get_libdir) \
			-gacdir /usr/$(get_libdir) \
			-package ${2:-${GACPN:-${PN}}} \
			|| die "installing ${1} into the Global Assembly Cache failed"
	fi
}

# @FUNCTION: egacadd
# @DESCRIPTION:  install package to GAC
egacadd() {
	if use gac; then
		use !prefix && has "${EAPI:-0}" 0 1 2 && ED="${D}"
		gacutil -i "${1}" \
			-root "${ED}"/usr/$(get_libdir) \
			-gacdir /usr/$(get_libdir) \
			-package ${2:-${GACPN:-${PN}}} \
			|| die "installing ${1} into the Global Assembly Cache failed"
	fi
}

# @FUNCTION: egacdel
# @DESCRIPTION:  remove package from GAC
egacdel() {
	if use gac; then
		use !prefix && has "${EAPI:-0}" 0 1 2 && ED="${D}"
		gacutil -u "${1}" \
			-root "${ED}"/usr/$(get_libdir) \
			-gacdir /usr/$(get_libdir) \
			-package ${2:-${GACPN:-${PN}}}
		# don't die
	fi
}

# @FUNCTION: einstall_pc_file
# @DESCRIPTION:  installs .pc file
# The file format contains predefined metadata keywords and freeform variables (like ${prefix} and ${exec_prefix})
# $1 = ${PN}
# $2 = myassembly.dll
einstall_pc_file()
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
