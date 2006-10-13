# Makefile for slack
# $Id$

include	Makefile.common

TARGETS = all test \
    install install-bin install-conf install-lib install-man \
    clean distclean realclean
SUBDIRS = doc src test

distdir = $(PACKAGE)-$(VERSION)


$(TARGETS)::
	@set -e; \
	 for i in $(SUBDIRS); do $(MAKE) -C $$i $@ ; done

deb:
	fakeroot ./debian/rules binary
	./debian/rules clean
	ls -l ../slack_*_all.deb

clean distclean realclean::
	./debian/rules clean

dist: distclean
	mkdir ../$(distdir)
	rsync -a --exclude=CVS --delete-excluded . ../$(distdir)/
	chmod -R a+rX ../$(distdir)
	cd .. ; \
	    tar cvfp $(distdir).tar $(distdir)
	rm -rf ../$(distdir)
	gzip -9f ../$(distdir).tar
	chmod a+r ../$(distdir).tar.gz
	@ls -l ../$(distdir).tar.gz

check: test
