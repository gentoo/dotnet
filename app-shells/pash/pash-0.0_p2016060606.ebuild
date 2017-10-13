# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"
KEYWORDS="~x86 ~amd64 ~ppc"
RESTRICT="mirror"
SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET}"

inherit msbuild eutils

DESCRIPTION="An Open Source reimplementation of Windows PowerShell"

LICENSE="BSD || ( GPL-2+ )"   # LICENSE syntax is defined in https://wiki.gentoo.org/wiki/GLEP:23

PROJECTNAME="Pash"
HOMEPAGE="https://github.com/Pash-Project/${PROJECTNAME}"
EGIT_COMMIT="8d6a48f5ed70d64f9b49e6849b3ee35b887dc254"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${P}-${PR}.tar.gz"
S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

CDEPEND="|| ( >=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999 )
	dev-dotnet/irony-framework
	"

RDEPEND="${CDEPEND}
	"
DEPEND="${CDEPEND}
	"

PROJECT1_PATH=Source/Microsoft.PowerShell.Security
PROJECT1_NAME=Microsoft.PowerShell.Security
PROJECT1_OUT=Microsoft.PowerShell.Security

PROJECT2_PATH=Source/System.Management
PROJECT2_NAME=System.Management
PROJECT2_OUT=System.Management

PROJECT3_PATH=Source/Microsoft.PowerShell.Commands.Utility
PROJECT3_NAME=Microsoft.PowerShell.Commands.Utility
PROJECT3_OUT=Microsoft.PowerShell.Commands.Utility

PROJECT4_PATH=Source/Microsoft.PowerShell.Commands.Management
PROJECT4_NAME=Microsoft.Commands.Management
PROJECT4_OUT=Microsoft.PowerShell.Commands.Management

PROJECT5_PATH=Source/PashConsole
PROJECT5_NAME=PashConsole
PROJECT5_OUT=PashConsole

src_prepare() {
	cp "${FILESDIR}/template.csproj" "${S}/${PROJECT1_PATH}/${PROJECT1_NAME}.csproj" || die
	cp "${FILESDIR}/template.csproj" "${S}/${PROJECT2_PATH}/${PROJECT2_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="Irony" />#' "${S}/${PROJECT2_PATH}/${PROJECT2_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="Microsoft.CSharp" />#' "${S}/${PROJECT2_PATH}/${PROJECT2_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Data" />#' "${S}/${PROJECT2_PATH}/${PROJECT2_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Xml" />#' "${S}/${PROJECT2_PATH}/${PROJECT2_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Configuration" />#' "${S}/${PROJECT2_PATH}/${PROJECT2_NAME}.csproj" || die
	cp "${FILESDIR}/template.csproj" "${S}/${PROJECT3_PATH}/${PROJECT3_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Data" />#' "${S}/${PROJECT3_PATH}/${PROJECT3_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Xml" />#' "${S}/${PROJECT3_PATH}/${PROJECT3_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Net" />#' "${S}/${PROJECT3_PATH}/${PROJECT3_NAME}.csproj" || die
	sed -i 's#^.*-- ProjectReference --.*$#&\n<ProjectReference Include="../${PROJECT1_PATH}/${PROJECT1_NAME}.csproj" />#' "${S}/${PROJECT3_PATH}/${PROJECT3_NAME}.csproj" || die
	cp "${FILESDIR}/template.csproj" "${S}/${PROJECT4_PATH}/${PROJECT4_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Data" />#' "${S}/${PROJECT4_PATH}/${PROJECT4_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Xml" />#' "${S}/${PROJECT4_PATH}/${PROJECT4_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.ServiceProcess" />#' "${S}/${PROJECT4_PATH}/${PROJECT4_NAME}.csproj" || die
	sed -i 's#^.*-- ProjectReference --.*$#&\n<ProjectReference Include="../${PROJECT1_PATH}/${PROJECT1_NAME}.csproj" />#' "${S}/${PROJECT4_PATH}/${PROJECT4_NAME}.csproj" || die
	cp "${FILESDIR}/template.csproj" "${S}/${PROJECT5_PATH}/${PROJECT5_NAME}.csproj" || die
	sed -i 's#^.*-- ProjectReference --.*$#&\n<ProjectReference Include="../${PROJECT1_PATH}/${PROJECT1_NAME}.csproj" />#' "${S}/${PROJECT5_PATH}/${PROJECT5_NAME}.csproj" || die
	sed -i 's#^.*-- ProjectReference --.*$#&\n<ProjectReference Include="../${PROJECT2_PATH}/${PROJECT2_NAME}.csproj" />#' "${S}/${PROJECT5_PATH}/${PROJECT5_NAME}.csproj" || die
	sed -i 's#^.*-- ProjectReference --.*$#&\n<ProjectReference Include="../${PROJECT3_PATH}/${PROJECT3_NAME}.csproj" />#' "${S}/${PROJECT5_PATH}/${PROJECT5_NAME}.csproj" || die
	sed -i 's#^.*-- ProjectReference --.*$#&\n<ProjectReference Include="../${PROJECT4_PATH}/${PROJECT4_NAME}.csproj" />#' "${S}/${PROJECT5_PATH}/${PROJECT5_NAME}.csproj" || die
	eapply_user
}

src_compile() {
	emsbuild "/p:AssemblyName=${PROJECT1_OUT}" "/p:OutputType=Library" "${S}/${PROJECT1_PATH}/${PROJECT1_NAME}.csproj"
	emsbuild "/p:AssemblyName=${PROJECT1_OUT}" "/p:OutputType=Library" "${S}/${PROJECT1_PATH}/${PROJECT2_NAME}.csproj"
	emsbuild "/p:AssemblyName=${PROJECT1_OUT}" "/p:OutputType=Library" "${S}/${PROJECT1_PATH}/${PROJECT3_NAME}.csproj"
	emsbuild "/p:AssemblyName=${PROJECT1_OUT}" "/p:OutputType=Library" "${S}/${PROJECT1_PATH}/${PROJECT4_NAME}.csproj"
	emsbuild "/p:AssemblyName=${PROJECT1_OUT}" "/p:OutputType=Exe" "${S}/${PROJECT1_PATH}/${PROJECT5_NAME}.csproj"
}

src_install() {
	if [ "${SLOT}"="0" ] ;
	then
		SLOTTEDDIR="/usr/share/${PN}"
	else
		SLOTTEDDIR="/usr/share/${PN}-${SLOT}"
	fi
	insinto "${SLOTTEDDIR}"

	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	doins Source/PashConsole/bin/${DIR}/Pash.exe
	doins Source/PashConsole/bin/${DIR}/*.dll
	if use developer; then
		doins Source/PashConsole/bin/${DIR}/*.pdb
	fi
	if use debug; then
		make_wrapper --debug pash "mono ${SLOTTEDDIR}/Pash.exe"
	else
		make_wrapper pash "mono ${SLOTTEDDIR}/Pash.exe"
	fi
}

