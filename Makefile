include config.mk

CFLAGS += -I. -DWLR_USE_UNSTABLE -std=c99 -pedantic -DVERSION=\"$(VERSION)\"

WAYLAND_PROTOCOLS=$(shell pkg-config --variable=pkgdatadir wayland-protocols)
WAYLAND_SCANNER=$(shell pkg-config --variable=wayland_scanner wayland-scanner)

PKGS = wlroots wayland-server xcb xkbcommon libinput
CFLAGS += $(foreach p,$(PKGS),$(shell pkg-config --cflags $(p)))
LDLIBS += $(foreach p,$(PKGS),$(shell pkg-config --libs $(p)))

PREFIX?= /usr/local
DESKTOP?= /usr/share/wayland-sessions

all: dwl

clean:
	rm -f dwl *.o *-protocol.h *-protocol.c

dist: clean
	mkdir -p dwl-$(VERSION)
	cp -R LICENSE* Makefile README.md generate-version.sh client.h\
		config.def.h config.mk protocols dwl.1 dwl.c util.c util.h\
		dwl-$(VERSION)
	echo "echo $(VERSION)" > dwl-$(VERSION)/generate-version.sh
	tar -caf dwl-$(VERSION).tar.gz dwl-$(VERSION)
	rm -rf dwl-$(VERSION)

install: dwl
	install -Dm755 dwl $(DESTDIR)$(PREFIX)/bin/dwl
	install -Dm755 dwl-session $(DESTDIR)$(PREFIX)/bin/dwl-session
	install -Dm644 dwl.1 $(DESTDIR)$(MANDIR)/man1/dwl.1
	install -Dm644 dwl.desktop ${DESKTOP}/dwl.desktop

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/dwl $(DESTDIR)$(PREFIX)/bin/dwl-session
	rm -f $(DESTDIR)$(MANDIR)/man1/dwl.1 ${DESKTOP}/dwl.desktop

.PHONY: all clean dist install uninstall

# wayland-scanner is a tool which generates C headers and rigging for Wayland
# protocols, which are specified in XML. wlroots requires you to rig these up
# to your build system yourself and provide them in the include path.
xdg-shell-protocol.h:
	$(WAYLAND_SCANNER) server-header \
		$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml $@

xdg-shell-protocol.c:
	$(WAYLAND_SCANNER) private-code \
		$(WAYLAND_PROTOCOLS)/stable/xdg-shell/xdg-shell.xml $@

xdg-shell-protocol.o: xdg-shell-protocol.h

pointer-constraints-unstable-v1-protocol.h:
	$(WAYLAND_SCANNER) server-header \
	$(WAYLAND_PROTOCOLS)/unstable/pointer-constraints/pointer-constraints-unstable-v1.xml $@

pointer-constraints-unstable-v1-protocol.c:
	$(WAYLAND_SCANNER) private-code \
	$(WAYLAND_PROTOCOLS)/unstable/pointer-constraints/pointer-constraints-unstable-v1.xml $@

pointer-constraints-unstable-v1-protocol.o: pointer-constraints-unstable-v1-protocol.c

wlr-layer-shell-unstable-v1-protocol.h:
	$(WAYLAND_SCANNER) server-header \
		protocols/wlr-layer-shell-unstable-v1.xml $@

wlr-layer-shell-unstable-v1-protocol.c:
	$(WAYLAND_SCANNER) private-code \
		protocols/wlr-layer-shell-unstable-v1.xml $@

wlr-layer-shell-unstable-v1-protocol.o: wlr-layer-shell-unstable-v1-protocol.h

idle-protocol.h:
	$(WAYLAND_SCANNER) server-header \
		protocols/idle.xml $@

idle-protocol.c:
	$(WAYLAND_SCANNER) private-code \
		protocols/idle.xml $@

idle-protocol.o: idle-protocol.h

config.h: | config.def.h
	cp config.def.h $@

dwl.o: config.mk config.h client.h xdg-shell-protocol.h wlr-layer-shell-unstable-v1-protocol.h idle-protocol.h util.h pointer-constraints-unstable-v1-protocol.h

dwl: xdg-shell-protocol.o wlr-layer-shell-unstable-v1-protocol.o idle-protocol.o util.o pointer-constraints-unstable-v1-protocol.o
