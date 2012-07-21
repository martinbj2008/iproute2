-include ../../env.mk

all:
	make ip
prepare:
	./configure
install:
	@cp -v ip/ip ${ROOT_ROMFS}/sbin/.
