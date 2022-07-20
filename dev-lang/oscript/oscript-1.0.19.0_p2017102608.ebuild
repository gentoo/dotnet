# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"

inherit multilib eutils msbuild

#if [ "${CATEGORY}" == "" ]; then
#	CATEGORY="dev-lang"
#fi
if [ "${SLOT}" != "0" ]; then
	APPENDIX="-${SLOT}"
fi

HOMEPAGE="https://oscript.io"
SRC_URI="https://github.com/ArsenShnurkov/shnurise-tarballs/raw/${CATEGORY}/${PN}${APPENDIX}/${PN}-${PV}.tar.gz"

DESCRIPTION="1C script language interpreter"
LICENSE="MPL-2.0"

IUSE="+${USE_DOTNET} debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
	dev-dotnet/newtonsoft-json
	dev-dotnet/dotnetzip-semverd
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	eapply_user
}

src_compile() {
	emsbuild "src/1Script_Mono.sln"
}

src_install() {
	insinto "/usr/share/${PN}${APPENDIX}"
	doins "${S}/src/oscript/bin/x86/Release/oscript.exe"
	doins "${S}/src/oscript/bin/x86/Release/oscript.cfg"
	doins "${S}/src/oscript/bin/x86/Release/OneScript.DebugProtocol.dll"
	doins "${S}/src/oscript/bin/x86/Release/ScriptEngine.dll"
	doins "${S}/src/oscript/bin/x86/Release/ScriptEngine.HostedScript.dll"
	if use developer ; then
		doins "${S}/src/oscript/bin/x86/Release/oscript.pdb"
		doins "${S}/src/oscript/bin/x86/Release/OneScript.DebugProtocol.pdb"
		doins "${S}/src/oscript/bin/x86/Release/ScriptEngine.pdb"
		doins "${S}/src/oscript/bin/x86/Release/ScriptEngine.HostedScript.pdb"
	fi

	if use debug; then
		make_wrapper oscript "/usr/bin/mono --debug \${MONO_OPTIONS} /usr/share/${PN}${APPENDIX}/oscript.exe"
	else
		make_wrapper oscript "/usr/bin/mono \${MONO_OPTIONS} /usr/share/${PN}${APPENDIX}/oscript.exe"
	fi
}
