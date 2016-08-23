# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit dotnet

NAME="slntools"
HOMEPAGE="https://github.com/ArsenShnurkov/${NAME}"

EGIT_COMMIT="705869e96a2f0e401be03f8e8478df3e1f2b9373"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${PF}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT=0

DESCRIPTION="Validator.nu HTML Parser, a HTML5 parser, port from Java Version 1.4 to C#"
LICENSE="MIT" # https://github.com/jamietre/HtmlParserSharp/blob/master/LICENSE.txt
KEYWORDS="~amd64 ~x86"
IUSE="developer nupkg debug"

RDEPEND=">=dev-lang/mono-4.0.2.5"
DEPEND="${RDEPEND}
	sys-apps/sed"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
SLN_FILE=SLNTools.sln
METAFILETOBUILD="${S}/Main/${SLN_FILE}"

src_unpack()
{
	# /usr/portage/distfiles/csquery-1.3.5.200.zip
	# /var/tmp/portage/dev-dotnet/csquery-1.3.5.200-r20150522/work/CsQuery-696ac0533a3e665a34cdc4050d1f46e91f5a3356
	default
}

src_prepare() {

	default

	epatch "${FILESDIR}/remove-wix-project-from-sln-file.patch"

	# System.EntryPointNotFoundException: GetStdHandle
	#   at (wrapper managed-to-native) CWDev.SLNTools.CommandLine.Parser:GetStdHandle (int)
	#   at CWDev.SLNTools.CommandLine.Parser.GetConsoleWindowWidth () [0x00000] in <filename unknown>:0 
	#   at CWDev.SLNTools.CommandLine.Parser.ArgumentsUsage (System.Type argumentType) [0x00000] in <filename unknown>:0 
	#   at CWDev.SLNTools.Program.Main (System.String[] args) [0x00000] in <filename unknown>:0 
	# http://stackoverflow.com/questions/23824961/c-sharp-to-mono-getconsolewindow-exception
	epatch "${FILESDIR}/console-window-width.patch"

	nuget restore "${METAFILETOBUILD}" || die
}

src_compile() {
	ARGS=""
	ARGSN=""

	if use debug; then
		ARGS="${ARGS} /p:Configuration=Debug"
		ARGSN="${ARGSN} Configuration=Debug"
	else
		ARGS="${ARGS} /p:Configuration=Release"
		ARGSN="${ARGSN} Configuration=Release"
	fi

	if use developer; then
		ARGS="${ARGS} /p:DebugSymbols=True"
	else
		ARGS="${ARGS} /p:DebugSymbols=False"
	fi

	exbuild ${ARGS} ${METAFILETOBUILD}

	if use nupkg; then
		nuget pack "${FILESDIR}/${SLN_FILE}.nuspec" -Properties ${ARGSN} -BasePath "${S}" -OutputDirectory "${WORKDIR}" -NonInteractive -Verbosity detailed
	fi
}

src_install() {
	default

	DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	# insinto "/usr/$(get_libdir)"	
	insinto "/usr/share/slntools/"

	# || die is not necessary after doins,
	# see examples at https://devmanual.gentoo.org/ebuild-writing/functions/src_install/index.html
	doins Main/SLNTools.exe/bin/${DIR}/CWDev.SLNTools.Core.dll
	doins Main/SLNTools.exe/bin/${DIR}/CWDev.SLNTools.Core.dll.mdb
	doins Main/SLNTools.exe/bin/${DIR}/CWDev.SLNTools.UIKit.dll
	doins Main/SLNTools.exe/bin/${DIR}/CWDev.SLNTools.UIKit.dll.mdb
	doins Main/SLNTools.exe/bin/${DIR}/SLNTools.exe
	doins Main/SLNTools.exe/bin/${DIR}/SLNTools.exe.mdb

	make_wrapper slntools "mono /usr/share/slntools/SLNTools.exe"

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
		doins "${WORKDIR}/SLNTools.1.1.3.nupkg"
	fi
}

# Usage:
# SLNTools.exe 
# @<file>    Read response file for more options
# <Command>  Command Name (CompareSolutions|MergeSolutions|CreateFilterFileFromSolution|EditFilterFile|OpenFilterFile|SortProjects)
