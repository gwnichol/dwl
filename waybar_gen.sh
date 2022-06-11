#!/bin/sh

waybar_path="$(which waybar-dwl)"

monitors="DVI-D-1 DP-2"

cat <<<'['
for monitor in ${monitors}; do
cat <<<'
    {
        "layer": "top",
        "output": "'${monitor}'",
        "modules-left": [
            "custom/dwl_tag#0", "custom/dwl_tag#1", "custom/dwl_tag#2", "custom/dwl_tag#3", "custom/dwl_tag#4", "custom/dwl_tag#5",
            "custom/dwl_tag#6", "custom/dwl_tag#7", "custom/dwl_tag#8",
            "custom/dwl_layout", "custom/dwl_title"
            ],'

for i in 0 1 2 3 4 5 6 7 8; do
cat <<< '        "custom/dwl_tag#'${i}'": {
            "exec": "'${waybar_path}' '${monitor}'" "'${i}'",
            "format": "{}",
            "return-type": "json"
        },'
done

cat <<< '        "custom/dwl_layout": {
            "exec": "'${waybar_path}' '${monitor}' layout",
            "format": "{}",
            "return-type": "json"
        },
        "custom/dwl_title": {
            "exec": "'${waybar_path}' '${monitor}' title",
            "format": "{}",
            "escape": true,
            "return-type": "json"
        }
    },
'
done
cat <<<']'
