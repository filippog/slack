# Makefile for slack
# $Id$

include	Makefile.common

TARGETS = all install install-bin install-conf clean distclean realclean
SUBDIRS = doc src

$(TARGETS)::
	@set -e; \
	 for i in $(SUBDIRS); do $(MAKE) -C $$i $@ ; done

deb:
	fakeroot ./debian/rules binary
	./debian/rules clean
	ls -l ../slack_*_all.deb

clean distclean realclean::
	./debian/rules clean
