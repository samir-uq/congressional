local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Confetti = require(script.Parent.Confetti)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local SimulationActions = require(ReplicatedStorage.Shared.Client.Handlers.SimulationActions)
local StateDataManager = require(ReplicatedStorage.Shared.Client.Handlers.StateDataManager)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Layout = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Layout)
local ProgressBar = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.ProgressBar)
local Text = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Text)
local ColorPallete = require(ReplicatedStorage.Shared.Client.Interface.MetaData.ColorPallete)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

local Dependency = {
    Container = Container,
    Layout = Layout,
    Text = Text,
    Button = Button,
    ProgressBar = ProgressBar,
    Confetti = Confetti
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>
return function (scope: any, props: {
    visible: state<boolean>,
    title: state<string>,
    publisher: state<number>,
    publishDate: state<number>,
    content: state<string>,
    authenticated: state<boolean>,
    prewritterns: state<string>,
    id: state<string>,
})
    local scope: scope = scope:innerScope(Dependency)

    local buttonYes = scope:Button {
        color = ColorPallete.greenOne,
        visible = props.visible,
        size = UDim2.fromScale(0.15, 1),
        position = UDim2.fromScale(0.1, 0.5),
        anchorPoint = Vector2.new(0, 0.5),
        roundness = 0.1,
        onClick = function()
            SimulationActions.Vote(false, peek(props.id), true)
            scope:Confetti {
                ConfettiCount = 100
            }
        end
    }

    local buttonNo = scope:Button {
        color = ColorPallete.redOne,
        visible = props.visible,
        size = UDim2.fromScale(0.15, 1),
        position = UDim2.fromScale(0.9, 0.5),
        anchorPoint = Vector2.new(1, 0.5),
        roundness = 0.1,
        onClick = function()
           SimulationActions.Vote(false, peek(props.id), false)
           scope:Confetti {
            ConfettiCount = 100
        }
        end
    }

    scope:Hydrate(buttonYes:FindFirstChildWhichIsA("ImageButton") :: ImageButton) {
        [Children] = Child {
            scope:Text {
                disableShadow = true,
                text = "Vote Yes",
            }
        }
    }

    scope:Hydrate(buttonNo:FindFirstChildWhichIsA("ImageButton") :: ImageButton) {
        [Children] = Child {
            scope:Text {
                disableShadow = true,
                text = "Vote No",
            }
        }
    }

    return scope:Hydrate(scope:Container {
        size = UDim2.fromScale(1, 0.4),
        transparency = 0,
        color = Color3.new(1,1,1),
    }) {
        LayoutOrder = props.publishDate,
        [Children] = Child {
            scope:New "UICorner" {
                CornerRadius = UDim.new(0.1),
            },

            scope:Layout {
                visible = props.visible,
                loadOrigin = "left",
                animationSide = "left",
                horizontalAlignment = Enum.HorizontalAlignment.Center,
                padding = UDim.new(0.01),

                content = {
                    scope:Text {
                        disableShadow = true,
                        text = props.title,
                        size = UDim2.fromScale(0.9, 0.1),
                        alignmentX = Enum.TextXAlignment.Center,
                        color = Color3.new()
                    },

                    scope:Text {
                        disableShadow = true,
                        text = scope:Computed(function(use)
                            local owner = use(props.publisher)
                            local when = use(props.publishDate) or 0

                            local username
                            local date: any = DateTime.fromUnixTimestamp(when):ToLocalTime()

                            local month = date.Month
                            local day = date.Day
                            local year = date.Year % 100
                            
                            local dateDisplay = string.format("%02d/%02d/%02d", month, day, year)
                            pcall(function()
                                username = Players:GetNameFromUserIdAsync(owner or 0)
                            end)

                            local finalDisplay = "Proposed on " .. dateDisplay
                            if username and username ~= "" then
                                finalDisplay = finalDisplay.. " by ".. username
                            end
                            return finalDisplay
                        end),
                        size = UDim2.fromScale(0.9, 0.05),
                        alignmentX = Enum.TextXAlignment.Left,
                        color = ColorPallete.greySeven,
                    },


                    scope:Text {
                        disableShadow = true,
                        text = scope:Computed(function(use)
                            local mainContent: string = use(props.content)
                            local prewritterns: {string} = use(props.prewritterns) or {}

                            local final = mainContent
                            for _, prewrittenId: string in prewritterns do
                                local exists = StateDataManager.Get().UGT[prewrittenId]
                                if exists then
                                    final = final .. "\n\n" .. exists.Data
                                end
                            end

                            return final
                        end),
                        size = UDim2.fromScale(0.9, 0.6125),
                        alignmentX = Enum.TextXAlignment.Left,
                        alignmentY = Enum.TextYAlignment.Top,
                        textSize = 20,
                        color = Color3.new()
                    },

                    scope:Text {
                        disableShadow = true,
                        text = scope:Computed(function(use)
                            local authenticated = use(props.authenticated)
                            if authenticated then
                                return "Bill has been authenticated"
                            end
                            return "Bill has not been authenticated"
                        end),
                        size = UDim2.fromScale(0.9, 0.05),
                        alignmentX = Enum.TextXAlignment.Left,
                        color = ColorPallete.greySeven,
                    },

                    scope:Hydrate(scope:Container {
                        size = UDim2.fromScale(1, 0.1)
                    }) {
                        [Children] = Child {
                            buttonYes,
                            buttonNo
                        }
                    }
                }
            }
        }
    }
end