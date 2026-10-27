# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake optfeature xdg

DESCRIPTION="Fast native Wayland screenshot and annotation overlay for Hyprland"
HOMEPAGE="https://github.com/omacom/omasnap"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/omacom/omasnap.git"
else
	SRC_URI="https://github.com/omacom/omasnap/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm64"
fi

# omasnap: MIT; bundled Neucha, JetBrains Mono, Inter fonts: OFL-1.1;
# Lucide pin icon geometry: ISC
LICENSE="MIT ISC OFL-1.1"
SLOT="0"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	app-arch/libdeflate
	>=dev-qt/qtbase-6.8:6[concurrent,gui,wayland,widgets]
	dev-libs/wayland
	kde-plasma/layer-shell-qt:6
"
RDEPEND="
	${DEPEND}
	gui-apps/wl-clipboard
	x11-misc/xdg-utils
"
DEPEND+="
	>=dev-libs/wayland-protocols-1.37
"
BDEPEND="
	dev-util/wayland-scanner
	virtual/pkgconfig
	test? ( app-text/tesseract )
"

src_prepare() {
	# protocol XMLs are referenced by absolute path
	sed -i -e "s|/usr/share/wayland-protocols|${ESYSROOT}/usr/share/wayland-protocols|" \
		CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTING=$(usex test)
	)

	cmake_src_configure
}

src_test() {
	# the smoke suite runs offscreen (set by CTest) with faked hyprctl
	cmake_src_test
}

src_install() {
	cmake_src_install

	# bundled font/icon licences go to /usr/share/licenses upstream (Arch style)
	docinto licenses
	dodoc "${ED}"/usr/share/licenses/${PN}/*
	rm -r "${ED}"/usr/share/licenses || die

	dodoc CHANGELOG.md README.md
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "omasnap is built for Hyprland: it needs 'hyprctl' in PATH for monitor"
	elog "and window discovery. Omarchy integrations (omarchy-notification-send,"
	elog "Omarchy theme colours) are optional and silently skipped when absent."
	elog "Bind it in hyprland.conf, e.g.:  bind = , PRINT, exec, omasnap"

	optfeature "OCR text recognition" app-text/tesseract
}
