# Makefile for slack/doc
# $Id$
include ../Makefile.common

all:

install: install-man

install-man: all
	$(MKDIR) $(DESTDIR)$(mandir)/man5
	$(INSTALL) slack.conf.5 $(DESTDIR)$(mandir)/man5
	$(MKDIR) $(DESTDIR)$(mandir)/man8
	$(INSTALL) slack.8 $(DESTDIR)$(mandir)/man8

install-bin install-conf install-lib: all

clean:

realclean: clean

distclean: clean

test:
