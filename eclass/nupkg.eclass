# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: nupkg.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: Functions for building and maintaining local nuget packages repository
# @DESCRIPTION: Common functionality needed by fake build system.

inherit dotnet

IUSE+=" +nupkg"

DEPEND+=" dev-dotnet/nuget"
RDEPEND+=" dev-dotnet/nuget"

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

CONFIG_PATH=${T}/.nuget
CONFIG_NAME=NuGet.Config

# @FUNCTION: enuget_download_rogue_binary
# @DESCRIPTION: downloads a binary package from 3rd untrusted party repository
# accepts Id of package as parameter
enuget_download_rogue_binary() {
	einfo "Downloading rogue binary '$1'"
	addwrite "$(get_nuget_untrusted_archives_location)" || die
	mkdir -p "$(get_nuget_untrusted_archives_location)" || die
	einfo wget --continue https://www.nuget.org/api/v2/package/$1/$2 --output-document="$(get_nuget_untrusted_archives_location)/$1.$2.nupkg"
	      wget --continue https://www.nuget.org/api/v2/package/$1/$2 --output-document="$(get_nuget_untrusted_archives_location)/$1.$2.nupkg" || die
        # -p ignores directory if it is already exists
	mkdir -p "${CONFIG_PATH}/" || die
	cat <<-EOF >"${CONFIG_PATH}/${CONFIG_NAME}" || die
		<?xml version="1.0" encoding="utf-8" ?>
		<configuration>
		    <config>
		        <add key="repositoryPath" value="$(get_nuget_untrusted_archives_location)" />
		    </config>
		    <disabledPackageSources />
		</configuration>
		EOF
	einfo "Installing rogue binary '$1' into '${S}/packages'"
	einfo "$(pwd)"
	einfo nuget install "$1" -Version "$2" -SolutionDirectory "${S}" -ConfigFile "${CONFIG_PATH}/${CONFIG_NAME}" -OutputDirectory "${S}/packages" -Verbosity detailed
	      nuget install "$1" -Version "$2" -SolutionDirectory "${T}" -ConfigFile "${CONFIG_PATH}/${CONFIG_NAME}" -OutputDirectory "${S}/packages" -Verbosity detailed || die
}

# @FUNCTION: enuspec
# @DESCRIPTION: run nuget pack
# accepts path to .nuspec file as parameter
enuspec() {
	if use nupkg; then
		# see http://docs.nuget.org/create/nuspec-reference#specifying-files-to-include-in-the-package
		# for the explaination why $configuration$ property is passed
		if use debug; then
			PROPS=configuration=Debug
		else
			PROPS=configuration=Release
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

# @ECLASS_VARIABLE: NUGET_DEPEND
# @DESCRIPTION Set false to net depend on nuget
: ${NUGET_NO_DEPEND:=}

if [[ -n ${NUGET_NO_DEPEND} ]]; then
	DEPEND+=" dev-dotnet/nuget"
fi

NPN=${PN/_/.}
if [[ $PV == *_alpha* ]] || [[ $PV == *_beta* ]] || [[ $PV == *_pre* ]]
then
	NPV=${PVR/_/-}
else
	NPV=${PVR}
fi
