ROOTDIR=$(DESTDIR)
PREFIX=/usr
LIBDIR=$(PREFIX)/lib
SBINDIR=/sbin
CONFDIR=/etc/iproute2
DATADIR=$(PREFIX)/share
DOCDIR=$(DATADIR)/doc/iproute2
MANDIR=$(DATADIR)/man
ARPDDIR=/var/lib/arpd

# Path to db_185.h include
DBM_INCLUDE:=$(ROOTDIR)/usr/include

SHARED_LIBS = y

DEFINES= -DRESOLVE_HOSTNAMES -DLIBDIR=\"$(LIBDIR)\"
ifneq ($(SHARED_LIBS),y)
DEFINES+= -DNO_SHARED_LIBS
endif

DEFINES+=-DCONFDIR=\"$(CONFDIR)\"

#options if you have a bind>=4.9.4 libresolv (or, maybe, glibc)
LDLIBS=-lresolv
ADDLIB=

#options for decnet
ADDLIB+=dnet_ntop.o dnet_pton.o

#options for ipx
ADDLIB+=ipx_ntop.o ipx_pton.o

CC = gcc
HOSTCC = gcc
DEFINES += -D_GNU_SOURCE
CCOPTS = -O2
WFLAGS = -Wall -Wstrict-prototypes
CFLAGS = $(WFLAGS) $(CCOPTS) -I../include $(DEFINES)
YACCFLAGS = -d -t -v

#SUBDIRS=lib ip tc misc netem genl man
SUBDIRS=lib ip

LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
LDLIBS += $(LIBNETLINK)

all: Config
	@set -e; \
	for i in $(SUBDIRS); \
	do $(MAKE) $(MFLAGS) -C $$i; done

Config:
	sh configure $(KERNEL_INCLUDE)

install: all
	install -m 0755 -d $(DESTDIR)$(SBINDIR)
	install -m 0755 -d $(DESTDIR)$(CONFDIR)
	install -m 0755 -d $(DESTDIR)$(ARPDDIR)
	install -m 0755 -d $(DESTDIR)$(DOCDIR)/examples
	install -m 0755 -d $(DESTDIR)$(DOCDIR)/examples/diffserv
	install -m 0644 README.iproute2+tc $(shell find examples -maxdepth 1 -type f) \
		$(DESTDIR)$(DOCDIR)/examples
	install -m 0644 $(shell find examples/diffserv -maxdepth 1 -type f) \
		$(DESTDIR)$(DOCDIR)/examples/diffserv
	@for i in $(SUBDIRS) doc; do $(MAKE) -C $$i install; done
	install -m 0644 $(shell find etc/iproute2 -maxdepth 1 -type f) $(DESTDIR)$(CONFDIR)

snapshot:
	echo "static const char SNAPSHOT[] = \""`date +%y%m%d`"\";" \
		> include/SNAPSHOT.h

clean:
	@for i in $(SUBDIRS) doc; \
	do $(MAKE) $(MFLAGS) -C $$i clean; done

clobber:
	touch Config
	$(MAKE) $(MFLAGS) clean
	rm -f Config cscope.*

distclean: clobber

cscope:
	cscope -b -q -R -Iinclude -sip -slib -smisc -snetem -stc

.EXPORT_ALL_VARIABLES:
