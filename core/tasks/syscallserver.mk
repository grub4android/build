# cleanup targets
CLEAN_TARGETS += syscallserver_clean
DISTCLEAN_TARGETS += syscallserver_distclean

# paths
SYSCALLSERVER_OUT = $(TARGET_COMMON_OUT)/syscallserver
SYSCALLSERVER_DIR = $(TOPDIR)external/syscallserver

# create out dir
$(shell mkdir -p $(SYSCALLSERVER_OUT))

#=============================================================================
# SYSCALLSERVER

# generate Makefiles
syscallserver_configure: $(SYSCALLSERVER_OUT)/Makefile
.PHONY : syscallserver_configure
$(SYSCALLSERVER_OUT)/Makefile:
	@ cd $(SYSCALLSERVER_OUT) && \
		cmake \
			-DCMAKE_C_COMPILER=$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)-gcc \
			-DCMAKE_CXX_COMPILER=$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)-g++ \
			$(PWD)/$(SYSCALLSERVER_DIR)

# main build
syscallserver: syscallserver_configure
	$(MAKE) -C $(SYSCALLSERVER_OUT)
.PHONY : syscallserver

# cleanup
syscallserver_clean:
	if [ -f $(SYSCALLSERVER_OUT)/Makefile ]; then $(MAKE) -C $(SYSCALLSERVER_OUT) clean; fi
.PHONY : syscallserver_clean

syscallserver_distclean:
	rm -Rf $(SYSCALLSERVER_OUT)/*
.PHONY : syscallserver_distclean
