

local function attrib(path,field)
    assert_string(1,path)
    assert_string(2,field)
    if not attributes then return nil end
    local attr,err = attributes(path)
    if not attr then return raise(err)
    else
        return attr[field]
    end
end

--- return an absolute path.
-- @param path A file path
function abspath(path)
    assert_string(1,path)
    if not currentdir then return path end
    if not isabs(path) then
        return join(currentdir(),path)
    else
        return path
    end
end

--- is this a directory?
-- @param path A file path
function isdir(path)
    return attrib(path,'mode') == 'directory'
end

--- is this a file?.
-- @param path A file path
function isfile(path)
    return attrib(path,'mode') == 'file'
end

--- return size of a file.
-- @param path A file path
function getsize(path)
    return attrib(path,'size')
end

--- does a path exist?.
-- @param path A file path
function exists(path)
    if attributes then
        return attributes(path) ~= nil
    else
        local f = io.open(path,'r')
        if f then
            f:close()
            return true
        else
            return false
        end
    end
end

--- Return the time of last access as the number of seconds since the epoch.
-- @param path A file path
function getatime(path)
    return attrib(path,'access')
end

--- Return the time of last modification
-- @param path A file path
function getmtime(path)
    return attrib(path,'modification')
end

---Return the system's ctime.
-- @param path A file path
function getctime(path)
    return attrib(path,'change')
end

