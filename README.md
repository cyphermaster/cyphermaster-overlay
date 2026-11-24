# cyphermaster-overlay

Personal Gentoo ebuild repository: desktop tools for Hyprland, observability stack,
configuration management, backups and a few out-of-tree kernel modules.

All ebuilds are EAPI 8 and ship OpenRC init scripts where a daemon is involved.

## Installation

With `eselect-repository`:

```bash
eselect repository add cyphermaster-overlay git https://github.com/cyphermaster/overlay.git
emaint sync -r cyphermaster-overlay
```

Or by hand in `/etc/portage/repos.conf/cyphermaster-overlay.conf`:

```ini
[cyphermaster-overlay]
location = /var/db/repos/cyphermaster-overlay
sync-type = git
sync-uri = https://github.com/cyphermaster/overlay.git
```

## Packages

| Package | Versions | Description | Upstream |
|---|---|---|---|
| [`app-admin/cfengine`](app-admin/cfengine) | 3.27.0-r1, ~3.27.3 | Autonomous configuration management implementing Promise Theory (`USE=fhs` for an FHS layout) | [cfengine.org](https://cfengine.org) |
| [`app-backup/plakar`](app-backup/plakar) | ~1.1.8 | Backup tool with deduplication, encryption and a built-in snapshot browser | [plakar.io](https://plakar.io) · [GitHub](https://github.com/PlakarKorp/plakar) |
| [`app-metrics/victorialogs`](app-metrics/victorialogs) | 1.52.1-r1 | Log database, with `vlagent` | [victoriametrics.com](https://victoriametrics.com/products/victorialogs/) · [GitHub](https://github.com/VictoriaMetrics/VictoriaLogs) |
| [`app-metrics/victoriametrics`](app-metrics/victoriametrics) | 1.148.1 | Time series database, with `vmagent`, `vmalert` and `vmauth` | [victoriametrics.com](https://victoriametrics.com/) · [GitHub](https://github.com/VictoriaMetrics/VictoriaMetrics) |
| [`media-gfx/omasnap`](media-gfx/omasnap) | ~1.26.3, 9999 | Native Wayland screenshot and annotation overlay for Hyprland | [GitHub](https://github.com/omacom/omasnap) |
| [`sys-power/it5570-fan`](sys-power/it5570-fan) | ~9999 | hwmon driver for the ITE IT5570E embedded controller (fans, temperatures) | [GitHub](https://github.com/passiveEndeavour/it5570-fan) |
| [`sys-power/it87`](sys-power/it87) | 9999 | Out-of-tree IT87 sensors module (frankcrawford fork) | [GitHub](https://github.com/frankcrawford/it87) |
| [`x11-misc/hyprfm`](x11-misc/hyprfm) | 0.6.1, ~0.7.0, ~0.7.1, 9999 | Lightweight Qt6/QML file manager for Hyprland | [GitHub](https://github.com/soyeb-jim285/hyprfm) |

Versions prefixed with `~` are keyworded `~amd64` (testing); `9999` are live
ebuilds built from upstream git and need an explicit `**` keyword.

Support packages: `acct-group/victoria-{logs,metrics}` and
`acct-user/victoria-{logs,metrics}` provide the system accounts for the
VictoriaMetrics daemons.

## License

The ebuilds and support files in this repository are released under the
[MIT license](LICENSE). Each packaged software keeps its own upstream license.
