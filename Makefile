# Default target executed when no arguments are given to make.
default_target: all
.PHONY : default_target

# paths
GRUB_DIR = ./grub
BUILD_DIR = ./build
CONFIG_DIR = ./config

# files
FILE_GRUB_KERNEL = $(BUILD_DIR)/grub_kernel.raw
FILE_GRUB_CONFIG = $(CONFIG_DIR)/load.cfg
FILE_UBOOT_IMAGE = $(BUILD_DIR)/uboot.img

# config
TOOLCHAIN_PREFIX = arm-linux-gnueabihf
GRUB_LOADING_ADDRESS = 0x08000000

#=============================================================================
# DEVICES

include devices/*.mk

#=============================================================================
# MAIN

all: $(BUILD_DIR) grub_kernel
.PHONY : all

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)


#=============================================================================
# GRUB

# generate Makefiles
grub_configure: $(GRUB_DIR)/Makefile
.PHONY : grub_configure
$(GRUB_DIR)/Makefile:
	@ cd $(GRUB_DIR) && \
	./autogen.sh && \
	./configure --host $(TOOLCHAIN_PREFIX)

# main kernel
grub_core: grub_configure
	$(MAKE) -C $(GRUB_DIR)
.PHONY : grub_core

# u-boot image
grub_uboot: grub_core
	qemu-arm -r 3.11 -L $(CROSSROOT)/$(TOOLCHAIN_PREFIX)/libc \
		$(GRUB_DIR)/grub-mkimage -c $(FILE_GRUB_CONFIG) -O arm-uboot -o $(FILE_UBOOT_IMAGE) \
			-d $(GRUB_DIR)/grub-core -p /boot/grub -T $(GRUB_LOADING_ADDRESS)
.PHONY : grub_uboot

# raw kernel
grub_kernel: grub_uboot
	tail -c+65 < $(FILE_UBOOT_IMAGE) > $(FILE_GRUB_KERNEL)
.PHONY : grub_kernel


#=============================================================================
# CLEANUP

clean:
	$(MAKE) -C $(GRUB_DIR) clean
	rm -Rf $(BUILD_DIR)
.PHONY : clean

distclean:
	$(MAKE) -C $(GRUB_DIR) distclean
.PHONY : distclean
