# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake optfeature virtualx xdg

# Commits of the src/qml/Quill and src/qml/icons submodules at this tag:
#   git ls-tree v${PV} src/qml/Quill src/qml/icons
QUILL_COMMIT="bc13deae669a1333a0d7bdd991c7015270a16a38"
QUILL_ICONS_COMMIT="10db5facf6a560e60d2693ccd1909267ef436002"

DESCRIPTION="A lightweight Qt6/QML file manager for Hyprland"
HOMEPAGE="https://github.com/soyeb-jim285/hyprfm"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/soyeb-jim285/hyprfm.git"
	EGIT_SUBMODULES=( '*' )
else
	SRC_URI="
		https://github.com/soyeb-jim285/hyprfm/archive/refs/tags/v${PV}.tar.gz
			-> ${P}.tar.gz
		https://github.com/soyeb-jim285/quill/archive/${QUILL_COMMIT}.tar.gz
			-> quill-${QUILL_COMMIT}.tar.gz
		https://github.com/soyeb-jim285/quill-icons/archive/${QUILL_ICONS_COMMIT}.tar.gz
			-> quill-icons-${QUILL_ICONS_COMMIT}.tar.gz
	"
	KEYWORDS="~amd64 ~arm64"
fi

# hyprfm, quill, toml++ (bundled header): MIT; quill-icons (Lucide): ISC
LICENSE="MIT ISC"
SLOT="0"
IUSE="kde test"
RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/glib:2
	dev-qt/qtbase:6[concurrent,dbus,gui,network]
	dev-qt/qtdeclarative:6
	dev-qt/qtsvg:6
	kde? ( kde-frameworks/kwindowsystem:6 )
"
RDEPEND="
	${DEPEND}
	dev-qt/qtwayland:6
	gnome-base/gvfs
	x11-misc/xdg-utils
"
BDEPEND="
	virtual/pkgconfig
"

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		git-r3_src_unpack
	else
		default
	fi
}

src_prepare() {
	if [[ ${PV} != 9999 ]]; then
		# GitHub tarballs ship the submodule paths as empty directories
		rm -rf src/qml/Quill src/qml/icons || die
		mv "${WORKDIR}/quill-${QUILL_COMMIT}" src/qml/Quill || die
		mv "${WORKDIR}/quill-icons-${QUILL_ICONS_COMMIT}" src/qml/icons || die
	fi

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_TESTS=$(usex test)
		-DHYPRFM_DATA_DIR="${EPREFIX}/usr/share/hyprfm"
		# precompiled QML; the on-disk tree is only a fallback
		-DHYPRFM_ENABLE_QML_CACHEGEN=ON
		$(cmake_use_find_package kde KF6WindowSystem)
	)

	cmake_src_configure
}

src_test() {
	virtx cmake_src_test
}

pkg_postinst() {
	xdg_pkg_postinst

	optfeature "clipboard support" gui-apps/wl-clipboard
	optfeature "fast recursive search" sys-apps/fd
	optfeature "syntax-highlighted text previews" sys-apps/bat
	optfeature "rendered Markdown previews" dev-libs/md4c
	optfeature "video thumbnails and audio/video metadata" media-video/ffmpeg
	optfeature "PDF thumbnails, previews and metadata" "app-text/poppler[utils]"
	optfeature "EXIF metadata for images" media-libs/exiftool
	optfeature "mounting devices from the sidebar" sys-fs/udisks:2
	optfeature "SMB/CIFS remote browsing" "gnome-base/gvfs[samba]"
	optfeature "Android phones (MTP) in the sidebar" "gnome-base/gvfs[mtp]"
	optfeature "cloud storage mounts" net-misc/rclone
	optfeature "git status in file views" dev-vcs/git
	optfeature "7z archives" app-arch/7zip
	optfeature "more archive formats (bsdtar)" app-arch/libarchive
	optfeature "zip archives" app-arch/unzip
	optfeature "zstd archives" app-arch/zstd
}
