local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Layout = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Layout)
local Text = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Text)
local ColorPallete = require(ReplicatedStorage.Shared.Client.Interface.MetaData.ColorPallete)
local StateData = require(ReplicatedStorage.Shared.Client.Interface.MetaData.StateData)
local UIConfiguration = require(ReplicatedStorage.Shared.Client.Interface.MetaData.UIConfiguration)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

local Dependency = {
    Container = Container,
    Button = Button,
    Layout = Layout,
    Text = Text
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>
return function (scope: scope, props: {
    visible: state<boolean>,
    size: state<UDim2>?,
    position: state<UDim2>?,

    name: state<string>?,
    state: state<string>?,
    district: state<string>?,
    party: state<string>?,
    termStartYear: state<string>?,
})
    local scope: scope = scope:innerScope(Dependency)

    local isHovering = scope:Value(false)
    local hoverScaleValue = scope:Computed(function(use, scope: scope)
        return if use(isHovering) then 1 else 0
    end)
    local hoverSpring = scope:Spring(hoverScaleValue, 12, 0.8)

    local colorObject = scope:Computed(function(use)
        return ColorPallete[use(props.party)] or Color3.new()
    end)

    local order = scope:Computed(function(use)
        return if use(isHovering) then 100 else 1
    end)

    local button = scope:Hydrate(scope:Button {
        roundness = 1,
        size = props.size or UDim2.fromScale(0.4, 0.4),
        color = colorObject,
        visible = props.visible,
        position = props.position,
        transparency = 0,
        hovering = isHovering
    }) {
        SizeConstraint = Enum.SizeConstraint.RelativeXX,
        ZIndex = order,

        [Children] = Child {
            scope:New "UIAspectRatioConstraint" {
                AspectRatio = 1,
            },

        }
    }

    scope:Hydrate(button:FindFirstChildWhichIsA("ImageButton") :: ImageButton) {
        [Children] = Child {
            scope:Hydrate(scope:Container {
                size = UDim2.fromOffset(UIConfiguration.statsSize*0.8,UIConfiguration.statsSize*0.95),
                position = UDim2.fromScale(1.03,0.4),
                anchorPoint = Vector2.new(),
                transparency = 0,
                color = ColorPallete.whiteOne
            }) {
                [Children] = Child {
                    scope:New "UICorner" {
                        CornerRadius = UDim.new(0.15),
                    },
                    scope:New "UIScale" {
                        Scale = hoverSpring
                    },

                    scope:Hydrate(scope:Container {
                        size = UDim2.fromScale(0.95, 0.95)
                    }) {
                        [Children] = Child{
                            scope:Layout {
                                visible = isHovering,
                                fillDir = Enum.FillDirection.Vertical,
                                verticalAlignment = Enum.VerticalAlignment.Center,
                                padding = UDim.new(0.01, 0),
                                loadOrigin = "left",
                                animationSide = "left",
                                content = {
                                    scope:Text {
                                        disableShadow = true,
                                        color = Color3.new(),
                                        text = props.name,
                                        size = UDim2.fromScale(1, 0.3)
                                    },

                                    scope:Text {
                                        disableShadow = true,
                                        color = Color3.fromRGB(24, 23, 23),
                                        text = scope:Computed(function(use)
                                            local currentState = use(props.state)
                                            local currentDistrict = use (props.district)

                                            if not currentState or currentState == "" then
                                                currentState = "NA"
                                            end

                                            local final = currentState

                                            if currentDistrict and currentDistrict ~= "" then
                                                final..= " District ".. currentDistrict
                                            end

                                            return final
                                        end),
                                        size = UDim2.fromScale(1, 0.2)
                                    },

                                    scope:Text {
                                        disableShadow = true,
                                        color = colorObject,
                                        text = props.party,
                                        size = UDim2.fromScale(1, 0.2)
                                    },

                                    scope:Text {
                                        disableShadow = true,
                                        color = Color3.fromRGB(24, 23, 23),
                                        text = scope:Computed(function(use)
                                            return "Year Started: ".. use(props.termStartYear)
                                        end),
                                        size = UDim2.fromScale(1, 0.2),
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }

    return button
end