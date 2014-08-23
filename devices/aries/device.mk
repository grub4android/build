GRUB_LOADING_ADDRESS = 0x8DF00000
GRUB_FONT_SIZE = 32
GRUB_BOOT_PARTITION = "storage"

build: grub_boot_fs lk
.PHONY : build

lk:
	$(ARM_CROSS_COMPILE) \
		GRUB_LOADING_ADDRESS=$(GRUB_LOADING_ADDRESS) \
		GRUB_BOOT_PARTITION=$(GRUB_BOOT_PARTITION) \
		$(MAKE) -C $(LK_DIR) msm8960
	cp $(LK_DIR)/build-msm8960/emmc_appsboot.mbn $(TARGET_OUT)/
.PHONY : lk
