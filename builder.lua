-- // builder.lua
-- // Description: Transpile Lua code into a syntactically correct format.
-- // Author: Komodo794
-- // Date: 2025-04-29
-- // Notes: terrible code :skull:

local module = {}
module.__index = module

-- // VALID TAGS WILL BE FILTERED OUT FOR STYLES
local VALID_TAGS = {
  "<p>",
  "</p>",
  "<h>",
  "</h>"
}

-- // USED FOR STYLES, IF NOT ONE OF THESE ELEMENTS, ADD A .
local ELEMENTS = {
  "body",
  "p",
}

local currentStyle = "#b" -- APPLYS STYLE TO STYLE, DUH!

-- // INDEX FOR PLACING HTML ELEMENTS ON THE PAGE
local function functions(name, content, appendToStyle)
  if appendToStyle then
    currentStyle = appendToStyle
  end
  local FUNCTIONS = {
    title = function() return module:title(content[2]) end,
    header = function() return module:header(content[2], content[3], content["style"] or nil) end,
    paragraph = function() return module:paragraph(content[2], content["style"] or content[3] or nil) end,
    horizontalrule = function() return module:horizontalrule() end,
    textcolor = function() return module:textcolor(content[2]) end,
    backgroundcolor = function() return module:backgroundcolor(content[2]) end,
    textallign = function() return module:textallign(content[2]) end,
    gradient = function() return module:backgroundgradient(content[2], content[3], content[4]) end,
    font = function() return module:font(content[2]) end,
    padding = function() return module:padding(content[2]) end,
    image = function() return module:image(content[2], content[3], content[4] or nil, content["style"]) end,
  }

  FUNCTIONS[content[1]]() -- Retrieve only the requested function
end

-- // RETURN EVERY LINE INSIDE THE CURRENT PAGE HTML
local function get_lines(page)
  return page.read(page)
end

-- // PUT CODE INSIDE A READABLE TABLE
local function get_page_contents(page)
  local contents = get_lines(page)
  local pagestuff = {}
  for tag in contents:gmatch("[^>]+>") do
    table.insert(pagestuff, tag)
  end
  return pagestuff
end

-- // TURN CODE INTO A STRING
local function new_code(pagestuff)
  local combinedCode = ""
  for _, entry in pairs(pagestuff) do
    combinedCode = combinedCode .. entry
  end
  return combinedCode
end

-- // PLACE TAG INTO CODE
local function append_tag(page, contents, pagestuff, text, starttag, closetag, where)
  contents = get_lines(page)
  for tag in contents:gmatch("[^>]+>") do
    if string.find(tag, where) then
      if closetag ~= nil then
        table.insert(pagestuff, starttag .. text .. closetag)
      else
        table.insert(pagestuff, starttag)
      end
    end
    table.insert(pagestuff, tag)
  end
  return pagestuff, contents
end

-- // WRITE NEW PAGE DATA TO HTML FILE
local function write_data(data)
  local page = io.open("index.html", "w")
  if page then
    page:write(data)
    page:close()
  end
end

-- // APPEND STYLE TAG TO THE CODE LINE
local function stylize(replacement, lookFor)
  local page = io.open("index.html", "r")
  local newData = ""
  local contents = get_lines(page)
  for entry in contents:gmatch("[^>]+>") do
    if string.find(entry, lookFor) then
      entry = replacement
    end
    newData = newData .. entry
  end
  return newData
end

-- // UPDATES START TAG TO HAVE CLASS IF SPECIFIED
function give_class(startTag, styleName)
  local newTag = string.sub(startTag, 1, #startTag - 1) .. ' class = "' .. styleName .. '">'
  return newTag
end

-- // REMOVE TAGS AND RETURN ONLY THE TEXT
local function extract_text(code)
  local finalString = code
  for _, validTag in pairs(VALID_TAGS) do
    finalString = string.gsub(finalString, validTag, "")
  end
  return finalString
end

-- [STYLES]
function module.bold(code)
  local page = io.open("index.html", "r")
  local pagestuff = {}
  local contents = get_lines(page)

  -- extract string
  local finalString = extract_text(code)

  for entry in contents:gmatch("[^>]+>") do
    if string.find(entry, finalString) then
      local newStyle = "<b>" .. code .. "</b>"
      pagestuff = stylize(newStyle, finalString)
      write_data(pagestuff)
    end
  end
  return code -- fallback
end

function module.italic(code)
  local page = io.open("index.html", "r")
  local pagestuff = {}
  local contents = get_lines(page)

  -- extract string
  local finalString = extract_text(code)

  for entry in contents:gmatch("[^>]+>") do
    if string.find(entry, finalString) then
      local newStyle = "<i>" .. code .. "</i>"
      pagestuff = stylize(newStyle, finalString)
      write_data(pagestuff)
    end
  end
  return code -- fallback
end

-- [ELEMENTS]
function module:textcolor(text)
  local page = io.open("index.html", "r")
  local pagestuff = {}
  if page then
    pagestuff = get_page_contents(page) -- GET CODE
    for i, v in pairs(pagestuff) do
      local newStyle = string.gsub(v, currentStyle, "color: " .. text .. "; " .. currentStyle)
      pagestuff[i] = newStyle
    end
    write_data(new_code(pagestuff)) -- CREATE NEW CODE
  end
end

function module:backgroundcolor(text)
  local page = io.open("index.html", "r")
  local pagestuff = {}
  if page then
    pagestuff = get_page_contents(page) -- GET CODE
    for i, v in pairs(pagestuff) do
      local newStyle = string.gsub(v, currentStyle, "background-color: " .. text .. "; " .. currentStyle)
      pagestuff[i] = newStyle
    end
    write_data(new_code(pagestuff)) -- CREATE NEW CODE
  end
end

function module:backgroundgradient(angle, color1, color2)
  local page = io.open("index.html", "r")
  local pagestuff = {}
  if page then
    pagestuff = get_page_contents(page) -- GET CODE
    for i, v in pairs(pagestuff) do
      local newStyle = string.gsub(v, currentStyle,
        "background-image: linear-gradient(" .. angle .. "deg, " .. color1 .. ", " .. color2 .. "); " .. currentStyle)
      pagestuff[i] = newStyle
    end
    write_data(new_code(pagestuff)) -- CREATE NEW CODE
  end
end

function module:textallign(text)
  local page = io.open("index.html", "r")
  local pagestuff = {}
  if page then
    pagestuff = get_page_contents(page) -- GET CODE
    for i, v in pairs(pagestuff) do
      local newStyle = string.gsub(v, currentStyle, "text-align: " .. text .. "; " .. currentStyle)
      pagestuff[i] = newStyle
    end
    write_data(new_code(pagestuff)) -- CREATE NEW CODE
  end
end

function module:font(text)
  local page = io.open("index.html", "r")
  local pagestuff = {}
  if page then
    pagestuff = get_page_contents(page) -- GET CODE
    for i, v in pairs(pagestuff) do
      local newStyle = string.gsub(v, currentStyle, "font-family: " .. text .. "; " .. currentStyle)
      pagestuff[i] = newStyle
    end
    write_data(new_code(pagestuff)) -- CREATE NEW CODE
  end
end

function module:padding(text)
  local page = io.open("index.html", "r")
  local pagestuff = {}
  if page then
    pagestuff = get_page_contents(page) -- GET CODE
    for i, v in pairs(pagestuff) do
      local newStyle = string.gsub(v, currentStyle, "padding: " .. text .. "; " .. currentStyle)
      pagestuff[i] = newStyle
    end
    write_data(new_code(pagestuff)) -- CREATE NEW CODE
  end
end

function module:title(text) -- <title></title>
  local page = io.open("index.html", "r")
  local pagestuff = {}
  local contents
  print("stop")
  if page then
    -- gets line and puts data in table
    pagestuff = append_tag(page, contents, pagestuff, text, "<title>", "</title>", "</head>")

    -- prints table entries
    write_data(new_code(pagestuff))
  end
end

function module:paragraph(text, style) -- <h1, h2, h3...></h>
  local page = io.open("index.html", "r")
  local pagestuff = {}
  local contents
  local startTag, endTag = "<p>", "</p>"
  if style ~= nil and type(style) == "string" then -- update tag for classes
    startTag = give_class(startTag, style)
  end
  if page then
    -- gets line and puts data in table
    pagestuff = append_tag(page, contents, pagestuff, text, startTag, endTag, "</body>")

    -- prints table entries
    write_data(new_code(pagestuff))
    local codeLine = "<p>" .. text .. "</p>"

    if style and type(style) == "table" then -- placeholder, not efficient at all!
      for i, v in pairs(style) do
        if v == "b" then
          module.bold(codeLine)
        end
        if v == "i" then
          module.italic(codeLine)
        end
      end
    end

    return codeLine
  end
end

function module:header(headerType, text, style) -- <h1, h2, h3...></h>
  local page = io.open("index.html", "r")
  local pagestuff = {}
  local contents
  local startTag, endTag = "<h" .. headerType .. ">", "</h" .. headerType .. ">"
  if style ~= nil and type(style) == "string" then -- update tag for classes
    startTag = give_class(startTag, style)
  end
  if page then
    -- gets line and puts data in table
    pagestuff = append_tag(page, contents, pagestuff, text, startTag, endTag, "</body>")

    -- prints table entries
    write_data(new_code(pagestuff))
    return "<h" .. headerType .. ">" .. text .. "</h" .. headerType .. ">"
  end
end

function module:image(imageLink, width, height, style) -- <h1, h2, h3...></h>
  local page = io.open("index.html", "r")
  local pagestuff = {}
  local contents
  if not height then
    height = width
  end
  local startTag = '<img src = "' .. imageLink .. '" width = "' .. width .. '" height = "' .. height .. '">'
  if style then
    startTag = '<img src = "' ..
    imageLink .. '" width = "' .. width .. '" height = "' .. height .. '" class = "' .. style .. '">'
  end
  if page then
    -- gets line and puts data in table
    pagestuff = append_tag(page, contents, pagestuff, nil, startTag, nil, "</body>")

    -- prints table entries
    write_data(new_code(pagestuff))
    return startTag
  end
end

function module:horizontalrule() -- <hr>
  local page = io.open("index.html", "r")
  local pagestuff = {}
  local contents
  if page then
    -- gets line and puts data in table
    pagestuff = append_tag(page, contents, pagestuff, nil, "<hr>", nil, "</body>")

    -- prints table entries
    write_data(new_code(pagestuff))
  end
end

-- // CREATE HTML PAGE WITH PROPER TEMPLATE
function module.create(param)
  local self = setmetatable({}, module)
  local page = io.open("index.html", "w")
  local data = {}
  if page then
    table.insert(data, "<html>")
    table.insert(data, "<head>")
    table.insert(data, "</head>")
    table.insert(data, "<style>")
    --table.insert(data, "button {color: white; background-color: rgba(210, 4, 45, 0.5); width: 180px; height = 40px; padding: 12px; font-size: 18px; font-family: Tahoma; border-radius: 10px; border: none;}")
    for _, section in pairs(param) do               -- head, body
      for functionName, content in pairs(section) do
        if type(content[1]) ~= "string" then        -- if is proper style
          local functionNewName = functionName      -- name for style
          local isStyle = false
          for _, validElement in pairs(ELEMENTS) do -- if style name isn't a valid element, then add a . to the beginning
            if validElement == functionName then isStyle = true end
          end
          if not isStyle then functionNewName = "." .. functionNewName end
          table.insert(data, functionNewName .. " {#" .. string.sub(functionName, 1, 2) .. "} ")
        end
      end
    end
    table.insert(data, "</style>")
    table.insert(data, "<body>")
    table.insert(data, "</body>")
    table.insert(data, "</html>")
    for _, line in pairs(data) do
      page:write(line)
    end
    page:close()
  end
  -- ugly solution, need to account for duplicate index
  for _, section in pairs(param) do -- head, body
    for functionName, content in pairs(section) do
      if type(content[1]) ~= "string" then
        local appendToStyle = "#" .. string.sub(functionName, 1, 2) .. "}"
        for styleIndex, styleData in pairs(content) do
          functions(styleIndex, styleData, appendToStyle)
        end
      else
        functions(functionName, content)
      end
    end
  end
  return self
end

return module
