# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: dotbuildtask.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: functions for installing msbuild task assembly
# @DESCRIPTION:
# It is separated into it's own file to provide ability to define default src_install function for msbuild tasks ebuilds

case ${EAPI:-0} in
	0) die "this eclass doesn't support EAPI 0" ;;
	1|2|3) ;;
	*) ;; #if [[ ${USE_DOTNET} ]]; then REQUIRED_USE="|| (${USE_DOTNET})"; fi;;
esac

inherit multilib dotnet msbuild

# @FUNCTION: get_MSBuildExtensionsPath
# @DESCRIPTION: returns path to .targets files
get_MSBuildExtensionsPath() {
	echo /usr/share/msbuild
}

# @FUNCTION: get_MSBuildExtensionsPath
# @DESCRIPTION: returns path to .targets files
einstask() {
	local state=a
	for var in "$@"
	do
		case "${state}" in
		a)
			elog installing msbuild task dll "${var}" into "$(get_dotlibdir)"
			insinto "$(get_dotlibdir)"
			doins ${var}
			insinto "$(get_MSBuildExtensionsPath)"
			state=b
			;;
		b)
			elog installing file task dll "${var}" into "$(get_MSBuildExtensionsPath)"
			doins ${var}
			;;
		esac
	done
}
