# Xiaomi eSIM LPA

A KernelSU Next module trying to add native eSIM management support for Xiaomi devices with MIUI and Xiaomi HyperOS, made for devices with removable eSIM chips (such as 5ber or eSIM.me) or built-in eSIM chips, but running ROM variants (CN) that lack eSIM support.

![screenshot](https://github.com/user-attachments/assets/6065297c-ea7d-4b3b-ba03-9b6462a29186)

> [!NOTE]
> 5ber Ultra is not supported, use Standard or Premium instead(both using the same hardware).

## Tested devices

- diting (Xiaomi 12T Pro/Redmi K50 Ultra)
- marble (Redmi Note 12 Turbo/POCO F5 5G)
- houji (Xiaomi 14)
- fuxi (Xiaomi 13)
- socrates (Redmi K60 Pro)

## Native mounting

Requires KernelSU Next and kernel OverlayFS support. Install in its Manager
and reboot. No Magic Mount or mounting metamodule is required. `skip_mount`
and a `files/` payload keep external mounters out. The blocking early boot
script merges permissions and, when needed, the bundled privileged APK into
product using read-only OverlayFS mounts with source `KSU`. Stock files remain
visible. Errors go to `native-overlay.log`; partial mounts roll back. Disable
or uninstall and reboot to return to stock. Properties and the existing
post-boot app-op grant are handled through KernelSU's normal module hooks.

Payloads are staged in private tmpfs mounts before OverlayFS mounting, so
F2FS or encrypted `/data` need not support OverlayFS lower layers. These RAM
copies and all overlays disappear on reboot.

Run `tests/test-native-overlay.sh` as root on Android for isolated mount
regression tests (merge, replacement, read-only behavior, repeat execution and
rollback). It creates a private mount namespace and touches no active modules.
