# Copyright 2009 The RE2 Authors.  All Rights Reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

all: obj/libre2.a obj/so/libre2.so

# to build against PCRE for testing or benchmarking,
# uncomment the next two lines
# CCPCRE=-I/usr/local/include -DUSEPCRE
# LDPCRE=-L/usr/local/lib -lpcre

CXX?=g++
CXXFLAGS?=-Wall -O3 -g -pthread # can override
RE2_CXXFLAGS?=-Wsign-compare -c -I. $(CCPCRE)  # required
LDFLAGS?=-pthread
AR?=ar
ARFLAGS?=rsc
NM?=nm
NMFLAGS?=-p

# Variables mandated by GNU, the arbiter of all good taste on the internet.
# http://www.gnu.org/prep/standards/standards.html
prefix=/usr/local
exec_prefix=$(prefix)
bindir=$(exec_prefix)/bin
includedir=$(prefix)/include
libdir=$(exec_prefix)/lib
INSTALL=install
INSTALL_PROGRAM=$(INSTALL)
INSTALL_DATA=$(INSTALL) -m 644

# ABI version
# http://tldp.org/HOWTO/Program-Library-HOWTO/shared-libraries.html
SONAME=0

# To rebuild the Tables generated by Perl and Python scripts (requires Internet
# access for Unicode data), uncomment the following line:
# REBUILD_TABLES=1

ifeq ($(shell uname),Darwin)
MAKE_SHARED_LIBRARY=$(CXX) -dynamiclib $(LDFLAGS) -exported_symbols_list libre2.symbols.darwin
else
MAKE_SHARED_LIBRARY=$(CXX) -shared -Wl,-soname,libre2.so.$(SONAME),--version-script=libre2.symbols $(LDFLAGS)
endif

INSTALL_HFILES=\
	re2/filtered_re2.h\
	re2/re2.h\
	re2/set.h\
	re2/stringpiece.h\
	re2/variadic_function.h\

HFILES=\
	util/atomicops.h\
	util/benchmark.h\
	util/flags.h\
	util/logging.h\
	util/mutex.h\
	util/pcre.h\
	util/random.h\
	util/sparse_array.h\
	util/sparse_set.h\
	util/test.h\
	util/thread.h\
	util/utf.h\
	util/util.h\
	util/valgrind.h\
	re2/filtered_re2.h\
	re2/prefilter.h\
	re2/prefilter_tree.h\
	re2/prog.h\
	re2/re2.h\
	re2/regexp.h\
	re2/set.h\
	re2/stringpiece.h\
	re2/testing/exhaustive_tester.h\
	re2/testing/regexp_generator.h\
	re2/testing/string_generator.h\
	re2/testing/tester.h\
	re2/unicode_casefold.h\
	re2/unicode_groups.h\
	re2/variadic_function.h\
	re2/walker-inl.h\

OFILES=\
	obj/util/hash.o\
	obj/util/rune.o\
	obj/util/stringprintf.o\
	obj/util/strutil.o\
	obj/util/valgrind.o\
	obj/re2/bitstate.o\
	obj/re2/compile.o\
	obj/re2/dfa.o\
	obj/re2/filtered_re2.o\
	obj/re2/mimics_pcre.o\
	obj/re2/nfa.o\
	obj/re2/onepass.o\
	obj/re2/parse.o\
	obj/re2/perl_groups.o\
	obj/re2/prefilter.o\
	obj/re2/prefilter_tree.o\
	obj/re2/prog.o\
	obj/re2/re2.o\
	obj/re2/regexp.o\
	obj/re2/set.o\
	obj/re2/simplify.o\
	obj/re2/stringpiece.o\
	obj/re2/tostring.o\
	obj/re2/unicode_casefold.o\
	obj/re2/unicode_groups.o\

TESTOFILES=\
	obj/util/pcre.o\
	obj/util/random.o\
	obj/util/thread.o\
	obj/re2/testing/backtrack.o\
	obj/re2/testing/dump.o\
	obj/re2/testing/exhaustive_tester.o\
	obj/re2/testing/null_walker.o\
	obj/re2/testing/regexp_generator.o\
	obj/re2/testing/string_generator.o\
	obj/re2/testing/tester.o\

TESTS=\
	obj/test/charclass_test\
	obj/test/compile_test\
	obj/test/filtered_re2_test\
	obj/test/mimics_pcre_test\
	obj/test/parse_test\
	obj/test/possible_match_test\
	obj/test/re2_test\
	obj/test/re2_arg_test\
	obj/test/regexp_test\
	obj/test/required_prefix_test\
	obj/test/search_test\
	obj/test/set_test\
	obj/test/simplify_test\
	obj/test/string_generator_test\

BIGTESTS=\
	obj/test/dfa_test\
	obj/test/exhaustive1_test\
	obj/test/exhaustive2_test\
	obj/test/exhaustive3_test\
	obj/test/exhaustive_test\
	obj/test/random_test\

SOFILES=$(patsubst obj/%,obj/so/%,$(OFILES))
STESTOFILES=$(patsubst obj/%,obj/so/%,$(TESTOFILES))
STESTS=$(patsubst obj/%,obj/so/%,$(TESTS))
SBIGTESTS=$(patsubst obj/%,obj/so/%,$(BIGTESTS))

DOFILES=$(patsubst obj/%,obj/dbg/%,$(OFILES))
DTESTOFILES=$(patsubst obj/%,obj/dbg/%,$(TESTOFILES))
DTESTS=$(patsubst obj/%,obj/dbg/%,$(TESTS))
DBIGTESTS=$(patsubst obj/%,obj/dbg/%,$(BIGTESTS))

obj/%.o: %.cc $(HFILES)
	@mkdir -p $$(dirname $@)
	$(CXX) -o $@ $(CPPFLAGS) $(CXXFLAGS) $(RE2_CXXFLAGS) -DNDEBUG $*.cc

obj/dbg/%.o: %.cc $(HFILES)
	@mkdir -p $$(dirname $@)
	$(CXX) -o $@ -fPIC $(CPPFLAGS) $(CXXFLAGS) $(RE2_CXXFLAGS) $*.cc

obj/so/%.o: %.cc $(HFILES)
	@mkdir -p $$(dirname $@)
	$(CXX) -o $@ -fPIC $(CPPFLAGS) $(CXXFLAGS) $(RE2_CXXFLAGS) -DNDEBUG $*.cc

obj/libre2.a: $(OFILES)
	@mkdir -p obj
	$(AR) $(ARFLAGS) obj/libre2.a $(OFILES)

obj/dbg/libre2.a: $(DOFILES)
	@mkdir -p obj/dbg
	$(AR) $(ARFLAGS) obj/dbg/libre2.a $(DOFILES)

obj/so/libre2.so: $(SOFILES)
	@mkdir -p obj/so
	$(MAKE_SHARED_LIBRARY) -o $@.$(SONAME) $(SOFILES)
	ln -sf libre2.so.$(SONAME) $@

obj/test/%: obj/libre2.a obj/re2/testing/%.o $(TESTOFILES) obj/util/test.o
	@mkdir -p obj/test
	$(CXX) -o $@ obj/re2/testing/$*.o $(TESTOFILES) obj/util/test.o obj/libre2.a $(LDFLAGS) $(LDPCRE)

obj/dbg/test/%: obj/dbg/libre2.a obj/dbg/re2/testing/%.o $(DTESTOFILES) obj/dbg/util/test.o
	@mkdir -p obj/dbg/test
	$(CXX) -o $@ obj/dbg/re2/testing/$*.o $(DTESTOFILES) obj/dbg/util/test.o obj/dbg/libre2.a $(LDFLAGS) $(LDPCRE)

obj/so/test/%: obj/so/libre2.so obj/libre2.a obj/so/re2/testing/%.o $(STESTOFILES) obj/so/util/test.o
	@mkdir -p obj/so/test
	$(CXX) -o $@ obj/so/re2/testing/$*.o $(STESTOFILES) obj/so/util/test.o -Lobj/so -lre2 obj/libre2.a $(LDFLAGS) $(LDPCRE)

obj/test/regexp_benchmark: obj/libre2.a obj/re2/testing/regexp_benchmark.o $(TESTOFILES) obj/util/benchmark.o
	@mkdir -p obj/test
	$(CXX) -o $@ obj/re2/testing/regexp_benchmark.o $(TESTOFILES) obj/util/benchmark.o obj/libre2.a $(LDFLAGS) $(LDPCRE)

ifdef REBUILD_TABLES
re2/perl_groups.cc: re2/make_perl_groups.pl
	perl $< > $@

re2/unicode_%.cc: re2/make_unicode_%.py
	python $< > $@
endif

distclean: clean
	rm -f re2/perl_groups.cc re2/unicode_casefold.cc re2/unicode_groups.cc

clean:
	rm -rf obj
	rm -f re2/*.pyc

testofiles: $(TESTOFILES)

test: $(DTESTS) $(TESTS) $(STESTS) debug-test static-test shared-test

debug-test: $(DTESTS)
	@echo
	@echo Running debug binary tests.
	@echo
	@./runtests $(DTESTS)

static-test: $(TESTS)
	@echo
	@echo Running static binary tests.
	@echo
	@./runtests $(TESTS)

shared-test: $(STESTS)
	@echo
	@echo Running dynamic binary tests.
	@echo
	@LD_LIBRARY_PATH=obj/so:$(LD_LIBRARY_PATH) ./runtests $(STESTS)

debug-bigtest: $(DTESTS) $(DBIGTESTS)
	@./runtests $(DTESTS) $(DBIGTESTS)

static-bigtest: $(TESTS) $(BIGTESTS)
	@./runtests $(TESTS) $(BIGTESTS)

shared-bigtest: $(STESTS) $(SBIGTESTS)
	@LD_LIBRARY_PATH=obj/so:$(LD_LIBRARY_PATH) ./runtests $(STESTS) $(SBIGTESTS)

benchmark: obj/test/regexp_benchmark

install: obj/libre2.a obj/so/libre2.so
	mkdir -p $(DESTDIR)$(includedir)/re2 $(DESTDIR)$(libdir)
	$(INSTALL_DATA) $(INSTALL_HFILES) $(DESTDIR)$(includedir)/re2
	$(INSTALL) obj/libre2.a $(DESTDIR)$(libdir)/libre2.a
	$(INSTALL) obj/so/libre2.so $(DESTDIR)$(libdir)/libre2.so.$(SONAME).0.0
	ln -sf libre2.so.$(SONAME).0.0 $(DESTDIR)$(libdir)/libre2.so.$(SONAME)
	ln -sf libre2.so.$(SONAME).0.0 $(DESTDIR)$(libdir)/libre2.so

testinstall:
	@mkdir -p obj
	cp testinstall.cc obj
	(cd obj && $(CXX) -I$(DESTDIR)$(includedir) -L$(DESTDIR)$(libdir) testinstall.cc -lre2 -pthread -static -o testinstall)
	obj/testinstall
	(cd obj && $(CXX) -I$(DESTDIR)$(includedir) -L$(DESTDIR)$(libdir) testinstall.cc -lre2 -pthread -o testinstall)
	LD_LIBRARY_PATH=$(DESTDIR)$(libdir) obj/testinstall

benchlog: obj/test/regexp_benchmark
	(echo '==BENCHMARK==' `hostname` `date`; \
	  (uname -a; $(CXX) --version; hg identify; file obj/test/regexp_benchmark) | sed 's/^/# /'; \
	  echo; \
	  ./obj/test/regexp_benchmark 'PCRE|RE2') | tee -a benchlog.$$(hostname | sed 's/\..*//')

# Keep gmake from deleting intermediate files it creates.
# This makes repeated builds faster and preserves debug info on OS X.

.PRECIOUS: obj/%.o obj/dbg/%.o obj/so/%.o obj/libre2.a \
	obj/dbg/libre2.a obj/so/libre2.a \
	obj/test/% obj/so/test/% obj/dbg/test/%

log:
	make clean
	make CXXFLAGS="$(CXXFLAGS) -DLOGGING=1" obj/test/exhaustive{,1,2,3}_test
	echo '#' RE2 exhaustive tests built by make log >re2-exhaustive.txt
	echo '#' $$(date) >>re2-exhaustive.txt
	obj/test/exhaustive_test |grep -v '^PASS$$' >>re2-exhaustive.txt
	obj/test/exhaustive1_test |grep -v '^PASS$$' >>re2-exhaustive.txt
	obj/test/exhaustive2_test |grep -v '^PASS$$' >>re2-exhaustive.txt
	obj/test/exhaustive3_test |grep -v '^PASS$$' >>re2-exhaustive.txt

	make CXXFLAGS="$(CXXFLAGS) -DLOGGING=1" obj/test/search_test
	echo '#' RE2 basic search tests built by make $@ >re2-search.txt
	echo '#' $$(date) >>re2-search.txt
	obj/test/search_test |grep -v '^PASS$$' >>re2-search.txt

x: x.cc obj/libre2.a
	g++ -I. -o x x.cc obj/libre2.a
