include ../Makefile.common

TEST_TMPDIR=tmp

TARGETS=slack.conf roles.conf

all: $(TARGETS)

install install-bin install-conf install-lib install-man: all

%.conf: %.conf.template gen_config_file
	./gen_config_file $< $@

clean:
	rm -f $(TARGETS)
	rm -rf $(TEST_TMPDIR)

realclean: clean

distclean: clean

test: clean all
	perl -MTest::Harness -e 'runtests(<*.t>)'

check: test
