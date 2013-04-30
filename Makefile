
CFLAGS = -Wall -Wextra -Wno-unused-parameter -std=gnu99 -g

headers = $(wildcard src/*.h)
sources = $(wildcard src/*.c)
objects = $(subst .c,.o,$(sources))

vcprompt: $(objects)
	$(CC) -o $@ $(objects)

# build a standalone version of capture_child() library for testing
src/capture: src/capture.c src/capture.h src/common.c src/common.h
	$(CC) -DTEST_CAPTURE $(CFLAGS) -o $@ src/capture.c src/common.c

# Maximally pessimistic view of header dependencies.
$(objects): $(headers)

.PHONY: check check-simple check-hg check-git check-fossil grind
check: check-simple check-hg check-git check-fossil

hgrepo = tests/hg-repo.tar
gitrepo = tests/git-repo.tar
fossilrepo = tests/fossil-repo

check-simple: vcprompt
	cd tests && ./test-simple

check-hg: vcprompt $(hgrepo)
	cd tests && ./test-hg

$(hgrepo): tests/setup-hg
	cd tests && ./setup-hg

check-git: vcprompt $(gitrepo)
	cd tests && ./test-git

$(gitrepo): tests/setup-git
	cd tests && ./setup-git

check-fossil: vcprompt $(fossilrepo)
	cd tests && ./test-fossil

$(fossilrepo): tests/setup-fossil
	cd tests && ./setup-fossil

grind: check
	make check VCPVALGRIND=y

clean:
	rm -f $(objects) vcprompt $(hgrepo) $(gitrepo) $(fossilrepo)

DESTDIR =
PREFIX = /usr/local
BINDIR = $(DESTDIR)$(PREFIX)/bin
MANDIR = $(DESTDIR)$(PREFIX)/man/man1

.PHONY: install
install: vcprompt
	install -d $(BINDIR) $(MANDIR)
	install vcprompt $(BINDIR)
	install vcprompt.1 $(MANDIR)
