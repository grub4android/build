# cleanup targets
CLEAN_TARGETS += e2fsprogs_clean
DISTCLEAN_TARGETS += e2fsprogs_distclean

# paths
E2FSPROGS_OUT = $(TARGET_COMMON_OUT)/e2fsprogs
E2FSPROGS_DIR = $(TOPDIR)external/e2fsprogs

# create out dir
$(shell mkdir -p $(E2FSPROGS_OUT))

#=============================================================================
# E2FSPROGS

# generate Makefiles
e2fsprogs_configure: $(E2FSPROGS_OUT)/Makefile
.PHONY : e2fsprogs_configure
$(E2FSPROGS_OUT)/Makefile:
	@ cd $(E2FSPROGS_OUT) && \
		LDFLAGS=-static \
		$(PWD)/$(E2FSPROGS_DIR)/configure --host $(TOOLCHAIN_LINUX_GNUEABIHF_HOST) --disable-elf-shlibs

# main build
e2fsprogs: e2fsprogs_configure
	$(MAKE) -C $(E2FSPROGS_OUT)
	$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)-strip -o $(E2FSPROGS_OUT)/e2fsck/e2fsck.stripped $(E2FSPROGS_OUT)/e2fsck/e2fsck
	$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)-strip -o $(E2FSPROGS_OUT)/misc/mke2fs.stripped $(E2FSPROGS_OUT)/misc/mke2fs
.PHONY : e2fsprogs

# cleanup
e2fsprogs_clean:
	if [ -f $(E2FSPROGS_OUT)/Makefile ]; then $(MAKE) -C $(E2FSPROGS_OUT) clean; fi
.PHONY : e2fsprogs_clean

e2fsprogs_distclean:
	if [ -f $(E2FSPROGS_OUT)/Makefile ]; then $(MAKE) -C $(E2FSPROGS_OUT) distclean; fi
	rm -Rf $(E2FSPROGS_OUT)/*
.PHONY : e2fsprogs_distclean
