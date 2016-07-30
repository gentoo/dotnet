# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit mono-env nuget dotnet

NAME="nunit"
HOMEPAGE="https://github.com/nunit/${NAME}"

EGIT_COMMIT="dd39deaa2c805783cb069878b58b0447d0849849"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PF}.tar.gz"
#RESTRICT="mirror"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="3"

DESCRIPTION="NUnit test suite for mono applications"
LICENSE="MIT" # https://github.com/nunit/nunit/blob/master/LICENSE.txt
KEYWORDS="~amd64 ~ppc ~x86"
#USE_DOTNET="net20 net40 net45"
USE_DOTNET="net45"
IUSE="net45 developer debug nupkg doc"

RDEPEND=">=dev-lang/mono-4.0.2.5
	dev-util/nant[nupkg]
"
DEPEND="${RDEPEND}
"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
FILE_TO_BUILD=NUnit.proj
METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

src_prepare() {
	chmod -R +rw "${S}" || die
	eapply "${FILESDIR}/nunit-3.0.1-removing-tests-from-nproj.patch"
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
	exbuild "${METAFILETOBUILD}"
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
	make_wrapper nunit "mono ${SLOTTEDDIR}/nunit-console.exe"

	if use gac; then
		if use debug; then
			DIR="Debug"
		else
			DIR="Release"
		fi

		egacinstall "${S}/bin/${DIR}/lib/nunit-console-runner.dll"
	fi

	if use doc; then
#		dodoc ${WORKDIR}/doc/*.txt
#		dohtml ${WORKDIR}/doc/*.html
#		insinto /usr/share/${P}/samples
#		doins -r ${WORKDIR}/samples/*
		doins LICENSE.txt NOTICES.txt CHANGES.txt
	fi

	enupkg "${WORKDIR}/NUnit.3.0.0.nupkg"
	enupkg "${WORKDIR}/NUnit.Runners.$(get_version_component_range 1-3).nupkg"
}
