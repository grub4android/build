GRUB_LOADING_ADDRESS = 0x8DF00000
GRUB_FONT_SIZE = 32
GRUB_COMPRESSION = xz -0

build: grub_boot_fs lk
	# tar grub fs
	rm -f $(TARGET_OUT)/grub_fs.tar
	tar -cf $(TARGET_OUT)/grub_fs.tar -C $(GRUB_BOOT_FS_DIR) .
	
	rm -f $(TARGET_OUT)/emmc_with_grubfs.img
	dd if=$(TARGET_OUT)/emmc_appsboot.mbn ibs=1M count=1 of=$(TARGET_OUT)/emmc_with_grubfs.img conv=sync
	cat $(TARGET_OUT)/grub_fs.tar >> $(TARGET_OUT)/emmc_with_grubfs.img
.PHONY : build

lk:
	$(ARM_CROSS_COMPILE) GRUB_LOADING_ADDRESS=$(GRUB_LOADING_ADDRESS) $(MAKE) -C $(LK_DIR) msm8960
	cp $(LK_DIR)/build-msm8960/emmc_appsboot.mbn $(TARGET_OUT)/
.PHONY : lk
