#!/bin/bash
# <xbar.title>Wireguard</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Jorge Rodríguez Pedrianes</xbar.author>
# <xbar.author.github>jrpedrianes</xbar.author.github>
# <xbar.desc>Manages a Wireguard VPN connection</xbar.desc>
# <xbar.image>https://f001.backblazeb2.com/file/bitbar/wireguard.png</xbar.image>
# <xbar.dependencies></xbar.dependencies>

# You will need to add the following line to your sudoers file. Remember to edit
# sudoers with `sudo visudo`.
#
# %admin  ALL=(ALL) NOPASSWD: /usr/local/bin/wg-quick
#
# Rename WG_CONFIG if your Wireguard config is not called `wg0-client`

PATH="/usr/local/bin:$PATH"

WG_CONNECTED="iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAY1BMVEVHcEwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD////Iv5pwAAAAH3RSTlMAA0yMvd6sez0V7/qzbglj5qR0Ncj1KA7VLlQflkGEXYPQGAAAAAFiS0dEILNrPYAAAAAJcEhZcwAAFiUAABYlAUlSJPAAAAAHdElNRQfiCB0GISSxSlkqAAABpklEQVQ4y2VT7YKEIAik1GyzTNus1nbz/d/y8AO3u+OXIMLMgABkTcu4EJ1kvJN9A3/twYYQghqnHvQ8BMMev+/neB2sZEt8++SrcvJWpbEhmdiy3wL0IfBapOlCMZkDezsL9A7KWMq1aVPVThhzpADPXTZVEpzgL/Q9+VRxrX44WB8xCvJdbNKHu6klYhjvJSrCsE7PrbV2R9iUITCbOqo5Qz7fmPEYSrQHT+99FfV9qyvhXU42jcPja/hsX+pj5fDEp8h+QKIPLCYrCFMQ4EuWxMkVqLADV1TEhLEcIjeSQgEdUNUrHrpmRnU+lTsQyw+ARuhumTWireq6WmuMDL31GghNAcnpiDpNrySEnkxNGCvcEK4p7Yv2vtlIyMCqkmaScZInW8/YK1RoZRajhileIOsB8ZI8pinsD8SGIHZH0dI5jiVRZpIPKHCbwy+ahUqoaPa+Ls9Js2B5AQYCDM1RxgGWGkfr8zwEtj5Rlg5HrmPInLQifcY8pT9RpTy279c6Ew7V1p+ITty8m3061ENde9654Ozr3//ePeOHsNfCxsvrGv4BOvFCaHw59FkAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTgtMDgtMjlUMTA6MzM6MzYtMDQ6MDCYYoC0AAAAJXRFWHRkYXRlOm1vZGlmeQAyMDE4LTA4LTI5VDEwOjMzOjM2LTA0OjAw6T84CAAAAABJRU5ErkJggg=="
WG_DISCONNECTED="iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAY1BMVEVHcEwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD////Iv5pwAAAAIHRSTlMAAhsxQk09K0Q6FgEHVFk/JVEoEklWDyAKBBkNHTUfLpaxL30AAAABYktHRCCzaz2AAAAACXBIWXMAABYlAAAWJQFJUiTwAAAAB3RJTUUH4ggdBiEgtiedMwAAAaFJREFUOMtdU1GigyAMKyIiKihOVDY373/LVypl7vVHSjFNEwDgEJWslWq0bI3uevgfg7QOY5w6EJN1Xg6/9YnKRstZYPaolxD0DUUYR6HWK68AOufaAtI3LofO/apNYbbwiTmXfUWojfJe0UYtqL6GfCCo+oH5xjkjLiV3i+wSR8V52IHo3GPGrTjeIZrv/9NjfRoTcSw+oXoYSn26KL8knhhs3uzg4PrBU+/vG66Gd14ZsuOTRn+u39FHaPMKBxxwHpu+CKaZBOSRAmokSZwLgYEtZFU89/XQp9mKFMALVPVM30ZM+10cRsB5ICJEmDc8KpiZCwWrSRN+zEH+yAKgyhRJp+m6D2L25cBY6Dp3zq9UjtshVhbSyaKkn3VycpdtcrByhVrMFCIkHw/kbPFgn5t4lIeMW5DbhhrSTF4UoZItT2qla3vkNcmevSBW7P1W9HmxF/Ky1zJhEEu2A+ghqHhdgO5SU2HrvUa+aHlMP/kXX5HOl+sIMbKU/IyoCxkZnpxvaYD48zi7JvU5aXN4O2tW+B/DJz1/c85yPI/v339ndyeoPSR2pwAAACV0RVh0ZGF0ZTpjcmVhdGUAMjAxOC0wOC0yOVQxMDozMzozMy0wNDowMMparxMAAAAldEVYdGRhdGU6bW9kaWZ5ADIwMTgtMDgtMjlUMTA6MzM6MzItMDQ6MDAdcBwbAAAAAElFTkSuQmCC"

WG_EXECUTABLE="/usr/local/bin/wg-quick"
WG_PIDFILE_BASE="/var/run/wireguard"

function get_wire_guard_configs {
  find /etc/wireguard -type f -path "*\.conf" -exec basename -a -s .conf {} \;
}

function connect_wg {
  local wg_interface wg_interface_real

  for wg_interface in $(get_wire_guard_configs); do
    if [ -f "${WG_PIDFILE_BASE}/${wg_interface}.name" ]; then
      continue
    fi

    sudo ${WG_EXECUTABLE} up "${wg_interface}" 2> /dev/null

    # Wait for connection so menu item refreshes instantly
    until [ -f "${WG_PIDFILE_BASE}/${wg_interface}.name" ]; do sleep 1; done

    # wg_interface_real="$(< "/var/run/wireguard/$INTERFACE.name")"
    # wg set "${wg_interface_real}" private-key <(op read "op://KuFlow/vpn/PrivateKey/${wg_interface}")
    # op read "op://KuFlow/vpn/PrivateKey/wg0" | sudo wg set "utun3" private-key /dev/stdin|
  done
}

function disconnect_wg {
  local wg_interface

  for wg_interface in $(get_wire_guard_configs); do
    if [ ! -f "${WG_PIDFILE_BASE}/${wg_interface}.name" ]; then
      continue
    fi

    sudo ${WG_EXECUTABLE} down "${wg_interface}" 2> /dev/null

    # Wait for disconnection so menu item refreshes instantly
    until [ ! -f "${WG_PIDFILE_BASE}/${wg_interface}.name" ]; do sleep 1; done
  done
}

function status_wg {
  local wg_interface connected=true

  for wg_interface in $(get_wire_guard_configs); do
    if [ ! -f "${WG_PIDFILE_BASE}/${wg_interface}.name" ]; then
      connected=false
    fi
  done

  if ${connected}; then
    echo "| templateImage=${WG_CONNECTED}"
    echo '---'
    echo "Disconnect Wireguard | bash='$0' param1=disconnect terminal=false refresh=true"
  else
    echo "| templateImage=${WG_DISCONNECTED}"
    echo '---'
    echo "Connect Wireguard | bash='$0' param1=connect terminal=false refresh=true"
  fi
}

case "$1" in
  connect)
    connect_wg
    ;;
  disconnect)
    disconnect_wg
    ;;
esac

status_wg
