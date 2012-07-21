-include ../../env.mk

all:
	make
prepare:
	./configure
install:
	@cp -v ip/ip ${ROOT_ROMFS}/sbin/.
