# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: mono-pkg-config.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: functions for registring in gac
# @DESCRIPTION:
# interacts with pkg-config tools

case ${EAPI:-0} in
	0|1|2|3|4|5) die "this eclass doesn't support EAPI ${EAPI:-0}" ;;
	6) ;;
esac

IUSE+=" pkg-config symlink"

DEPEND+=" dev-lang/mono"
RDEPEND+=" dev-lang/mono"

# http://www.gossamer-threads.com/lists/gentoo/dev/263462
# pkg config files should always come from upstream
# but what if they are not?
# you can fork, or you can use a configuration system that upstream actually supports.
# both are more difficult than creating .pc in ebuilds. Forks requires maintenance, and 
# second one requires rewriting the IDE (disrespecting the decision of IDE's authors who decide to use .pc-files)
# So, "keep fighting the good fight, don't stop believing, and let the haters hate" (q) desultory from #gentoo-dev-help @ freenode

# @FUNCTION: einstall_pc_file
# @DESCRIPTION:  installs .pc file
# The file format contains predefined metadata keywords and freeform variables (like ${prefix} and ${exec_prefix})
# $1 = ${PN}
# $2 = ${PV}
# $3 = myassembly1 # should not contain path, shouldn't contain .dll extension
# $4 = myassembly2
# $N = myassemblyN-2 # see DLL_REFERENCES
einstall_pc_file()
{
	if use pkg-config; then
		local PC_NAME="$1"
		local PC_VERSION="$2"

		shift 2
		if [ "$#" == "0" ]; then
			die "no assembly names given"
		fi
		local DLL_REFERENCES=""
		while (( "$#" )); do
			DLL_REFERENCES+=" -r:\${libdir}/mono/${PC_NAME}/${1}.dll"
			shift
		done

#		local PC_FILENAME="${PC_NAME}-${PC_VERSION}"
		local PC_FILENAME="${PN}-${PV}"
		local PC_DIRECTORY="/usr/$(get_libdir)/pkgconfig"
		#local PC_DIRECTORY_DELTA="${CATEGORY}/${PN}"
		local PC_DIRECTORY_VER="${PC_DIRECTORY}/${PC_DIRECTORY_DELTA}"

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
			-e "s*@LIBS@*${DLL_REFERENCES}*" \
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
