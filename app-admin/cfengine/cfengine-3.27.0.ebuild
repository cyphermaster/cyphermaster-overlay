# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8

inherit autotools

DESCRIPTION="Autonomous configuration management system implementing Promise Theory"
HOMEPAGE="https://cfengine.org"
SRC_URI="https://github.com/cfengine/core/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

SRC_URI="https://cfengine-package-repos.s3.amazonaws.com/tarballs/${PN}-community-${PV}.tar.gz
	masterfiles? ( https://cfengine-package-repos.s3.amazonaws.com/tarballs/${PN}-masterfiles-${PV}.tar.gz )"
LICENSE="GPL-3"
SLOT="3.27"
KEYWORDS="~amd64"

IUSE="acl mysql pam selinux xml curl masterfiles examples"

BDEPEND="virtual/pkgconfig"

DEPEND="
    dev-db/lmdb
	curl? ( net-misc/curl )
    dev-libs/openssl:=
    dev-libs/libpcre2:=
    dev-libs/libyaml
    net-libs/librsync
    dev-libs/icu
    acl? ( virtual/acl )
    pam? ( sys-libs/pam )
    xml? ( dev-libs/libxml2 )
    selinux? ( sys-libs/libselinux )
	mysql? ( virtual/mysql )
"


RDEPEND="${DEPEND}"
#S="${WORKDIR}/${PN}-community-${PV}"

src_prepare() {
    default
}

src_unpack() {
	unpack ${PN}-community-${PV}.tar.gz

	if use masterfiles; then
		unpack ${PN}-masterfiles-${PV}.tar.gz
	fi
}

src_configure() {
	# Enforce /var/cfengine for historical compatibility

	econf \
		--enable-fhs \
		--docdir=/usr/share/doc/${PF} \
		--with-workdir=/var/cfengine \
		--with-pcre2 \
	 	$(use_with acl libacl) \
        $(use_with mysql) \
        $(use_with pam) \
        $(use_with xml libxml2) \
        $(use_enable selinux) \
		$(use_with curl)

}

src_install() {
	default
	keepdir /var/cfengine
    fperms 700 /var/cfengine
	newinitd "${FILESDIR}"/cf-serverd.rc6 cf-serverd
	newinitd "${FILESDIR}"/cf-monitord.rc6 cf-monitord
	newinitd "${FILESDIR}"/cf-execd.rc6 cf-execd

	dodoc AUTHORS

	if ! use examples; then
		rm -rf "${ED}"/usr/share/doc/${PF}/example*
	fi

	# Create cfengine working directory
	dodir /var/cfengine/bin
	fperms 700 /var/cfengine

	# Copy cfagent into the cfengine tree otherwise cfexecd won't
	# find it. Most hosts cache their copy of the cfengine
	# binaries here. This is the default search location for the
	# binaries.
	for bin in promises agent monitord serverd execd runagent key; do
		dosym ../../../usr/sbin/cf-$bin /var/cfengine/bin/cf-$bin
	done

	if use masterfiles; then
		insinto /var/cfengine
		doins -r "${WORKDIR}/masterfiles"
	fi

	dodir /etc/env.d
	echo 'CONFIG_PROTECT=/var/cfengine/masterfiles' >"${ED}/etc/env.d/99${PN}" || die
}

pkg_postinst() {
	echo
	einfo "Init scripts for cf-serverd, cf-monitord, and cf-execd are provided."
	einfo
	einfo "To run cfengine out of cron every half hour modify your crontab:"
	einfo "0,30 * * * *    /usr/sbin/cf-execd -F"
	echo

	elog "If you run cfengine the very first time, you MUST generate the keys for cfengine by running:"
	elog "emerge --config ${CATEGORY}/${PN}"

}

pkg_config() {
	if [[ -z ${ROOT} ]]; then
		if [ ! -f "/var/cfengine/ppkeys/localhost.priv" ]; then
			einfo "Generating keys for localhost."
			/usr/sbin/cf-key
		fi
	else
		die "cfengine cfkey does not support any value of ROOT other than /."
	fi
}
