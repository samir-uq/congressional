local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Confetti = require(script.Parent.Confetti)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local SimulationActions = require(ReplicatedStorage.Shared.Client.Handlers.SimulationActions)
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
    lean: state<number>,
    content: state<string>,
    authenticated: state<boolean>,
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
            local Success = SimulationActions.Vote(true, peek(props.id), true)
            if not Success then return end
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
            local Success = SimulationActions.Vote(true, peek(props.id), false)
            if not Success then return end
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
        LayoutOrder = scope:Computed(function(use)
            return -use(props.publishDate)
        end),
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

                    scope:ProgressBar {
                        size = UDim2.fromScale(0.5, 0.1),
                        percentage = scope:Computed(function(use)
                            local lean: number = use(props.lean) or 0
                            return math.abs(lean)
                        end),
                        direction = "center-side",
                        children = scope:Hydrate(scope:Container {
                            size = UDim2.fromScale(1,1)
                        }) {
                            [Children] = Child {
                                scope:Hydrate(scope:Container {
                                    size = UDim2.fromScale(1, 1),
                                    color = ColorPallete.Democratic,
                                    transparency = scope:Computed(function(use)
                                        if use(props.lean) < 0 then return 0 else return 1 end
                                    end)
                                }) {
                                    [Children] = Child {
                                        scope:New "UICorner" {
                                            CornerRadius = UDim.new(1),
                                        }
                                    }
                                },

                                scope:Hydrate(scope:Container {
                                    size = UDim2.fromScale(1, 1),
                                    color = ColorPallete.Republican,
                                    transparency = scope:Computed(function(use)
                                        if use(props.lean) >= 0 then return 0 else return 1 end
                                    end)
                                }) {
                                    [Children] = Child {
                                        scope:New "UICorner" {
                                            CornerRadius = UDim.new(1),
                                        }
                                    }
                                },

                                scope:Text {
                                    disableShadow = true,
                                    text = scope:Computed(function(use)
                                        return "Lean: " .. math.round(use(props.lean)::number*1000)/1000
                                    end),
                                    size = UDim2.fromScale(0.3,0.5),
                                    alignmentX = Enum.TextXAlignment.Center,
                                    color = Color3.new(1,1,1)
                                },
                            }
                        }
                    } :: any,

                    scope:Text {
                        disableShadow = true,
                        text = props.content,
                        size = UDim2.fromScale(0.9, 0.5125),
                        alignmentX = Enum.TextXAlignment.Left,
                        alignmentY = Enum.TextYAlignment.Top,
                        maxSize = 20,
                        color = Color3.new()
                    },

                    scope:Text {
                        disableShadow = true,
                        text = scope:Computed(function(use)
                            local authenticated = use(props.authenticated)
                            if authenticated then
                                return "Topic has been authenticated"
                            end
                            return "Topic has not been authenticated"
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