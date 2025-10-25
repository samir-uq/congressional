local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local SimulationActions = require(ReplicatedStorage.Shared.Client.Handlers.SimulationActions)
local StateDataManager = require(ReplicatedStorage.Shared.Client.Handlers.StateDataManager)
local Background = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.Background)
local BillDisplay = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.BillDisplay)
local ChamberDataContainer = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.ChamberDataContainer)
local Confetti = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.Confetti)
local Searchbar = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.Searchbar)
local SelectOptions = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.SelectOptions)
local UserGeneratedDisplay = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.UserGeneratedDisplay)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Layout = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Layout)
local Text = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Text)
local ColorPallete = require(ReplicatedStorage.Shared.Client.Interface.MetaData.ColorPallete)
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
    Searchbar = Searchbar,
    SelectOptions = SelectOptions,
    Confetti = Confetti
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>


function Interface.Create(scope: scope, props: {
    visible: state<boolean>,
    currentFrame: Fusion.Value<string>,
})

    scope = scope:innerScope(Dependency)

    local name = scope:Value("")
    local content = scope:Value("")
    local leanText = scope:Value("0")
    local lean = scope:Computed(function(use)
        local tonum = math.clamp(tonumber(use(leanText)) or 0, -1, 1)
        return tonum
    end)

    local selectionOpened = scope:Value(false)
    scope:Observer(props.visible):onBind(function()
        local isFalse = peek(props.visible) == false
        if not isFalse then return end
        selectionOpened:set(false)
    end)

    return scope:Hydrate(scope:Container {
        size = UDim2.fromScale(1,1),
    }) {
        Visible = props.visible,
        [Children] = Child {
            scope:Text {
                disableShadow = true,
                color = Color3.new(1,1,1),
                text = "User Generated Topics",
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
                    scope:Layout {
                        padding = UDim.new(0.02, 0),
                        fillDir = Enum.FillDirection.Vertical,
                        horizontalAlignment = Enum.HorizontalAlignment.Center,
                        verticalAlignment = Enum.VerticalAlignment.Top,
                        animationSide = "left",
                        loadOrigin = "left",
                        sortOrder = Enum.SortOrder.LayoutOrder,
                        horizontalFlex = Enum.UIFlexAlignment.Fill,
                        inversedSetup = false,
                        visible = props.visible,

                        content = {
                            scope:Searchbar {
                                text = name,
                                size = UDim2.fromScale(1, 0.1),
                                placeholderText = "Title",
                            },

                            scope:Searchbar {
                                text = content,
                                size = UDim2.fromScale(1, 0.65),
                                textYAlignment = Enum.TextYAlignment.Top,
                                textScaled = false,
                                textSize = 25,
                                placeholderText = "Topic Content"
                            },

                            scope:Searchbar {
                                text = leanText,
                                size = UDim2.fromScale(1, 0.1),
                                placeholderText = "Lean [-1,1]",
                            },
                        }
                    }
                })
            }),

            scope:Computed(function(use)
                local button = scope:Button {
                    color = ColorPallete.greenOne,
                    visible = props.visible,
                    size = UDim2.fromScale(0.5, 0.08),
                    position = UDim2.fromScale(0.5, 0.83),
                    roundness = 0.1,
                    onClick = function()
                        local Success = SimulationActions.CreateUGT(peek(name), peek(content), peek(lean))
                        if not Success then return end
                       scope:Confetti {
                        ConfettiCount = 100
                        }

                        props.currentFrame:set("View User Generated")
                    end
                }

                scope:Hydrate(button:FindFirstChildWhichIsA("ImageButton") :: ImageButton) {
                    [Children] = Child {
                        scope:Text {
                            disableShadow = true,
                            text = "Propose",
                        }
                    }
                }

                return button
            end),

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
   
end

return Interface