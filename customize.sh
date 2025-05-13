SKIPUNZIP=1

# Move current to cis
mv -f "$WORK_DIR/vendor/tee" "$WORK_DIR/vendor/tee_cis"
sed -i "s./vendor/tee./vendor/tee_cis.g" "$WORK_DIR/configs/file_context-vendor"
sed -i "s.vendor/tee.vendor/tee_cis.g" "$WORK_DIR/configs/fs_config-vendor"

# Setup extraction script
# Create the placebo dir
mkdir -p "$WORK_DIR/vendor/tee"
cp -a --preserve=all "$SRC_DIR/target/a53x/patches/tee/vendor/etc/"* "$WORK_DIR/vendor/etc"
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

cp -a --preserve=all "$SRC_DIR/target/a53x/patches/tee/vendor/tee_eur" "$WORK_DIR/vendor/tee_eur"

if ! grep -q "vendor/tee_eur" "$WORK_DIR/configs/file_context-vendor"; then
    {
        echo "/vendor/tee_eur u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-000000010081 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-000000020081 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-000000534b4d u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-000048444350 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-0000534b504d u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-0050524f4341 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-0053545354ab u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-00575644524d u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-42494f535542 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-46494e474502 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-4662436b6d52 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-474154454b45 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-4b45594d5354 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-4d5053545549 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-4d704e434954 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-4d70536b566e u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-4d7073617574 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-505256544545 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-5345435f4652 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-53454d655345 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-54412d48444d u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-54496473706c u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-544974684c6c u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-564c544b5052 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-656e676d6f64 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-657365636f6d u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-6b6e78677564 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-6d706f667376 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/00000000-0000-0000-0000-6d73745f5441 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/driver u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/driver/00000000-0000-0000-0000-494363447256 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/driver/00000000-0000-0000-0000-4d53546d7374 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/driver/00000000-0000-0000-0000-53626f786476 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/driver/00000000-0000-0000-0000-564c544b4456 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/ffffffff-0000-0000-0000-000000000030 u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/tui u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/tui/resolution_common u:object_r:tee_file:s0"
        echo "/vendor/tee_eur/tui/resolution_common/ID00000100 u:object_r:tee_file:s0"
    } >> "$WORK_DIR/configs/file_context-vendor"
fi

if ! grep -q "vendor/tee_eur" "$WORK_DIR/configs/fs_config-vendor"; then
    {
        echo "vendor/tee_eur 0 2000 755 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-000000010081 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-000000020081 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-000000534b4d 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-000048444350 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-0000534b504d 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-0050524f4341 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-0053545354ab 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-00575644524d 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-42494f535542 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-46494e474502 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-4662436b6d52 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-474154454b45 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-4b45594d5354 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-4d5053545549 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-4d704e434954 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-4d70536b566e 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-4d7073617574 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-505256544545 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-5345435f4652 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-53454d655345 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-54412d48444d 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-54496473706c 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-544974684c6c 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-564c544b5052 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-656e676d6f64 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-657365636f6d 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-6b6e78677564 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-6d706f667376 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/00000000-0000-0000-0000-6d73745f5441 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/driver 0 2000 755 capabilities=0x0"
        echo "vendor/tee_eur/driver/00000000-0000-0000-0000-494363447256 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/driver/00000000-0000-0000-0000-4d53546d7374 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/driver/00000000-0000-0000-0000-53626f786476 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/driver/00000000-0000-0000-0000-564c544b4456 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/ffffffff-0000-0000-0000-000000000030 0 0 644 capabilities=0x0"
        echo "vendor/tee_eur/tui 0 2000 755 capabilities=0x0"
        echo "vendor/tee_eur/tui/resolution_common 0 2000 755 capabilities=0x0"
        echo "vendor/tee_eur/tui/resolution_common/ID00000100 0 0 644 capabilities=0x0"
    } >> "$WORK_DIR/configs/fs_config-vendor"
fi

if ! grep -q "tee_file (dir (mounton" "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"; then
    echo "(allow init_31_0 tee_file (dir (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
    echo "(allow priv_app_31_0 tee_file (dir (getattr)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
fi
