# cleanup targets
CLEAN_TARGETS += busybox_clean 
DISTCLEAN_TARGETS += busybox_distclean

# paths
BUSYBOX_OUT = $(OUT_DIR)/busybox
BUSYBOX_DIR = $(TOPDIR)external/busybox

# create out dir
$(shell mkdir -p $(BUSYBOX_OUT))

#=============================================================================
# BUSYBOX

BUSYBOX_CC=CROSS_COMPILE=$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)-

# generate config
$(BUSYBOX_OUT)/.config:
	cp $(CONFIG_DIR)/busybox_defconfig $(BUSYBOX_OUT)/.config
	CONFIG_STATIC=y $(BUSYBOX_CC) $(MAKE) -C $(BUSYBOX_DIR) O=$(PWD)/$(BUSYBOX_OUT) oldconfig

# main build
busybox: $(BUSYBOX_OUT)/.config
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
