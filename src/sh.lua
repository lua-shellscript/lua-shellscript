
sh = {}

local function import_to(tbl, mod)
   local modtbl = require(mod)
   for k,v in pairs(modtbl) do
      tbl[k] = v
   end
end

import_to(sh, "sh.path")
import_to(sh, "sh.commands")

require "sh.alt_getopt"

function sh.getopt(short_opts, long_opts, ...)
   local arg = {...}
   local options, idx = alt_getopt.get_opts (arg, short_opts, long_opts)
   local outargs = {}
   for i = idx, #arg do
      table.insert(outargs, arg[i])
   end
   return options, outargs
end

sh.test = {}
setmetatable(sh.test, {
   __index = function(t, k)
      local fn = function(...)
         return sh.ok.test("-"..k, ...)
      end
      rawset(t, k, fn)
      return fn
   end
})

function sh.die(msg)
   print(msg)
   os.exit(1)
end

return sh

