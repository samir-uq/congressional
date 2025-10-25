local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local StateData = require(ReplicatedStorage.Shared.Configs.Data.StateData)
local UGT = require(script.Parent.UGT)
local TopicsList = require(ReplicatedStorage.Shared.Configs.Data.TopicsList)
local GameTypes = require(ReplicatedStorage.Shared.Configs.GameTypes)
local ServerEvent = require(ReplicatedStorage.Shared.Event.ServerEvent)
local Robase = require(ServerScriptService.Server.Utilities.Robase)


local Sim = {}
-- local Cooldowns = {}

local AllSim = {}

local SimulationBase = (Robase :: any):GetRobase("Simulation")
local COOLDOWN_PER_SIMULATION = 1
local MIN_VOTES = 1


local function IsBillValid(SimulatedBill: GameTypes.SimBillCore): (boolean, number)

	if type(SimulatedBill.Name) ~= "string" then
		return false, 1
	end

	if SimulatedBill.Name:len() > 250 then
		return false, 2
	end

	if type(SimulatedBill.Topics)~="table" then
		return false, 3
	end

	for _, Topic in SimulatedBill.Topics do
		if table.find(TopicsList, Topic) then continue end
		table.remove(SimulatedBill.Topics, table.find(SimulatedBill.Topics, Topic))
	end

	if #SimulatedBill.Topics == 0 then
		return false, 4
	end

	if type(SimulatedBill.Content)~="string" then
		return false, 5
	end

	if type(SimulatedBill.Prewrittens)~="table" then
		return false, 6
	end

	UGT.RefreshContent()
	local PrewrittenContent = UGT.GetContent()

	for _, UserTopic in SimulatedBill.Prewrittens do
		if not PrewrittenContent[UserTopic] then
			table.remove(SimulatedBill.Prewrittens, table.find(SimulatedBill.Prewrittens, UserTopic))
		end
	end

	return true, 7
end

function BiasedRandom(Lean)
	Lean = math.clamp(Lean, -1, 1)
	local Raw = math.random() * 2 - 1
	local BiasedStrength = math.abs(Lean)
	return Raw * (1 - BiasedStrength) + Lean * BiasedStrength
end

function Sim.UpdateClient(Player: Player?, SimBillList: GameTypes.SimBillList)
	local Data: any = {
        SimBill = SimBillList
    }
    if Player then
        ServerEvent.UpdateState.Fire(Player, Data)
    else
        ServerEvent.UpdateState.FireAll(Data)
    end
end

function Sim.GetSimulatedResults(SimulatedBill: GameTypes.SimBillCore, CongressLean: number): (boolean, any)
	if not IsBillValid(SimulatedBill) then
		return false, {}
	end

	if #SimulatedBill.Prewrittens == 0 then
		return false, {}
	end

	local Results = {
		HOR = {
			Votes = {},
			Passed = false,
		},

        Senate = {
			Votes = {},
			Passed = false,
		},


		LawPassed = false,
		EndOfLaw = "House Failed",
	}

	local BillLean = 0
	local PrewrittenContent = UGT.GetContent()
	for _, Prewritten in SimulatedBill.Prewrittens do
		local PrewrittenData = PrewrittenContent[Prewritten]
		if not PrewrittenData then continue end

		BillLean += PrewrittenData.Lean or 0
	end

	BillLean /= #SimulatedBill.Prewrittens
	local VotedYes = 0

	for State, HORCount: any in StateData.HORCount do
		for X = 1, HORCount do
			local Vote = math.abs(BiasedRandom(CongressLean)-BillLean) < 1
			Results.HOR.Votes[`{State}/{X}`] = Vote

			if Vote then VotedYes += 1 end
		end
	end

	print(`HOR DECISION: {VotedYes}/435`)

	if VotedYes/435 > 0.5 then
		Results.HOR.Passed = true
	else
		Results.LawPassed = false
		return true, Results
	end

	VotedYes = 0

	for State, _ in StateData.HORCount do
		for X = 1, 2 do
			local Vote = math.abs(BiasedRandom(CongressLean)-BillLean) < 1
			Results.Senate.Votes[`{State}/{X}`] = Vote

			if Vote then VotedYes += 1 end
		end
	end
	print(`Senate DECISION: {VotedYes}/100`)
	if VotedYes > 50 then
		Results.Senate.Passed = true
	end

	if VotedYes == 50 then
		local Vote = math.abs(BiasedRandom(CongressLean)-BillLean) < 1
		Results.Senate.VicePresident = Vote
		Results.Senate.Passed = Vote
	end

	if VotedYes < 50 and not Results.Senate.VicePresident then
		Results.LawPassed = false
		Results.EndOfLaw = "Senate Failed"
		return true, Results
	end

	Results.LawPassed = true
	Results.EndOfLaw = "Passed"

	return true, Results
end

function Sim.CreateGlobal(Player: Player, SimulatedBill: GameTypes.SimBillCore): (boolean, string)
	local Valid, ReasonNum = IsBillValid(SimulatedBill)
	if not Valid  then
		return false, "Failed to validate bill. Reason ".. ReasonNum
	end

	-- if Cooldowns[Player] then
	-- 	return false, "Attempt again in " .. math.round(COOLDOWN_PER_SIMULATION - (DateTime.now().UnixTimestamp - Cooldowns[Player]))
	-- end

	local PublicationTime = DateTime.now().UnixTimestamp
	local Id = HttpService:GenerateGUID()


	-- Cooldowns[Player] = PublicationTime
	-- task.delay(COOLDOWN_PER_SIMULATION, function()
	-- 	Cooldowns[Player] = nil
	-- end)

	local BillData = {
		Publisher = Player.UserId,
		PublishDate = PublicationTime,
		Authenticated = false,

		Bill = SimulatedBill
	}

	local Success, Result = pcall(function()
		SimulationBase:UpdateAsync("Content", function(Current)
			Current = Current or {}

			Current[Id] = BillData

			AllSim = Current

			return Current
		end)
	end)

	if not Success then
		return false, "Error"
	end

    Sim.UpdateClient(nil, {[Id] = AllSim[Id]})

	return true, Id
end

function Sim.VoteGlobal(Player: Player, BillId: string, VotingYes: boolean): (boolean, string)
	if not AllSim[BillId] then
		return false, "Invalid data"
	end

	local RatifyBill = false

	local Success, Result = pcall(function()
		SimulationBase:UpdateAsync("Votes", function(Current)
			Current = Current or {}
			Current[BillId] = Current[BillId] or {}
			Current[BillId][Player.UserId] = VotingYes

			local TotalCount = 0
			local SuccessCount = 0

			for _, Value in Current[BillId] do
				TotalCount += 1
				if Value then SuccessCount += 1 end
			end

			if (SuccessCount / TotalCount) > 0.5 and TotalCount >= MIN_VOTES then
				RatifyBill = true
			end

			return Current
		end)
	end)

	if RatifyBill then
		Success, Result = pcall(function()
			SimulationBase:UpdateAsync("Content", function(Current)
				Current = Current or {}
				if not Current[BillId] then return Current end

				Current[BillId].Authenticated = true

				AllSim = Current

				return Current
			end)
		end)

		if Success then
            Sim.UpdateClient(nil, {[BillId] = AllSim[BillId]})
		end
	end

	if not Success then
		return false, "Error"
	end

	return true, "Successfully voted!"
end

function Sim.RefreshContent()
    local _
	pcall(function()
		_, AllSim = SimulationBase:GetAsync("Content")
	end)
    Sim.UpdateClient(nil, AllSim)
end

function Sim.GetContent()
	return AllSim
end

function Sim.Start()
    ServerEvent.RunSim.On(function(Player: Player, Data): any
        if Data.Global then
            local Success, Result = Sim.CreateGlobal(Player, Data.SimulatingBill :: any)
			print(Success, Result)
            return {Success = Success, Result = Result}
        end

        local _, SimResult = Sim.GetSimulatedResults(Data.SimulatingBill :: any, Data.CongressLean or 0)
		SimResult.Success = true
		SimResult.Result = "Simulated Bill"
        return SimResult
    end)

    ServerEvent.Vote.On(function(Player: Player, Data)
        local Success, Result

        if Data.UGT then
            Success, Result = UGT.Vote(Player, Data.Id, Data.Vote)
        else
            Success, Result = Sim.VoteGlobal(Player, Data.Id, Data.Vote)
        end
		print(Success, Result)
        return {Success = Success, Result = Result}
    end)

    ServerEvent.CreateUGT.On(function(Player: Player, Data)
        local Success, Result = UGT.Create(Player, Data.Title, Data.Body, Data.Lean)
		print(Success, Result)
        return {Success = Success, Result = Result}
    end)

	Sim.RefreshContent()
end

return Sim