# Makefile for slack/doc
# $Id$
include ../Makefile.common

all:

install: install-man

install-man: all
	$(MKDIR) $(DESTDIR)$(mandir)/man5
	$(INSTALL) slack.conf.5 $(DESTDIR)$(mandir)/man5

clean:

realclean: clean

distclean: clean
