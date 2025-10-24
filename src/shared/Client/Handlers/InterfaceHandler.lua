local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local BackgroundFrame = require(ReplicatedStorage.Shared.Client.Handlers.Interface.BackgroundFrame)
local GlobalDisplayOptionScreen = require(ReplicatedStorage.Shared.Client.Handlers.Interface.GlobalDisplayOptionScreen)
local HORDisplayFrame = require(ReplicatedStorage.Shared.Client.Handlers.Interface.HORDisplayFrame)
local MainOptionScreen = require(ReplicatedStorage.Shared.Client.Handlers.Interface.MainOptionScreen)
local SenateDisplayFrame = require(ReplicatedStorage.Shared.Client.Handlers.Interface.SenateDisplayFrame)
local SimulatedBillScreen = require(ReplicatedStorage.Shared.Client.Handlers.Interface.SimulatedBillScreen)
local UGTScreen = require(ReplicatedStorage.Shared.Client.Handlers.Interface.UGTScreen)
local Background = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.Background)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Interface = {}

local LocalPlayer = Players.LocalPlayer

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Child = Fusion.Child

local Dependency = {
    Background = BackgroundFrame.Create,
    MainOptionScreen = MainOptionScreen.Create,
    SenateDisplayFrame = SenateDisplayFrame.Create,
    HORDisplayFrame = HORDisplayFrame.Create,
    GlobalDisplayOptionScreen = GlobalDisplayOptionScreen.Create,
    SimulatedBillScreen = SimulatedBillScreen.Create,
    UGTScreen = UGTScreen.Create
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>

local scope: any = scoped(Dependency, Fusion)

function Interface.Start()
    local visible = scope:Value("Menu")

    scope:New "ScreenGui" {
        Parent = LocalPlayer.PlayerGui,
        IgnoreGuiInset = true,
        [Children] = {
            scope:Background {},
            scope:MainOptionScreen {
                visible = scope:Computed(function(use)
                    return use(visible) == "Menu"
                end),
                currentFrame = visible,
            },

            scope:SenateDisplayFrame {
                visible = scope:Computed(function(use)
                    return use(visible) == "View Senate"
                end),
                currentFrame = visible,

            },

            scope:HORDisplayFrame {
                visible = scope:Computed(function(use)
                    return use(visible) == "View HOR"
                end),
                currentFrame = visible,
            },

            scope:GlobalDisplayOptionScreen {
                visible = scope:Computed(function(use)
                    return use(visible) == "Global"
                end),
                currentFrame = visible,
            },

            scope:SimulatedBillScreen {
                visible = scope:Computed(function(use)
                    return use(visible) == "View Simulated Bills"
                end),
                currentFrame = visible,
            },

            scope:UGTScreen {
                visible = scope:Computed(function(use)
                    return use(visible) == "View User Generated"
                end),
                currentFrame = visible,
            }

        }
    }
end

return Interface