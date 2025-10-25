local module = {}

module._num = 0
local function get()
    module._num+=1
    return module._num-1
end

module.get = get

return module