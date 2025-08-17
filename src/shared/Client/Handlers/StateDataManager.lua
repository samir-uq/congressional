local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
local GameTypes = require(ReplicatedStorage.Shared.Configs.GameTypes)
local ClientEvent = require(ReplicatedStorage.Shared.Event.ClientEvent)


local StateData = {}

local AmendmentCache: {GameTypes.Amendment} = {}
local BillsCache: {GameTypes.Bill} = {}
local MembersCache: {[string]: {GameTypes.Member}} = {}
local UGTCache: GameTypes.UGTList = {}
local SimBillCache: GameTypes.SimBillList = {}

local AmendmentUpdated = Signal.new()
local BillsUpdated = Signal.new()
local MembersUpdated = Signal.new()
local UGTUpdated = Signal.new()
local SimBillUpdated = Signal.new()

local function GetHash<A,B,C,D>(Items:{[C]:D},Processor: ((C,D)->(A,B))): {[A]: B}
    local Cache = {}
    for A,B in Items do
        local C,D = Processor(A,B)
        Cache[C] = D
    end
    return Cache
end

local function HandleData()
    ClientEvent.UpdateState.On(function(Data)
        if Data.Amendment then
            local Hash = GetHash(AmendmentCache, function(Key, Val)
                return Val.number, Key
            end)

            for Index, Amendment: any in Data.Amendment do
                if Hash[Amendment.number] then
                    AmendmentCache[Hash[Amendment.number]] = Amendment
                    continue
                end
                table.insert(AmendmentCache, Amendment)
            end
        end

        if Data.Bill then
            local Hash = GetHash(BillsCache, function(Key, Val)
                return Val.number, Key
            end)

            for Index, Bill: any in Data.Bill do
                if Hash[Bill.number] then
                    BillsCache[Hash[Bill.number]] = Bill
                    continue
                end
                table.insert(BillsCache, Bill)
            end
        end

        if Data.Members then
            for State, Members in Data.Members do
                MembersCache[State] = MembersCache[State] or {}
                local Hash = GetHash(MembersCache[State], function(Key, Val)
                    return Val.bioguideId, Key
                end)

                for Index, Member: any in Members do
                    if Hash[Member.bioguideId] then
                        MembersCache[State][Hash[Member.bioguideId]] = Member
                        continue
                    end
                    table.insert(MembersCache[State], Member)
                end
            end
        end

        if Data.UGT then
            for Key, UGT in Data.UGT do
                UGTCache[Key] = UGT
            end
        end

        if Data.SimBill then
            for Key, SimBill: any in Data.SimBill do
                SimBillCache[Key] = SimBill
            end
        end
    end)
end

function StateData.Get()
    return {
        Amendment = AmendmentCache,
        Bill = BillsCache,
        UGT = UGTCache,
        Members = MembersCache,
        SimBill = SimBillCache
    }
end

function StateData.Start()
    HandleData()
    ClientEvent.StateRequest.Fire()
end

return StateData