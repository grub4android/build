# cleanup targets
CLEAN_TARGETS += lk_clean
DISTCLEAN_TARGETS += lk_distclean

# paths
LK_DIR = $(TOPDIR)lk
LK_OUT = $(TARGET_OUT)/lk

# create out directories
$(shell mkdir -p $(LK_OUT))

# common
LK_MAKE_FLAGS = \
	$(ARM_CROSS_COMPILE) \
	GRUB_BOOT_PARTITION=$(GRUB_BOOT_PARTITION) \
	GRUB_BOOT_PATH_PREFIX=$(GRUB_BOOT_PATH_PREFIX) \
	BUILDROOT=$(PWD)/$(LK_OUT) \
	LKFONT_HEADER=$(PWD)/$(LK_OUT)/lkfont.h

# 2ndstage
ifneq ($(ENABLE_2NDSTAGE_BOOT),)
LK_MAKE_FLAGS += \
	ENABLE_2NDSTAGE_BOOT=$(ENABLE_2NDSTAGE_BOOT)
endif

# membase
ifneq ($(LK_LOADING_ADDRESS),)
LK_MAKE_FLAGS += \
	MEMBASE=$(LK_LOADING_ADDRESS)
endif

# DT
LK_MKBOOTIMG_ADDITIONAL_FLAGS=
ifneq ($(LK_DT_IMG),)
LK_MKBOOTIMG_ADDITIONAL_FLAGS+=--dt $(LK_DT_IMG)
endif

lk_font:
	$(GRUB_TOOL_PREFIX)-mkfont -s $$(build/tools/font_inch_to_px $(DISPLAY_PPI) "0.11") \
		-o $(LK_OUT)/lkfont.pf2 --range=0x0-0x7f $(PREBUILTS_DIR)/unifont/unifont.ttf
	@ cd $(LK_OUT) && \
		xxd -i lkfont.pf2 > lkfont.h
.PHONY : lk_font

lk: lk_font
	$(LK_MAKE_FLAGS) \
		$(MAKE) -C $(LK_DIR) $(LK_TARGET_NAME)
.PHONY : lk

lk_bootimg: lk mkbootimg
	echo "#include \"$(PWD)/$(LK_OUT)/build-$(LK_TARGET_NAME)/config.h\"" > $(LK_OUT)/kernel_addr.c
	echo -e "#include <stdio.h>\nint main(void){printf(\"0x%x\", LINUX_BASE); return 0;}" >> $(LK_OUT)/kernel_addr.c
	gcc $(LK_OUT)/kernel_addr.c -o $(LK_OUT)/kernel_addr
	
	$(MKBOOTIMG)  --kernel $(LK_OUT)/build-$(LK_TARGET_NAME)/lk.bin --ramdisk /dev/zero $(LK_MKBOOTIMG_ADDITIONAL_FLAGS) \
		--pagesize 2048 --base $$(printf "0x%x" $$($(LK_OUT)/kernel_addr)) -o $(TARGET_OUT)/lkboot.img
.PHONY : lk_bootimg

lk_clean:
	$(LK_MAKE_FLAGS) \
		$(MAKE) -C $(LK_DIR) $(LK_TARGET_NAME) clean
.PHONY : lk_clean

lk_distclean: lk_clean
	rm -Rf $(LK_OUT)/*
.PHONY : lk_distclean
