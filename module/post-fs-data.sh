#!/system/bin/sh
MODDIR=${0%/*}
[ ! -f "$MODDIR/disable" ] && [ ! -f "$MODDIR/remove" ] || exit 0
exec 2>"$MODDIR/native-overlay.log"
. "$MODDIR/native-overlay.sh" || exit 1
trap 'native_overlay_rollback' EXIT
trap 'exit 1' HUP INT TERM
product=/product
[ -d "$product/etc/permissions" ] || product=/system/product
native_overlay "$MODDIR/files/etc/permissions" "$product/etc/permissions" || exit 1
if [ -f "$MODDIR/files/priv-app/MIUIEsimLPA/MIUIEsimLPA.apk" ]; then
    native_overlay "$MODDIR/files/priv-app" "$product/priv-app" || exit 1
fi
# Keep successful mounts until reboot; roll back all mounts on failure.
OVERLAY_MOUNTS=""
trap - EXIT HUP INT TERM
