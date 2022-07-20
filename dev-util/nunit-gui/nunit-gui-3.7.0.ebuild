# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="3"

USE_DOTNET="net45"
IUSE="+net45 developer debug nupkg gac doc"

inherit mono-env gac nupkg mpt-r20150903 versionator

NAME="nunit-gui"
HOMEPAGE="https://github.com/nunit/${NAME}"

EGIT_COMMIT="df9dd76fcaad5679c08cca0775b6f43e96852a21"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="NUnit test suite for mono applications"
LICENSE="MIT" # https://github.com/nunit/nunit/blob/master/LICENSE.txt

CDEPEND=">=dev-lang/mono-5.0.1.1
	>=dev-dotnet/nunit-framework-3.7.0
	>=dev-util/nunit-console-3.7.0
	dev-dotnet/cecil
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

FILE_TO_BUILD="${NAME}.sln"
METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

NUGET_PACKAGE_VERSION="$(get_version_component_range 1-3)"

src_prepare() {
	empt-sln --remove-proj="nunit-gui.tests" --sln-file="${METAFILETOBUILD}"
	empt-csproj --replace-reference="nunit.framework" --dir="${S}"
	empt-csproj --replace-reference="nunit.engine" --dir="${S}"
	empt-csproj --replace-reference="nunit.engine.api" --dir="${S}"
	empt-csproj --replace-reference="Mono.Cecil" --dir="${S}"
	empt-csproj --remove-reference="NUnit.System.Linq" --dir="${S}"
	sed -i '/<CopyToOutputDirectory>PreserveNewest<\/CopyToOutputDirectory>/d' "${S}/src/nunit-gui/nunit-gui.csproj" || die
	sed -i 's/"nunit.framework/"nunit.framework, Version=3.7.0.0/g' "${S}/src/mock-assembly/mock-assembly.csproj" || die
	eapply_user
}

src_compile() {
	exbuild "${METAFILETOBUILD}"
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
	rm "${D}/usr/share/nunit-3/nunit.engine.api.dll" || die #it is isntalled by dev-util/nunit-console package
	# install: cannot stat 'bin/Release/*.mdb': No such file or directory
	if use developer; then
		doins bin/${DIR}/*.mdb
	fi

	make_wrapper nunit-gui "mono ${SLOTTEDDIR}/nunit-gui.exe"

	if use doc; then
		doins LICENSE.txt NOTICES.txt CHANGES.txt
	fi
}
