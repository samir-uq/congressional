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
    filters: state<{{name: state<string>, valid: ((any)->boolean)}}>,
    items: state<any>,-- TODO,
    selected: Fusion.Value<string>
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
        size = UDim2.fromScale(0.415, 1),
        image = "rbxassetid://109184285128135",
        animationSide = "top",
        color = Color3.new(1,1,1),
        onClick = function()
            props.opened:set(not peek(props.opened))
        end,

        position = UDim2.fromScale(0, 1),
    }

    scope:Hydrate(button:FindFirstChildWhichIsA("ImageButton") :: ImageButton) {
        [Children] = Child {
            scope:New "UIGradient" {
                Color = ColorPallete.topSequence,
                Rotation = 5
            },

            scope:Hydrate(scope:Image {
                size = UDim2.fromScale(0.45, 0.45),
                sizeConstraint = Enum.SizeConstraint.RelativeYY,
                position = UDim2.fromScale(0.85, 0.43),
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
                color = Color3.new(1,1,1),
                text = "Quality",
                anchorPoint = Vector2.new(0, 0.5),
                size = UDim2.fromScale(0.645, 0.5),
                position = UDim2.fromScale(0.107, 0.43),
                alignmentX = Enum.TextXAlignment.Left
            },

            scope:Image {
                size = UDim2.fromScale(0.85, 0.9),
                sizeConstraint = Enum.SizeConstraint.RelativeYY,
                position = UDim2.fromScale(0.7, 0.415),
                image = "rbxassetid://116965044778180",
                transparency = 0.5,
                color = ColorPallete.greySeven
            },

            scope:ProgressBar {
                percentage = dropdownOpenPercentageSpring,
                direction = "down",
                -- compressSize = 0.8,
                disableCompress = true,
                size = UDim2.fromScale(0.86, 2.107),
                position = UDim2.fromScale(0.5, 0),
                anchorPoint = Vector2.new(0.5, 1),

                children = scope:Hydrate(scope:Container {
                    size = UDim2.fromScale(1,1)
                }) {
                    [Children] = Child {
                        scope:Hydrate(scope:Image {
                            image = "rbxassetid://91475227618595",
                            size = UDim2.fromScale(1,1),
                            imageType = Enum.ScaleType.Slice
                        }) {
                            SliceCenter = Rect.new(451, 101, 451, 399),
                            [Children] = Child {
                                scope:New "UIGradient" {
                                    Rotation = 15,
                                    Color = ColorPallete.topSequence
                                },

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
                            Size = UDim2.fromScale(0.91, 0.8),
                            BackgroundTransparency = 1,

                            AutomaticCanvasSize =  Enum.AutomaticSize.Y,
                            CanvasSize = UDim2.new(),
                            ScrollBarImageColor3 = ColorPallete.vanillaOne,
                            ScrollBarThickness = 4,
                            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
                            TopImage = "rbxassetid://71418806063429",
                            MidImage = "rbxassetid://140249735342084",
                            BottomImage = "rbxassetid://116318494421504",
                            ScrollingDirection =  Enum.ScrollingDirection.Y,

                            [Children] = Child {
                                scope:Computed(function(use, scope: scope)
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
                                            local kids = scope:ForPairs(props.filters, function(use, scope: scope, index: number, data: {name: state<string>, valid: ((any)->boolean)})
                                                local val = scope:Computed(function(use, scope: scope)
                                                    local count = 0
                                                    for _, item in use(props.items) do
                                                        if data.valid(item) then
                                                            count+= 1
                                                        end
                                                    end
                                                    return count
                                                end)
                                                local valSpr = scope:Spring(val, StateData.GetSpring("qualityfilterValue"), StateData.GetDamp("qualityfilterValue"))

                                                local transparencyVal = scope:Computed(function(use, scope: scope)
                                                    return if use(props.selected) == use(data.name) then 0 else 1
                                                end)
                                                local transparencySpr = scope:Spring(transparencyVal, StateData.GetSpring("qualityfilterTransparency"), StateData.GetDamp("qualityfilterTransparency"))
                                                table.insert(valSprings, valSpr)

                                                local button = scope:Button {
                                                    size = UDim2.fromScale(0.9, 0.4),
                                                    visible = true,
                                                    color = Color3.new(1,1,1),
                                                    transparency = 1,
                                                    animationSide = "left",
                                                    hoverScale = 1.02,
                                                    onClick = function()
                                                        props.selected:set(use(data.name) :: string)
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
                                                                    color = ColorPallete.greySix,
                                                                    alignmentX = Enum.TextXAlignment.Left,
                                                                },
                                                                scope:Text {
                                                                    disableShadow = true,
                                                                    text = scope:Computed(function(use, scope: scope)
                                                                        return tostring(math.round(use(valSpr)))
                                                                    end),
                                                                        size = UDim2.fromScale(0.5, 0.65),
                                                                        position = UDim2.fromScale(0.953, 0.5),
                                                                        anchorPoint = Vector2.new(1, 0.5),
                                                                        color = Color3.new(1,1,1),
                                                                        alignmentX = Enum.TextXAlignment.Right,
                                                                    },
                                                                }
                                                            },

                                                            scope:Hydrate(scope:Container {
                                                                size = UDim2.fromScale(1.05, 1),
                                                                transparency = transparencySpr
                                                            }) {
                                                                [Children] = Child {
                                                                    scope:New "UICorner" {
                                                                        CornerRadius = UDim.new(0.5, 0),
                                                                    },
                                                                    scope:New "UIGradient" {
                                                                        Color = ColorPallete.goldTwoSequence,
                                                                        Transparency = NumberSequence.new(0.5),
                                                                    }
                                                                }
                                                            }
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