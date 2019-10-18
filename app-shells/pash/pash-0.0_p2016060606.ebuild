# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
KEYWORDS="~amd64"
RESTRICT="mirror"
SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET}"

inherit dotnet msbuild eutils

DESCRIPTION="An Open Source reimplementation of Windows PowerShell"

LICENSE="BSD || ( GPL-2+ )"   # LICENSE syntax is defined in https://wiki.gentoo.org/wiki/GLEP:23

PROJECTNAME="Pash"
HOMEPAGE="https://github.com/Pash-Project/${PROJECTNAME}"
EGIT_COMMIT="8d6a48f5ed70d64f9b49e6849b3ee35b887dc254"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${P}-${PR}.tar.gz"
S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

CDEPEND="|| ( >=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999 )
	dev-dotnet/irony-daxnet
	"

RDEPEND="${CDEPEND}
	"
DEPEND="${CDEPEND}
	"

PROJECT1_PATH=Source/System.Management
PROJECT1_NAME=System.Management
PROJECT1_OUT=System.Management.Automation

PROJECT2_PATH=Source/Microsoft.PowerShell.Security
PROJECT2_NAME=Microsoft.PowerShell.Security
PROJECT2_OUT=Microsoft.PowerShell.Security

PROJECT3_PATH=Source/Microsoft.PowerShell.Commands.Utility
PROJECT3_NAME=Microsoft.PowerShell.Commands.Utility
PROJECT3_OUT=Microsoft.PowerShell.Commands.Utility

PROJECT4_PATH=Source/Microsoft.PowerShell.Commands.Management
PROJECT4_NAME=Microsoft.Commands.Management
PROJECT4_OUT=Microsoft.PowerShell.Commands.Management

PROJECT5_PATH=Source/PashConsole
PROJECT5_NAME=PashConsole
PROJECT5_OUT=Pash

src_prepare() {
	sed -i "s/new Version(1, 0, 0, 0)/System.Reflection.Assembly.GetExecutingAssembly().GetName().Version/" Source/System.Management/Pash/Implementation/LocalHost.cs || die
	sed -i "/Version/d" "${S}/${PROJECT1_PATH}/Properties/AssemblyInfo.cs" || die
	sed -i "/Version/d" "${S}/${PROJECT2_PATH}/Properties/AssemblyInfo.cs" || die
	sed -i "/Version/d" "${S}/${PROJECT3_PATH}/Properties/AssemblyInfo.cs" || die
	sed -i "/Version/d" "${S}/${PROJECT4_PATH}/Properties/AssemblyInfo.cs" || die
	sed -i "/Version/d" "${S}/${PROJECT5_PATH}/Properties/AssemblyInfo.cs" || die
	sed "s/\$(OutputType)/Library/; s/\$(AssemblyName)/${PROJECT1_OUT}/" "${FILESDIR}/template.csproj" > "${S}/${PROJECT1_PATH}/${PROJECT1_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="Irony" />#' "${S}/${PROJECT1_PATH}/${PROJECT1_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="Microsoft.CSharp" />#' "${S}/${PROJECT1_PATH}/${PROJECT1_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Data" />#' "${S}/${PROJECT1_PATH}/${PROJECT1_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Xml" />#' "${S}/${PROJECT1_PATH}/${PROJECT1_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Configuration" />#' "${S}/${PROJECT1_PATH}/${PROJECT1_NAME}.csproj" || die
	sed "s/\$(OutputType)/Library/; s/\$(AssemblyName)/${PROJECT2_OUT}/" "${FILESDIR}/template.csproj" > "${S}/${PROJECT2_PATH}/${PROJECT2_NAME}.csproj" || die
	sed -i "s#^.*-- ProjectReference --.*\$#&\\n<ProjectReference Include=\"../../${PROJECT1_PATH}/${PROJECT1_NAME}.csproj\" />#" "${S}/${PROJECT2_PATH}/${PROJECT2_NAME}.csproj" || die
	sed "s/\$(OutputType)/Library/; s/\$(AssemblyName)/${PROJECT3_OUT}/" "${FILESDIR}/template.csproj" > "${S}/${PROJECT3_PATH}/${PROJECT3_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Data" />#' "${S}/${PROJECT3_PATH}/${PROJECT3_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Xml" />#' "${S}/${PROJECT3_PATH}/${PROJECT3_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Net" />#' "${S}/${PROJECT3_PATH}/${PROJECT3_NAME}.csproj" || die
	sed -i "s#^.*-- ProjectReference --.*\$#&\\n<ProjectReference Include=\"../../${PROJECT1_PATH}/${PROJECT1_NAME}.csproj\" />#" "${S}/${PROJECT3_PATH}/${PROJECT3_NAME}.csproj" || die
	sed "s/\$(OutputType)/Library/; s/\$(AssemblyName)/${PROJECT4_OUT}/" "${FILESDIR}/template.csproj" > "${S}/${PROJECT4_PATH}/${PROJECT4_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Data" />#' "${S}/${PROJECT4_PATH}/${PROJECT4_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.Xml" />#' "${S}/${PROJECT4_PATH}/${PROJECT4_NAME}.csproj" || die
	sed -i 's#^.*-- Reference --.*$#&\n<Reference Include="System.ServiceProcess" />#' "${S}/${PROJECT4_PATH}/${PROJECT4_NAME}.csproj" || die
	sed -i "s#^.*-- ProjectReference --.*\$#&\\n<ProjectReference Include=\"../../${PROJECT1_PATH}/${PROJECT1_NAME}.csproj\" />#" "${S}/${PROJECT4_PATH}/${PROJECT4_NAME}.csproj" || die
	sed "s/\$(OutputType)/Exe/; s/\$(AssemblyName)/${PROJECT5_OUT}/" "${FILESDIR}/template.csproj" > "${S}/${PROJECT5_PATH}/${PROJECT5_NAME}.csproj" || die
	sed -i "s#^.*-- ProjectReference --.*\$#&\\n<ProjectReference Include=\"../../${PROJECT1_PATH}/${PROJECT1_NAME}.csproj\" />#" "${S}/${PROJECT5_PATH}/${PROJECT5_NAME}.csproj" || die
	sed -i "s#^.*-- ProjectReference --.*\$#&\\n<ProjectReference Include=\"../../${PROJECT2_PATH}/${PROJECT2_NAME}.csproj\" />#" "${S}/${PROJECT5_PATH}/${PROJECT5_NAME}.csproj" || die
	sed -i "s#^.*-- ProjectReference --.*\$#&\\n<ProjectReference Include=\"../../${PROJECT3_PATH}/${PROJECT3_NAME}.csproj\" />#" "${S}/${PROJECT5_PATH}/${PROJECT5_NAME}.csproj" || die
	sed -i "s#^.*-- ProjectReference --.*\$#&\\n<ProjectReference Include=\"../../${PROJECT4_PATH}/${PROJECT4_NAME}.csproj\" />#" "${S}/${PROJECT5_PATH}/${PROJECT5_NAME}.csproj" || die
	eapply_user
}

src_compile() {
	emsbuild "/p:VersionNumber=1.0.2016.606" "${S}/${PROJECT5_PATH}/${PROJECT5_NAME}.csproj"
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
