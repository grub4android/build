#=============================================================================
# BASIC ENVIRONMENT SETUP

# this turns off the suffix rules built into make
.SUFFIXES:

# this turns off the RCS / SCCS implicit rules of GNU Make
% : RCS/%,v
% : RCS/%
% : %,v
% : s.%
% : SCCS/s.%

# If a rule fails, delete $@.
.DELETE_ON_ERROR:

# Absolute path of the present working direcotry.
# This overrides the shell variable $PWD, which does not necessarily points to
# the top of the source tree, for example when "make -C" is used in m/mm/mmm.
PWD := $(shell pwd)

TOP := .
TOPDIR :=

BUILD_SYSTEM := $(TOPDIR)build/core

# This is the default target.  It must be the first declared target.
.PHONY: all
DEFAULT_GOAL := all
$(DEFAULT_GOAL):

# paths
GRUB_DIR = $(TOPDIR)grub
LK_DIR = $(TOPDIR)lk
OUT_DIR = $(TOPDIR)out
CONFIG_DIR = $(TOPDIR)build/config
PREBUILTS_DIR = $(TOPDIR)prebuilts
TARGET_OUT = $(OUT_DIR)/$(firstword $(MAKECMDGOALS))

# files
FILE_GRUB_KERNEL = $(OUT_DIR)/grub_kernel.raw
FILE_GRUB_CONFIG = $(CONFIG_DIR)/load.cfg
FILE_UBOOT_IMAGE = $(OUT_DIR)/uboot.img

# toolchain
TOOLCHAIN_LINUX_GNUEABIHF = $(PREBUILTS_DIR)/gcc/linux-x86/arm/arm-linux-gnueabihf-4.9
TOOLCHAIN_LINUX_GNUEABIHF_HOST = arm-linux-gnueabihf
TOOLCHAIN_LINUX_GNUEABIHF_LIBC = $(TOOLCHAIN_LINUX_GNUEABIHF)/$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)/libc

TOOLCHAIN_NONE_EABI = $(PREBUILTS_DIR)/gcc/linux-x86/arm/arm-none-eabi-4.9
TOOLCHAIN_NONE_EABI_PREFIX = arm-none-eabi-
ARM_CROSS_COMPILE = ARCH=arm SUBARCH=arm CROSS_COMPILE=$(TOOLCHAIN_NONE_EABI_PREFIX) TOOLCHAIN_PREFIX=$$CROSS_COMPILE

# create OUT_DIR
$(shell mkdir -p $(OUT_DIR))
$(shell mkdir -p $(TARGET_OUT))

# default variables
GRUB_LOADING_ADDRESS = 0x08000000

# shell
SHELL := /bin/bash
PATH := $(PWD)/$(TOOLCHAIN_LINUX_GNUEABIHF)/bin:$(PATH)
PATH := $(PWD)/$(TOOLCHAIN_NONE_EABI)/bin:$(PATH)


#=============================================================================
# DEVICES

include $(TOPDIR)build/devices/*.mk


#=============================================================================
# GRUB

# generate Makefiles
grub_configure: $(GRUB_DIR)/Makefile
.PHONY : grub_configure
$(GRUB_DIR)/Makefile:
	@ cd $(GRUB_DIR) && \
	./autogen.sh && \
	./configure --host $(TOOLCHAIN_LINUX_GNUEABIHF_HOST)

# main kernel
grub_core: grub_configure
	$(MAKE) -C $(GRUB_DIR)
.PHONY : grub_core

# u-boot image
grub_uboot: grub_core
	qemu-arm -r 3.11 -L $(TOOLCHAIN_LINUX_GNUEABIHF_LIBC) \
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
	rm -Rf $(OUT_DIR)/*
	rm -Rf $(LK_DIR)/build-*
	$(MAKE) -C $(GRUB_DIR) clean
.PHONY : clean

distclean: clean
	$(MAKE) -C $(GRUB_DIR) distclean
.PHONY : distclean
