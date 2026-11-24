# cyphermaster-overlay

## Contents

- [Installation](#installation)
- [Packages](#packages)
  - [acct-group](#acct-group)
  - [acct-user](#acct-user)
  - [app-admin](#app-admin)
  - [app-backup](#app-backup)
  - [app-metrics](#app-metrics)
  - [media-gfx](#media-gfx)
  - [sys-power](#sys-power)
  - [x11-misc](#x11-misc)
- [License](#license)

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

Versions prefixed with `~` are keyworded for testing (`~amd64`). `9999` are
live ebuilds built from upstream git.

### acct-group

- [**victoria-logs**](acct-group/victoria-logs) — System group for `app-metrics/victorialogs`
- [**victoria-metrics**](acct-group/victoria-metrics) — System group for `app-metrics/victoriametrics`

### acct-user

- [**victoria-logs**](acct-user/victoria-logs) — System user for `app-metrics/victorialogs`
- [**victoria-metrics**](acct-user/victoria-metrics) — System user for `app-metrics/victoriametrics`

### app-admin

- [**cfengine**](app-admin/cfengine) — Autonomous configuration management implementing Promise Theory; `USE=fhs` for an FHS layout
  - Versions: 3.27.0-r1, ~3.27.3
  - Upstream: <https://cfengine.org>

### app-backup

- [**plakar**](app-backup/plakar) — Backup tool with deduplication, encryption and a built-in snapshot browser
  - Versions: ~1.1.8
  - Upstream: <https://plakar.io>, <https://github.com/PlakarKorp/plakar>

### app-metrics

- [**victorialogs**](app-metrics/victorialogs) — Log database, with `vlagent`
  - Versions: 1.52.1-r1
  - Upstream: <https://victoriametrics.com/products/victorialogs/>, <https://github.com/VictoriaMetrics/VictoriaLogs>
- [**victoriametrics**](app-metrics/victoriametrics) — Time series database, with `vmagent`, `vmalert` and `vmauth`
  - Versions: 1.148.1
  - Upstream: <https://victoriametrics.com/>, <https://github.com/VictoriaMetrics/VictoriaMetrics>

### media-gfx

- [**omasnap**](media-gfx/omasnap) — Native Wayland screenshot and annotation overlay for Hyprland
  - Versions: ~1.26.3, 9999
  - Upstream: <https://github.com/omacom/omasnap>

### sys-power

- [**it5570-fan**](sys-power/it5570-fan) — hwmon driver for the ITE IT5570E embedded controller (fans, temperatures)
  - Versions: ~9999
  - Upstream: <https://github.com/passiveEndeavour/it5570-fan>
- [**it87**](sys-power/it87) — Out-of-tree IT87 sensors module (frankcrawford fork)
  - Versions: 9999
  - Upstream: <https://github.com/frankcrawford/it87>

### x11-misc

- [**hyprfm**](x11-misc/hyprfm) — Lightweight Qt6/QML file manager for Hyprland
  - Versions: 0.6.1, ~0.7.0, ~0.7.1, 9999
  - Upstream: <https://github.com/soyeb-jim285/hyprfm>

## License

The ebuilds and support files in this repository are released under the
[MIT license](LICENSE). Each packaged software keeps its own upstream license.
