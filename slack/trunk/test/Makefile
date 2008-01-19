include ../Makefile.common

TEST_TMPDIR=tmp

CONFFILES=slack.conf roles.conf
TARGETS=$(addprefix $(TEST_TMPDIR)/, $(CONFFILES))

all: $(TARGETS)

install install-bin install-conf install-lib install-man: all

$(TEST_TMPDIR)/%.conf: %.conf.template gen_config_file
	mkdir -p $(TEST_TMPDIR)
	./gen_config_file $< $@

clean:
	rm -f $(TARGETS)
	rm -rf $(TEST_TMPDIR)

realclean: clean

distclean: clean

test: clean all
	perl -MTest::Harness -e 'runtests(<*.t>)'

check: test
