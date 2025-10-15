local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local ColorPallete = require(ReplicatedStorage.Shared.Client.Interface.MetaData.ColorPallete)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

local Dependency = {
    Container = Container,
    Button = Button
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>
return function (scope: scope, props: {
    visible: state<boolean>,
    color: state<Color3>,
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

    local button = scope:Hydrate(scope:Button {
        roundness = 1,
        size = props.size or UDim2.fromScale(0.4, 0.4),
        color = props.color,
        visible = props.visible,
        position = props.position,
        transparency = 0,
        hovering = isHovering
    }) {
        SizeConstraint = Enum.SizeConstraint.RelativeXX,
    }



    scope:Hydrate(button:FindFirstChildWhichIsA("ImageButton") :: ImageButton) {
        [Children] = Child {
            scope:Hydrate(scope:Container {
                size = UDim2.fromScale(0.8,1),
                position = UDim2.fromScale(1.03,0.4),
                anchorPoint = Vector2.new(),
                transparency = 0,
                color = ColorPallete.whiteOne
            }) {
                [Children] = Child {
                    scope:New "UICorner" {
                        CornerRadius = UDim.new(0.25),
                    },
                    scope:New "UIScale" {
                        Scale = hoverSpring
                    },



                    
                }
            }
        }
    }

    return button
end