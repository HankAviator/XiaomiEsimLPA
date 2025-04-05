##########################################################################################
#
# Magisk
# by topjohnwu
#
# This is a template zip for developers
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure the settings in this file (common/config.sh)
# 4. For advanced features, add shell commands into the script files under common:
#    post-fs-data.sh, service.sh
# 5. For changing props, add your additional/modified props into common/system.prop
#
##########################################################################################


##########################################################################################
# Installation Message
##########################################################################################

# Set what you want to show when installing your mod

# Source module information from module.prop
name=$(grep_prop name "$MODPATH/module.prop")
version=$(grep_prop version "$MODPATH/module.prop")


##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# By default Magisk will merge your files with the original system
# Directories listed here however, will be directly mounted to the correspond directory in the system

# You don't need to remove the example below, these values will be overwritten by your own list
# This is an example
REPLACE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here, it will overwrite the example
# !DO NOT! remove this if you don't need to replace anything, leave it empty as it is now
REPLACE="
"

##########################################################################################
# Permissions
##########################################################################################

# NOTE: This part has to be adjusted to fit your own needs

set_permissions() {
	# Default permissions, don't remove them
	set_perm_recursive $MODPATH 0 0 0755 0644

	# Only some special files require specific permissions
	# The default permissions should be good enough for most cases

	# Some templates if you have no idea what to do:

	# set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
	# set_perm_recursive  $MODPATH/system/lib       0       0       0755            0644

	# set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
	# set_perm  $MODPATH/system/bin/app_process32   0       2000    0755         u:object_r:zygote_exec:s0
	# set_perm  $MODPATH/system/bin/dex2oat         0       2000    0755         u:object_r:dex2oat_exec:s0
	# set_perm  $MODPATH/system/lib/libart.so       0       0       0644
}

# check if LPA app is included in ROM
ui_print "*****************"
ui_print "$name $version"
ui_print "*****************"
if [ -d /product/priv-app/EsimLPA ] && ! echo "$MODPATH" | grep -q "/product"; then
	ui_print "LPA app is already present in the system image."
	ui_print "Using the system version."
	rm -rf "$MODPATH/system/product/priv-app/MIUIEsimLPA"
else
	ui_print "LPA app is not present in the system image."
fi


ui_print "- Granting permissions for LPA app"
appops set com.miui.euicc android:read_device_identifiers allow