-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local Fusion = require(ReplicatedStorage.Packages.Fusion)
-- local New = Fusion.New
-- local Spring = Fusion.Spring
-- local Value = Fusion.Value

-- local Player = game.Players.LocalPlayer
-- local PlayerGui = Player.PlayerGui

-- return function(ConfettiCount: number, MaxSpringSpeed: number?, WaitForEach: number?, MaxLeft: number?, MaxRight: number?, ConfettiMinSize: Vector2?, ConfettiMaxSize: Vector2?, ColorRange: {Color3}?)
-- 	local NewCanvas = New("ScreenGui") {
-- 		ResetOnSpawn = false,
-- 		DisplayOrder = 100,
-- 		IgnoreGuiInset = true,
-- 		ScreenInsets = Enum.ScreenInsets.None,
-- 		Name = "Confetti",
-- 		Parent = PlayerGui
-- 	}

-- 	local Length = (MaxSpringSpeed and math.round(3.5/MaxSpringSpeed)+1) or 3

-- 	local MinSize = Vector2.new(ConfettiMinSize and ConfettiMinSize.X or 5, ConfettiMinSize and ConfettiMinSize.Y or 5)
-- 	local MaxSize = Vector2.new(ConfettiMaxSize and ConfettiMaxSize.X or 12, ConfettiMaxSize and ConfettiMaxSize.Y or 20)

-- 	local MinPos = Vector2.new(MaxLeft and MaxLeft or 0.35 -0.4)
-- 	local MaxPos = Vector2.new(MaxRight and MaxRight or 0.65 ,-0.2)

-- 	local RandomSeed = Random.new()

-- 	for _ = 1, ConfettiCount or 80 do
-- 		local FinalPos = UDim2.fromScale(RandomSeed:NextNumber(MinPos.X, MaxPos.X), RandomSeed:NextNumber(MinPos.Y, MaxPos.Y))

-- 		local Scale, Rot, Pos = Value(0), Value(0), Value(UDim2.fromScale(FinalPos.X.Scale + RandomSeed:NextNumber(-0.15, 0.15), 1.2))

-- 		local ScaleSpring = Spring(Scale, 32, 0.25)
-- 		local RotSpring = Spring(Scale, 32, 0.35)
-- 		local PosSpring = Spring(Pos, RandomSeed:NextNumber(0.1, MaxSpringSpeed or 2.5), 0.35)

-- 		local Color

-- 		if ColorRange then
-- 			Color = ColorRange[math.random(1, #ColorRange)]
-- 		else
-- 			Color = Color3.new(math.random(), math.random(), math.random())
-- 		end

-- 		local ConfettiInstance = New("Frame") {
-- 			AnchorPoint = Vector2.new(0.5, 0.5),
-- 			Interactable = false,
-- 			BackgroundColor3 = Color,
-- 			Parent = NewCanvas,

-- 			Size = UDim2.fromOffset(RandomSeed:NextNumber(MinSize.X, MaxSize.X), RandomSeed:NextNumber(MinSize.Y, MaxSize.Y)),
-- 			Position = PosSpring,
-- 			Rotation = RotSpring,
-- 		}

-- 		local UIScale = New("UIScale") {
-- 			Scale = ScaleSpring,
-- 			Parent = ConfettiInstance
-- 		}

-- 		Scale:set(1.5)
-- 		PosSpring:setPosition(FinalPos)
-- 		task.spawn(function()
-- 			for x = 1, (Length*3) do
-- 				RotSpring:addVelocity(RandomSeed:NextNumber(-3, 3) * 40)
-- 				task.wait(0.2)
-- 			end
-- 		end)

-- 		task.delay(Length/1.3, function()
-- 			Scale:set(0)
-- 		end)

-- 		if WaitForEach then task.wait(WaitForEach) end
-- 	end


-- 	task.delay(Length*1.2, function()
-- 		NewCanvas:Destroy()
-- 	end)
-- end



local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

local Dependency = {

}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>
return function (props: {
    scope: scope,
    ConfettiCount: number, 
    MaxSpringSpeed: number?, 
    WaitForEach: number?, 
    MaxLeft: number?, 
    MaxRight: number?, 
    ConfettiMinSize: Vector2?, 
    ConfettiMaxSize: Vector2?, 
    ColorRange: {Color3}?
})
    local scope = props.scope:innerScope()


    local Length = (props.MaxSpringSpeed and math.round(3.5/props.MaxSpringSpeed)+1) or 3

	local MinSize = Vector2.new(props.ConfettiMinSize and props.ConfettiMinSize.X or 5, props.ConfettiMinSize and props.ConfettiMinSize.Y or 5)
	local MaxSize = Vector2.new(props.ConfettiMaxSize and props.ConfettiMaxSize.X or 12, props.ConfettiMaxSize and props.ConfettiMaxSize.Y or 20)

	local MinPos = Vector2.new(props.MaxLeft and props.MaxLeft or 0.35 -0.4)
	local MaxPos = Vector2.new(props.MaxRight and props.MaxRight or 0.65 ,-0.2)

	local RandomSeed = Random.new()

    local NewCanvas
    NewCanvas = scope:New "ScreenGui" {
        ResetOnSpawn = false,
        DisplayOrder = 100,
        IgnoreGuiInset = true,
        ScreenInsets = Enum.ScreenInsets.None,
        Parent = Players.LocalPlayer.PlayerGui,
        [Children] = Child {
            scope:ForKeys(table.create(props.ConfettiCount or 80), function(use, scope: scope, index: number)
                local FinalPos = UDim2.fromScale(RandomSeed:NextNumber(MinPos.X, MaxPos.X), RandomSeed:NextNumber(MinPos.Y, MaxPos.Y))

		        local Scale, Rot, Pos = scope:Value(0), scope:Value(0), scope:Value(UDim2.fromScale(FinalPos.X.Scale + RandomSeed:NextNumber(-0.15, 0.15), 1.2))

		        local ScaleSpring = scope:Spring(Scale, 32, 0.25)
		        local RotSpring = scope:Spring(Scale, 32, 0.35)
		        local PosSpring = scope:Spring(Pos, RandomSeed:NextNumber(0.1, props.MaxSpringSpeed or 2.5), 0.35)

		        local Color

                if props.ColorRange then
                    Color = props.ColorRange[math.random(1, #props.ColorRange)]
                else
                    Color = Color3.new(math.random(), math.random(), math.random())
                end

                local MetaData = scope:New "Frame" {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Interactable = false,
                    BackgroundColor3 = Color,
                    Size = UDim2.fromOffset(RandomSeed:NextNumber(MinSize.X, MaxSize.X), RandomSeed:NextNumber(MinSize.Y, MaxSize.Y)),
                    Position = PosSpring,
                    Rotation = RotSpring,
                    Parent = NewCanvas,

                    [Children] = Child {
                        scope:New "UIScale" {
                            Scale = ScaleSpring,
                        },


                    }
                }

                Scale:set(1.5)
                PosSpring:setPosition(FinalPos)

                task.spawn(function()
                    for x = 1, (Length*3) do
                        RotSpring:addVelocity(RandomSeed:NextNumber(-3, 3) * 40)
                        task.wait(0.2)
                    end
                end)

                task.delay(Length/1.3, function()
                    Scale:set(0)
                end)

                if props.WaitForEach then task.wait(props.WaitForEach) end
                
                return MetaData
            end)
        }
    }

    task.delay(Length*1.2, function()
        if not scope then return end
        scope:doCleanup()
    end)

    return NewCanvas
end
