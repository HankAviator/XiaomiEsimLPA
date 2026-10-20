#!/system/bin/sh

MODDIR=${0%/*}
GRANT_FLAG="$MODDIR/.device_identifiers_granted"

# Skip even the boot wait once a previous grant succeeded.
[ -f "$GRANT_FLAG" ] && exit 0

# A newly installed system APK is only registered after the next boot.
while [ "$(getprop sys.boot_completed)" != 1 ]; do
	sleep 2
done

if pm path com.miui.euicc >/dev/null 2>&1; then
	if appops set com.miui.euicc android:read_device_identifiers allow; then
		# Keep the flag in the module directory so uninstalling removes it too.
		touch "$GRANT_FLAG" ||
			log -t XiaomiEsimLPA "Failed to save the device identifier grant flag."
	else
		log -t XiaomiEsimLPA "Failed to grant device identifier access to com.miui.euicc."
	fi
else
	log -t XiaomiEsimLPA "LPA package com.miui.euicc is not installed."
fi
