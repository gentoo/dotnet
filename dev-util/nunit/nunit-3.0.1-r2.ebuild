# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="3"

USE_DOTNET="net45"
IUSE="+net45 developer debug nupkg gac doc"

inherit mono-env xbuild gac nupkg versionator

NAME="nunit"
HOMEPAGE="https://github.com/nunit/${NAME}"

EGIT_COMMIT="dd39deaa2c805783cb069878b58b0447d0849849"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
#	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="NUnit test suite for mono applications"
LICENSE="MIT" # https://github.com/nunit/nunit/blob/master/LICENSE.txt

CDEPEND=">=dev-lang/mono-4.0.2.5
	net45? (
		developer? (
			debug?  ( dev-dotnet/cecil[net45,gac,developer,debug] )
			!debug? ( dev-dotnet/cecil[net45,gac,developer] )
		)
		!developer? (
			debug?  ( dev-dotnet/cecil[net45,gac,debug] )
			!debug? ( dev-dotnet/cecil[net45,gac] )
		)
	)
"

DEPEND="${CDEPEND}
	net45? (
		developer? (
			debug? ( dev-util/nant[net45,nupkg,developer,debug] )
			!debug? ( dev-util/nant[net45,nupkg,developer] )
		)
		!developer? (
			debug? ( dev-util/nant[net45,nupkg,debug] )
			!debug? ( dev-util/nant[net45,nupkg] )
		)
	)
"

RDEPEND="${CDEPEND}
"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
FILE_TO_BUILD=NUnit.proj
METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

NUGET_PACKAGE_VERSION="$(get_version_component_range 1-3)"

src_prepare() {
	# cp "${DISTDIR}/mono.snk" "${S}/src/nunit.snk" || die
	chmod -R +rw "${S}" || die
	eapply "${FILESDIR}/nunit-3.0.1-removing-tests-from-nproj.patch"
	eapply "${FILESDIR}/nunit-3.0.1-nuget.nuspec.patch"
	eapply "${FILESDIR}/nunit-3.0.1-nunit.console.nuspec.patch"
	eapply "${FILESDIR}/nunit-3.0.1-nunit.engine.nuspec.patch"
	enuget_restore "${METAFILETOBUILD}"

	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	sed -i "s=\\\$version\\\$=${NUGET_PACKAGE_VERSION}=g" "${S}/nuget/"*.nuspec || die
	sed -i 's#\\#/#g' "${S}/nuget/"*.nuspec || die
	sed -i "s=\\\$dir\\\$=${DIR}=g" "${S}/nuget/"*.nuspec || die
	default
}

src_compile() {
	exbuild "${METAFILETOBUILD}"
	enuspec "${S}/nuget/nunit.nuspec"
	enuspec "${S}/nuget/nunit.runners.nuspec"
	enuspec "${S}/nuget/nunit.console.nuspec"
	enuspec "${S}/nuget/nunit.engine.nuspec"
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	SLOTTEDDIR="/usr/share/nunit-${SLOT}/"
	insinto "${SLOTTEDDIR}"
	doins bin/${DIR}/*.{config,dll,exe}
	# install: cannot stat 'bin/Release/*.mdb': No such file or directory
	if use developer; then
		doins bin/${DIR}/*.mdb
	fi

	make_wrapper nunit "mono ${SLOTTEDDIR}/nunit3-console.exe"

	# https://stackoverflow.com/questions/36430417/is-there-a-nunit-console-runner-dll-for-nunit-3-0
	# egacinstall "${S}/bin/${DIR}/nunit-console-runner.dll"
	sn -R "bin/${DIR}/net-4.5/nunit.framework.dll" src/nunit.snk || die
	egacinstall "bin/${DIR}/net-4.5/nunit.framework.dll"

	if use doc; then
#		dodoc ${WORKDIR}/doc/*.txt
#		dohtml ${WORKDIR}/doc/*.html
#		insinto /usr/share/${P}/samples
#		doins -r ${WORKDIR}/samples/*
		doins LICENSE.txt NOTICES.txt CHANGES.txt
	fi

	enupkg "${WORKDIR}/NUnit.${NUGET_PACKAGE_VERSION}.nupkg"
	enupkg "${WORKDIR}/NUnit.Runners.${NUGET_PACKAGE_VERSION}.nupkg"
	enupkg "${WORKDIR}/NUnit.Console.${NUGET_PACKAGE_VERSION}.nupkg"
	enupkg "${WORKDIR}/NUnit.Engine.${NUGET_PACKAGE_VERSION}.nupkg"
}
