# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/gtk-sharp-module.eclass,v 1.7 2008/12/03 20:44:04 loki_val Exp $

# Author : Peter Johanson <latexer@gentoo.org>, butchered by ikelos, then loki_val.
# Based off of original work in gst-plugins.eclass by <foser@gentoo.org>

# Note that this breaks compatibility with the original gtk-sharp-component
# eclass.

inherit eutils mono multilib autotools base versionator

# Get the name of the component to build and the build dir; by default,
# extract it from the ebuild's name.
GTK_SHARP_MODULE=${GTK_SHARP_MODULE:=${PN/-sharp/}}
GTK_SHARP_MODULE_DIR=${GTK_SHARP_MODULE_DIR:=${PN/-sharp/}}

# Allow ebuilds to set a value for the required GtkSharp version.
GTK_SHARP_REQUIRED_VERSION=${GTK_SHARP_REQUIRED_VERSION}

# Version number used to differentiate between unversioned 1.0 series and the
# versioned 2.0 series (2.0 series has 2 or 2.0 appended to various paths and
# scripts). Default to ${SLOT}.
GTK_SHARP_SLOT="${GTK_SHARP_SLOT:=${SLOT}}"
GTK_SHARP_SLOT_DEC="${GTK_SHARP_SLOT_DEC:=-${GTK_SHARP_SLOT}.0}"

#Handy little var
PV_MAJOR=$(get_version_component_range 1-2)

# Set some defaults.
DESCRIPTION="GtkSharp's ${GTK_SHARP_MODULE} module"
HOMEPAGE="http://www.mono-project.com/GtkSharp"

LICENSE="LGPL-2.1"
DEPEND="
	>=dev-lang/mono-2.0.1
	>=sys-apps/sed-4
	>=dev-util/pkgconfig-0.23
	"
RDEPEND="
	>=dev-lang/mono-2.0.1
	"

IUSE="debug"


# The GtkSharp modules are currently divided into three seperate tarball
# distributions. Figure out which of these our component belongs to.

gtk_sharp_module_list="glib glade gtk gdk atk pango gtk-dotnet gtk-gapi"
gnome_sharp_module_list="art gnome gnomevfs gconf"
gnome_desktop_sharp_module_list="gnome-desktop gnome-print gnome-panel gtkhtml gtksourceview nautilusburn rsvg vte wnck"

has "${GTK_SHARP_MODULE}" ${gtk_sharp_module_list} && GTK_SHARP_REQUIRED_VERSION=${PV}


add_bdepend() {
	DEPEND="${DEPEND} $@"
}

add_rdepend() {
	RDEPEND="${RDEPEND} $@"
}

add_depend() {
	DEPEND="${DEPEND} $@"
	RDEPEND="${RDEPEND} $@"
}

gsm_get_tarball() {
	has "${GTK_SHARP_MODULE}" ${gtk_sharp_module_list} \
		&& echo "gtk-sharp" && return 0
	has "${GTK_SHARP_MODULE}" ${gnome_sharp_module_list} \
		&& echo "gnome-sharp" && return 0
	has "${GTK_SHARP_MODULE}" ${gnome_desktop_sharp_module_list} \
		&& echo "gnome-desktop-sharp" && return 0
	die "unknown GtkSharp module: ${GTK_SHARP_MODULE}"
}

[[ "${PN}" != "gtk-sharp-gapi" ]] && add_bdepend "=dev-dotnet/gtk-sharp-gapi-${GTK_SHARP_REQUIRED_VERSION}*"
has "${GTK_SHARP_MODULE}" ${gnome_sharp_module_list} ${gnome_desktop_sharp_module_list} gtk-dotnet glade \
	&& add_depend "=dev-dotnet/gtk-sharp-${GTK_SHARP_REQUIRED_VERSION}*"
has "${GTK_SHARP_MODULE}" gtk gdk atk pango gtk-dotnet parser \
	&& add_depend "=dev-dotnet/glib-sharp-${GTK_SHARP_REQUIRED_VERSION}*"
has "${GTK_SHARP_MODULE}" ${gnome_desktop_sharp_module_list} \
	&& add_depend ">=dev-dotnet/gnome-sharp-${PV_MAJOR}"

case ${PF} in
	#gtk-sharp tarball
	gtk-sharp-gapi*)
		add_depend "dev-perl/XML-LibXML"
		;;
	gtk-sharp-*)
		add_depend "~dev-dotnet/atk-sharp-${PV}"
		add_depend "~dev-dotnet/gdk-sharp-${PV}"
		add_depend "~dev-dotnet/pango-sharp-${PV}"
		;;
	gdk-sharp-*)
		add_rdepend "!<=dev-dotnet/gtk-sharp-2.12.7:2"
		add_depend "x11-libs/gtk+:2"
		add_depend "~dev-dotnet/pango-sharp-${PV}"
		;;
	atk-sharp-*)
		add_rdepend "!<=dev-dotnet/gtk-sharp-2.12.7:2"
		add_depend "dev-libs/atk"
		;;
	glib-sharp-*)
		add_rdepend "!<=dev-dotnet/gtk-sharp-2.12.7:2"
		add_depend "dev-libs/glib:2"
		;;
	pango-sharp-*)
		add_rdepend "!<=dev-dotnet/gtk-sharp-2.12.7:2"
		add_depend "x11-libs/pango"
		;;
	gtk-dotnet-*)
		add_rdepend "!<=dev-dotnet/gtk-sharp-2.12.7:2"
		add_depend "~dev-dotnet/gdk-sharp-${PV}"
		add_depend "~dev-dotnet/pango-sharp-${PV}"
		add_depend "!dev-lang/mono[minimal]"
		;;
	glade-sharp-*)
		add_depend "~dev-dotnet/atk-sharp-${PV}"
		add_depend "~dev-dotnet/gdk-sharp-${PV}"
		add_depend "~dev-dotnet/pango-sharp-${PV}"
		add_depend ">=gnome-base/libglade-2.3.6"
		;;
	#gnome-sharp tarball
	art-sharp-*)
		add_depend ">=media-libs/libart_lgpl-2.3.20"
		;;
	gnome-sharp-*)
		add_depend ">=gnome-base/libgnomeui-${PV_MAJOR}"
		add_depend ">=gnome-base/gnome-panel-${PV_MAJOR}"
		add_depend "~dev-dotnet/gnomevfs-sharp-${PV}"
		add_depend "~dev-dotnet/art-sharp-${PV}"
		add_depend ">=gnome-base/libgnomecanvas-${GNOMECANVAS_REQUIRED_VERSION}"
		;;
	gconf-sharp-*)
		add_depend ">=gnome-base/gconf-${PV_MAJOR}"
		add_depend ">=dev-dotnet/glade-sharp-${GTK_SHARP_REQUIRED_VERSION}"
		add_depend "~dev-dotnet/gnome-sharp-${PV}"
		add_depend "~dev-dotnet/art-sharp-${PV}"
		;;
	gnomevfs-sharp-*)
		add_depend ">=gnome-base/gnome-vfs-${PV_MAJOR}"
		;;
	#gnome-desktop-sharp tarball
	gnome-desktop-sharp-*)
		add_depend "=gnome-base/gnome-desktop-${PV_MAJOR}*"
		;;
	gnome-panel-sharp-*)
		add_depend "=gnome-base/gnome-panel-${PV_MAJOR}*"
		;;
	gnome-print-sharp-*)
		add_depend ">=gnome-base/libgnomeprint-${API_VERSION}"
		;;
	gtkhtml-sharp-*)
		#NOTE: gtkhtml dependency must follow gtkhtml-sharp version.
		#i.e.   gtkhtml-sharp-2.24.0 >=gtkhtml-3.24
		#       gtkhtml-sharp-2.16.0 >=gtkhtml-3.16
		#       See bug 249540 for unpleasant side effects.
		add_depend ">=gnome-extra/gtkhtml-$(($(get_version_component_range 1) + 1 )).$(get_version_component_range 2)"
		;;
	gtksourceview-sharp-*)
		add_depend ">=x11-libs/gtksourceview-${GTKSOURCEVIEW_REQUIRED_VERSION}:2.0"
		;;
	nautilusburn-sharp-*)
		add_depend ">=gnome-extra/nautilus-cd-burner-${PV_MAJOR}"
		;;
	rsvg-sharp-*)
		add_depend ">=gnome-base/librsvg-${RSVG_REQUIRED_VERSION}"
		;;
	vte-sharp-*)
		add_depend ">=x11-libs/vte-${VTE_REQUIRED_VERSION}"
		;;
	wnck-sharp-*)
		add_depend ">=x11-libs/libwnck-${PV_MAJOR}"
		;;
esac



GSM_P=$(gsm_get_tarball)-${PV}
S=${WORKDIR}/${GSM_P}
SRC_URI="mirror://gnome/sources/$(gsm_get_tarball)/${PV%.*}/${GSM_P}.tar.bz2"

if [[ "${GSM_P%.*}" = "gtk-sharp-2.12" ]]
then
	SRC_URI="${SRC_URI}
		mirror://gentoo/gtk-sharp-2.12.0-patches.tar.bz2"
	#Upstream: https://bugzilla.novell.com/show_bug.cgi?id=$bugno
	#Upstream bug #421063
	PATCHES=( "${WORKDIR}/patches/$(gsm_get_tarball)-2.12.0-parallelmake.patch"
	        "${WORKDIR}/patches/$(gsm_get_tarball)-2.12.0-doc-parallelmake.patch" )
	EAUTORECONF="YES"
fi


### Public functions.

gtk-sharp-module_fix_files() {
	# Change references like "/r:../art/art-sharp.dll" ->
	# "/r:/usr/lib/pkgconfig/../../lib/mono/gtk-sharp-2.0/art-sharp.dll" and references like
	# "../glib/glib-sharp.xml" or "$(top_srcdir)/glib/glib-sharp.xml" ->
	# "${gapi_dir}/glib-sharp.xml".
	#
	# We also make sure to call the installed gapi-fixup and gapi-codegen and
	# not the ones that would be built locally.
	local gapi_dir="${ROOT}/usr/share/gapi${GTK_SHARP_SLOT_DEC}"
	local GAPI_FIXUP="gapi${GTK_SHARP_COMPONENT_SLOT}-fixup"
	local GAPI_CODEGEN="gapi${GTK_SHARP_COMPONENT_SLOT}-codegen"

	local makefiles=( $(find "${S}" -name Makefile.in) )
	sed -i \
		-e "s;\(\.\.\|\$(top_srcdir)\|\$(srcdir)/\.\.\)/[[:alpha:]]*/\([[:alpha:]]*\(-[[:alpha:]]*\)*\).xml;${gapi_dir}/\2.xml;g" \
		-e "s; \.\./glib/glib-sharp.dll; $(get_sharp_lib glib-sharp-2.0);g" \
		-e "s; \.\./pango/pango-sharp.dll; $(get_sharp_lib pango-sharp-2.0);g" \
		-e "s; \.\./art/art-sharp.dll; $(get_sharp_lib art-sharp-2.0);g" \
		-e "s; \.\./atk/atk-sharp.dll; $(get_sharp_lib atk-sharp-2.0);g" \
		-e "s; \.\./gdk/gdk-sharp.dll; $(get_sharp_lib gdk-sharp-2.0);g" \
		-e "s; \.\./gtk/gtk-sharp.dll; $(get_sharp_lib gtk-sharp-2.0);g" \
		-e "s;\.\./gnomevfs/gnome-vfs-sharp.dll;$(get_sharp_lib gnome-vfs-sharp-2.0);g" \
		-e "s;\$(top_builddir)/art/art-sharp.dll;$(get_sharp_lib art-sharp-2.0);" \
		-e "s;\$(top_builddir)/gnome/gnome-sharp.dll;$(get_sharp_lib gnome-sharp-2.0);" \
		-e "s;\$(RUNTIME) \$(top_builddir)/parser/gapi-fixup.exe;${GAPI_FIXUP};" \
		-e "s;\$(RUNTIME) \$(top_builddir)/generator/gapi_codegen.exe;${GAPI_CODEGEN};" \
		-e "s:\$(SYMBOLS) \$(top_builddir)/parser/gapi-fixup.exe:\$(SYMBOLS):" \
		-e "s:\$(INCLUDE_API) \$(top_builddir)/generator/gapi_codegen.exe:\$(INCLUDE_API):" \
		"${makefiles[@]}" || die "failed to fix GtkSharp makefiles"
}

get_sharp_lib() {
	S="$(pkg-config --libs ${1})"
	S=${S%% *}
	printf ${S#-r:}
}

gtk-sharp_tarball_src_prepare() {
	local package
	sed -i	-e '/SUBDIRS/s/ glib / /'	\
		-e '/SUBDIRS/s/ glade / /'	\
		-e '/SUBDIRS/s/ sample / /'	\
		-e '/SUBDIRS/s/ doc/ /'		\
		Makefile.am || die "failed sedding sense into gtk-sharp's Makefile.am"
	for package in GLIB PANGO ATK GTK
	do
		sed -r -i -e "s:(PKG_CHECK_MODULES\(${package}.*)\):\1,[foo=bar],[bar=foo]):" \
			configure.in || die "failed  sedding sense into gnome-sharp's configure.in"
	done
	EAUTORECONF=YES
}

gnome-sharp_tarball_src_prepare() {
	if ! [[ "${PN}" = "gconf-sharp" ]]
	then
		sed -r -i -e "s:(PKG_CHECK_MODULES\(GLADESHARP.*)\):\1,[foo=bar],[bar=foo]):" \
			configure.in || die "failed  sedding sense into gnome-sharp's configure.in"
		EAUTORECONF=YES
	fi
}

gtk-sharp-module_src_prepare() {
	if [[ "$(type -t $(gsm_get_tarball)_tarball_src_prepare)" = "function" ]]
	then
		ebegin "Running $(gsm_get_tarball)_tarball_src_prepare"
		$(gsm_get_tarball)_tarball_src_prepare
		eend $?
	fi
	base_src_util autopatch

	[[ ${EAUTORECONF} ]] && eautoreconf

	cd "${S}/${GTK_SHARP_MODULE_DIR}"

	gtk-sharp-module_fix_files &> /dev/null
}

gtk-sharp-module_src_configure() {
	econf	--disable-static \
		--disable-dependency-tracking \
		--disable-maintainer-mode \
		$(use debug &&echo "--enable-debug" ) \
		${gtk_sharp_conf} \
		${@} || die "econf failed"
}

gtk-sharp-module_src_compile() {
	cd "${S}/${GTK_SHARP_MODULE_DIR}"
	emake || die "emake failed"
}

gtk-sharp-module_src_install() {

	cd "${GTK_SHARP_MODULE_DIR}"
	emake DESTDIR=${D} install || die "emake install failed"
	mono_multilib_comply
	find "${D}" -name '*.la' -exec rm -rf '{}' '+' || die "la removal failed"
	if has "${GTK_SHARP_MODULE}" gtk gdk atk pango
	then
		find "${D}" -name '*.pc' -exec rm -rf '{}' '+' || die "la removal failed"
				pkgconfig_filename="${PN}${GTK_SHARP_SLOT_DEC}"
				pkgconfig_pkgname="${GTK_SHARP_MODULE}#"
				pkgconfig_description=".NET/Mono bindings for ${GTK_SHARP_MODULE}"
				pkgconfig_monodir="$(gsm_get_tarball)${GTK_SHARP_SLOT_DEC}"
		case ${GTK_SHARP_MODULE} in
			gtk)
				pkgconfig_requires="glib-sharp${GTK_SHARP_SLOT_DEC} atk-sharp${GTK_SHARP_SLOT_DEC} gdk-sharp${GTK_SHARP_SLOT_DEC} pango-sharp${GTK_SHARP_SLOT_DEC}"
				;;
			gdk)
				pkgconfig_requires="glib-sharp${GTK_SHARP_SLOT_DEC} pango-sharp${GTK_SHARP_SLOT_DEC}"
				;;
			atk)
				pkgconfig_requires="glib-sharp${GTK_SHARP_SLOT_DEC}"
				;;
			pango)
				pkgconfig_requires="glib-sharp${GTK_SHARP_SLOT_DEC}"
				;;
			*)
				die "unhandled gtk_sharp_module"
				;;
		esac
		generate_pkgconfig
	fi
}

EXPORT_FUNCTIONS src_prepare src_configure src_compile src_install

generate_pkgconfig() {
	ebegin "Generating .pc file for ${P}"
	local	dll \
		gfile \
		pkgconfig_gapidir \
		apifile \
		LSTRING='Libs:' \
		CSTRING='Cflags:' \
		pkgconfig_filename="${1:-${pkgconfig_filename:-${PN}}}" \
		pkgconfig_monodir="${2:-${pkgconfig_monodir:-${pkgconfig_filename}}}" \
		pkgconfig_pkgname="${3:-${pkgconfig_pkgname:-${pkgconfig_filename}}}" \
		pkgconfig_version="${4:-${pkgconfig_version:-${PV}}}" \
		pkgconfig_description="${5:-${pkgconfig_description:-${DESCRIPTION}}}" \
		pkgconfig_requires="${6:-${pkgconfig_requires}}" \

	pushd "${D}/usr/" &> /dev/null
	apifile=$(find share -name '*-api.xml' 2>/dev/null)
	popd &> /dev/null

	pkgconfig_gapidir=${apifile:+\$\{prefix\}/${apifile%/*}}

	dodir "/usr/$(get_libdir)/pkgconfig"
	cat <<- EOF -> "${D}/usr/$(get_libdir)/pkgconfig/${pkgconfig_filename}.pc"
		prefix=\${pcfiledir}/../..
		exec_prefix=\${prefix}
		libdir=\${prefix}/$(get_libdir)
		gapidir=${pkgconfig_gapidir}
		Name: ${pkgconfig_pkgname}
		Description: ${pkgconfig_description}
		Version: ${pkgconfig_version}
	EOF

        for gfile in "${D}"/usr/${apifile%/*}/*-api.xml
        do
                CSTRING="${CSTRING} -I:"'${gapidir}'"/${gfile##*/}"
        done
	echo "${CSTRING}" >> "${D}/usr/$(get_libdir)/pkgconfig/${pkgconfig_filename}.pc"


	for dll in "${D}"/usr/$(get_libdir)/mono/${pkgconfig_monodir}/*.dll
	do
		if ! [[ "${dll##*/}" == "policy."*".dll" ]]
		then
			LSTRING="${LSTRING} -r:"'${libdir}'"/mono/${pkgconfig_monodir}/${dll##*/}"
		fi
	done
	echo "${LSTRING}" >> "${D}/usr/$(get_libdir)/pkgconfig/${pkgconfig_filename}.pc"

	if [[ "${pkgconfig_requires}" ]]
	then
		printf "Requires: ${pkgconfig_requires}" >> "${D}/usr/$(get_libdir)/pkgconfig/${pkgconfig_filename}.pc"
	fi
	PKG_CONFIG_PATH="${D}/usr/$(get_libdir)/pkgconfig/" pkg-config --silence-errors --libs ${pkgconfig_filename} &> /dev/null
	eend $?
}

