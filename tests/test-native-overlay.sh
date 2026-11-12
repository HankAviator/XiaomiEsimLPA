#!/system/bin/sh
# Android integration regression: run as root; all mounts stay private.
set -eu
BB=/data/adb/ksu/bin/busybox
export ASH_STANDALONE=1
if [ "${1:-}" != --inside ]; then
    exec "$BB" unshare -m "$BB" ash "$0" --inside
fi
mount --make-rprivate /
[ "$(readlink /proc/self/ns/mnt)" != "$(readlink /proc/1/ns/mnt)" ]
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
LIB="$ROOT/native-overlay.sh"
[ -f "$LIB" ] || LIB="$ROOT/module/native-overlay.sh"
TESTWORK=/data/local/tmp/native-overlay-test.$$
[ ! -e "$TESTWORK" ]
mkdir "$TESTWORK"
mount -t tmpfs -o mode=0755 KSU_TEST "$TESTWORK"
MODDIR="$TESTWORK/module"
mkdir -p "$MODDIR" "$TESTWORK/payload" "$TESTWORK/target"
chcon -R u:object_r:system_file:s0 "$TESTWORK"
. "$LIB"
cleanup() {
    native_overlay_rollback
    umount "$TESTWORK"
    rmdir "$TESTWORK"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
printf 'stock\n' > "$TESTWORK/target/replace"
printf 'preserved\n' > "$TESTWORK/target/keep"
printf 'replacement\n' > "$TESTWORK/payload/replace"
printf 'added\n' > "$TESTWORK/payload/new"
native_overlay "$TESTWORK/payload" "$TESTWORK/target"
[ "$(cat "$TESTWORK/target/replace")" = replacement ]
[ "$(cat "$TESTWORK/target/keep")" = preserved ]
[ "$(cat "$TESTWORK/target/new")" = added ]
if (echo forbidden > "$TESTWORK/target/write") 2>/dev/null; then
    echo 'Overlay was writable' >&2
    exit 1
fi
before=$(wc -l < /proc/mounts)
native_overlay "$TESTWORK/payload" "$TESTWORK/target"
[ "$(wc -l < /proc/mounts)" = "$before" ]
if native_overlay "$TESTWORK/missing" "$TESTWORK/target"; then exit 1; fi
native_overlay_rollback
[ "$(cat "$TESTWORK/target/replace")" = stock ]
[ ! -e "$TESTWORK/target/new" ]
echo 'PASS: native merge, overwrite, read-only, idempotence and rollback'
