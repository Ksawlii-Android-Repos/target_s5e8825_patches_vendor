set -e

if [ "$SRC_DIR" ] && [ "$SRC_DIR/unica" ]; then
  UNICA="1"
  SKIPUNZIP=1
else
  UNICA="0"
fi

if [ -z "$1" ] && [ -z "$2" ] && [ "$UNICA" != "1" ]; then
  echo "Usage: $0 [model] [vendor_dir] [mods_dir]"
  echo "Example: $0 A536B ../vendor /home/ksawlii/vendor_mods"
  exit 1
fi

# For UNICA
if [ "$UNICA" = "1" ]; then
  if [ "$TARGET_UNIFIED_NAME" != "false" ]; then
    D="$TARGET_UNIFIED_NAME"
  else
    D="$TARGET_CODENAME"
  fi
  TEE_DIR="$SRC_DIR/target/$D/patches/vendor/tee"
  LATEST="$(cat $SRC_DIR/target/$D/patches/tee/.latest)"

  mv -f "$WORK_DIR/vendor/tee" "$WORK_DIR/vendor/tee_latest"
  sed -i "s./vendor/tee./vendor/tee_latest.g" "$WORK_DIR/configs/file_context-vendor"
  sed -i "s.vendor/tee.vendor/tee_latest.g" "$WORK_DIR/configs/fs_config-vendor"
  mkdir -p "$WORK_DIR/vendor/tee"

  if [ -f "$VENDOR/etc/init/tee_blobs.rc" ]; then
    rm -f "$VENDOR/etc/init/tee_blobs.rc" 
  fi

  if ! grep -q "tee_blobs" "$WORK_DIR/configs/file_context-vendor"; then
    {
      echo "/vendor/etc/init/tee_blobs\.rc u:object_r:vendor_configs_file:s0"
      echo "/vendor/tee u:object_r:tee_file:s0"
    } >> "$WORK_DIR/configs/file_context-vendor"
  fi

  if ! grep -q "tee_blobs" "$WORK_DIR/configs/fs_config-vendor"; then
    {
      echo "vendor/etc/init/tee_blobs.rc 0 0 644 capabilities=0x0"
      echo "vendor/tee 0 2000 755 capabilities=0x0"
    } >> "$WORK_DIR/configs/fs_config-vendor"
  fi

  MODEL=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 1)
  mapfile -t BLOBS < <(find "$TEE_DIR" -maxdepth 1 -type d -name "${MODEL}*" -printf '%f\n')

  for t in "${BLOBS[@]}"; do
    cp -fa --preserve=all "$SRC_DIR/target/$D/patches/vendor/tee/$t" "$WORK_DIR/vendor/"

    echo "on early-fs && property:ro.boot.em.model=$MODEL && property:ro.boot.bootloader=$t" >> "$WORK_DIR/vendor/etc/init/tee_blobs.rc"
    echo "mount none /vendor/$t /vendor/tee bind" >> "$WORK_DIR/vendor/etc/init/tee_blobs.rc"

    if ! grep -q "vendor/$t" "$WORK_DIR/configs/file_context-vendor"; then
      {
        echo "/vendor/$t u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-000000010081 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-000000020081 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-000000534b4d u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-000048444350 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-0000534b504d u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-0050524f4341 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-0053545354ab u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-00575644524d u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-42494f535542 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-46494e474502 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-4662436b6d52 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-474154454b45 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-4b45594d5354 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-4d5053545549 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-4d704e434954 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-4d70536b566e u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-4d7073617574 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-505256544545 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-5345435f4652 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-53454d655345 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-54412d48444d u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-54496473706c u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-544974684c6c u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-564c544b5052 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-656e676d6f64 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-657365636f6d u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-6b6e78677564 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-6d706f667376 u:object_r:tee_file:s0"
        echo "/vendor/$t/00000000-0000-0000-0000-6d73745f5441 u:object_r:tee_file:s0"
        echo "/vendor/$t/driver u:object_r:tee_file:s0"
        echo "/vendor/$t/driver/00000000-0000-0000-0000-494363447256 u:object_r:tee_file:s0"
        echo "/vendor/$t/driver/00000000-0000-0000-0000-4d53546d7374 u:object_r:tee_file:s0"
        echo "/vendor/$t/driver/00000000-0000-0000-0000-53626f786476 u:object_r:tee_file:s0"
        echo "/vendor/$t/driver/00000000-0000-0000-0000-564c544b4456 u:object_r:tee_file:s0"
        echo "/vendor/$t/ffffffff-0000-0000-0000-000000000030 u:object_r:tee_file:s0"
        echo "/vendor/$t/tui u:object_r:tee_file:s0"
        echo "/vendor/$t/tui/resolution_common u:object_r:tee_file:s0"
        echo "/vendor/$t/tui/resolution_common/ID00000100 u:object_r:tee_file:s0"
      } >> "$WORK_DIR/configs/file_context-vendor"
    fi

    if ! grep -q "vendor/$t" "$WORK_DIR/configs/fs_config-vendor"; then
      {
        echo "vendor/$t 0 2000 755 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-000000010081 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-000000020081 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-000000534b4d 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-000048444350 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-0000534b504d 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-0050524f4341 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-0053545354ab 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-00575644524d 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-42494f535542 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-46494e474502 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-4662436b6d52 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-474154454b45 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-4b45594d5354 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-4d5053545549 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-4d704e434954 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-4d70536b566e 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-4d7073617574 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-505256544545 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-5345435f4652 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-53454d655345 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-54412d48444d 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-54496473706c 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-544974684c6c 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-564c544b5052 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-656e676d6f64 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-657365636f6d 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-6b6e78677564 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-6d706f667376 0 0 644 capabilities=0x0"
        echo "vendor/$t/00000000-0000-0000-0000-6d73745f5441 0 0 644 capabilities=0x0"
        echo "vendor/$t/driver 0 2000 755 capabilities=0x0"
        echo "vendor/$t/driver/00000000-0000-0000-0000-494363447256 0 0 644 capabilities=0x0"
        echo "vendor/$t/driver/00000000-0000-0000-0000-4d53546d7374 0 0 644 capabilities=0x0"
        echo "vendor/$t/driver/00000000-0000-0000-0000-53626f786476 0 0 644 capabilities=0x0"
        echo "vendor/$t/driver/00000000-0000-0000-0000-564c544b4456 0 0 644 capabilities=0x0"
        echo "vendor/$t/ffffffff-0000-0000-0000-000000000030 0 0 644 capabilities=0x0"
        echo "vendor/$t/tui 0 2000 755 capabilities=0x0"
        echo "vendor/$t/tui/resolution_common 0 2000 755 capabilities=0x0"
        echo "vendor/$t/tui/resolution_common/ID00000100 0 0 644 capabilities=0x0"
      } >> "$WORK_DIR/configs/fs_config-vendor"
    fi
  done

    echo "on early-fs && property:ro.boot.em.model=$MODEL && property:ro.boot.bootloader=$LATEST" >> "$WORK_DIR/vendor/etc/init/tee_blobs.rc"
    echo "mount none /vendor/tee_latest /vendor/tee bind" >> "$WORK_DIR/vendor/etc/init/tee_blobs.rc"
  
  if ! grep -q "tee_file (dir (mounton" "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"; then
      echo "(allow init_31_0 tee_file (dir (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
      echo "(allow priv_app_31_0 tee_file (dir (getattr)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
  fi

  cp -fa --preserve=all "$SRC_DIR/target/$D/patches/vendor/libs/lib/libtinyalsa.so" "$WORK_DIR/vendor/lib/vndk/libtinyalsa.so"
  cp -fa --preserve=all "$SRC_DIR/target/$D/patches/vendor/libs/lib64/libtinyalsa.so" "$WORK_DIR/vendor/lib64/vndk/libtinyalsa.so"
fi

# For MIO or some other kitchen
if [ "$UNICA" = "0" ]; then
  MODEL="$1"
  VENDOR="$2"
  MODS_DIR="$3"    
  LATEST="$(cat $MODS_DIR/.latest)"

  mv -f "$VENDOR/tee" "$VENDOR/tee_latest"
  mkdir -p "$VENDOR/tee"

  [ -f "$VENDOR/etc/init/tee_blobs.rc" ] && rm -f "$VENDOR/etc/init/tee_blobs.rc" 
  
  mapfile -t BLOBS < <(find "$MODS_DIR" -maxdepth 1 -type d -name "${MODEL}*" -printf '%f\n')
 
  for t in "${BLOBS[@]}"; do
    [ -d "$VENDOR/tee_$t" ]
    echo "Copying $t"
    cp -fa --preserve=all "$MODS_DIR/tee/$t" "$VENDOR/tee_$t"

    echo "on early-fs && property:ro.boot.em.model=$MODEL && property:ro.boot.bootloader=$t" >> "$VENDOR/etc/init/tee_blobs.rc"
    echo "mount none /vendor/tee_$t /vendor/tee bind" >> "$VENDOR/etc/init/tee_blobs.rc"
  done

  echo "on early-fs && property:ro.boot.em.model=$MODEL && property:ro.boot.bootloader=$LATEST" >> "$VENDOR/etc/init/tee_blobs.rc"
  echo "mount none /vendor/tee_latest /vendor/tee bind" >> "$VENDOR/etc/init/tee_blobs.rc"
  
  if ! grep -q "tee_file (dir (mounton" "$VENDOR/etc/selinux/vendor_sepolicy.cil"; then
      echo "(allow init_31_0 tee_file (dir (mounton)))" >> "$VENDOR/etc/selinux/vendor_sepolicy.cil"
      echo "(allow priv_app_31_0 tee_file (dir (getattr)))" >> "$VENDOR/etc/selinux/vendor_sepolicy.cil"
  fi

  cp -fa --preserve=all "$SRC_DIR/target/$D/patches/vendor/libs/lib/libtinyalsa.so" "$WORK_DIR/vendor/lib/vndk/libtinyalsa.so"
  cp -fa --preserve=all "$SRC_DIR/target/$D/patches/vendor/libs/lib64/libtinyalsa.so" "$WORK_DIR/vendor/lib64/vndk/libtinyalsa.so"
fi
