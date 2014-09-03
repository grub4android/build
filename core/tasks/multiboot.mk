# cleanup targets
CLEAN_TARGETS += strace_clean
DISTCLEAN_TARGETS += strace_distclean

# paths
STRACE_OUT = $(OUT_DIR)/strace
STRACE_DIR = $(TOPDIR)external/strace

# create out dir
$(shell mkdir -p $(STRACE_OUT))

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
