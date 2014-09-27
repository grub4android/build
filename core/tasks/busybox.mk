# cleanup targets
CLEAN_TARGETS += busybox_clean 
DISTCLEAN_TARGETS += busybox_distclean

# paths
BUSYBOX_OUT = $(TARGET_COMMON_OUT)/busybox
BUSYBOX_DIR = $(TOPDIR)external/busybox

# create out dir
$(shell mkdir -p $(BUSYBOX_OUT))

#=============================================================================
# BUSYBOX

BUSYBOX_CC=CROSS_COMPILE=$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)-

# generate config
busybox_defconfig:
	cp $(CONFIG_DIR)/busybox_defconfig $(BUSYBOX_OUT)/.config
	$(BUSYBOX_CC) $(MAKE) -C $(BUSYBOX_DIR) O=$(PWD)/$(BUSYBOX_OUT) oldconfig
.PHONY : busybox_defconfig

# main build
busybox: busybox_defconfig
	$(BUSYBOX_CC) $(MAKE) -C $(BUSYBOX_DIR) O=$(PWD)/$(BUSYBOX_OUT)
.PHONY : busybox

# cleanup
busybox_clean:
	$(BUSYBOX_CC) $(MAKE) -C $(BUSYBOX_DIR) O=$(PWD)/$(BUSYBOX_OUT) clean
.PHONY : busybox_clean

busybox_distclean:
	$(BUSYBOX_CC) $(MAKE) -C $(BUSYBOX_DIR) O=$(PWD)/$(BUSYBOX_OUT) distclean
	rm -Rf $(BUSYBOX_OUT)/*
.PHONY : busybox_distclean
