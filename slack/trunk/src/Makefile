# Makefile for slack/src
# $Id$
include ../Makefile.common

BACKENDS = slack-installfiles slack-installfiles_rsync-2.5 slack-installfiles_rsync-2.6 slack-runscript slack-sync

all:

install: install-bin install-conf

install-bin: all
	$(MKDIR) $(DESTDIR)$(sbindir)
	$(INSTALL) slack $(DESTDIR)$(sbindir)
	$(MKDIR) $(DESTDIR)$(slack_libexecdir)
	@set -ex;\
	for i in $(BACKENDS); do \
	$(INSTALL) $$i $(DESTDIR)$(slack_libexecdir); done
	$(MKDIR) $(DESTDIR)$(slack_localstatedir)

install-conf: all
	$(MKDIR) $(DESTDIR)$(sysconfdir)
	$(INSTALL) slack.conf $(DESTDIR)$(sysconfdir)

clean:

realclean: clean

distclean: clean
