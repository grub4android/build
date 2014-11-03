cmake_minimum_required(VERSION 2.8)

# common
project(selinux)
set(CMAKE_BUILD_TYPE Release)
add_definitions(-DHOST)
set(CMAKE_C_FLAGS "-Wall -Wextra -Wshadow -fPIC -static-libgcc -Wl,-static")
set(SELINUX_SOURCE_DIR $ENV{SOURCE_DIR}/src)
set(SELINUX_INCLUDE_DIR $ENV{SOURCE_DIR}/include)

# main
add_library(selinux STATIC
	${SELINUX_SOURCE_DIR}/booleans.c
	${SELINUX_SOURCE_DIR}/canonicalize_context.c
	${SELINUX_SOURCE_DIR}/disable.c
	${SELINUX_SOURCE_DIR}/enabled.c
	${SELINUX_SOURCE_DIR}/fgetfilecon.c
	${SELINUX_SOURCE_DIR}/fsetfilecon.c
	${SELINUX_SOURCE_DIR}/getenforce.c
	${SELINUX_SOURCE_DIR}/getfilecon.c
	${SELINUX_SOURCE_DIR}/getpeercon.c
	${SELINUX_SOURCE_DIR}/lgetfilecon.c
	${SELINUX_SOURCE_DIR}/load_policy.c
	${SELINUX_SOURCE_DIR}/lsetfilecon.c
	${SELINUX_SOURCE_DIR}/policyvers.c
	${SELINUX_SOURCE_DIR}/procattr.c
	${SELINUX_SOURCE_DIR}/setenforce.c
	${SELINUX_SOURCE_DIR}/setfilecon.c
	${SELINUX_SOURCE_DIR}/context.c
	${SELINUX_SOURCE_DIR}/mapping.c
	${SELINUX_SOURCE_DIR}/stringrep.c
	${SELINUX_SOURCE_DIR}/compute_create.c
	${SELINUX_SOURCE_DIR}/compute_av.c
	${SELINUX_SOURCE_DIR}/avc.c
	${SELINUX_SOURCE_DIR}/avc_internal.c
	${SELINUX_SOURCE_DIR}/avc_sidtab.c
	${SELINUX_SOURCE_DIR}/get_initial_context.c
	${SELINUX_SOURCE_DIR}/checkAccess.c
	${SELINUX_SOURCE_DIR}/sestatus.c
	${SELINUX_SOURCE_DIR}/deny_unknown.c

	${SELINUX_SOURCE_DIR}/callbacks.c
	${SELINUX_SOURCE_DIR}/check_context.c
	${SELINUX_SOURCE_DIR}/freecon.c
	${SELINUX_SOURCE_DIR}/init.c
	${SELINUX_SOURCE_DIR}/label.c
	${SELINUX_SOURCE_DIR}/label_file.c
	${SELINUX_SOURCE_DIR}/label_android_property.c
)
set_property(TARGET selinux PROPERTY INCLUDE_DIRECTORIES
	${SELINUX_INCLUDE_DIR}
)
