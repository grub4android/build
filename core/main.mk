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

# verfiy device name
DEVICE_NAME = $(firstword $(MAKECMDGOALS))
ifeq ($(DEVICE_NAME),)
$(error No device specified.  Use "make devicename")
endif
ifeq ($(wildcard build/devices/$(DEVICE_NAME)/device.mk),)
$(error $(DEVICE_NAME) is not a valid device.)
endif

# src paths
GRUB_DIR = $(TOPDIR)grub
LK_DIR = $(TOPDIR)lk
CONFIG_DIR = $(TOPDIR)build/config
PREBUILTS_DIR = $(TOPDIR)prebuilts

# build paths
OUT_DIR = $(TOPDIR)out
TARGET_OUT = $(OUT_DIR)/$(DEVICE_NAME)
LK_OUT = $(TARGET_OUT)/lk
GRUB_OUT = $(TARGET_OUT)/grub
GRUB_BOOT_FS_DIR = $(GRUB_OUT)/rootfs

# files
FILE_GRUB_KERNEL = $(GRUB_OUT)/grub_kernel.raw
FILE_GRUB_FILEIMAGE = $(GRUB_OUT)/grub_fileimage.img
FILE_GRUB_CONFIG = $(CONFIG_DIR)/load.cfg
FILE_UBOOT_IMAGE = $(GRUB_OUT)/uboot.img

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
$(shell mkdir -p $(GRUB_OUT))

# default variables
GRUB_LOADING_ADDRESS = 0x08000000
GRUB_FONT_SIZE = 16
GRUB_COMPRESSION = cat
LK_MAKE_FLAGS =

# shell
SHELL := /bin/bash
PATH := $(PWD)/$(TOOLCHAIN_LINUX_GNUEABIHF)/bin:$(PATH)
PATH := $(PWD)/$(TOOLCHAIN_NONE_EABI)/bin:$(PATH)


#=============================================================================
# DEVICES

include $(TOPDIR)build/devices/$(DEVICE_NAME)/device.mk

ifeq ($(DEVICE_NAME),$(MAKECMDGOALS))
$(DEVICE_NAME): build
.PHONY: $(DEVICE_NAME)
else
$(DEVICE_NAME):
.PHONY: $(DEVICE_NAME)
endif


#=============================================================================
# TASKS

include $(TOPDIR)build/core/tasks/*.mk

#=============================================================================
# CLEANUP

clean: grub_clean lk_clean
.PHONY : clean

distclean: grub_distclean lk_distclean
	rm -Rf $(TARGET_OUT)/*
.PHONY : distclean
