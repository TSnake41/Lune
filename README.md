![lune logo](assets/logo.png)

[![release](https://img.shields.io/github/v/release/TSnake41/lune?style=flat-square)](https://github.com/TSnake41/lune/releases/latest)
[![downloads](https://img.shields.io/github/downloads/tsnake41/lune/total?style=flat-square)](https://github.com/TSnake41/lune/releases)

## lune

[TODO]

*basically a raylib-less raylib-lua*

### Usage (lune_s)

lune_s is the script-mode binary of Lune.
Without any argument, you get into the REPL which gives you a minimal Lua]
shell that allows you to run Lua code from terminal.]

You can specify a Lua file as argument to run the specified Lua file.

### Usage (lune_e)

lune_e is the embedding-mode binary of Lune.

This binary allows you to build standalone lune applications from Lua code.

There are 3 ways to use it :
 - zip mode :
     If you specify a zip file as argument, this zip will be used as payload
     application, this file expects to have a `main.lua` which is the entry point
     of the application.
 - directory mode :
     Similar to zip mode except that it automatically build the zip payload from
     the specified directory.
 - lua mode :
     Build the executable from a single Lua file.

Using `require` in embedded mode works as expected but `dofile` and `loadfile`
may not work as expected as these functions load from a external file rather
than from `package` loaders.

### Building / Contribution

To build lune from source, you need to take care that submodules are
imported, if not or you are unsure :

```shell
git submodule init
git submodule update
```

This make take some time depending on network bandwidth.
Then, lune should build as expected using `make` tool with a working C compiler.

A working Lua interpreter is needed, by default the luajit interpreter built
along with `libluajit.a` is used. In case of cross-compiling, you may want to
change which Lua interpreter is used to a one your system supports.
You can specify the interpreter with the `LUA` variable.

#### Debugging

You can use [Local Lua Debugger for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=tomblind.local-lua-debugger-vscode)
to provide debugging support with Visual Studio Code.
You need to add this at the beginning of your code to use it : 
```lua
do local f = getmetatable(rl).__index;rawset(rl, "__index", function (_, k) return select(2, pcall(f, _, k)) end) end
package.path = package.path .. os.getenv "LUA_PATH"
local lldebugger = require "lldebugger"; lldebugger.start()
```
You also need to setup a launch configuration in Visual Studio Code to run raylua_s with debugger attached, e.g
```json
{
    "type": "lua-local",
    "request": "launch",
    "name": "(Lua) Launch",
    "cwd": "${workspaceFolder}",
    "program": { "command": "PATH TO raylua_s" },
    "args": [ "main.lua OR ${file} OR WHATEVER" ]
}
```
This debugger doesn't support pausing, you need to place a breakpoint before executing
to get a actual debug, otherwise, a error needs to be thrown in the application to get the debugging.
This debugger has a significant overhead, expect a performance loss in intensive projects.

### Licence

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
