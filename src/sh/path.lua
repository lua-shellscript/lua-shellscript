
--- Path manipulation module
-- based on Penlight 0.8b by Steve Donovan,
-- which was modelled after Python's os.path library (11.1)

local path = {}

local getenv = os.getenv
local sub = string.sub

local function at(s,i)
    return sub(s,i,i)
end

local function assert_string(n, str)
    local t = type(str)
    if t ~= "string" then
        error("bad argument #"..tostring(n).." (string expected, got "..t..")")
    end
end

local sep = '/'
local dirsep = ':'

--- given a path, return the directory part and a file part.
-- if there's no directory part, the first value will be empty
-- @param path A file path
function path.splitpath(path)
    assert_string(1,path)
    local i = #path
    local ch = at(path,i)
    while i > 0 and ch ~= sep and ch ~= other_sep do
        i = i - 1
        ch = at(path,i)
    end
    if i == 0 then
        return '',path
    else
        return sub(path,1,i-1), sub(path,i+1)
    end
end

--- given a path, return the root part and the extension part.
-- if there's no extension part, the second value will be empty
-- @param path A file path
function path.splitext(path)
    assert_string(1,path)
    local i = #path
    local ch = at(path,i)
    while i > 0 and ch ~= '.' do
        if ch == sep or ch == other_sep then
            return path,''
        end
        i = i - 1
        ch = at(path,i)
    end
    if i == 0 then
        return path,''
    else
        return sub(path,1,i-1),sub(path,i)
    end
end

--- return the directory part of a path
-- @param path A file path
function path.dirname(path)
    assert_string(1,path)
    local p1,p2 = path.splitpath(path)
    return p1
end

--- return the file part of a path
-- @param path A file path
function path.basename(path)
    assert_string(1,path)
    local p1,p2 = path.splitpath(path)
    return p2
end

--- get the extension part of a path.
-- @param path A file path
function path.extension(path)
    assert_string(1,path)
    p1,p2 = path.splitext(path)
    return p2
end

--- is this an absolute path?.
-- @param path A file path
function path.isabs(path)
    assert_string(1,path)
    if is_windows then
        return at(path,1) == '/' or at(path,1)=='\\' or at(path,2)==':'
    else
        return at(path,1) == '/'
    end
end

--- return the path resulting from combining the two paths.
-- if the second is already an absolute path, then it returns it.
-- @param p1 A file path
-- @param p2 A file path
function path.join(p1,p2)
    assert_string(1,p1)
    assert_string(2,p2)
    if path.isabs(p2) then return p2 end
    local endc = at(p1,#p1)
    if endc ~= sep and endc ~= other_sep then
        p1 = p1..sep
    end
    return p1..p2
end

--- Normalize the case of a pathname. On Unix, this returns the path unchanged;
--  for Windows, it converts the path to lowercase, and it also converts forward slashes
-- to backward slashes. Will also replace '\dir\..\' by '\' (PL extension!)
-- @param path A file path
function path.normcase(path)
    assert_string(1,path)
    if is_windows then
        return (path:lower():gsub('/','\\'):gsub('\\[^\\]+\\%.%.',''))
    else
        return path
    end
end

--- Replace a starting '~' with the user's home directory.
-- In windows, if HOME isn't set, then USERPROFILE is used in preference to
-- HOMEDRIVE HOMEPATH. This is guaranteed to be writeable on all versions of Windows.
-- @param path A file path
function path.expanduser(path)
    assert_string(1,path)
    if at(path,1) == '~' then
        local home = getenv('HOME')
        if not home then -- has to be Windows
            home = getenv 'USERPROFILE' or (getenv 'HOMEDRIVE' .. getenv 'HOMEPATH')
        end
        return home..sub(path,2)
    else
        return path
    end
end

--- return the largest common prefix path of two paths.
-- @param path1 a file path
-- @param path2 a file path
function common_prefix (path1,path2)
    assert_string(1,path1)
    assert_string(2,path2)
    -- get them in order!
    if #path1 > #path2 then path2,path1 = path1,path2 end
    for i = 1,#path1 do
        local c1 = at(path1,i)
        if c1 ~= at(path2,i) then
            local cp = path1:sub(1,i-1)
            if at(path1,i-1) ~= sep then
                cp = path.dirname(cp)
            end
            return cp
        end
    end
    if at(path2,#path1+1) ~= sep then path1 = path.dirname(path1) end
    return path1
    --return ''
end

function path.dir(...)
    local dir = table.concat({...}, "/")
    return dir:gsub("/+", "/")
end

function path.split(str, delim)
   if not delim then delim="%s" end
   local tks = {}
   for tk in str:gmatch("[^"..delim.."]+") do
      table.insert(tks, tk)
   end
   return tks
end

return path

