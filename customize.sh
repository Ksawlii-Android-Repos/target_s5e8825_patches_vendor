set -e

if [ "$TARGET_CODENAME" != "a53x" ]; then
    echo "INFO: Target codename is not a53x, skipping vendor patch"
    exit 0
fi

if [ "$SRC_DIR" ] && [ "$SRC_DIR/unica" ]; then
  UNICA="1"
  SKIPUNZIP=1
else
  echo "ERROR: UN1CA build system not detected"
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
  LATEST="$(cat $FW_DIR/SM-A536B_EUX/.extracted | cut -d'/' -f1 )"
  TARGET_MODEL=$(echo "$TARGET_FIRMWARE" | sed -E 's/^SM-([A-Z0-9]+).*/\1/')
  MODEL=$(echo "$TARGET_FIRMWARE" | sed -E 's/^SM-([A-Z0-9]+)[A-Z].*/\1/')
  FULL_MODEL=$(echo -n "$TARGET_FIRMWARE" | cut -d "/" -f 1)

  if [ "$FULL_MODEL" != "SM-A536B" ]; then
    echo "ERROR: Please use SM-A536B vendor to continue"
    exit 1
  fi

  mapfile -t BLOBS < <(
    find "$TEE_DIR" -maxdepth 1 -type d -name "${MODEL}*" -printf '%f\n' |
    grep -v "$LATEST"
  )

  # Tee stuff
  [ -d "$WORK_DIR/vendor/tee_latest" ] && rm -rf "$WORK_DIR/vendor/tee_latest"
  mv -f "$WORK_DIR/vendor/tee" "$WORK_DIR/vendor/tee_latest"
  sed -i "s./vendor/tee./vendor/tee_latest.g" "$WORK_DIR/configs/file_context-vendor"
  sed -i "s.vendor/tee.vendor/tee_latest.g" "$WORK_DIR/configs/fs_config-vendor"
  mkdir -p "$WORK_DIR/vendor/tee"
  [ -f "$WORK_DIR/vendor/etc/init/tee_blobs.rc" ] && rm -f "$WORK_DIR/vendor/etc/init/tee_blobs.rc" 

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

  for t in "${BLOBS[@]}"; do
    [ -d "$WORK_DIR/vendor/tee_$t" ] && rm -rf "$WORK_DIR/vendor/tee_$t"
    cp -fa --preserve=all "$SRC_DIR/target/$D/patches/vendor/tee/$t" "$WORK_DIR/vendor/tee_$t"

    VARIANT=$(echo "$t" | sed -E 's/^([A-Z0-9]{5}).*/\1/') 

    if [ "$VARIANT" = "A536B" ]; then
      OPEN="eur"
    elif [ "$VARIANT" = "A536E" ]; then
      OPEN="cis"
    fi

    {
      echo "on early-fs && property:ro.boot.em.model=SM-$VARIANT && property:ro.boot.bootloader=$t"
      echo "mount none /vendor/tee_$t /vendor/tee bind"
      echo "mount none /vendor/firmware/$OPEN/AP_AUDIO_SLSI.bin /vendor/firmware/AP_AUDIO_SLSI.bin bind"
      echo "mount none /vendor/firmware/$OPEN/APDV_AUDIO_SLSI.bin /vendor/firmware/APDV_AUDIO_SLSI.bin bind"
      echo "mount none /vendor/firmware/$OPEN/calliope_sram.bin /vendor/firmware/calliope_sram.bin bind"
      echo "mount none /vendor/firmware/$OPEN/mfc_fw.bin /vendor/firmware/mfc_fw.bin bind"
      echo "mount none /vendor/firmware/$OPEN/NPU.bin /vendor/firmware/NPU.bin bind"
      echo "mount none /vendor/firmware/$OPEN/os.checked.bin /vendor/firmware/os.checked.bin bind"
      echo "mount none /vendor/firmware/$OPEN/vts.bin /vendor/firmware/vts.bin bind"
    } >> "$WORK_DIR/vendor/etc/init/tee_blobs.rc"

    if ! grep -q "vendor/tee_$t" "$WORK_DIR/configs/file_context-vendor"; then
      {
        echo "/vendor/tee_$t u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-000000010081 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-000000020081 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-000000534b4d u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-000048444350 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-0000534b504d u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-0050524f4341 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-0053545354ab u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-00575644524d u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-42494f535542 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-46494e474502 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-4662436b6d52 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-474154454b45 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-4b45594d5354 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-4d5053545549 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-4d704e434954 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-4d70536b566e u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-4d7073617574 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-505256544545 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-5345435f4652 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-54412d48444d u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-54496473706c u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-544974684c6c u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-564c544b5052 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-656e676d6f64 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-657365636f6d u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-6b6e78677564 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-6d706f667376 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/00000000-0000-0000-0000-6d73745f5441 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/driver u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/driver/00000000-0000-0000-0000-494363447256 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/driver/00000000-0000-0000-0000-4d53546d7374 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/driver/00000000-0000-0000-0000-53626f786476 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/driver/00000000-0000-0000-0000-564c544b4456 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/ffffffff-0000-0000-0000-000000000030 u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/tui u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/tui/resolution_common u:object_r:tee_file:s0"
        echo "/vendor/tee_$t/tui/resolution_common/ID00000100 u:object_r:tee_file:s0"
      } >> "$WORK_DIR/configs/file_context-vendor"
    fi

    if [ "$VARIANT" = "A536B" ]; then
      if ! grep -q "vendor/tee_$t/00000000-0000-0000-0000-53454d655345" "$WORK_DIR/configs/file_context-vendor"; then
        echo "/vendor/tee_$t/00000000-0000-0000-0000-53454d655345 u:object_r:tee_file:s0" >> "$WORK_DIR/configs/file_context-vendor"
      fi
    elif [ "$VARIANT" = "A536E" ]; then
      if ! grep -q "vendor/tee_$t/00000000-0000-0000-0000-544545535355" "$WORK_DIR/configs/file_context-vendor"; then
        echo "/vendor/tee_$t/00000000-0000-0000-0000-544545535355 u:object_r:tee_file:s0" >> "$WORK_DIR/configs/file_context-vendor"
      fi
    fi

    if ! grep -q "vendor/tee_$t" "$WORK_DIR/configs/fs_config-vendor"; then
      {
        echo "vendor/tee_$t 0 2000 755 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-000000010081 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-000000020081 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-000000534b4d 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-000048444350 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-0000534b504d 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-0050524f4341 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-0053545354ab 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-00575644524d 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-42494f535542 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-46494e474502 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-4662436b6d52 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-474154454b45 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-4b45594d5354 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-4d5053545549 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-4d704e434954 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-4d70536b566e 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-4d7073617574 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-505256544545 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-5345435f4652 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-54412d48444d 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-54496473706c 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-544974684c6c 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-564c544b5052 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-656e676d6f64 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-657365636f6d 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-6b6e78677564 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-6d706f667376 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/00000000-0000-0000-0000-6d73745f5441 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/driver 0 2000 755 capabilities=0x0"
        echo "vendor/tee_$t/driver/00000000-0000-0000-0000-494363447256 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/driver/00000000-0000-0000-0000-4d53546d7374 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/driver/00000000-0000-0000-0000-53626f786476 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/driver/00000000-0000-0000-0000-564c544b4456 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/ffffffff-0000-0000-0000-000000000030 0 0 644 capabilities=0x0"
        echo "vendor/tee_$t/tui 0 2000 755 capabilities=0x0"
        echo "vendor/tee_$t/tui/resolution_common 0 2000 755 capabilities=0x0"
        echo "vendor/tee_$t/tui/resolution_common/ID00000100 0 0 644 capabilities=0x0"
      } >> "$WORK_DIR/configs/fs_config-vendor"
    fi

    if [ "$VARIANT" = "A536B" ]; then
      if ! grep -q "vendor/tee_$t/00000000-0000-0000-0000-53454d655345" "$WORK_DIR/configs/fs_config-vendor"; then
        echo "vendor/tee_$t/00000000-0000-0000-0000-53454d655345 0 0 644 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-vendor"
      fi
    elif [ "$VARIANT" = "A536E" ]; then
      if ! grep -q "vendor/tee_$t/00000000-0000-0000-0000-544545535355" "$WORK_DIR/configs/fs_config-vendor"; then
        echo "vendor/tee_$t/00000000-0000-0000-0000-544545535355 0 0 644 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-vendor"
      fi 
    fi
  done

  # Firmware stuff
  mkdir -p "$WORK_DIR/vendor/firmware/eur"
  mv -f "$WORK_DIR/vendor/firmware/AP_AUDIO_SLSI.bin" "$WORK_DIR/vendor/firmware/eur/AP_AUDIO_SLSI.bin"
  mv -f "$WORK_DIR/vendor/firmware/APDV_AUDIO_SLSI.bin" "$WORK_DIR/vendor/firmware/eur/APDV_AUDIO_SLSI.bin"
  mv -f "$WORK_DIR/vendor/firmware/calliope_sram.bin" "$WORK_DIR/vendor/firmware/eur/calliope_sram.bin"
  mv -f "$WORK_DIR/vendor/firmware/mfc_fw.bin" "$WORK_DIR/vendor/firmware/eur/mfc_fw.bin"
  mv -f "$WORK_DIR/vendor/firmware/os.checked.bin" "$WORK_DIR/vendor/firmware/eur/os.checked.bin"
  mv -f "$WORK_DIR/vendor/firmware/NPU.bin" "$WORK_DIR/vendor/firmware/eur/NPU.bin"
  mv -f "$WORK_DIR/vendor/firmware/vts.bin" "$WORK_DIR/vendor/firmware/eur/vts.bin"
  touch "$WORK_DIR/vendor/firmware/AP_AUDIO_SLSI.bin"
  touch "$WORK_DIR/vendor/firmware/APDV_AUDIO_SLSI.bin"
  touch "$WORK_DIR/vendor/firmware/calliope_sram.bin"
  touch "$WORK_DIR/vendor/firmware/mfc_fw.bin"
  touch "$WORK_DIR/vendor/firmware/os.checked.bin"
  touch "$WORK_DIR/vendor/firmware/NPU.bin"
  touch "$WORK_DIR/vendor/firmware/vts.bin"
  [ -d "$WORK_DIR/vendor/firmware/cis" ] && rm -rf "$WORK_DIR/vendor/firmware/cis" && mkdir -p "$WORK_DIR/vendor/firmware/cis"
  cp -a --preserve=all "$SRC_DIR/target/$D/patches/vendor/firmware/cis" "$WORK_DIR/vendor/firmware/cis"

  if ! grep -q "vendor/firmware/eur" "$WORK_DIR/configs/file_context-vendor"; then
    {
      echo "/vendor/firmware/eur u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/eur/AP_AUDIO_SLSI\.bin u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/eur/APDV_AUDIO_SLSI\.bin u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/eur/calliope_sram\.bin u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/eur/mfc_fw\.bin u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/eur/NPU\.bin u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/eur/os.checked\.bin u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/eur/vts\.bin u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/cis u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/cis/AP_AUDIO_SLSI\.bin u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/cis/APDV_AUDIO_SLSI\.bin u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/cis/calliope_sram\.bin u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/cis/mfc_fw\.bin u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/cis/NPU\.bin u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/cis/os.checked\.bin u:object_r:vendor_fw_file:s0"
      echo "/vendor/firmware/cis/vts\.bin u:object_r:vendor_fw_file:s0"
    } >> "$WORK_DIR/configs/file_context-vendor"
  fi

  if ! grep -q "vendor/firmware/eur" "$WORK_DIR/configs/fs_config-vendor"; then
    {
      echo "vendor/firmware/eur 0 2000 755 capabilities=0x0"
      echo "vendor/firmware/eur/AP_AUDIO_SLSI.bin 0 0 644 capabilities=0x0"
      echo "vendor/firmware/eur/APDV_AUDIO_SLSI.bin 0 0 644 capabilities=0x0"
      echo "vendor/firmware/eur/calliope_sram.bin 0 0 644 capabilities=0x0"
      echo "vendor/firmware/eur/mfc_fw.bin 0 0 644 capabilities=0x0"
      echo "vendor/firmware/eur/NPU.bin 0 0 644 capabilities=0x0"
      echo "vendor/firmware/eur/os.checked.bin 0 0 644 capabilities=0x0"
      echo "vendor/firmware/eur/vts.bin 0 0 644 capabilities=0x0"
      echo "vendor/firmware/cis 0 2000 755 capabilities=0x0"
      echo "vendor/firmware/cis/AP_AUDIO_SLSI.bin 0 0 644 capabilities=0x0"
      echo "vendor/firmware/cis/APDV_AUDIO_SLSI.bin 0 0 644 capabilities=0x0"
      echo "vendor/firmware/cis/calliope_sram.bin 0 0 644 capabilities=0x0"
      echo "vendor/firmware/cis/mfc_fw.bin 0 0 644 capabilities=0x0"
      echo "vendor/firmware/cis/NPU.bin 0 0 644 capabilities=0x0"
      echo "vendor/firmware/cis/os.checked.bin 0 0 644 capabilities=0x0"
      echo "vendor/firmware/cis/vts.bin 0 0 644 capabilities=0x0"
    } >> "$WORK_DIR/configs/fs_config-vendor"
  fi

  # Tee/Firmware
  {
    echo "on early-fs && property:ro.boot.em.model=$FULL_MODEL && property:ro.boot.bootloader=$LATEST"
    echo "mount none /vendor/tee_latest /vendor/tee bind"
    echo "mount none /vendor/firmware/eur/AP_AUDIO_SLSI.bin /vendor/firmware/AP_AUDIO_SLSI.bin bind"
    echo "mount none /vendor/firmware/eur/APDV_AUDIO_SLSI.bin /vendor/firmware/APDV_AUDIO_SLSI.bin bind"
    echo "mount none /vendor/firmware/eur/calliope_sram.bin /vendor/firmware/calliope_sram.bin bind"
    echo "mount none /vendor/firmware/eur/mfc_fw.bin /vendor/firmware/mfc_fw.bin bind"
    echo "mount none /vendor/firmware/eur/NPU.bin /vendor/firmware/NPU.bin bind"
    echo "mount none /vendor/firmware/eur/os.checked.bin /vendor/firmware/os.checked.bin bind"
    echo "mount none /vendor/firmware/eur/vts.bin /vendor/firmware/vts.bin bind"
  } >> "$WORK_DIR/vendor/etc/init/tee_blobs.rc"

  # Sepolicy
  if ! grep -q "tee_file (dir (mounton" "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"; then
    echo "(allow init_31_0 tee_file (dir (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow priv_app_31_0 tee_file (dir (getattr)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow init_31_0 vendor_fw_file (file (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow priv_app_31_0 vendor_fw_file (file (getattr)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
  fi
fi
