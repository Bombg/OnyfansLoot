if not strsplit then
    function strsplit(delimiter, text)
        local result = {}
        local from = 1
        local delim_from, delim_to = string.find(text, delimiter, from)
        while delim_from do
            table.insert(result, string.sub(text, from, delim_from - 1))
            from = delim_to + 1
            delim_from, delim_to = string.find(text, delimiter, from)
        end
        table.insert(result, string.sub(text, from))
        return unpack(result)
    end
end

if not string.gmatch then
    string.gmatch = string.gfind
end

if not string.match then
    local function getargs(s, e, ...)
        return unpack(arg)
    end
    function string.match(str, pattern)
        if not str then str = "" end
        return getargs(string.find(str, pattern))
    end
end

if not string.trim then
    function string.trim(str)
        return (string.match(str, "^%s*(.-)%s*$"))
    end
end

if not table.wipe then
    function table.wipe(tbl)
        for key in next, tbl do
            tbl[key] = nil
        end
    end
end
if not wipe then
    wipe = table.wipe
end

if not hooksecurefunc then
    ---@overload fun(name, hook)
    function hooksecurefunc(table, name, hook)
        if not hook then
            name, hook = table, name
            table = _G
        end

        local old = table[name]
        assert(type(old) == "function")
        table[name] = function(...)
            local result = { old(unpack(arg)) }
            hook(unpack(arg))
            return unpack(result)
        end
    end
end
