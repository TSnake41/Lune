--[[
  Saphire-based build system for Lune project
  Copyright (C) 2021-2022 Astie Teddy

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
]]

local saphire = require "saphire"
local c = require "saphire-c"
local Future = require "saphire-future"
local los = require "los"

local cc = os.getenv "CC" or "cc"
local ar = os.getenv "AR" or "ar"
local windres = os.getenv "WINDRES" or "windres"

-- TODO: Use current lua interpreter
local lua = os.getenv "LUA"
local needs_luajit_built = not (os.getenv "LUA")

local cflags = os.getenv "CFLAGS" or "-O2 -s"
local ldflags = os.getenv "LDFLAGS" or "-O2 -s -lm"
local ldflags_r = os.getenv "LDFLAGS_R" or ""

cflags = cflags .. " -Iluajit/src"

if los.type() == "linux" then
  ldflags = ldflags .. " -pthread"
  cflags = cflags .. " -fPIC"
  lua = lua or "luajit/src/luajit"
elseif los.type() == "win32" then
  ldflags = ldflags .. " -static "
  ldflags_r = ldflags_r .. "-mwindows"
  lua = lua or "luajit\\src\\luajit"
end

local libluajit
if saphire.targets.clean then
  libluajit = {
    command = "make -C luajit clean",
    name = "LuaJIT"
  }
else
  libluajit = {
    command = string.format("make -C luajit amalg CC=%s BUILDMODE=static MACOSX_DEPLOYMENT_TARGET=10.13", cc),
    name = "LuaJIT"
  }
end
saphire.do_single(libluajit)
libluajit[1] = "luajit/src/libluajit.a"

local function lua2c(files, output, name)
  if saphire.targets.clean then
    return string.format("rm -f %s", output)
  else
    return string.format("%s tools/lua2str.lua %s %s %s", lua, output, name, table.concat(files, " "))
  end
end

local function genbind(output)
  if saphire.targets.clean then
    return string.format("rm -f %s", output)
  else
    return string.format("%s tools/genbind.lua src/autogen/bind.c", lua)
  end
end

local lune_src = {
  c.src("src/lune.c", function ()
    -- Generate bind.c and boot.c
    if needs_luajit_built then
      -- LuaJIT needs to be built
      libluajit:wait()
    end

    saphire.do_multi({
      {
        command = lua2c(
          { "src/lune.lua" },
          "src/autogen/boot.c",
          "lune_boot_lua"
        ),
        name = "boot.c"
      },
      {
        command = genbind("src/autogen/bind.c"),
        name = "bind.c"
      }
    }, true)
  end)
}
local lune_obj = c.compile(lune_src, cflags, "lune", cc)

local liblune = c.lib("liblune.a", lune_obj, "lune", ar)

local lune_s_src = {
  "src/lune_s.c"
}
local lune_s_objs = c.compile(lune_s_src, cflags, "lune_s", cc)

local lune_e_src = {
  c.src("src/lune_builder.c", function ()
    saphire.do_single(lua2c({ "src/lune_builder.lua" }, "src/autogen/builder.c", "lune_builder_lua"), true)
  end),
  "src/lune_e.c",
  "src/lib/miniz.c",
  "src/lune_self.c",
}
local lune_e_objs = c.compile(lune_e_src, cflags, "lune_e", cc)

local icon
if los.type() == "win32" then
  icon = c.res("src/res/icon.rc", { "src/res/icon.ico" }, "icon", windres)
end

local lune_s = c.link("lune_s",
  saphire.merge(lune_s_objs, { liblune, libluajit, icon }),
  ldflags,
  false,
  "lune_s",
  cc
)

local lune_e = c.link("lune_e",
  saphire.merge(lune_e_objs, { liblune, libluajit, icon }),
  ldflags,
  false,
  "lune_e",
  cc
)

local lune_r = c.link("lune_r",
  saphire.merge(lune_e_objs, { liblune, libluajit, icon }),
  ldflags .. " " .. ldflags_r,
  false,
  "lune_r",
  cc
)