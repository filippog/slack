include ../Makefile.common

all:

install install-bin install-conf install-lib install-man: all

clean:
	rm -rf ./tmp

realclean: clean

distclean: clean

test:
	perl -MTest::Harness -e 'runtests(<*.t>)'

check: test
