local APIKey = "17NKdA3L6hn1rRLiTm9D2zYF7xlLUtePwtKkR47Z"
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Simulation = require(script.Parent.Simulation)
local UGT = require(script.Parent.UGT)
local StateData = require(ReplicatedStorage.Shared.Configs.Data.StateData)
local GameTypes = require(ReplicatedStorage.Shared.Configs.GameTypes)
local ServerEvent = require(ReplicatedStorage.Shared.Event.ServerEvent)

local NextBillData = nil
local NextAmendmentData = nil

local CongressAPI = {}

local BillsCache: {GameTypes.Bill} = {}
local AmendmentsCache: {GameTypes.Amendment} = {}
local MemberCache: {[string]: {GameTypes.Member}} = {}

function CongressAPI.GetURL(Params: {[string]: string},...: string) 
	local Keys = {...}
	
	local Prefix = "https://api.congress.gov/v3"
	
	for _, Key in Keys do
		Prefix..="/"..Key
	end
	Prefix ..="?"
	
	for Key, Val in Params do
		Prefix..=Key.."="..Val.."&"
	end
	
	return Prefix.."format=json&api_key="..APIKey
end

function CongressAPI.Get(URL: string): {}
	local Result = HttpService:GetAsync(URL)
	
	local Success, Result = pcall(function()
		return HttpService:JSONDecode(Result)
	end)
	
	if Success then return Result else return {} end
end

function CongressAPI.UpdateClients(Player: Player?)
    local Data: any = {
        Amendment = AmendmentsCache,
        Bill = BillsCache,
        Members = MemberCache,
        UGT = UGT.GetContent(),
        SimBill = Simulation.GetContent()
    }
    if Player then
        ServerEvent.UpdateState.Fire(Player, Data)
    else
        ServerEvent.UpdateState.FireAll(Data)
    end
end

function CongressAPI.GetNextSetOfAmendment()
	local NextUrl = NextAmendmentData or CongressAPI.GetURL({limit = "250"},"amendment")
	local FetchedData: GameTypes.AmendmentRequest = CongressAPI.Get(NextUrl) :: any

	NextAmendmentData = FetchedData.pagination.next.."&api_key="..APIKey

    local CurrentCache = {}
	for _, Bill in FetchedData.amendments do
		table.insert(AmendmentsCache, Bill)
        table.insert(CurrentCache, Bill)
	end

     ServerEvent.UpdateState.FireAll({
        Amendment = CurrentCache :: any
    })
end

function CongressAPI.GetNextSetOfBills()
	local NextUrl = NextBillData or CongressAPI.GetURL({limit = "250"},"bill")
	local FetchedData: GameTypes.BillRequest = CongressAPI.Get(NextUrl) :: any
	
	NextBillData = FetchedData.pagination.next.."&api_key="..APIKey
	
    local CurrentCache = {}
	for _, Bill in FetchedData.bills do
		table.insert(BillsCache, Bill)
        table.insert(CurrentCache, Bill)
	end

    ServerEvent.UpdateState.FireAll({
        Bill = CurrentCache :: any
    })
end


function CongressAPI.Start()
    ServerEvent.StateRequest.On(function(Player: Player)
        CongressAPI.UpdateClients(Player)
    end)

	
	local AllFinished = 0
	for _, ID in StateData.StateID do
		task.spawn(function()
			local URL = CongressAPI.GetURL({currentMember = "True", limit = "100"}, "member", ID)
            local FetchedData: GameTypes.MemberRequest = CongressAPI.Get(URL) :: any
			MemberCache[ID] = FetchedData.members
			AllFinished += 1
		end)
	end

	CongressAPI.GetNextSetOfAmendment()
	CongressAPI.GetNextSetOfBills()	

	while (AllFinished < 50) do
		task.wait()
	end
	CongressAPI.UpdateClients()
end



return CongressAPI