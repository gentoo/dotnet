# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit git-2 elisp-common autotools dotnet eutils

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
	monodevelop? ( dev-util/monodevelop )
	emacs? ( >=virtual/emacs-${NEED_EMACS:-21} app-emacs/s app-emacs/dash app-emacs/auto-complete )"
RDEPEND="${DEPEND}"

pkg_setup() {
	dotnet_pkg_setup
	if use emacs; then
		elisp-need-emacs "${NEED_EMACS:-21}"
		case $? in
			0) ;;
			1) die "Emacs version too low" ;;
			*) die "Could not determine Emacs version" ;;
		esac
	fi
}

src_unpack() {
	git-2_src_unpack
	if use emacs; then
		cd "${S}/emacs"
		if [[ -f ${P}.el ]]; then
			# the "simple elisp" case with a single *.el file in WORKDIR
			mv ${P}.el ${PN}.el || die
			[[ -d ${S} ]] || S=${WORKDIR}
		fi
	fi
}

src_prepare() {
	if use monodevelop; then
		epatch "${FILESDIR}/Makefile.patch"
	fi
}

src_configure() {
	if use monodevelop; then
		cd "${S}/monodevelop"
		addpredict "/etc/mono/registry"
		./configure.sh || die "configure failed"
	fi
}
src_compile() {
	if use monodevelop; then
	   cd "${S}/monodevelop"
	   emake
	fi
	if use emacs; then
		cd "${S}/emacs"
		elisp-compile *.el
		if [[ -n ${ELISP_TEXINFO} ]]; then
			makeinfo ${ELISP_TEXINFO} || die
		fi
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
		cd "${S}/emacs"
		elisp-install ${PN} *.el *.elc
		if [[ -n ${SITEFILE} ]]; then
			elisp-site-file-install "${FILESDIR}/${SITEFILE}"
		fi
		if [[ -n ${ELISP_TEXINFO} ]]; then
			set -- ${ELISP_TEXINFO}
			set -- ${@##*/}
			doinfo ${@/%.*/.info*}
		fi
		#AutoComplete:
		xbuild "${S}/FSharp.AutoComplete/FSharp.AutoComplete.fsproj" /property:OutputPath="${D}/usr/share/emacs/site-lisp/${PN}/bin/"
	fi

	# They try to install in the user directory
	#if use monodevelop; then
	#   cd "${S}/monodevelop"
	#   emake install
	#fi
}

pkg_postinst() {
	if use emacs; then
		elisp-site-regen
		if declare -f readme.gentoo_print_elog >/dev/null; then
			readme.gentoo_print_elog
		fi
		ewarn "To install fsharpbindings in emacs add the following lines to your init.el and read https://github.com/fsharp/fsharpbinding/tree/master/emacs"
		ewarn "(autoload 'fsharp-mode \"fsharp-mode\"     \"Major mode for editing F# code.\" t)"
		ewarn "(add-to-list 'auto-mode-alist '(\"\\.fs[iylx]?$\" . fsharp-mode))"
	fi
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
