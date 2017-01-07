# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: nuget.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: Common functionality for nuget apps
# @DESCRIPTION: my idea of nuget was following:
# introduce nuget IUSE flag for packages that are on nuget to download them from nuget. (if sources fails with some reason or dependies is complicated or if user just want binaries).
# or maybe even introduce few packages that just downloads and instulls from nuget, reason is obviously - easy maintaince

inherit nupkg

# @ECLASS_VARIABLE: NUGET_DEPEND
# @DESCRIPTION Set false to net depend on nuget
: ${NUGET_NO_DEPEND:=}

if [[ -n ${NUGET_NO_DEPEND} ]]; then
	IUSE+=" +nuget"
	
	DEPEND+=" nuget? ( dev-dotnet/nuget )"
	RDEPEND+=" nuget? ( dev-dotnet/nuget )"
fi

# @FUNCTION: enuget_download_rogue_binary
# @DESCRIPTION: downloads a binary package from 3rd untrusted party repository
# accepts Id of package as parameter
enuget_download_rogue_binary() {
	CONFIG_PATH=${T}/.nuget
	CONFIG_NAME=NuGet.Config
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

if [[ $PV == *_alpha* ]] ; then
	NPV=${PVR/_alpha/-alpha}
else
	if [[ $PV == *_beta* ]] ; then
		NPV=${PVR/_beta/-beta}
	else
		if [[ $PV == *_pre* ]] ; then
			NPV=${PVR/_pre/-pre}
		else
			if [[ $PV == *_p* ]] ; then
				NPV=${PVR/_p/-p}
			else
				NPV=${PVR}
			fi
		fi
	fi
fi

# @FUNCTION: nuget_src_unpack
# @DESCRIPTION: Runs nuget
# Here is usage example where nuget is alternative way: https://github.com/gentoo/dotnet/blob/master/dev-dotnet/fake
# Src_compile does nothing and src_install just installs sources from nuget_src_unpack
nuget_src_unpack() {
	default
	einfo "src_unpack() from nuget.eclass is called"

	NPN=${PN/_/.}

	nuget install "${NPN}" -Version "${NPV}" -OutputDirectory "${P}"
}

# @FUNCTION: nuget_src_configure
# @DESCRIPTION: Runs nothing.
nuget_src_configure() { :; }

# @FUNCTION: nuget_src_compile
# @DESCRIPTION: Runs nothing.
nuget_src_compile() { :; }

EXPORT_FUNCTIONS src_unpack src_configure src_compile
