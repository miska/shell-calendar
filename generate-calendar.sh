#!/bin/sh
#
# Copyright (C) 2016 Michal Hrusecky <Michal@Hrusecky.net>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program. If not, see http://www.gnu.org/licenses/.

if [ "$START" ]; then
  NOW="$START"
else
  NOW=$(date --date='next year' +%Y)-01-01
fi
PLUS="0"

get_year() {
    date --date="$NOW + $PLUS days" +%Y
}

get_month() {
    date --date="$NOW + $PLUS days" +%m
}

get_day() {
    date --date="$NOW + $PLUS days" +%d
}

NOW_Y="`get_year`"
cat << EOF
<!DOCTYPE html>
<hmtl>
<head>
  <meta charset="UTF-8">
  <title>Kalendář pro rok $NOW_Y</title>
  <style type="text/css">
    /* Some generic settings */
    .month {   
      width: 21cm;
      height: 29.7cm;
      display: block;
    }
    @media screen {
      .month {
        margin: 0 auto;
        margin-bottom: 0.5cm;
        box-shadow: 0 0 0.5cm rgba(0,0,0,0.5);
      }
    }
    h1 {
      text-align: center;
      text-transform: capitalize;
      padding-top: 1cm;
      font-size: 1.5cm;
      padding-bottom: 1cm;
      margin: 0px;
    }
    h2 {
      text-align: center;
      padding-top: 0.5cm;
      font-size: 0.3cm;
      font-style: italic;
      font-weight: normal;
      padding-bottom: 0.5cm;
      margin: 0px;
    }
    .notes { font-size: 0.7em; padding-top: 0; }
    p { margin: 0; }
    img { padding-left: 10%; width: 80%; height: auto; }
    table { width: 100%; padding-left: 1.75cm; padding-right: 1.75cm; }
    td { text-align: center; width: 2.5cm; vertical-align: top; }
    tr { height: 1.3cm; }

    /* Printing specific */
    @page {
      size: A4 portrait;
      margin: 0;
    }
    @media print {
      .month {
        margin: 0;
        box-shadow: 0;
        border: 0;
        border-radius: 0;
        box-shadow: 0;
      }
    }
  </style>
  <style type="text/css">
    /* Colors */
    .month { background: white; }
    body { background: gray; color: black; }
    .Sunday { color: red; }
    .Saturday { color: red; }
  </style>
  <style type="text/css">
    /* List styles */
EOF
for i in *.list; do
    echo "    .$(basename $i .list) { $(sed -n 's|^style=||p' $i) }"
done
cat << EOF
  </style>
</head>
<body>
EOF

while [ `get_year` -eq $NOW_Y ]; do
    NOW_M="`get_month`"
    echo '<div class="month">'
    echo "<h1>$(date --date="$NOW + $PLUS days" +%B) ${NOW_Y}</h1>"
    echo ''
    echo "<img alt='$(date --date="$NOW + $PLUS days" +%B) ${NOW_Y}' src='$(date --date="$NOW + $PLUS days" +%m).jpg'/>"
    if [ -f "$(date --date="$NOW + $PLUS days" +%m).txt" ]; then
        echo "<h2>$(cat $(date --date="$NOW + $PLUS days" +%m).txt)</h2>"
    fi
    echo ''
    echo '<table>'
    echo "<tr>"
    for i in Monday Tuesday Wednesday Thursday Friday Saturday Sunday; do
        echo "  <th class='$i'>$(date --date=$i +%A)</th>"
    done
    echo "</tr>"
    echo "<tr>"
    if [ $(date --date="$NOW + $PLUS days" +%u) -ne 1 ]; then
        for i in $(seq 2 $(date --date="$NOW + $PLUS days" +%u)); do
            echo '  <td></td>'
        done
    fi
    while [ `get_month` -eq $NOW_M ]; do
        echo "  <td class='$(LANG=C date --date="$NOW + $PLUS days" +%A)'>"
        echo "    <p class='date'>$(date --date="$NOW + $PLUS days" +%d)</p>"
        DATE_LIST="$(date --date="$NOW + $PLUS days" +%0m-%0d)"
        DATE_LIST_Y="$(date --date="$NOW + $PLUS days" +%y-%0m-%0d)"
        for i in *.list; do
            TEXT="$(sed -n 's|^'$DATE_LIST'\ ||p' $i)"
            [ -z "$TEXT" ] || echo "<p class='notes $(basename $i .list)'>$TEXT</p>"
            TEXT="$(sed -n 's|^'$DATE_LIST_Y'\ ||p' $i)"
            [ -z "$TEXT" ] || echo "<p class='notes $(basename $i .list)'>$TEXT</p>"
        done
        echo "  </td>"
        if [ $(date --date="$NOW + $PLUS days" +%u) -eq 7 ]; then
            echo "</tr>"
            echo "<tr>"
        fi
        PLUS="`expr $PLUS + 1`"
    done
    if [ $(date --date="$NOW + $PLUS days" +%u) -ne 1 ]; then
        for i in $(seq $(date --date="$NOW + $PLUS days" +%u) 7); do
            echo '  <td></td>'
        done
        echo '</tr>'
    fi
    echo "</table>"
    echo "</div>"
done
cat << EOF
</body>
</html>
EOF
