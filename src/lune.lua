--[[
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
]]

local load = loadstring

lune.version = "v0.1-dev"

function lune.repl()
  print("> Lune " .. lune.version .. " <")
  print "Type 'q' to quit."
  print ""

  while true do
    io.write "> "
    local line = io.read "l"
    if line == "q" then
      break
    end

    local f, err = loadstring(line)

    if f then
      local status, err = pcall(f)
      if not status then
        print(err)
      end
    else
      print(err)
    end
  end
end

package.path = "?.lua;?/init.lua"

if os.getenv "LUA_PATH" then
  package.path = package.path .. ";" .. os.getenv "LUA_PATH"
end

if lune.loadfile then
  -- Change the second loader to load files using lune.loadfile
  package.loaders[2] = function (name)
    for path in package.path:gmatch "([^;]+);?" do
      name = name:gsub("%.", "/")
      path = path:gsub("?", name)

      local content, err = lune.loadfile(path)
      if content then
        local f, err = load(content, path)
        assert(f, err)

        return f
      end
    end
  end

  print "LUNE: Load main.lua from payload."

  local f, err = load(lune.loadfile "main.lua", "main.lua")
  if f then
    local status, f_err = xpcall(f, debug.traceback)

    if not status then
      print(f_err)
    end
  else
    print(err)
  end

  if not lune.isrepl then
    return
  end

  -- Keep launching the repl even with `loadfile` defined.
end

if arg and arg[1] then
  local f, err = loadfile(arg[1])
  if f then
    local status, f_err = xpcall(f, debug.traceback)

    if not status then
      print(f_err)
    end
  else
    print(err)
  end

  return
end

if lune.isrepl then
  print "LUNE: Go to repl."
  lune.repl()
end
