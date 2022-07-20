# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="1"

USE_DOTNET="net45"

inherit multilib dotbuildtask eutils

NAME="antlrcs"
HOMEPAGE="https://github.com/antlr/${NAME}"
EGIT_COMMIT="ca331b7109e1faa5a6aa7336bb6281ce9363e62b"
SRC_URI="https://github.com/ArsenShnurkov/shnurise-tarballs/raw/dev-utils/${PN}-${SLOT}/${PN}-${PV}.tar.gz -> ${NAME}-${PV}.tar.gz"
S="${WORKDIR}"

DESCRIPTION="The C# port of ANTLR 3"
LICENSE="BSD" # https://github.com/antlr/antlrcs/blob/master/LICENSE.txt

IUSE="+${USE_DOTNET} debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	>=dev-dotnet/antlr3-runtime-${PV}
"

OUTPUT_PATH="${PN}-${SLOT}"
ASSEMBLY_VERSION="3.5.1.26"

src_prepare() {
	sed "s#\$(AntlrBuildTaskPath)#/usr/$(get_libdir)/mono/${EBUILD_FRAMEWORK}/${PN}-${SLOT}#;s#\$(AntlrToolPath)#/usr/share/${PN}-${SLOT}/Antlr3.exe#" "${FILESDIR}/Antlr3.props" >"${S}/AntlrBuildTask/Antlr3.props" || die
	local ATEXT="[assembly:System.Reflection.AssemblyVersion(\"${ASSEMBLY_VERSION}\")]"
	echo "${ATEXT}" >"${S}/AntlrBuildTask/AV.cs" || die
	echo "${ATEXT}" >"${S}/Runtime/Antlr3.Runtime/AV.cs" || die
	echo "${ATEXT}" >"${S}/Runtime/Antlr3.Runtime.Debug/AV.cs" || die
	echo "${ATEXT}" >"${S}/Antlr4.StringTemplate/AV.cs" || die
	echo "${ATEXT}" >"${S}/Antlr3/AV.cs" || die
	echo "${ATEXT}" >"${S}/Antlr3.Targets/Antlr3.Targets.CSharp3/AV.cs" || die
	eapply_user
}

src_compile() {
	GAC_PATH=/usr/$(get_libdir)/mono/gac

	mkdir -p "${OUTPUT_PATH}" || die
	mkdir -p "${S}/${OUTPUT_PATH}/Targets" || die

	FW_PATH="/usr/lib64/mono/4.6-api"

	COMMON_KEYS="/utf8output /subsystemversion:6.00 /noconfig /nowarn:1701,1702 /nostdlib+  /highentropyva+ /reference:${FW_PATH}/mscorlib.dll /reference:${FW_PATH}/System.dll /recurse:*.cs"
	if use debug; then
	COMMON_KEYS="${COMMON_KEYS} /define:DEBUG /debug+ /debug:full /optimize-"
	fi

	cd "${S}/AntlrBuildTask" || die
	mono /usr/lib/mono/4.5/csc.exe /target:library "/out:${S}/${OUTPUT_PATH}/AntlrBuildTask.dll" /reference:${FW_PATH}/System.Core.dll /reference:${GAC_PATH}/Microsoft.Build.Framework/15.3.0.0__0738eb9f132ed756/Microsoft.Build.Framework.dll /reference:${GAC_PATH}/Microsoft.Build.Utilities.Core/15.3.0.0__0738eb9f132ed756/Microsoft.Build.Utilities.Core.dll ${COMMON_KEYS} || die

	cd "${S}/Runtime/Antlr3.Runtime" || die
	mono /usr/lib/mono/4.5/csc.exe /target:library "/out:${S}/${OUTPUT_PATH}/Antlr.Runtime.dll" /reference:${FW_PATH}/System.Core.dll ${COMMON_KEYS} || die

	cd "${S}/Runtime/Antlr3.Runtime.Debug" || die
	mono /usr/lib/mono/4.5/csc.exe /target:library "/out:${S}/${OUTPUT_PATH}/Antlr.Runtime.Debug.dll" "/reference:${FW_PATH}/System.Core.dll" "/reference:${S}/${OUTPUT_PATH}/Antlr.Runtime.dll" ${COMMON_KEYS} || die

	cd "${S}/Antlr4.StringTemplate" || die
	mono /usr/lib/mono/4.5/csc.exe /target:library "/out:${S}/${OUTPUT_PATH}/Antlr4.StringTemplate.dll" "/reference:${FW_PATH}/System.Core.dll" "/reference:${S}/${OUTPUT_PATH}/Antlr.Runtime.dll" ${COMMON_KEYS} || die

	cd "${S}/Antlr3" || die
	mono /usr/lib/mono/4.5/csc.exe /target:exe "/out:${S}/${OUTPUT_PATH}/Antlr3.exe" /define:NETSTANDARD "/reference:${FW_PATH}/System.Core.dll" "/reference:${FW_PATH}/System.Xml.Linq.dll" "/reference:${S}/${OUTPUT_PATH}/Antlr.Runtime.dll" "/reference:${S}/${OUTPUT_PATH}/Antlr.Runtime.Debug.dll" "/reference:${S}/${OUTPUT_PATH}/Antlr4.StringTemplate.dll" ${COMMON_KEYS} || die

	cd "${S}/Antlr3.Targets/Antlr3.Targets.CSharp3" || die
	mono /usr/lib/mono/4.5/csc.exe /target:library "/out:${S}/${OUTPUT_PATH}/Targets/Antlr3.Targets.CSharp3.dll" /define:NETSTANDARD "/reference:${FW_PATH}/System.Core.dll" "/reference:${S}/${OUTPUT_PATH}/Antlr3.exe" "/reference:${S}/${OUTPUT_PATH}/Antlr4.StringTemplate.dll" ${COMMON_KEYS} || die

	cd "${S}" || die
}

src_install() {
	insinto "usr/share"
	doins -r "${S}/${OUTPUT_PATH}"

	insinto "usr/share/${OUTPUT_PATH}"
	doins -r "${S}/Reference/antlr3/tool/src/main/resources/org/antlr/Tool"
	doins -r "${S}/Reference/antlr3/tool/src/main/resources/org/antlr/Codegen"

	local TASKS_PROPS_FILE="${S}/AntlrBuildTask/Antlr3.props"
	local TASKS_TARGETS_FILE="${S}/AntlrBuildTask/Antlr3.targets"
	einstask "${OUTPUT_PATH}/AntlrBuildTask.dll" "${TASKS_PROPS_FILE}" "${TASKS_TARGETS_FILE}"

	if use debug; then
		make_wrapper antlrcs "/usr/bin/mono --debug \${MONO_OPTIONS} /usr/share/${PN}-${SLOT}/Antlr3.exe"
	else
		make_wrapper antlrcs "/usr/bin/mono \${MONO_OPTIONS} /usr/share/${PN}-${SLOT}/Antlr3.exe"
	fi
}
