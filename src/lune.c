/*
  Copyright (C) 2020-2022 Astie Teddy

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted, provided that the above
  copyright notice and this permission notice appear in all copies.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
  OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
  CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

#include <stdbool.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include "lune_binding.c"
#include "autogen/boot.c"

extern const char *lune_boot_str;

void lune_boot(lua_State *L, lua_CFunction loadfile, lua_CFunction listfiles,
  bool repl)
{
  lua_newtable(L);

  if (loadfile) {
    lua_pushstring(L, "loadfile");
    lua_pushcfunction(L, loadfile);
    lua_settable(L, -3);
  }

  if (listfiles) {
    lua_pushstring(L, "listfiles");
    lua_pushcfunction(L, listfiles);
    lua_settable(L, -3);
  }

  lua_pushstring(L, "entries");
  lua_pushlightuserdata(L, lune_entries);
  lua_settable(L, -3);

  lua_pushstring(L, "isrepl");
  lua_pushboolean(L, repl);
  lua_settable(L, -3);

  lua_setglobal(L, "lune");

  if (luaL_dostring(L, lune_boot_lua)) {
    fputs(luaL_checkstring(L, -1), stderr);
    fputc('\n', stderr);
  }
}
