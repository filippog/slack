# Makefile for slack/src
# $Id$
include ../Makefile.common

BACKENDS = slack-getroles slack-installfiles slack-runscript slack-sync slack-stage

all:

install: install-bin install-conf install-lib

install-bin: all
	$(MKDIR) $(DESTDIR)$(sbindir)
	$(INSTALL) slack $(DESTDIR)$(sbindir)
	$(MKDIR) $(DESTDIR)$(slack_libexecdir)
	@set -ex;\
	for i in $(BACKENDS); do \
	$(INSTALL) $$i $(DESTDIR)$(slack_libexecdir); done
	$(INSTALL) -p -d -m $(PRIVDIRMODE) $(DESTDIR)$(slack_localstatedir)
	$(INSTALL) -p -d -m $(PRIVDIRMODE) $(DESTDIR)$(slack_localcachedir)

install-conf: all
	$(MKDIR) $(DESTDIR)$(sysconfdir)
	$(INSTALL) slack.conf $(DESTDIR)$(sysconfdir)

install-lib: all
	$(MKDIR) $(DESTDIR)$(slack_libdir)
	$(INSTALL) -m 0644 Slack.pm $(DESTDIR)$(slack_libdir)

clean:

realclean: clean

distclean: clean
