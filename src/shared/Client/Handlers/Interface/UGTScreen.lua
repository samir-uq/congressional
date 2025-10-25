local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local StateDataManager = require(ReplicatedStorage.Shared.Client.Handlers.StateDataManager)
local Background = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.Background)
local BillDisplay = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.BillDisplay)
local ChamberDataContainer = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.ChamberDataContainer)
local UserGeneratedDisplay = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.UserGeneratedDisplay)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Layout = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Layout)
local Text = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Text)
local ColorPallete = require(ReplicatedStorage.Shared.Client.Interface.MetaData.ColorPallete)
local TrackerUtil = require(ReplicatedStorage.Shared.Client.Interface.Utils.TrackerUtil)
local StateData = require(ReplicatedStorage.Shared.Configs.Data.StateData)
local Interface = {}

local LocalPlayer = Players.LocalPlayer

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Child = Fusion.Child

local Dependency = {
    Container = Container,
    Button = Button,
    Layout = Layout,
    Text = Text,
    UserGeneratedDisplay = UserGeneratedDisplay
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>

local forkedInfo: Fusion.Value<any>

function Interface.Create(scope: scope, props: {
    visible: state<boolean>,
    currentFrame: Fusion.Value<string>,
})

    forkedInfo = scope:Value({})

    scope = scope:innerScope(Dependency)
    return scope:Hydrate(scope:Container {
        size = UDim2.fromScale(1,1),
    }) {
        Visible = props.visible,
        [Children] = Child {
            scope:Text {
                disableShadow = true,
                color = Color3.new(1,1,1),
                text = "Simulated User Generated Topics",
                size = UDim2.fromScale(1, 0.1),
                position = UDim2.fromScale(0.5, 0),
                anchorPoint = Vector2.new(0.5, 0)
            },

            scope:New("ScrollingFrame")({
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(0.6, 0.7),
                BackgroundTransparency = 1,

                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.new(),
                ScrollBarImageColor3 = ColorPallete.greyFive,
                ScrollBarThickness = 0,
                VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
                TopImage = "rbxassetid://71418806063429",
                MidImage = "rbxassetid://140249735342084",
                BottomImage = "rbxassetid://116318494421504",
                ScrollingDirection = Enum.ScrollingDirection.Y,

                [Children] = Child({

                    scope:New "UIListLayout" {

                        Padding = UDim.new(0.02),
                        FillDirection = Enum.FillDirection.Vertical,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Top,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalFlex = Enum.UIFlexAlignment.Fill
                    },

                    scope:ForPairs(forkedInfo, function(use, scope: scope, key, value)
    
                        return TrackerUtil.get(), scope:UserGeneratedDisplay {
                            visible = props.visible,
                            id = key,
                            authenticated = value.Authenticated,
                            publishDate = value.PublishDate,
                            publisher = value.Publisher,
                            title = value.Title,
                            content = value.Data,
                            lean = value.Lean,
                        }
                    end)
                })
            }),

            scope:Computed(function(use)
                local button = scope:Button {
                    color = ColorPallete.whiteTwo,
                    visible = props.visible,
                    size = UDim2.fromScale(0.15, 0.08),
                    position = UDim2.fromScale(0.5, 0.94),
                    roundness = 0.1,
                    onClick = function()
                        props.currentFrame:set("Menu")
                    end
                }

                scope:Hydrate(button:FindFirstChildWhichIsA("ImageButton") :: ImageButton) {
                    [Children] = Child {
                        scope:Text {
                            disableShadow = true,
                            text = "Return",
                        }
                    }
                }

                return button
            end),
        }
    }
end

function Interface.Start()
    StateDataManager.GetSignals().UGT:Connect(function()
        if not forkedInfo then return end
        forkedInfo:set(StateDataManager.Get().UGT)
    end)
end

return Interface