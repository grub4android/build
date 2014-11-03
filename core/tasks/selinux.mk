# cleanup targets
CLEAN_TARGETS += selinux_clean
DISTCLEAN_TARGETS += selinux_distclean

# paths
SELINUX_OUT = $(TARGET_COMMON_OUT)/selinux
SELINUX_DIR = $(TOPDIR)external/libselinux

# create out dir
$(shell mkdir -p $(SELINUX_OUT))

#=============================================================================
# SELINUX

# generate Makefiles
selinux_configure: $(SELINUX_OUT)/Makefile
.PHONY : selinux_configure
$(SELINUX_OUT)/Makefile:
	@ cd $(SELINUX_OUT) && \
	STATIC_COMPILE=1 \
	SOURCE_DIR=$(PWD)/$(SELINUX_DIR) \
		cmake \
		-DCMAKE_C_COMPILER=$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)-gcc \
		-DCMAKE_CXX_COMPILER=$(TOOLCHAIN_LINUX_GNUEABIHF_HOST)-g++ \
			$(PWD)/build/core/tasks/selinux

# main build
selinux: selinux_configure
	$(MAKE) -C $(SELINUX_OUT)
.PHONY : selinux

# cleanup
selinux_clean:
	if [ -f $(SELINUX_OUT)/Makefile ]; then $(MAKE) -C $(SELINUX_OUT) clean; fi
.PHONY : selinux_clean

selinux_distclean:
	rm -Rf $(SELINUX_OUT)/*
.PHONY : selinux_distclean
