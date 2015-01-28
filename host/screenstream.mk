# cleanup targets
CLEAN_TARGETS += screenstream_clean
DISTCLEAN_TARGETS += screenstream_distclean

# paths
SCREENSTREAM_OUT = $(HOST_OUT)/screenstream
SCREENSTREAM_DIR = $(TOPDIR)external/screenstream

# create out dir
$(shell mkdir -p $(SCREENSTREAM_OUT))

#=============================================================================
# SCREENSTREAM

# generate Makefiles
screenstream_configure: $(SCREENSTREAM_OUT)/Makefile
.PHONY : screenstream_configure
$(SCREENSTREAM_OUT)/Makefile:
	@ cd $(SCREENSTREAM_OUT) && \
		cmake $(PWD)/$(SCREENSTREAM_DIR)

# main build
screenstream: screenstream_configure
	$(MAKE) -C $(SCREENSTREAM_OUT)
.PHONY : screenstream

# cleanup
screenstream_clean:
	if [ -f $(SCREENSTREAM_OUT)/Makefile ]; then $(MAKE) -C $(SCREENSTREAM_OUT) clean; fi
.PHONY : screenstream_clean

screenstream_distclean:
	rm -Rf $(SCREENSTREAM_OUT)/*
.PHONY : screenstream_distclean
