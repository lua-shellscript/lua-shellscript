
local commands = {}

local path = require("sh.path")

-- based on shell.lua, by Peter Odding

local function escape(...)
 local command = type(...) == 'table' and ... or { ... }
 for i, s in ipairs(command) do
  s = (tostring(s) or ''):gsub('"', '\\"')
  if s:find '[^A-Za-z0-9_."/-]' then
   s = '"' .. s .. '"'
  elseif s == '' then
   s = '""'
  end
  command[i] = s
 end
 return table.concat(command, ' ')
end

commands.ok = {}
setmetatable(commands.ok, {
   __index = function(self, program)
      return function(...)
         return os.execute(escape(program, ...)) == 0
      end
   end,
})

commands.out = {}
setmetatable(commands.out, {
   __index = function(self, program)
      return function(...)
         local fd = io.popen(escape(program, ...), "r")
         local result = fd:read("*a")
         fd:close()
         return result
      end
   end,
})

commands.inp = {}
setmetatable(commands.inp, {
   __index = function(self, program)
      return function(...)
         local args = {...}
         return function(data)
            local fd = io.popen(escape(program, unpack(args)), "w")
            fd:write(data)
            fd:close()
         end
      end
   end,
})

commands.lines = {}
setmetatable(commands.lines, {
   __index = function(self, program)
      return function(...)
         local fd = io.popen(escape(program, ...), "r")
         local linesf = fd:lines()
         return function()
            local line = linesf()
            if line then
               return line
            else
               fd:close()
               return nil
            end
         end
      end
   end,
})

commands.tokens = {}
setmetatable(commands.tokens, {
   __index = function(self, program)
      return function(...)
         local fd = io.popen(escape(program, ...), "r")
         local linesf = fd:lines()
         return function()
            local line = linesf()
            if line then
               return unpack(path.split(line, "%s"))
            else
               fd:close()
               return nil
            end
         end
      end
   end,
})

commands.run = {}
setmetatable(commands.run, {
   __index = function(self, program)
      return function(...)
         return os.execute(escape(program, ...))
      end
   end,
})

commands.env = {}
setmetatable(commands.env, {
   __index = function(self, var)
      return function(...)
         return os.getenv(var)
      end
   end,
})

return commands

