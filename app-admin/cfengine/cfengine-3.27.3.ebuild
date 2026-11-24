# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Autonomous configuration management system implementing Promise Theory"
HOMEPAGE="https://cfengine.org"
SRC_URI="https://cfengine-package-repos.s3.amazonaws.com/tarballs/${PN}-community-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="3"
KEYWORDS="~amd64"
IUSE="acl curl examples fhs mysql pam xml yaml"

DEPEND="
	dev-db/lmdb
	dev-libs/libpcre2:=
	dev-libs/openssl:=
	net-libs/librsync
	acl? ( sys-apps/acl )
	curl? ( net-misc/curl )
	mysql? ( dev-db/mysql-connector-c )
	pam? ( sys-libs/pam )
	xml? ( dev-libs/libxml2 )
	yaml? ( dev-libs/libyaml )
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	local myeconfargs=(
		# Also sets the log, pid and module dirs to /var/cfengine
		--with-workdir=/var/cfengine
	)
	if use fhs; then
		myeconfargs+=( --enable-fhs )
	else
		# Upstream layout: everything under /var/cfengine
		myeconfargs+=(
			--prefix=/var/cfengine
			--bindir=/var/cfengine/bin
			--libdir=/var/cfengine/lib
		)
	fi

	econf \
		"${myeconfargs[@]}" \
		--with-lmdb \
		--with-pcre2 \
		--with-librsync \
		--without-libvirt \
		--without-postgresql \
		$(use_with acl libacl) \
		$(use_with curl libcurl) \
		$(use_with mysql) \
		$(use_with pam) \
		$(use_with xml libxml2) \
		$(use_with yaml libyaml)
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die

	if ! use examples; then
		rm -r "${ED}/usr/share/doc/${PF}/examples" || die
	fi

	local dir
	for dir in inputs modules outputs plugins ppkeys state; do
		keepdir "/var/cfengine/${dir}"
	done

	# Policies and init scripts expect the binaries in /var/cfengine/bin
	local bin
	if use fhs; then
		for bin in "${ED}"/usr/bin/cf-*; do
			dosym -r "/usr/bin/${bin##*/}" "/var/cfengine/bin/${bin##*/}"
		done
	else
		for bin in "${ED}"/var/cfengine/bin/cf-*; do
			dosym -r "/var/cfengine/bin/${bin##*/}" "/usr/sbin/${bin##*/}"
		done
	fi
	fperms -R 700 /var/cfengine

	local svc
	for svc in cf-serverd cf-monitord cf-execd; do
		newinitd "${FILESDIR}/${svc}.initd" "${svc}"
		newconfd "${FILESDIR}/${svc}.confd" "${svc}"
	done

	newenvd - "99${PN}" <<-EOF
		CONFIG_PROTECT="/var/cfengine/masterfiles"
	EOF
}

pkg_postinst() {
	elog "OpenRC services cf-serverd, cf-monitord and cf-execd are provided;"
	elog "they need a bootstrapped host (/var/cfengine/inputs/promises.cf)."
	elog "To run cfengine from cron every half hour instead of cf-execd:"
	elog "0,30 * * * *    /var/cfengine/bin/cf-execd --once"
	elog
	elog "On first install, generate the host keys with:"
	elog "emerge --config ${CATEGORY}/${PN}"
	elog "then bootstrap with: cf-agent --bootstrap <policy server>"
}

pkg_config() {
	[[ -z ${ROOT} ]] || die "cf-key only supports ROOT=/"

	if [[ ! -f ${EROOT}/var/cfengine/ppkeys/localhost.priv ]]; then
		einfo "Generating keys for localhost."
		"${EROOT}"/var/cfengine/bin/cf-key || die
	fi
}
