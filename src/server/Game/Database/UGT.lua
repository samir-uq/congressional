local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


local StateData = require(ReplicatedStorage.Shared.Configs.Data.StateData)
local GameTypes = require(ReplicatedStorage.Shared.Configs.GameTypes)
local ServerEvent = require(ReplicatedStorage.Shared.Event.ServerEvent)
local Robase = require(ServerScriptService.Server.Utilities.Robase)

local UGT = {}
-- local Cooldowns = {}


local TopicsBase = (Robase::any):GetRobase("UserGeneratedTopics")
local AllContent = {}
local COOLDOWN_PER_UGT = 250
local MIN_VOTES = 1

function UGT.UpdateClient(Player: Player?, UGTLIst: GameTypes.UGTList)
	local Data: any = {
        UGT = UGTLIst
    }
    if Player then
        ServerEvent.UpdateState.Fire(Player, Data)
    else
        ServerEvent.UpdateState.FireAll(Data)
    end
end

function UGT.Create(Player: Player, TopicTitle: string, TopicBody: string, TopicLean: number): (boolean, string)
	
	-- if Cooldowns[Player] then
	-- 	return false, "Attempt again in " .. math.round(COOLDOWN_PER_UGT - (DateTime.now().UnixTimestamp - Cooldowns[Player]))
	-- end
	
	if typeof(TopicTitle) ~= "string" then
		return false, "Invalid data"
	end
	
	if typeof(TopicBody) ~= "string" then
		return false, "Invalid data"
	end
	
	if typeof(TopicLean) ~= "number" then
		return false, "Invalid data"
	end
	
	if #TopicTitle > 25 then
		return false, "Title too long"
	end	

	TopicLean = math.clamp(TopicLean, -1, 1)
	
	local PublicationTime = DateTime.now().UnixTimestamp
	local Id = HttpService:GenerateGUID()
	
	-- Cooldowns[Player] = PublicationTime
	-- task.delay(COOLDOWN_PER_UGT, function()
	-- 	Cooldowns[Player] = nil
	-- end)
	
	local UGData = {
		Title = TopicTitle,
		Data = TopicBody,
		Lean = TopicLean,
		Publisher = Player.UserId,
		PublishDate = PublicationTime,
		Authenticated = false,
	}
	
	local Success, Result = pcall(function()
		TopicsBase:UpdateAsync("Content", function(Current)
			Current = Current or {}
			
			Current[Id] = UGData
			
			AllContent = Current
			return Current
		end,{})
	end)
	
	if not Success then
		return false, "Error"
	end
	
	UGT.UpdateClient(nil, {[Id] = AllContent[Id]})
	return true, Id
end

function UGT.Vote(Player: Player, UGId: string, VotingYes: boolean): (boolean, string)
	if typeof(UGId) ~= "string" then
		return false, "Invalid data"
	end
	if not AllContent[UGId] then
		return false, "Invalid data"
	end
	
	if type(VotingYes)~="boolean" then
		return false, "Invalid data"
	end
	
	local RatifyUGId = false
	
	local Success, Result = pcall(function()
		TopicsBase:UpdateAsync("Votes", function(Current)
			Current = Current or {}
			Current[UGId] = Current[UGId] or {}
			Current[UGId][Player.UserId] = VotingYes
			
			local TotalCount = 0
			local SuccessCount = 0
			
			for _, Value in Current[UGId] do
				TotalCount += 1
				if Value then SuccessCount += 1 end
			end
			
			if (SuccessCount / TotalCount) > 0.5 and TotalCount >= MIN_VOTES then
				RatifyUGId = true
			end
			
			return Current
		end)
	end)
	
	if RatifyUGId then
		Success, Result = pcall(function()
			TopicsBase:UpdateAsync("Content", function(Current)
				Current = Current or {}
				if not Current[UGId] then return Current end
				
				Current[UGId].Authenticated = true
				
				AllContent = Current
				return Current
			end)
		end)
		
		if Success then
			UGT.UpdateClient(nil, {[UGId] = AllContent[UGId]})
		end
	end
	
	if not Success then
		return false, "Error"
	end
	
	return true, "Successfully voted!"
end

function UGT.RefreshContent()
    local _
	pcall(function()
		_, AllContent = TopicsBase:GetAsync("Content")
	end)
	UGT.UpdateClient(nil, AllContent)
end

function UGT.GetContent()
	return AllContent
end

function UGT.Start()
	UGT.RefreshContent()
end

return UGT