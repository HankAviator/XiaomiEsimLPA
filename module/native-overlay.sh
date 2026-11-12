#!/system/bin/sh
# Native read-only OverlayFS with RAM staging for unsupported /data lower layers.
# MODDIR must name the owning module. Call native_overlay <payload> <target>.
OVERLAY_MOUNTS=""
native_overlay_rollback() {
    for overlay_target in $OVERLAY_MOUNTS; do
        umount "$overlay_target" || :
    done
    OVERLAY_MOUNTS=""
}
native_overlay() {
    local payload target context stage key
    payload=$(readlink -f "$1") || return 1
    target=$(readlink -f "$2") || return 1
    case "$payload" in *:*) return 1 ;; esac
    case "$target" in *:*) return 1 ;; esac
    case "$payload:$target" in
        *','*|*' '*|*'	'*|*'
'*) echo "Unsupported OverlayFS path" >&2; return 1 ;;
    esac
    [ -d "$payload" ] && [ -d "$target" ] || return 1
    case "$target" in /|/data|/data/adb) return 1 ;; esac
    key=$(echo "$target" | tr / _)
    stage="$MODDIR/runtime/native-overlay/$key"
    # A repeated invocation must not stack another copy of this overlay.
    if awk -v p="$stage" -v t="$target" '
        $1 == "KSU" && $2 == t && $3 == "overlay" &&
        index($4, "lowerdir=" p ":") { found=1 }
        END { exit !found }' /proc/mounts; then
        return 0
    fi
    context=$(ls -Zd "$target" | awk '{print $1}') || return 1
    case "$context" in u:object_r:*:s0) ;; *) return 1 ;; esac
    mkdir -p "$stage" || return 1
    # Clear a leftover staging mount from an interrupted earlier invocation.
    if awk -v p="$stage" '$1 == "KSU" && $2 == p && $3 == "tmpfs" {f=1} END {exit !f}' /proc/mounts; then
        umount "$stage" || return 1
    fi
    mount -t tmpfs -o mode=0755,nodev,nosuid KSU "$stage" || return 1
    OVERLAY_MOUNTS="$stage $OVERLAY_MOUNTS"
    cp -a "$payload/." "$stage/" || return 1
    # Relabel only the RAM copy, never stock files or the original payload.
    chcon -R "$context" "$stage" || return 1
    mount -t overlay -o "ro,lowerdir=$stage:$target" KSU "$target" || return 1
    OVERLAY_MOUNTS="$target $OVERLAY_MOUNTS"
}
