# customize.sh is sourced by the module installer after extraction and default
# permissions have been applied.
name=$(grep_prop name "$MODPATH/module.prop")
version=$(grep_prop version "$MODPATH/module.prop")

ui_print "*****************"
ui_print "$name $version"
ui_print "*****************"

# Prefer the ROM's LPA when available. Check files rather than Package Manager:
# the bundled app may already be registered from an earlier module installation.
system_lpa_present=false
for lpa_apk in \
	/product/priv-app/EsimLPA/*.apk \
	/system/product/priv-app/EsimLPA/*.apk; do
	if [ -f "$lpa_apk" ]; then
		system_lpa_present=true
		break
	fi
done

if [ "$system_lpa_present" = true ]; then
	ui_print "LPA app is already present in the system image."
	ui_print "Using the system version."
	# Only remove the bundled APK; do not recursively delete an installer path.
	rm -f "$MODPATH/system/product/priv-app/MIUIEsimLPA/MIUIEsimLPA.apk" ||
		abort "Unable to remove the bundled LPA APK."
	rmdir "$MODPATH/system/product/priv-app/MIUIEsimLPA" 2>/dev/null || :
else
	# The bundled APK declares minSdkVersion 33 (Android 13).
	[ "$API" -ge 33 ] || abort "The bundled LPA requires Android 13 or newer."
	ui_print "LPA app is not present in the system image."
	ui_print "Installing bundled LPA 4.0.9.1."
fi

ui_print "- Device identifier access will be granted after reboot."
