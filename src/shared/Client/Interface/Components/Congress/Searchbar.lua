local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local PopoutAnimation = require(ReplicatedStorage.Shared.Client.Interface.Components.Animations.PopoutAnimation)
local Image = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Image)
local ColorPallete = require(ReplicatedStorage.Shared.Client.Interface.MetaData.ColorPallete)
local StateData = require(ReplicatedStorage.Shared.Client.Interface.MetaData.StateData)
local UIConfiguration = require(ReplicatedStorage.Shared.Client.Interface.MetaData.UIConfiguration)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child
local Out = Fusion.Out
local OnEvent = Fusion.OnEvent
local Dependency = {
    Image = Image,
    PopoutAnimation = PopoutAnimation
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>
return function (scope: any, props: {
    text: Fusion.Value<string>,
    size: state<UDim2>?,
    position: state<UDim2>?,
})
    local scope: scope = scope:innerScope(Dependency)
    local scaleSpring = scope:Spring(scope:Value(1), StateData.GetSpring("searchbarSize"), StateData.GetDamp("searchbarSize"))
    
    local rotVal = scope:Value(0)
    local rotSpring = scope:Spring(rotVal, StateData.GetSpring("searchbarRotation"), StateData.GetDamp("searchbarRotation"))

    local textTransparency = scope:Computed(function(use, scope: scope)
        return use(props.text):len() > 0 and 0 or 0.5
    end)
    local textTransparencySpring = scope:Spring(textTransparency, StateData.GetSpring("searchbarTransparency"), StateData.GetDamp("searchbarTransparency"))

    scope:Observer(props.text):onChange(function()
        scaleSpring:addVelocity(0.6)
    end)

    local function updateRotation(boolean: boolean)
        if type(boolean) == "boolean" and not boolean then return end
        rotVal:set(peek(rotVal) == 360 and 0 or 360)
    end

    return scope:Hydrate(scope:Image {
        size = props.size or UDim2.fromScale(0.415, 1),
        position = props.position,
        image = "rbxassetid://109184285128135",
    }) {
        [Children] = Child {
            scope:New "UIGradient" {
                Color = ColorPallete.topSequence,
                Rotation = 5
            },

            scope:New "UIScale" {
                Scale =  scaleSpring
            },

            scope:Hydrate(scope:Image {
                size = UDim2.fromScale(0.45, 0.45),
                sizeConstraint = Enum.SizeConstraint.RelativeYY,
                position = UDim2.fromScale(0.125, 0.43),
                image = "rbxassetid://95261447785280",
            }) {
                Rotation = rotSpring,
                [Children] =  Child {
                    scope:New "UIGradient" {
                        Rotation = 45,
                        Color = ColorPallete.goldSequence
                    }
                }
            },

            scope:Image {
                size = UDim2.fromScale(0.85, 0.9),
                sizeConstraint = Enum.SizeConstraint.RelativeYY,
                position = UDim2.fromScale(0.85, 0.415),
                image = "rbxassetid://116965044778180",
                transparency = 0.5,
                color = ColorPallete.greySeven
            },

            scope:New "TextBox" {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.2, 0.43),
                Size = UDim2.fromScale(0.662, 0.5),
                PlaceholderColor3 = ColorPallete.greyTwo,
                PlaceholderText = "Search",
                TextColor3 = Color3.new(1,1,1),
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = textTransparencySpring,

                [Out "Text"] = props.text,
                -- [OnEvent "Focused"] = updateRotation,
                [OnEvent "FocusLost"] = updateRotation
            }
        }
    }
end