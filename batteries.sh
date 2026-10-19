#!/bin/bash
# Per-battery lines plus a TOTAL line, tab separated:
# name label pct state watts cycles sizeWh health% active time
# Labels are fixed by battery name; adjust here if the mapping is the other way round.
declare -A label=([BAT0]=Internal [BAT1]=External)
raw=""
for b in /sys/class/power_supply/BAT*; do
  [[ -r $b/capacity ]] || continue
  n=$(basename "$b")
  read -r state < "$b/status"
  p=0; [[ -r $b/power_now ]] && read -r p < "$b/power_now"
  c="—"; [[ -r $b/cycle_count ]] && read -r c < "$b/cycle_count"
  now=0; full=0; design=0
  [[ -r $b/energy_now ]] && read -r now < "$b/energy_now"
  [[ -r $b/energy_full ]] && read -r full < "$b/energy_full"
  [[ -r $b/energy_full_design ]] && read -r design < "$b/energy_full_design"
  raw+="$n|${label[$n]:-$n}|$state|$p|$c|$now|$full|$design"$'\n'
done
awk -F'|' '
function fmt(h,   H, M) { H = int(h); M = int((h - H) * 60); return M > 0 ? H "h " M "m" : H "h" }
NF < 8 { next }
{
  act = ($3 == "Discharging" || $3 == "Charging") && $4 > 0
  printf "%s\t%s\t%d%%\t%s\t%.1fW\t%s\t%dWh\t%d%%\t%d\t\n", $1, $2, ($7 > 0 ? $6 * 100 / $7 : 0), $3, $4 / 1e6, $5, $7 / 1e6, ($8 > 0 ? $7 * 100 / $8 : 0), act
  now += $6; full += $7; design += $8; power += $4
  cyc = cyc (cyc == "" ? "" : " / ") $5
  if ($3 == "Discharging") dis = 1
  if ($3 == "Charging") chg = 1
  if (act) active = active (active == "" ? "" : " + ") $2
  state = (state == "" || $3 == "Discharging" || $3 == "Charging") ? $3 : state
}
END {
  if (full == 0) exit
  st = dis ? "Discharging" : (chg ? "Charging" : state)
  t = ""
  if (power > 0 && dis) t = fmt(now / power)
  else if (power > 0 && chg) t = fmt((full - now) / power)
  printf "TOTAL\tCombined\t%d%%\t%s\t%.1fW\t%s\t%dWh\t%d%%\t%s\t%s\n", (full > 0 ? now * 100 / full : 0), st, power / 1e6, cyc, full / 1e6, (design > 0 ? full * 100 / design : 0), active, t
}' <<<"$raw"
