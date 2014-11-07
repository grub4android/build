# cleanup targets
CLEAN_TARGETS += tracy_clean multiboot_clean
DISTCLEAN_TARGETS += tracy_distclean multiboot_distclean

# paths
TRACY_OUT = $(TARGET_COMMON_OUT)/tracy
TRACY_DIR = $(TOPDIR)external/tracy/src
MULTIBOOT_OUT = $(TARGET_COMMON_OUT)/multiboot
MULTIBOOT_DIR = $(TOPDIR)multiboot
MULTIBOOT_BOOTFS = $(MULTIBOOT_OUT)/bootfs

# create out dir
$(shell mkdir -p $(TRACY_OUT))
$(shell mkdir -p $(MULTIBOOT_OUT))
$(shell mkdir -p $(MULTIBOOT_BOOTFS))

#=============================================================================
# TRACY

# generate Makefiles
tracy_configure: $(TRACY_OUT)/Makefile
.PHONY : tracy_configure
$(TRACY_OUT)/Makefile:
	@ cd $(TRACY_OUT) && \
	STATIC_COMPILE=1 \
		cmake \
		-DCMAKE_C_COMPILER=$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)-gcc \
		-DCMAKE_CXX_COMPILER=$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)-g++ \
			$(PWD)/$(TRACY_DIR)

# main build
tracy: tracy_configure
	$(MAKE) -C $(TRACY_OUT)
.PHONY : tracy

# cleanup
tracy_clean:
	if [ -f $(TRACY_OUT)/Makefile ]; then $(MAKE) -C $(TRACY_OUT) clean; fi
.PHONY : tracy_clean

tracy_distclean:
	rm -Rf $(TRACY_OUT)/*
.PHONY : tracy_distclean


#=============================================================================
# MULTIBOOT

# generate Makefiles
multiboot_configure: $(MULTIBOOT_OUT)/Makefile
.PHONY : multiboot_configure
 $(MULTIBOOT_OUT)/Makefile:
	@ cd $(MULTIBOOT_OUT) && \
	cmake \
		-DCMAKE_C_COMPILER=$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)-gcc \
		-DCMAKE_CXX_COMPILER=$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)-g++ \
		-DTRACY_BIN_DIR=$(PWD)/$(TRACY_OUT) \
		-DTRACY_SRC_DIR=$(PWD)/$(TRACY_DIR) \
		-DBB_BIN_DIR=$(PWD)/$(BUSYBOX_OUT) \
		-DSELINUX_BIN_DIR=$(PWD)/$(SELINUX_OUT) \
		-DSELINUX_SRC_DIR=$(PWD)/$(SELINUX_DIR) \
		$(PWD)/$(MULTIBOOT_DIR)

# main build
multiboot: multiboot_configure tracy selinux busybox e2fsprogs
	$(MAKE) -C $(MULTIBOOT_OUT)
	cp $(MULTIBOOT_OUT)/init $(MULTIBOOT_BOOTFS)/
	cp $(MULTIBOOT_DIR)/prebuilt/* $(MULTIBOOT_BOOTFS)/
	cp $(BUSYBOX_OUT)/busybox $(MULTIBOOT_BOOTFS)/
	cp $(E2FSPROGS_OUT)/e2fsck/e2fsck.stripped $(MULTIBOOT_BOOTFS)/e2fsck
	cp build/devices/$(DEVICE_NAME)/fstab $(MULTIBOOT_BOOTFS)/
.PHONY : multiboot

# cleanup
multiboot_clean:
	if [ -f $(MULTIBOOT_OUT)/Makefile ]; then $(MAKE) -C $(MULTIBOOT_OUT) clean; fi
.PHONY : multiboot_clean

multiboot_distclean:
	rm -Rf $(MULTIBOOT_OUT)/*
.PHONY : multiboot_distclean
