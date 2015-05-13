CC=g++

ifeq ($(DEBUG),yes)
	CXXFLAGS=-Wall -g
	LDFLAGS=-Wall -g
else
	CXXFLAGS=-Wall
	LDFLAGS=-Wall
endif

INCPATH=inc
SRCPATH=src
OBJPATH=obj
LIBPATH=lib
BINPATH=bin

OBJS=$(OBJPATH)/GTM.o $(OBJPATH)/gtmlib_wrap.o
OUT=$(LIBPATH)/libGTMLib.so

INCLUDES=-I ./$(INCPATH)

#Set this to your go installation directory
EXE=$$HOME/dev/goinstallation/go/bin/
export PATH := bin:$(PATH)

default: $(OUT)

$(OUT): $(OBJS)
	$(CC) $(LDFLAGS) -shared -o $@ $^

obj/gtmlib_wrap.o: gtmlib_wrap.cxx inc/GTM.h
	$(CC) $(CXXFLAGS) $(INCLUDES) -fpic -c $< -o $@

obj/GTM.o: src/GTM.cpp inc/GTM.h
	$(CC) $(CXXFLAGS) $(INCLUDES) -fpic -c $< -o $@


gtmlib_wrap.cxx:
	swig -go -c++ -intgosize 64 -soname libGTMLib.so gtmlib.swig

.PHONY: clean cleanall

clean:
	rm -f $(OBJPATH)/*.o

cleanall: clean
	rm -f $(OUT)
	rm -f *.6
	rm -f *.a
	rm -f *.so
	rm -f *.cxx
	rm -f *.c

build:
	@echo "Building bindings..."
	$(EXE)go tool 6c -I $$HOME/dev/goinstallation/go/pkg/linux_amd64/ -D _64BIT gtmlib_gc.c
	$(EXE)go tool 6g gtmlib.go
	$(EXE)go tool pack grc gtmlib.a gtmlib.6 gtmlib_gc.6
	
	
install:
	@echo "Installing go package..."
	#Rename swig file so go install command does not try to reprocess it
	mv gtmlib.swig gtmlib.notswig
	export GOPATH=$$HOME/dev/go/; \
	$(EXE)go install
	mv gtmlib.notswig gtmlib.swig

	@echo "Installing go shared lib..."
	sudo cp -f lib/libGTMLib.so /usr/local/lib/
	sudo ldconfig