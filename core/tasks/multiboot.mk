# cleanup targets
CLEAN_TARGETS += strace_clean libmultiboot_clean
DISTCLEAN_TARGETS += strace_distclean libmultiboot_distclean

# paths
STRACE_OUT = $(OUT_DIR)/strace
STRACE_DIR = $(TOPDIR)external/strace
LIBMULTIBOOT_OUT = $(OUT_DIR)/multiboot
LIBMULTIBOOT_DIR = $(TOPDIR)multiboot

# create out dir
$(shell mkdir -p $(STRACE_OUT))
$(shell mkdir -p $(LIBMULTIBOOT_OUT))

#=============================================================================
# STRACE

# generate Makefiles
strace_configure: $(STRACE_OUT)/Makefile
.PHONY : strace_configure
$(STRACE_OUT)/Makefile:
	@ cd $(STRACE_DIR) && \
	./bootstrap && \
	cd $(PWD)/$(STRACE_OUT) && \
	CFLAGS="-O2 -static" \
		$(PWD)/$(STRACE_DIR)/configure --host $(TOOLCHAIN_LINUX_GNUEABIHF_HOST)

# main build
strace: strace_configure
	$(MAKE) -C $(STRACE_OUT)
.PHONY : strace

# cleanup
strace_clean:
	if [ -f $(STRACE_OUT)/Makefile ]; then $(MAKE) -C $(STRACE_OUT) clean; fi
.PHONY : strace_clean

strace_distclean:
	if [ -f $(STRACE_OUT)/Makefile ]; then $(MAKE) -C $(STRACE_OUT) distclean; fi
	git -C $(STRACE_DIR)/ clean -dfX
	rm -Rf $(STRACE_OUT)/*
.PHONY : strace_distclean


#=============================================================================
# LIBMULTIBOOT

# generate Makefiles
libmultiboot_configure: $(LIBMULTIBOOT_OUT)/Makefile
.PHONY : libmultiboot_configure
 $(LIBMULTIBOOT_OUT)/Makefile:
	@ cd $(LIBMULTIBOOT_OUT) && \
	cmake \
		-DCMAKE_C_COMPILER=$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)-gcc \
		-DSTRACE_BIN_DIR=$(PWD)/$(STRACE_OUT) \
		-DSTRACE_SRC_DIR=$(PWD)/$(STRACE_DIR) \
		$(PWD)/$(LIBMULTIBOOT_DIR)

# main build
libmultiboot: libmultiboot_configure strace
	$(MAKE) -C $(LIBMULTIBOOT_OUT)
.PHONY : libmultiboot

# cleanup
libmultiboot_clean:
	if [ -f $(LIBMULTIBOOT_OUT)/Makefile ]; then $(MAKE) -C $(LIBMULTIBOOT_OUT) clean; fi
.PHONY : libmultiboot_clean

libmultiboot_distclean:
	rm -Rf $(LIBMULTIBOOT_OUT)/*
.PHONY : libmultiboot_distclean
