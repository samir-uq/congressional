local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameTypes = require(ReplicatedStorage.Shared.Configs.GameTypes)
local ClientEvent = require(ReplicatedStorage.Shared.Event.ClientEvent)


local SimulationAction = {}

function SimulationAction.Vote(UGT: boolean?, Id: string, Vote: boolean): (boolean, string)
    local Result = ClientEvent.Vote.Invoke({
        UGT = UGT or false,
        Id = Id,
        Vote = Vote,
    })

    return Result.Success, Result.Result
end

function SimulationAction.CreateUGT(Title: string, Body: string, Lean: number): (boolean, string)
    local Result = ClientEvent.CreateUGT.Invoke({
        Title = Title,
        Body = Body,
        Lean = Lean
    })

    return Result.Success, Result.Result
end

function SimulationAction.CreateBill(SimulatedBill: GameTypes.SimBillCore, Lean: number?): GameTypes.SimRes
    local Result = ClientEvent.RunSim.Invoke({
        Global = if Lean then false else true,
        CongressLean = Lean or 0,
        SimulatingBill = SimulatedBill,
    })

    return Result
end

function SimulationAction.Start()
    -- task.wait(4)
	-- print(SimulationAction.CreateUGT("Gun Ban Now!", "Ban all guns!", -1))
	-- print(SimulationAction.Vote(true, "{051265fc-dca3-4917-a448-d39ca3fcb45e}", true))
	-- print(SimulationAction.CreateBill({
	-- 	Name = "Gun Rights of 2026",
	-- 	Topics = {"Education"},
	-- 	Content = "This will eradicate all further gun usage.",
	-- 	Prewrittens = {"{90737baa-0191-4a44-9658-5e36e8eae16c}"}
	-- }))
	-- print(SimulationAction.Vote(false, "{dca4fdd3-aed7-482e-bd58-0631d294586d}", true))
	
	-- print(SimulationAction.CreateBill({
	-- 	Name = "Gun Rights of 2025",
	-- 	Topics = {"Education"},
	-- 	Content = "This will eradicate all further gun usage.",
	-- 	Prewrittens = {"{90737baa-0191-4a44-9658-5e36e8eae16c}"}
	-- }, -1))
end

return SimulationAction