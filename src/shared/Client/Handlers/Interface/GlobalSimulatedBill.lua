local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VoiceChatInternal = game:GetService("VoiceChatInternal")
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

local forkedInfo: Fusion.Value<any>

function Interface.Create(scope: scope, props: {
    visible: state<boolean>,
    currentFrame: Fusion.Value<string>,
})

    forkedInfo = scope:Value({})
    scope = scope:innerScope(Dependency)

    local name = scope:Value("")
    local content = scope:Value("")
    local prewrittens = scope:Value({})

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
                text = "Global Simulated Bill",
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
                                size = UDim2.fromScale(1, 0.5125),
                                textYAlignment = Enum.TextYAlignment.Top,
                                textScaled = false,
                                textSize = 25,
                                placeholderText = "Bill Content"
                            },

                            scope:Hydrate(scope:Container {
                                size = UDim2.fromScale(1, 0.25),
                            }) {
                                [Children] = Child {
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
                                            scope:Hydrate(scope:Container {
                                                size = UDim2.fromScale(1, 0.48),
                                                transparency = 0,
                                                color = ColorPallete.whiteOne,
                                            }) {
                                                [Children] = Child {
                                                    scope:New "UICorner" {
                                                        CornerRadius = UDim.new(0, 20),
                                                    },

                                                    scope:New("ScrollingFrame")({
                                                        AnchorPoint = Vector2.new(0.5, 0.5),
                                                        Position = UDim2.fromScale(0.5, 0.5),
                                                        Size = UDim2.fromScale(0.98, 0.98),
                                                        BackgroundTransparency = 1,
                                        
                                                        AutomaticCanvasSize = Enum.AutomaticSize.X,
                                                        CanvasSize = UDim2.new(),
                                                        ScrollBarImageColor3 = ColorPallete.greyFive,
                                                        ScrollBarThickness = 0,
                                                        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
                                                        ScrollingDirection = Enum.ScrollingDirection.Y,
                                                        
                                                        [Children] = Child {
                                                            scope:Computed(function(use)
                                                                use(prewrittens)
                                                                use(forkedInfo)
                                                                local childrens: any = scope:Layout {
                                                                    padding = UDim.new(0.02, 0),
                                                                    fillDir = Enum.FillDirection.Horizontal,
                                                                    horizontalAlignment = Enum.HorizontalAlignment.Left,
                                                                    verticalAlignment = Enum.VerticalAlignment.Center,
                                                                    animationSide = "left",
                                                                    loadOrigin = "left",
                                                                    sortOrder = Enum.SortOrder.LayoutOrder,
                                                                    horizontalFlex = Enum.UIFlexAlignment.Fill,
                                                                    inversedSetup = false,
                                                                    visible = props.visible,
                                            
                                                                    content = scope:Computed(function(use, scope: scope)    
                                                                        local kids = scope:ForPairs(prewrittens, function(use, scope: scope, key, value)
                                                                            local button = scope:Button {
                                                                                color = ColorPallete.greyTwo,
                                                                                size = UDim2.fromScale(0.3, 0.9),
                                                                                roundness = 0.1,
                                                                                visible = props.visible,
                                                                                onClick = function()
                                                                                    local found = use(prewrittens)
                                                                                    table.remove(found, key)
                                                                                    prewrittens:set(found)
                                                                                end
                                                                            }
                                                                            
                                                                            scope:Hydrate(button:FindFirstChildWhichIsA("ImageButton") :: ImageButton) {
                                                                                [Children] = Child {
                                                                                    scope:Text {
                                                                                        size = UDim2.fromScale(0.95, 0.95),
                                                                                        disableShadow = true,
                                                                                        text = scope:Computed(function(use)
                                                                                            local titleName = StateDataManager.Get().UGT[value]
                                                                                            if not titleName then
                                                                                                return ""
                                                                                            end

                                                                                            return titleName.Title
                                                                                        end),
                                                                                    }
                                                                                }
                                                                            }

                                                                            return key, button
                                                                        end)
                                                                       return peek(kids)
                                                                    end)
                                                                }
                                        
                                                                -- local finalChildren = childrens:GetChildren()
                                                                -- local outcome = {}

                                                                -- for _, child in finalChildren do
                                                                --     if not child:IsA("Frame") then
                                                                --         table.insert(outcome, child)
                                                                --         continue
                                                                --     end

                                                                --     local finalFrame = child:FindFirstChildWhichIsA("Frame")
                                                                --     scope:Hydrate(finalFrame) {
                                                                --         Size = child.Size,
                                                                --     }

                                                                --     table.insert(outcome, finalFrame)
                                                                -- end
                                                                -- warn(outcome)
                                                                -- return outcome
                                                                return childrens:GetChildren()
                                                            end)
                                                        }
                                                    }),
                                                }
                                            },

                                            scope:SelectOptions {
                                                opened = selectionOpened,
                                                items = scope:Computed(function(use)
                                                    local ugtInformation = use(forkedInfo)
                                                    local listOfItems = {}

                                                    for id, data in ugtInformation do
                                                        if not data.Authenticated then
                                                            continue
                                                        end
                                                        table.insert(listOfItems, {name = data.Title, id = id})
                                                    end
                                                    return listOfItems
                                                end),
                                                onSelect = function(id)
                                                    local found = StateDataManager.Get().UGT[id]
                                                    if not id then return end

                                                    local prewrittenList = peek(prewrittens)
                                                    if table.find(prewrittenList, id) then
                                                        return
                                                    end
                                                    table.insert(prewrittenList, id)
                                                    prewrittens:set(prewrittenList)
                                                end

                                            }
                                        }
                                    }
                                }
                            }
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
                       local Success = SimulationActions.CreateBill({
                            Content = peek(content),
                            Name = peek(name),
                            Prewrittens = peek(prewrittens),
                            Topics = {"Education"}
                       })

                       if not Success then
                        return
                       end

                       scope:Confetti {
                        ConfettiCount = 100
                        }

                        props.currentFrame:set("View Simulated Bills")
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
    StateDataManager.GetSignals().UGT:Connect(function()
        if not forkedInfo then return end
        forkedInfo:set(StateDataManager.Get().UGT)
    end)
end

return Interface