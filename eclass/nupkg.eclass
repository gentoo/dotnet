# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: nupkg.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: Functions for building and maintaining local nuget packages repository
# @DESCRIPTION: Common functionality needed by fake build system.

inherit dotnet

IUSE+=" +nupkg"

DEPEND+=" nupkg? ( dev-dotnet/nuget )"
RDEPEND+=" nupkg? ( dev-dotnet/nuget )"

# @FUNCTION: get_nuget_trusted_icons_location
# @USAGE: [directory]
# @DESCRIPTION:
# returns base directory for monodevelop addin icons
get_nuget_trusted_icons_location() {
	echo $(get_nuget_trusted_archives_location)/icons
}

# @FUNCTION: get_nuget_trusted_archives_location
# @USAGE: [directory]
# @DESCRIPTION:
# returns base directory for various nuget folders.
get_nuget_trusted_archives_location() {
	if [ -d "/var/calculate/remote/distfiles" ]; then
		# Control will enter here if the directory exist.
		# this is necessary to handle calculate linux profiles feature (for corporate users)
		echo /var/calculate/remote/packages/NuGet
	else
		# this is for all normal gentoo-based distributions
		echo /usr/local/nuget/nupkg
	fi
}

# @FUNCTION: get_nuget_trusted_archives_location
# @USAGE: [directory]
# @DESCRIPTION:
# returns base directory for various nuget folders.
get_nuget_untrusted_archives_location() {
	if [ -d "/var/calculate/remote/distfiles" ]; then
		# Control will enter here if the directory exist.
		# this is necessary to handle calculate linux profiles feature (for corporate users)
		echo /var/calculate/remote/packages/NuGet/nuget.org
	else
		# this is for all normal gentoo-based distributions
		echo /usr/local/nuget/downloads/nuget.org
	fi
}

# @FUNCTION: get_nuget_trusted_unpacked_location
# @USAGE: [directory]
# @DESCRIPTION:
# returns base directory for package content (system wide installation location)
get_nuget_trusted_unpacked_location() {
	if [ -d "/var/calculate/remote/distfiles" ]; then
		# Control will enter here if the directory exist.
		# this is necessary to handle calculate linux profiles feature (for corporate users)
		echo /var/calculate/remote/distfiles/NuGet/packages
	else
		# this is for all normal gentoo-based distributions
		echo /usr/local/nuget/packages
	fi
}

# @FUNCTION: enuget_restore
# @DESCRIPTION: run nuget restore
# accepts path to .sln or .proj or .csproj file to restore as parameter
enuget_restore() {
	nuget restore "$@" || die
}

# @FUNCTION: enuspec
# @DESCRIPTION: run nuget pack
# accepts path to .nuspec file as parameter
enuspec() {
	if use nupkg; then
		local PROPS=${NUSPEC_PROPERTIES}
		if [ -n "${PROPS}" ]; then
			PROPS+=';'
		fi
		# see http://docs.nuget.org/create/nuspec-reference#specifying-files-to-include-in-the-package
		# for the explaination why $configuration$ property is passed
		if use debug; then
			PROPS+="configuration=Debug"
		else
			PROPS+="configuration=Release"
		fi
		nuget pack -Properties "${PROPS}" -BasePath "${S}" -OutputDirectory "${WORKDIR}" -NonInteractive -Verbosity detailed "$@" || die
	fi
}

# @FUNCTION: enupkg
# @DESCRIPTION: installs .nupkg into local repository
# accepts path to .nupkg file as parameter
enupkg() {
	if use nupkg; then
		elog "enupkg $@ -> $(get_nuget_trusted_archives_location)"
		insinto $(get_nuget_trusted_archives_location)
		doins "$@"
	fi
}
