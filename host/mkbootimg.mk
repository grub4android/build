# cleanup targets
CLEAN_TARGETS += mkbootimg_clean
DISTCLEAN_TARGETS += mkbootimg_distclean

# paths
MKBOOTIMG_OUT = $(OUT_DIR)/mkbootimg
MKBOOTIMG_DIR = $(TOPDIR)external/mkbootimg

# binary
MKBOOTIMG = $(MKBOOTIMG_OUT)/mkbootimg

# create out dir
$(shell mkdir -p $(MKBOOTIMG_OUT))


#=============================================================================
# MKBOOTIMG

# generate Makefiles
mkbootimg_configure: $(MKBOOTIMG_OUT)/Makefile
.PHONY : mkbootimg_configure
 $(MKBOOTIMG_OUT)/Makefile:
	@ cd $(MKBOOTIMG_OUT) && \
		cmake $(PWD)/$(MKBOOTIMG_DIR)

# main build
mkbootimg: mkbootimg_configure
	$(MAKE) -C $(MKBOOTIMG_OUT)
.PHONY : mkbootimg

# cleanup
mkbootimg_clean:
	if [ -f $(MKBOOTIMG_OUT)/Makefile ]; then $(MAKE) -C $(MKBOOTIMG_OUT) clean; fi
.PHONY : mkbootimg_clean

mkbootimg_distclean:
	rm -Rf $(MKBOOTIMG_OUT)/*
.PHONY : mkbootimg_distclean
