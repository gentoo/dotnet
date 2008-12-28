# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit mono multilib nsplugins

MY_P=moon-${PV/_beta/b}
DESCRIPTION="This is a sample skeleton ebuild file"
HOMEPAGE="http://foo.bar.com/"
SRC_URI="ftp://ftp.novell.com/pub/mono/sources/moon/${MY_P}.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE="alsa pulseaudio debug"
RDEPEND="
	>=dev-lang/mono-2.2_rc1[moonlight]
	>=x11-libs/cairo-1.8.0
	>=media-video/ffmpeg-0.4.9_p20081014
	>=net-libs/xulrunner-1.9.0.2:1.9
	>=dev-dotnet/rsvg-sharp-2.24.0
	>=dev-dotnet/gtk-sharp-2.12.7
	x11-libs/libXrandr
	>=x11-libs/gtk+-2.14.0
	alsa? ( >=media-libs/alsa-lib-1.0.18 )
	pulseaudio? ( media-sound/pulseaudio )
	>=media-libs/freetype-2.3.7
	>=media-gfx/imagemagick-6.2.8
	>=media-libs/fontconfig-2.6.0
	>=dev-libs/dbus-glib-0.60
	>=dev-dotnet/dbus-sharp-0.6.1a
	"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.23"
S="${WORKDIR}/${MY_P}"

src_configure() {
	econf	--enable-shared \
		--disable-static \
	 	--with-cairo=system \
		--with-ffmpeg=yes \
		--with-ff3=yes \
		--without-ff2 \
		--with-managed=yes \
		--enable-user-plugin \
		$(use_with alsa) \
		$(use_with pulseaudio) \
		$(use_with debug) \
		--disable-user-plugin \
		|| die "econf failed"
}

src_install() {
	local LTDL_SO LTDL_SOLIST=( "libavutil.so" "libswscale.so" "libavcodec.so" "libmono.so" )
	emake DESTDIR="${D}" install || die "emake install failed"
	if [[ -e "${D}/usr/$(get_libdir)/moon/plugin/libmoonloader.so" ]]
	then
		dodir /usr/$(get_libdir)/moon/plugin/moonlight
		dosym "../libmoonplugin-ff3bridge.so" "/usr/$(get_libdir)/moon/plugin/moonlight/libmoonplugin-ff3bridge.so" \
			|| die "dosym libmoonplugin-ff3bridge failed"
		dosym "../libmoonplugin.so" "/usr/$(get_libdir)/moon/plugin/moonlight/libmoonplugin.so" \
			|| die "dosym libmoonplugin failed"
		dosym "/usr/$(get_libdir)/libmoon.so" "/usr/$(get_libdir)/moon/plugin/moonlight/libmoon.so" \
			|| die "dosym libmoon failed"
		for LTDL_SO in "${LTDL_SOLIST[@]}"
		do
			if [[ -e "/usr/$(get_libdir)/${LTDL_SO}" ]]
			then
				dosym "/usr/$(get_libdir)/${LTDL_SO}" "/usr/$(get_libdir)/moon/plugin/moonlight/${LTDL_SO}" \
					|| die "dosym ${LTDL_SO} failed"
			else
				die "${LTDL_SO} does not exist"
			fi
		done

		inst_plugin /usr/$(get_libdir)/moon/plugin/libmoonloader.so || die "installing libmoonloader failed"
	else
		die "/usr/$(get_libdir)/moon/plugin/libmoonloader.so not built WTF!"
	fi
	find "${D}" -name '*.la' -exec rm -rf '{}' '+' || die "la removal failed"
}
