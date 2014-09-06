# cleanup targets
CLEAN_TARGETS += grub_clean
DISTCLEAN_TARGETS += grub_distclean

# builtin modules
GRUB_BUILTIN_MODULES = $(shell cat $(CONFIG_DIR)/modules_builtin.lst | xargs)
ifneq ($(wildcard build/devices/$(DEVICE_NAME)/modules_builtin.lst),)
GRUB_BUILTIN_MODULES += $(shell cat build/devices/$(DEVICE_NAME)/modules_builtin.lst | xargs)
endif

# device specific grub.cfg
GRUB_DEVICE_GRUB_CFG = build/devices/$(DEVICE_NAME)/grub.cfg

# generate Makefiles
grub_configure: $(GRUB_OUT)/Makefile
.PHONY : grub_configure
$(GRUB_OUT)/Makefile:
	@ cd $(GRUB_DIR) && \
	./autogen.sh && \
	cd $(PWD)/$(GRUB_OUT) && \
	$(PWD)/$(GRUB_DIR)/configure --host $(TOOLCHAIN_LINUX_GNUEABIHF_HOST)

# main kernel
grub_core: grub_configure
	$(MAKE) -C $(GRUB_OUT)
.PHONY : grub_core

# u-boot image
grub_uboot: grub_core
	qemu-arm -r 3.11 -L $(TOOLCHAIN_LINUX_GNUEABIHF_LIBC) \
		$(GRUB_OUT)/grub-mkimage -c $(FILE_GRUB_CONFIG) -O arm-uboot -o $(FILE_UBOOT_IMAGE) \
			-d $(GRUB_OUT)/grub-core -p /boot/grub -T $(GRUB_LOADING_ADDRESS) $(GRUB_BUILTIN_MODULES)
.PHONY : grub_uboot

# raw kernel
grub_kernel: grub_uboot
	tail -c+65 < $(FILE_UBOOT_IMAGE) > $(FILE_GRUB_KERNEL)
.PHONY : grub_kernel

# boot image
grub_boot_fs: grub_kernel
	# cleanup
	rm -Rf $(GRUB_BOOT_FS_DIR)/boot/grub
	rm -f /tmp/grub_font.pf2
	
	# directories
	mkdir -p $(GRUB_BOOT_FS_DIR)/boot/grub
	mkdir -p $(GRUB_BOOT_FS_DIR)/boot/grub/fonts
	mkdir -p $(GRUB_BOOT_FS_DIR)/boot/grub/locale
	
	# font
	grub-mkfont -s $(GRUB_FONT_SIZE) -o /tmp/grub_font.pf2 /usr/share/fonts/truetype/unifont/unifont.ttf
	cat /tmp/grub_font.pf2 | $(GRUB_COMPRESSION) > $(GRUB_BOOT_FS_DIR)/boot/grub/fonts/unicode.pf2
	# env
	grub-editenv $(GRUB_BOOT_FS_DIR)/boot/grub/grubenv create
	# config
	cp $(CONFIG_DIR)/grub.cfg $(GRUB_BOOT_FS_DIR)/boot/grub/
	sed -i -e '/{DEVICE_SPECIFIC_GRUB_CFG}/{r $(GRUB_DEVICE_GRUB_CFG)' -e 'd}' $(GRUB_BOOT_FS_DIR)/boot/grub/grub.cfg
	# kernel
	cp $(FILE_GRUB_KERNEL) $(GRUB_BOOT_FS_DIR)/boot/grub/core.img
.PHONY : grub_boot_fs

grub_sideload_image: grub_boot_fs
	# tar grub fs
	rm -f $(TARGET_OUT)/grub_fs.tar
	tar -cf $(TARGET_OUT)/grub_fs.tar -C $(GRUB_BOOT_FS_DIR) .
	
	# build sideload image
	mkbootimg --board "GRUB" --kernel $(FILE_GRUB_KERNEL) --ramdisk $(TARGET_OUT)/grub_fs.tar \
		--ramdisk_offset 0x2000000 \
		--pagesize 2048 --base $$(printf "0x%x" $$(($(GRUB_LOADING_ADDRESS)-0x8000))) -o $(TARGET_OUT)/grub/grub_sideload.img
.PHONY : grub_sideload_image

grub_clean:
	if [ -f $(GRUB_OUT)/Makefile ]; then $(MAKE) -C $(GRUB_OUT) clean; fi
	rm -Rf $(GRUB_TARGET_OUT)/*
.PHONY : grub_clean

grub_distclean:
	if [ -f $(GRUB_OUT)/Makefile ]; then $(MAKE) -C $(GRUB_OUT) distclean; fi
	git -C $(GRUB_DIR)/ clean -dfX
	rm -Rf $(GRUB_OUT)/*
	rm -Rf $(GRUB_TARGET_OUT)/*
.PHONY : grub_distclean
