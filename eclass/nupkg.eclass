# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: nupkg.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: Functions for building and maintaining local nuget packages repository
# @DESCRIPTION: Common functionality needed by fake build system.

inherit dotnet

# @FUNCTION: enuget_restore
# @DESCRIPTION: run nuget restore
# accepts path to .sln or .proj or .csproj file to restore as parameter
enuget_restore() {
	nuget restore "$@" || die
}

# @FUNCTION: enuget_download_rogue_binary
# @DESCRIPTION: downloads a binary package from 3rd untrusted party repository
# accepts Id of package as parameter
enuget_download_rogue_binary() {
	if [ -d "/var/calculate/remote/distfiles" ]; then
		NUGET_LOCAL_REPOSITORY_PATH=/var/calculate/remote/packages/NuGet
	else
		# this is for all normal gentoo-based distributions
		NUGET_LOCAL_REPOSITORY_PATH=/usr/local/nuget/nupkg
	fi
	#einfo "Downloading rogue binary '$1' into '${NUGET_LOCAL_REPOSITORY_PATH}'"
	# https://www.nuget.org/api/v2/package/{packageID}/{packageVersion}
	
	# this will give "* ACCESS DENIED:  open_wr:      /var/calculate/remote/packages/NuGet" message
	# wget -c https://www.nuget.org/api/v2/package/$1/$2 -o "${LOCAL_NUGET_REPOSITORY_PATH}"

	einfo "Downloading rogue binary '$1' into '${T}/$1.$2.nupkg'"
	wget -c https://www.nuget.org/api/v2/package/$1/$2 --directory-prefix="${T}/" --output-document="$1.$2.nupkg" || die
        # -p ignores directory if it is already exists
	mkdir -p "${T}/NuGet/" || die
	echo <<\EOF >"${T}/NuGet/NuGet.Config" || die
<?xml version="1.0" encoding="utf-8" ?>
<configuration><config>
<add key="repositoryPath" value="${T}" />
</config></configuration>
EOF
	einfo "Installing rogue binary '$1' into '${S}'"
	nuget install "$1" -Version "$2" -OutputDirectory ${S}
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
		if [ -d "/var/calculate/remote/distfiles" ]; then
			# Control will enter here if the directory exist.
			# this is necessary to handle calculate linux profiles feature (for corporate users)
			elog "Installing .nupkg into /var/calculate/remote/packages/NuGet"
			insinto /var/calculate/remote/packages/NuGet
		else
			# this is for all normal gentoo-based distributions
			elog "Installing .nupkg into /usr/local/nuget/nupkg"
			insinto /usr/local/nuget/nupkg
		fi
		doins "$@"
	fi
}

# @ECLASS_VARIABLE: NUGET_DEPEND
# @DESCRIPTION Set false to net depend on nuget
: ${NUGET_NO_DEPEND:=}

if [[ -n $NUGET_NO_DEPEND ]]; then
	DEPEND+=" dev-dotnet/nuget"
fi

NPN=${PN/_/.}
if [[ $PV == *_alpha* ]] || [[ $PV == *_beta* ]] || [[ $PV == *_pre* ]]
then
	NPV=${PVR/_/-}
else
	NPV=${PVR}
fi

