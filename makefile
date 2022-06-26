CFLAGS := -O2 -s 
LDFLAGS := -O2 -s -lm

AR ?= ar
LUA ?= luajit/src/luajit

WINDRES ?= windres

CFLAGS += -Iluajit/src
LDFLAGS += luajit/src/libluajit.a

ifeq ($(OS),Windows_NT)
	LDFLAGS += -static
	LDFLAGS_R += -mwindows 
	EXTERNAL_FILES := src/res/icon.res
else ifeq ($(shell uname),Darwin)
	LDFLAGS += -Wl,-pagezero_size,10000,-image_base,100000000
	EXTERNAL_FILES :=
else
	LDFLAGS += -pthread
	EXTERNAL_FILES :=
endif

all: lune_s lune_e lune_r luajit

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

luajit:
	$(MAKE) -C luajit amalg \
		CC=$(CC) BUILDMODE=static \
		MACOSX_DEPLOYMENT_TARGET=10.13

lune_s: src/lune_s.o $(EXTERNAL_FILES) liblune.a
	$(CC) -o $@ $^ $(LDFLAGS) luajit/src/libluajit.a

lune_e: src/lune_e.o src/lune_self.o src/lune_builder.o src/lib/miniz.o \
		$(EXTERNAL_FILES) liblune.a
	$(CC) -o $@ $^ $(LDFLAGS) luajit/src/libluajit.a

lune_r: src/lune_e.o src/lune_self.o src/lune_builder.o src/lib/miniz.o \
		$(EXTERNAL_FILES) liblune.a
	$(CC) -o $@ $^ $(LDFLAGS) $(LDFLAGS_R) luajit/src/libluajit.a

src/res/icon.res: src/res/icon.rc
	$(WINDRES) $^ -O coff $@

liblune.a: src/lune.o
	$(AR) rcu $@ $^

lune.dll: src/lune.o
	$(CC) -shared -fPIE -o $@ $^ $(LDFLAGS) -llua5.1

lune.so: src/lune.o
	$(CC) -shared -fPIE -o $@ $^ $(LDFLAGS) -llua5.1

src/lune.o: luajit src/autogen/boot.c

src/lune_builder.o: src/autogen/builder.c

src/autogen/boot.c: src/lune.lua
	$(LUA) tools/lua2str.lua $@ lune_boot_lua $^

src/autogen/bind.c:
	$(LUA) tools/genbind.lua $@ $(MODULES)

src/autogen/builder.c: src/lune_builder.lua
	$(LUA) tools/lua2str.lua $@ lune_builder_lua $^

clean:
	rm -rf lune_s lune_e liblune.a src/lune_e.o src/lune_s.o \
		src/lune.o src/lune_self.o src/lune_builder.o src/autogen/*.c \
		src/lib/miniz.o src/res/icon.res
	$(MAKE) -C luajit clean

.PHONY: all src/autogen/boot.c lune_s lune_e luajit clean
