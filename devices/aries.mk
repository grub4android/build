GRUB_LOADING_ADDRESS = 0x8DF00000

aries: grub_kernel
	mkbootimg --board "GRUB" --kernel $(FILE_GRUB_KERNEL) --ramdisk /dev/zero \
		--pagesize 2048 --base $$(printf "0x%x" $$(($(GRUB_LOADING_ADDRESS)-0x8000))) -o $(BUILD_DIR)/lkboot_aries.img
.PHONY : aries
