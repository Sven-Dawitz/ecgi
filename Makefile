SHAREDOPT = -shared
LIBDIR = $(PREFIX)/usr/lib
INCDIR = $(PREFIX)/include
AR = ar
CC?= gcc
INCS =  -Iinclude/ -I.
CFLAGS += -Wall

all: obj/ecgi.o obj/ecgitk.o libecgi.a
	$(MAKE) -C html2h/
	$(MAKE) libecgi.so

obj:
	mkdir -p obj

shared: libecgi.so | obj
	cp libecgi.so /usr/lib

libecgi.a: obj/ecgi.o obj/ecgitk.o | obj
	printf "\n\n***trying shared now - might crash***\nrun 'make install' if this happens\n\n"
	ar rs libecgi.a obj/ecgi.o obj/memfile.o obj/ecgitk.o
	printf "\n\n***congratulations - compilation worked***\n***       run 'make install' now       ***\n\n"

libecgi.so: obj/ecgi.So obj/ecgitk.So obj/memfile.So | obj
	$(CC) $(SHAREDOPT) obj/ecgi.So obj/memfile.So obj/ecgitk.So -o libecgi.so

install:
	cp libecgi.a $(LIBDIR)
	cp ecgi.h $(INCDIR)
	cp include/memfile.h $(INCDIR)
	cp ecgitk.h $(INCDIR)
	$(MAKE) -C html2h/ install
	cp libecgi.so $(LIBDIR)

tests:	all
	$(CC) tests/test.c -o tests/test.cgi $(INCS) $(CFLAGS) libecgi.a
	$(CC) tests/testload.c -o tests/testload libecgi.a $(INCS) $(CFLAGS)

obj/ecgi.o: src/ecgi.c ecgi.h obj/memfile.o | obj
	$(CC) -c src/ecgi.c $(INCS) $(CFLAGS) -o obj/ecgi.o

obj/memfile.o:  src/memfile.c include/memfile.h | obj
	$(CC) -o obj/memfile.o -c src/memfile.c $(INCS) $(CFLAGS)

obj/ecgitk.o: src/ecgitk.c ecgitk.h | obj
	$(CC) -c src/ecgitk.c $(INCS) $(CFLAGS) -o obj/ecgitk.o

obj/ecgi.So: src/ecgi.c ecgi.h obj/memfile.o | obj
	$(CC) -c src/ecgi.c $(INCS) $(CFLAGS) -fPIC -o obj/ecgi.So

obj/memfile.So:  src/memfile.c include/memfile.h | obj
	$(CC) -o obj/memfile.So -c src/memfile.c -fPIC $(INCS) $(CFLAGS)

obj/ecgitk.So: src/ecgitk.c ecgitk.h | obj
	$(CC) -c src/ecgitk.c $(INCS) $(CFLAGS) -fPIC -o obj/ecgitk.So

clean:
	rm -f obj/* *.a *.so -f tests/test.cgi tests/testload
	$(MAKE) -C html2h/ clean

zip: clean
	rm -f ../ecgi-0.6.3.zip
	(cd ..; zip -r ecgi-0.6.3.zip ecgi-0.6.3*)
