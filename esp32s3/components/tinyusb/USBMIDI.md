# Why TinyUSB is vendored here

`idf.py add-dependency espressif/esp_tinyusb` is the normal route and it does
not work in this environment: the component registry is unreachable through the
agent proxy (`CONNECT tunnel failed, 403` to
`components-file.espressif.com`). GitHub IS reachable, so the upstream sources
are checked in instead.

Source: https://github.com/hathach/tinyusb , `src/` only, host mode and the
`typec` tree removed. Licence: MIT, kept verbatim in `LICENSE`.

Only the device side and only the MIDI class are compiled -- see
`CMakeLists.txt`. A narrower build is a narrower thing to be wrong about.

## What to check first if the host sees no device

1. **The socket.** The S3 has two USB paths. The console/flash socket is a
   UART bridge and CANNOT do USB MIDI. Use the OTHER one.
2. `S3L_USBMIDI=1` must be in `S3_EXTRA_DEFS`, not only `-DS3_USBMIDI=1`. The
   first is the C flag, the second selects the source file.
3. The boot log prints `USB MIDI: started` or `FAILED TO START`.

## The build trap this cost, recorded so it is not repeated

`REQUIRES` is resolved in an EARLY expansion pass where the component's own
cache variables are not reliably visible. Writing

    if(S3_USBMIDI)
        list(APPEND APP_REQ tinyusb)
    endif()

produced a `main` component with no tinyusb requirement at all, and the build
failed on a missing `tusb.h`. The requirement is unconditional now;
`--gc-sections` drops the class code when the feature is off.
