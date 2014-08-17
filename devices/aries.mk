GRUB_LOADING_ADDRESS = 0x8DF00000

build: lk grub_kernel
	mkbootimg --board "GRUB" --kernel $(FILE_GRUB_KERNEL) --ramdisk /dev/zero \
		--pagesize 2048 --base $$(printf "0x%x" $$(($(GRUB_LOADING_ADDRESS)-0x8000))) -o $(TARGET_OUT)/grub_sideload.img
.PHONY : build

lk:
	$(ARM_CROSS_COMPILE) $(MAKE) -C $(LK_DIR) msm8960
	cp $(LK_DIR)/build-msm8960/emmc_appsboot.mbn $(TARGET_OUT)/
.PHONY : lk
