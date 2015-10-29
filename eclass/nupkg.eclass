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

