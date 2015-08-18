# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: nuget.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: Common functionality for nuget apps
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
		if use debug; then
			PROPS=Configuration=Debug
		else
			PROPS=Configuration=Release
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
if [[ $PV == *_alpha* ]]
then
	NPV=${PVR/_/-}
else
	NPV=${PVR}
fi

# @FUNCTION: nuget_src_unpack
# @DESCRIPTION: Runs nuget.
nuget_src_unpack() {
	default
	nuget install "${NPN}" -Version "${NPV}" -OutputDirectory "${P}"
}

# @FUNCTION: nuget_src_configure
# @DESCRIPTION: Runs nothing.
nuget_src_configure() { :; }

# @FUNCTION: nuget_src_compile
# @DESCRIPTION: Runs nothing.
nuget_src_compile() { :; }

EXPORT_FUNCTIONS src_unpack src_configure src_compile
