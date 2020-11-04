# SPDX-License-Identifier: GPL-2.0-or-later
#
# Device Tree Compiler
#

BUILD_DIR=build

all: $(BUILD_DIR)/build.ninja
	ninja -C build

$(BUILD_DIR)/build.ninja:
	meson $(BUILD_DIR)

check:
	meson test -C $(BUILD_DIR) -v

checkm:
	WITH_VALGRIND=1 meson test -C $(BUILD_DIR) -v

%::
	ninja -C $(BUILD_DIR) $@

#
# Release signing and uploading
# This is for maintainer convenience, don't try this at home.
#
ifeq ($(MAINTAINER),y)
GPG = gpg2
KUP = kup
KUPDIR = /pub/software/utils/dtc

kup: dist
	dtc_version=`meson introspect --projectinfo build | jq -r '.version'` && \
	xz -d build/meson-dist/dtc-$$dtc_version.tar.xz && \
	$(GPG) --detach-sign --armor -o dtc-$$dtc_version.tar.sign \
		build/meson-dist/dtc-$$dtc_version.tar && \
	gzip build/meson-dist/dtc-$$dtc_version.tar && \
	$(KUP) put build/meson-dist/dtc-$$dtc_version.tar.gz dtc-$$dtc_version.tar.sign \
		$(KUPDIR)/dtc-$$dtc_version.tar.gz
endif
