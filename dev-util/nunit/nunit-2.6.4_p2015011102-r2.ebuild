# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="2" # NUnit V2 IS NO LONGER MAINTAINED OR UPDATED.

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} developer debug +gac nupkg doc"

inherit mono-env xbuild gac nupkg

NAME="nunitv2"
HOMEPAGE="https://github.com/nunit/${NAME}"

EGIT_COMMIT="1b549f4f8b067518c7b54a5b263679adb83ccda4"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${PN}-${PV}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="NUnit test suite for mono applications"
LICENSE="NUnit-License" # https://nunit.org/nuget/license.html

RDEPEND=">=dev-lang/mono-4.0.2.5
	dev-util/nant[nupkg]
"
DEPEND="${RDEPEND}
"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
FILE_TO_BUILD=nunit.sln
METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

# PN = Package name, for example vim.
# PV = Package version (excluding revision, if any), for example 6.3.

src_prepare() {
	chmod -R +rw "${S}" || die
	enuget_restore "${METAFILETOBUILD}"

	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	sed -i '/x86/d' "${S}/nuget/"*.nuspec || die
	sed -i '/log4net/d' "${S}/nuget/"*.nuspec || die
	sed -i 's#\\#/#g' "${S}/nuget/"*.nuspec || die
	sed -i "s#\${package.version}#$(get_version_component_range 1-3)#g" "${S}/nuget/"*.nuspec || die
	sed -i "s#\${project.base.dir}##g" "${S}/nuget/"*.nuspec || die
	sed -i "s#\${current.build.dir}#bin/${DIR}#g" "${S}/nuget/"*.nuspec || die
	default
}

src_compile() {
	# /p:PublicSign=true
	exbuild /p:SignAssembly=true /p:DelaySign=true "/p:AssemblyOriginatorKeyFile=${S}/src/nunit.snk" "${METAFILETOBUILD}"
	sn -R "${S}/bin/${DIR}/lib/nunit-console-runner.dll" "${S}/src/nunit.snk" || die
	sn -R "${S}/bin/${DIR}/framework/nunit.framework.dll" "${S}/src/nunit.snk" || die
	enuspec "${S}/nuget/nunit.nuspec"
	enuspec "${S}/nuget/nunit.runners.nuspec"
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

#	into /usr
#	dobin ${FILESDIR}/nunit-console
	make_wrapper nunit264 "mono ${SLOTTEDDIR}/nunit-console.exe"

	if use gac; then
		if use debug; then
			DIR="Debug"
		else
			DIR="Release"
		fi

		egacinstall "${S}/bin/${DIR}/lib/nunit-console-runner.dll"
		egacinstall "${S}/bin/${DIR}/framework/nunit.framework.dll"
	fi

	if use doc; then
#		dodoc ${WORKDIR}/doc/*.txt
#		dohtml ${WORKDIR}/doc/*.html
#		insinto /usr/share/${P}/samples
#		doins -r ${WORKDIR}/samples/*
		doins license.txt
	fi

	enupkg "${WORKDIR}/NUnit.$(get_version_component_range 1-3).nupkg"
	enupkg "${WORKDIR}/NUnit.Runners.$(get_version_component_range 1-3).nupkg"
}
