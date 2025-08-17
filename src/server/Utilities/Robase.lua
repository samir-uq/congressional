local RobaseService = require(script.Parent.RobaseService.Service)

local BaseURL = "https://congress-475e3-default-rtdb.firebaseio.com/"
local Token = "SeABuIx6vAvevr5vDU63HZOs59wfZXc133BrzCQ7"

return RobaseService.new(BaseURL, Token)