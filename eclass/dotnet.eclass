# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: dotnet.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: common settings and functions for mono and dotnet related packages
# @DESCRIPTION:
# The dotnet eclass contains common environment settings that are useful for
# dotnet packages.  Currently, it provides no functions, just exports
# MONO_SHARED_DIR and sets LC_ALL in order to prevent errors during compilation
# of dotnet packages.

case ${EAPI:-0} in
	0) die "this eclass doesn't support EAPI 0" ;;
	1|2|3) ;;
	*) ;; #if [[ ${USE_DOTNET} ]]; then REQUIRED_USE="|| (${USE_DOTNET})"; fi;;
esac

inherit eutils versionator mono-env

# @ECLASS-VARIABLE: USE_DOTNET
# @DESCRIPTION:
# Use flags added to IUSE

DEPEND+=" dev-lang/mono"
IUSE+=" debug developer"

# SRC_URI+=" https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
# I was unable to setup it this ^^ way

# SET default use flags according on DOTNET_TARGETS
for x in ${USE_DOTNET}; do
	case ${x} in
		net45) if [[ ${DOTNET_TARGETS} == *net45* ]]; then IUSE+=" +net45"; else IUSE+=" net45"; fi;;
		net40) if [[ ${DOTNET_TARGETS} == *net40* ]]; then IUSE+=" +net40"; else IUSE+=" net40"; fi;;
		net35) if [[ ${DOTNET_TARGETS} == *net35* ]]; then IUSE+=" +net35"; else IUSE+=" net35"; fi;;
		net20) if [[ ${DOTNET_TARGETS} == *net20* ]]; then IUSE+=" +net20"; else IUSE+=" net20"; fi;;
	esac
done

# @FUNCTION: dotnet_pkg_setup
# @DESCRIPTION:  This function set FRAMEWORK
dotnet_pkg_setup() {
	EBUILD_FRAMEWORK=""
	mono-env_pkg_setup
	for x in ${USE_DOTNET} ; do
		case ${x} in
			net45) EBF="4.5"; if use net45; then F="${EBF}";fi;;
			net40) EBF="4.0"; if use net40; then F="${EBF}";fi;;
			net35) EBF="3.5"; if use net35; then F="${EBF}";fi;;
			net20) EBF="2.0"; if use net20; then F="${EBF}";fi;;
		esac
		if [[ -z ${FRAMEWORK} ]]; then
			if [[ ${F} ]]; then
				FRAMEWORK="${F}";
			fi
		else
			version_is_at_least "${F}" "${FRAMEWORK}" || FRAMEWORK="${F}"
		fi
		if [[ -z ${EBUILD_FRAMEWORK} ]]; then
			if [[ ${EBF} ]]; then
				EBUILD_FRAMEWORK="${EBF}";
			fi
		else
			version_is_at_least "${EBF}" "${EBUILD_FRAMEWORK}" || EBUILD_FRAMEWORK="${EBF}"
		fi
	done
	if [[ -z ${FRAMEWORK} ]]; then
		if [[ -z ${EBUILD_FRAMEWORK} ]]; then
			FRAMEWORK="4.0"
			elog "Ebuild doesn't contain USE_DOTNET="
		else
			FRAMEWORK="${EBUILD_FRAMEWORK}"
			elog "User did not set any netNN use-flags in make.conf or profile, .ebuild demands USE_DOTNET=""${USE_DOTNET}"""
		fi
	fi
	einfo " -- USING .NET ${FRAMEWORK} FRAMEWORK -- "
}

# >=mono-0.92 versions using mcs -pkg:foo-sharp require shared memory, so we set the
# shared dir to ${T} so that ${T}/.wapi can be used during the install process.
export MONO_SHARED_DIR="${T}"

# Building mono, nant and many other dotnet packages is known to fail if LC_ALL
# variable is not set to C. To prevent this all mono related packages will be
# build with LC_ALL=C (see bugs #146424, #149817)
export LC_ALL=C

# Monodevelop-using applications need this to be set or they will try to create config
# files in the user's ~ dir.

export XDG_CONFIG_HOME="${T}"

# Fix bug 83020:
# "Access Violations Arise When Emerging Mono-Related Packages with MONO_AOT_CACHE"

unset MONO_AOT_CACHE

# @FUNCTION: output_relpath
# @DESCRIPTION:  returns default relative directory for Debug or Release configuration depending from USE="debug"
function output_relpath ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "bin/${DIR}"
}

# @FUNCTION: dotnet_multilib_comply
# @DESCRIPTION:  multilib comply
dotnet_multilib_comply() {
	use !prefix && has "${EAPI:-0}" 0 1 2 && ED="${D}"
	local dir finddirs=() mv_command=${mv_command:-mv}
	if [[ -d "${ED}/usr/lib" && "$(get_libdir)" != "lib" ]]
	then
		if ! [[ -d "${ED}"/usr/"$(get_libdir)" ]]
		then
			mkdir "${ED}"/usr/"$(get_libdir)" || die "Couldn't mkdir ${ED}/usr/$(get_libdir)"
		fi
		${mv_command} "${ED}"/usr/lib/* "${ED}"/usr/"$(get_libdir)"/ || die "Moving files into correct libdir failed"
		rm -rf "${ED}"/usr/lib
		for dir in "${ED}"/usr/"$(get_libdir)"/pkgconfig "${ED}"/usr/share/pkgconfig
		do

			if [[ -d "${dir}" && "$(find "${dir}" -name '*.pc')" != "" ]]
			then
				pushd "${dir}" &> /dev/null
				sed  -i -r -e 's:/(lib)([^a-zA-Z0-9]|$):/'"$(get_libdir)"'\2:g' \
					*.pc \
					|| die "Sedding some sense into pkgconfig files failed."
				popd "${dir}" &> /dev/null
			fi
		done
		if [[ -d "${ED}/usr/bin" ]]
		then
			for exe in "${ED}/usr/bin"/*
			do
				if [[ "$(file "${exe}")" == *"shell script text"* ]]
				then
					sed -r -i -e ":/lib(/|$): s:/lib(/|$):/$(get_libdir)\1:" \
						"${exe}" || die "Sedding some sense into ${exe} failed"
				fi
			done
		fi

	fi
}

EXPORT_FUNCTIONS pkg_setup
