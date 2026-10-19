# Omarchy power panel for two-battery laptops

A modified copy of Omarchy's built-in `omarchy.power` bar widget. The stock widget
reads only the first battery; this version treats the laptop's batteries as one pack
and shows each of them too.

Built and tested on a ThinkPad T480 (internal `BAT0` + hot-swappable external `BAT1`)
under Omarchy 4.0.5. **Not tested on other hardware or on a clean install.**

## What changes

- **Combined figures:** percentage, progress bar, bar-button percentage, size (Wh),
  time left / time to full and power draw are computed across all batteries
  (`sum(energy_now) / sum(energy_full)`, runtime from total energy and total draw).
- **Active battery at a glance:** the panel title reads `Battery · Internal` (or
  `External`, or `Internal + External`), taken from whichever battery is actually
  discharging or charging.
- **Batteries section:** one block per battery with percentage (● marks the active
  one), state, power, capacity and health, and charge cycles. It is hidden when the
  machine has a single battery.

## Install

```bash
omarchy plugin add https://github.com/jaderfeijo/omarchy-dual-battery-power.git --enable
```

Then replace `omarchy.power` with `jaderfeijo.power` in the `bar.layout` section of
`~/.config/omarchy/shell.json` (or run `omarchy plugin disable omarchy.power`), and
restart the shell with `omarchy restart shell`. Hot-reloading edits to a cloned panel
left a stale copy of it running in my testing, so restart instead of relying on it.

## Internal / External labels

`batteries.sh` labels `BAT0` as Internal and `BAT1` as External. That matches the T480
(the kernel exposes an `eject` control only on `BAT1`, and TLP documents BAT1 as the
replaceable battery), but it is a fixed mapping. Edit the `label=(...)` line at the top
of `batteries.sh` for other machines.

## Notes from testing on the T480

Not part of the widget, but what I measured while building it:

- The embedded controller chooses which battery discharges first. Here the internal
  battery was drained and the external one stayed at 0 W.
- `charge_behaviour` accepted `force-discharge` on the external battery with AC
  connected and rejected it (`Input/output error`) on battery power, so it cannot
  be used to change the drain order.

## License

MIT. `Panel.qml` and `Model.js` are derived from Omarchy's `omarchy.power` plugin
(MIT, <https://github.com/basecamp/omarchy>); see `LICENSE`.
