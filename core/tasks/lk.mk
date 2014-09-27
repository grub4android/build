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
	GRUB_LOADING_ADDRESS=$(GRUB_LOADING_ADDRESS) \
	GRUB_BOOT_PARTITION=$(GRUB_BOOT_PARTITION) \
	GRUB_BOOT_PATH_PREFIX=$(GRUB_BOOT_PATH_PREFIX) \
	BOOTLOADER_OUT=$(PWD)/$(LK_OUT)

# 2ndstage
ifneq ($(ENABLE_2NDSTAGE_BOOT),)
LK_MAKE_FLAGS += \
	ENABLE_2NDSTAGE_BOOT=$(ENABLE_2NDSTAGE_BOOT) \
	DISPLAY_2NDSTAGE_WIDTH=$(DISPLAY_WIDTH) \
	DISPLAY_2NDSTAGE_HEIGHT=$(DISPLAY_HEIGHT) \
	DISPLAY_2NDSTAGE_BPP=$(DISPLAY_BPP)

ifneq ($(DISPLAY_FBADDR),)
LK_MAKE_FLAGS += \
	DISPLAY_2NDSTAGE_FBADDR=$(DISPLAY_FBADDR)
endif

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

lk:
	$(LK_MAKE_FLAGS) \
		$(MAKE) -C $(LK_DIR) $(LK_TARGET_NAME)
.PHONY : lk

lk_bootimg: lk mkbootimg
	$(MKBOOTIMG)  --kernel $(LK_OUT)/build-$(LK_TARGET_NAME)/lk.bin --ramdisk /dev/zero $(LK_MKBOOTIMG_ADDITIONAL_FLAGS) \
		--pagesize 2048 --base $$(printf "0x%x" $$(($(LK_LOADING_ADDRESS)-0x8000))) -o $(TARGET_OUT)/lkboot.img
.PHONY : lk_bootimg

lk_clean:
	$(LK_MAKE_FLAGS) \
		$(MAKE) -C $(LK_DIR) $(LK_TARGET_NAME) clean
.PHONY : lk_clean

lk_distclean: lk_clean
	rm -Rf $(LK_OUT)/*
.PHONY : lk_distclean
