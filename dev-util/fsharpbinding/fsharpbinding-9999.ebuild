# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

USE_DOTNET="net40"

inherit git-2 autotools mono

EGIT_REPO_URI="git://github.com/fsharp/fsharpbinding.git"

DESCRIPTION="The F# Compiler"
HOMEPAGE="https://github.com/fsharp/fsharpbinding"
SRC_URI=""

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE="-emacs +monodevelop"

MAKEOPTS="-j1" #nowarn
DEPEND="dev-lang/fsharp
	dev-util/monodevelop
	"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/Makefile.patch"
}

src_configure() {
	if use monodevelop; then
	   cd "${S}/monodevelop"
	   ./configure.sh
	fi	
}
src_compile() {
	if use monodevelop; then
	   cd "${S}/monodevelop"
	   emake
	fi
}
src_install() {
	if use monodevelop; then
	   dodir /usr/lib/monodevelop/Packs
	   insinto /usr/lib/monodevelop/Packs
	   PACKVERSION=`cat monodevelop/Makefile.orig | head -n 7 | tail -n 1 | grep -o "[0-9]\+.[0-9]\+.[0-9]\+\(.[0-9]\+\)\?"`
	   elog "Using Packversion: ${PACKVERSION}"
	   newins "monodevelop/pack/${PACKVERSION}/local/Debug/MonoDevelop.FSharpBinding_${PACKVERSION}.mpack" "Monodevelop.FSharpBinding_${PVR}.mpack"

	fi
	if use emacs; then
	   eerror "emacs is currently not supported in this ebuild :/"
	fi
 
	# They try to install in the user directory
	#if use monodevelop; then
	#   cd "${S}/monodevelop"
	#   emake install
	#fi
	#if use emacs; then
	#   cd "${S}/emacs"
	#   emake install
	#fi
}

pkg_postinst() {
	#if use emacs; then
	#   ewarn "To install fsharpbindings in emacs add the following lines to your init.el and read https://github.com/fsharp/fsharpbinding/tree/master/emacs"	
	#   ewarn "(add-to-list 'load-path \"~/.emacs.d/fsharp-mode/\")"
	#   ewarn "(autoload 'fsharp-mode \"fsharp-mode\"     \"Major mode for editing F# code.\" t)"
	#   ewarn "(add-to-list 'auto-mode-alist '(\"\\.fs[iylx]?$\" . fsharp-mode))"
	#fi
	if use monodevelop; then
	   ewarn "To install fsharpbinding to monodevelop for your current user execute"
	   ewarn "mdtool setup install -y /usr/lib/monodevelop/Packs/Monodevelop.FSharpBinding_${PVR}.mpack"
	   ewarn "Please make sure to manually deinstall all old fsharpbinding versions before using the above command"
	   ewarn "If you still have problems use:"
	   ewarn "rm -r ~/.config/MonoDevelop/addins"
	   ewarn "rm -r ~/.local/share/MonoDevelop-3.0/LocalInstall/Addins"
	   ewarn "rm -r ~/.local/share/MonoDevelop-4.0/LocalInstall/Addins"
	   ewarn "Note that this will remove all Addins of the current user."
	   
	fi
}
