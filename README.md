# WWLua
Static website generator based on Lua 5.4

## Requirements
- Lua 5.4
- Windows 8.1 or higher

## Features
- Runs completely on Lua
- Simple syntax to get used to

## Getting Started
To build a project, use any Lua interceptor of your choice, and make a new script. You will need to require the ```builder.lua``` module in this project. Below is an example of how it is setup
```lua
local builder = require("builder")

local content = {
  head = {},
  body = {
    {"paragraph", "Welcome to my page!"}
  },
}

local page = builder.create(content)
```
