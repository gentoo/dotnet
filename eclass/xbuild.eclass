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

inherit dotnet

# @FUNCTION: exbuild_raw
# @DESCRIPTION: run xbuild with given parameters
exbuild_raw() {
	elog """$@"""
	xbuild "$@" || die
}

# @FUNCTION: exbuild
# @DESCRIPTION: run xbuild with Release configuration and configurated FRAMEWORK
exbuild() {
	if use debug; then
		CARGS=/p:Configuration=Debug
	else
		CARGS=/p:Configuration=Release
	fi

	if use developer; then
		SARGS=/p:DebugSymbols=True
	else
		SARGS=/p:DebugSymbols=False
	fi

	if [[ -z ${TOOLS_VERSION} ]]; then
		TOOLS_VERSION=4.0
	fi

	exbuild_raw "/v:detailed" "/tv:${TOOLS_VERSION}" "/p:TargetFrameworkVersion=v${FRAMEWORK}" "${CARGS}" "${SARGS}" "$@"
}

# @FUNCTION: exbuild_strong
# @DESCRIPTION: run xbuild with default key signing
exbuild_strong() {
	# http://stackoverflow.com/questions/7903321/only-sign-assemblies-with-strong-name-during-release-build
	DOTNET_ECLASSDIR="`dirname "${EBUILD}"`/../../eclass"
	if use gac; then
		if [[ -z ${SNK_FILENAME} ]]; then
			# elog ${BASH_SOURCE}
			SNK_FILENAME="${DOTNET_ECLASSDIR}/mono.snk"
			# sn - Digitally sign/verify/compare strongnames on CLR assemblies. 
			# man sn = http://linux.die.net/man/1/sn
			if [ -f ${SNK_FILENAME} ]; then
				einfo "build through snk = ${SNK_FILENAME}"
				KARGS1=/p:SignAssembly=true 
				KARGS2=/p:AssemblyOriginatorKeyFile=${SNK_FILENAME}
			else
				einfo "build through container"
				KARGS1=/p:SignAssembly=true 
				KARGS2=/p:AssemblyKeyContainerName=mono
			fi
		else
			einfo "build through given snk"
			KARGS1=/p:SignAssembly=true 
			KARGS2=/p:AssemblyOriginatorKeyFile=${SNK_FILENAME}
		fi
	else
		einfo "no strong signing"
		KARGS1=
		KARGS2=
	fi
	exbuild "${KARGS1}" "${KARGS2}" "$@"
}
