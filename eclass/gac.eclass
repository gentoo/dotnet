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

IUSE+=" +gac +pkg-config +symlink"

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
# $2 = ${PV}
# $3 = myassembly.dll # should not contain path, it is calculated magically, see DLL_FILENAME variable
einstall_pc_file()
{
	if use pkg-config; then
		local PC_NAME="$1"
		local PC_VERSION="$2"
		local DLL_NAME="$3"
		local PC_FILENAME="${PC_NAME}-${PC_VERSION}"
		local PC_DIRECTORY="/usr/$(get_libdir)/pkgconfig"
		#local PC_DIRECTORY_DELTA="${CATEGORY}/${PN}"
		local PC_DIRECTORY_VER="${PC_DIRECTORY}/${PC_DIRECTORY_DELTA}"
		local DLL_FILENAME="\${libdir}/mono/${PC_NAME}/${DLL_NAME}"

		dodir "${PC_DIRECTORY}"
		dodir "${PC_DIRECTORY_VER}"

		ebegin "Installing ${PC_DIRECTORY_VER}/${PC_FILENAME}.pc file"

		# @Name@: A human-readable name for the library or package. This does not affect usage of the pkg-config tool,
		# which uses the name of the .pc file.
		# see https://people.freedesktop.org/~dbn/pkg-config-guide.html

		# \${name} variables going directly into .pc file after unescaping $ sign
		#
		# other variables are not substituted to sed input directly
		# to protect them from processing by bash
		# (they only requires sed escaping for replacement path)
		sed \
			-e "s:@PC_VERSION@:${PC_VERSION}:" \
			-e "s:@Name@:${CATEGORY}/${PN}:" \
			-e "s:@DESCRIPTION@:${DESCRIPTION}:" \
			-e "s:@LIBDIR@:$(get_libdir):" \
			-e "s*@LIBS@*-r:${DLL_FILENAME}*" \
			<<-EOF >"${D}/${PC_DIRECTORY_VER}/${PC_FILENAME}.pc" || die
				prefix=\${pcfiledir}/../..
				exec_prefix=\${prefix}
				libdir=\${exec_prefix}/@LIBDIR@
				Version: @PC_VERSION@
				Name: @Name@
				Description: @DESCRIPTION@
				Libs: @LIBS@
			EOF

		einfo PKG_CONFIG_PATH="${D}/${PC_DIRECTORY_VER}" pkg-config --exists "${PC_FILENAME}"
		PKG_CONFIG_PATH="${D}/${PC_DIRECTORY_VER}" pkg-config --exists "${PC_FILENAME}" || die ".pc file failed to validate."
		eend $?

		if use symlink; then
			einfo "SymLinking ${PC_DIRECTORY_VER}/${PC_FILENAME}.pc file as ${PC_DIRECTORY}/${PC_NAME}.pc"
			dosym "./${PC_DIRECTORY_DELTA}/${PC_FILENAME}.pc" "${PC_DIRECTORY}/${PC_NAME}.pc"
		fi
	fi
}
