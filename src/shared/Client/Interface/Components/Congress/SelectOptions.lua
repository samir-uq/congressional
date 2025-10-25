local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Image = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Image)
local Layout = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Layout)
local ProgressBar = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.ProgressBar)
local Text = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Text)
local ColorPallete = require(ReplicatedStorage.Shared.Client.Interface.MetaData.ColorPallete)
local StateData = require(ReplicatedStorage.Shared.Client.Interface.MetaData.StateData)
local DelayValue = require(ReplicatedStorage.Shared.Client.Interface.Utils.DelayValue)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

local Dependency = {
    Container = Container,
    Image = Image,
    Button = Button,
    Text = Text,
    ProgressBar = ProgressBar,
    Layout = Layout
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>
return function (scope: any, props: {
    opened: Fusion.Value<boolean>,
    items: state<any>,-- TODO,
    onSelect: ((any)->()),
})
    local scope: scope = scope:innerScope(Dependency)


    local rotVal = scope:Computed(function(use, scope: scope)
        return if use(props.opened) then 180 else 0
    end)
    local rotSpring = scope:Spring(rotVal, StateData.GetSpring("qualityfilterRotation"), StateData.GetDamp("qualityfilterRotation"))

    local dropdownOpenPercentage = scope:Computed(function(use, scope: scope)
        return if use(props.opened) then 1 else 0
    end)
    local dropdownOpenPercentageSpring = scope:Spring(dropdownOpenPercentage, StateData.GetSpring("qualityfilterSize"), StateData.GetDamp("qualityfilterSize"))
    
    local valSprings: {Fusion.Spring<number>} = {}
    local function changed()
        if not peek(props.opened) then
            return
        end
        for _, spr: Fusion.Spring<number> in valSprings do
            spr:addVelocity(-1000)
        end
    end
    scope:Observer(props.opened):onChange(changed)


    local button = scope:Button {
        visible = true,
        size = UDim2.fromScale(0.7, 0.4),
        -- image = "rbxassetid://109184285128135",
        roundness = 0.125,
        animationSide = "top",
        color = Color3.new(1,1,1),
        onClick = function()
            props.opened:set(not peek(props.opened))
        end,

        position = UDim2.fromScale(0, 1),
    }

    scope:Hydrate(button:FindFirstChildWhichIsA("ImageButton") :: ImageButton) {
        Size = UDim2.fromScale(0.95, 0.8),
        [Children] = Child {

            scope:Hydrate(scope:Image {
                size = UDim2.fromScale(0.45, 0.45),
                sizeConstraint = Enum.SizeConstraint.RelativeYY,
                position = UDim2.fromScale(0.95, 0.43),
                image = "rbxassetid://106487695588019",
            }) {
                Rotation = rotSpring,
                [Children] =  Child {
                    scope:New "UIGradient" {
                        Rotation = 45,
                        Color = ColorPallete.goldSequence,
                        Transparency = NumberSequence.new(0.2),
                    }
                }
            },

            scope:Text {
                disableShadow = true,
                color = ColorPallete.greyOne,
                text = "Select",
                anchorPoint = Vector2.new(0, 0.5),
                size = UDim2.fromScale(0.645, 0.9),
                position = UDim2.fromScale(0.05, 0.5),
                alignmentX = Enum.TextXAlignment.Left
            },


            scope:ProgressBar {
                percentage = dropdownOpenPercentageSpring,
                direction = "down",
                compressSize = 0.8,
                size = UDim2.fromScale(1, 4),
                position = UDim2.fromScale(0.5, 0),
                anchorPoint = Vector2.new(0.5, 1),

                children = scope:Hydrate(scope:Container {
                    size = UDim2.fromScale(1,1)
                }) {
                    [Children] = Child {
                        scope:Hydrate(scope:Container {
                            image = "rbxassetid://91475227618595",
                            transparency = 0,
                            size = UDim2.fromScale(1,1),
                            color = ColorPallete.greySix
                        }) {
                            [Children] = Child {

                                scope:Hydrate(scope:Image {
                                    anchorPoint = Vector2.new(0.5, 1),
                                    position = UDim2.fromScale(0.492, 0.918),
                                    size = UDim2.fromScale(0.926, 0.9),
                                    image = "rbxassetid://106599257075921",
                                    imageType = Enum.ScaleType.Crop
                                }) {
                                    ZIndex = -5,
                                    ImageTransparency = 0.95,
                                    [Children] = Child {
                                        scope:New "UICorner" {
                                            CornerRadius = UDim.new(0.115, 0),
                                        },
                                        scope:New "UIGradient" {
                                            Rotation = 25,
                                            Transparency = NumberSequence.new(0.5),
                                        }
                                    }
                                },
                            }
                        },

                        scope:New "ScrollingFrame" {
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.45),
                            Size = UDim2.fromScale(0.95, 1),
                            BackgroundTransparency = 1,

                            AutomaticCanvasSize =  Enum.AutomaticSize.Y,
                            CanvasSize = UDim2.new(),
                            ScrollBarImageColor3 = ColorPallete.vanillaOne,
                            ScrollBarThickness = 0,
                            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
                            TopImage = "rbxassetid://71418806063429",
                            MidImage = "rbxassetid://140249735342084",
                            BottomImage = "rbxassetid://116318494421504",
                            ScrollingDirection =  Enum.ScrollingDirection.Y,

                            [Children] = Child {
                                scope:Computed(function(use, scope: scope)
                                    use(props.items)
                                    local final = scope:Layout {
                                        padding = UDim.new(0.02, 0),
                                        fillDir = Enum.FillDirection.Vertical,
                                        horizontalAlignment = Enum.HorizontalAlignment.Left,
                                        verticalAlignment = Enum.VerticalAlignment.Top,
                                        animationSide = "left",
                                        loadOrigin = "left",
                                        inversedSetup = false,
                                        loadTime = 0.2,
                                        visible = true,

                                        content = scope:Computed(function(use, scope: scope)
                                            local kids = scope:ForPairs(props.items, function(use, scope: scope, index: number, data: {name: string, id: string})
                                                local button = scope:Button {
                                                    size = UDim2.fromScale(0.9, 0.4),
                                                    visible = true,
                                                    color = Color3.new(1,1,1),
                                                    transparency = 1,
                                                    animationSide = "left",
                                                    hoverScale = 1.02,
                                                    onClick = function()
                                                        props.onSelect(data.id)
                                                        props.opened:set(false)
                                                    end
                                                }

                                                scope:Hydrate(button:FindFirstChildWhichIsA("ImageButton") :: ImageButton) {
                                                    [Children] = Child {
                                                        scope:Layout {
                                                            padding = UDim.new(0.05, 0),
                                                            fillDir = Enum.FillDirection.Horizontal,
                                                            horizontalAlignment = Enum.HorizontalAlignment.Left,
                                                            verticalAlignment = Enum.VerticalAlignment.Center,
                                                            animationSide = "left",
                                                            loadOrigin = "left",
                                                            inversedSetup = true,
                                                            loadTime = 0.2,
                                                            visible = true,

                                                            content = {
                                                                scope:Text {
                                                                    disableShadow = true,
                                                                    text = use(data.name),
                                                                    size = UDim2.fromScale(0.5, 0.65),
                                                                    color = Color3.new(),
                                                                    alignmentX = Enum.TextXAlignment.Left,
                                                                },
                                                                }
                                                            },
                                                    }
                                                }
                                                return index, button
                                            end)

                                           return peek(kids)
                                        end)
                                    }

                                    return final:GetChildren()
                                end)
                            }
                        }
                    }
                }
            }
        }
    }

    return button
end