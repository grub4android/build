# cleanup targets
CLEAN_TARGETS += fastboot_clean
DISTCLEAN_TARGETS += fastboot_distclean

# paths
FASTBOOT_OUT = $(HOST_OUT)/fastboot
FASTBOOT_DIR = $(TOPDIR)external/fastboot

# binary
FASTBOOT = $(FASTBOOT_OUT)/fastboot

# create out dir
$(shell mkdir -p $(FASTBOOT_OUT))


#=============================================================================
# FASTBOOT

# generate Makefiles
fastboot_configure: $(FASTBOOT_OUT)/Makefile
.PHONY : fastboot_configure
 $(FASTBOOT_OUT)/Makefile:
	@ cd $(FASTBOOT_OUT) && \
		cmake $(PWD)/$(FASTBOOT_DIR)

# main build
fastboot: fastboot_configure
	$(MAKE) -C $(FASTBOOT_OUT)
.PHONY : fastboot

# cleanup
fastboot_clean:
	if [ -f $(FASTBOOT_OUT)/Makefile ]; then $(MAKE) -C $(FASTBOOT_OUT) clean; fi
.PHONY : fastboot_clean

fastboot_distclean:
	rm -Rf $(FASTBOOT_OUT)/*
.PHONY : fastboot_distclean
