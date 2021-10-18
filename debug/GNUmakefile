#
# This makefile is provisional, should be replaced with
# autoconf / cmake.
#

all:
	if test ! -d jv-vdb; then \
		echo "WARNING:"; \
		echo "WARNING: VDB not found, debugging in GDB may not be possible. Please, see README.md."; \
		echo "WARNING:"; \
	else \
		$(MAKE) -C jv-vdb python; \
	fi
