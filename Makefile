#
# Makefile
# Ye Chang, 2020-04-07 21:23
#

all: binary
	@echo "Done!"

binary:
	@echo "Building binary by dart2native..."
	@dart2native bin/main.dart -o build/bio 1>/dev/null 2>/dev/null

# vim:ft=make
#
