local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UIConfiguration = require(ReplicatedStorage.Shared.Client.Interface.MetaData.UIConfiguration)

local scoped = Fusion.scoped
local peek = Fusion.peek


type scope = Fusion.Scope<typeof(Fusion)>
type state<T> = Fusion.UsedAs<T>
return function (scope: scope, props: {
    size: state<UDim2>?,
    position: state<UDim2>?,
    anchorPoint: state<Vector2>?,
    
    transparency: state<number>?,
    color: state<Color3>?,
    automaticSize: state<Enum.AutomaticSize>?,
    image: state<string>?,
    imageType: state<Enum.ScaleType>?,
    sizeConstraint: state<Enum.SizeConstraint>?,
    rotation: state<number>?,
})
    local scope = scope:innerScope()

    return scope:New "ImageLabel" {
        AnchorPoint = props.anchorPoint or UIConfiguration.default.anchorPoint,
        Size = props.size or UIConfiguration.default.size,
        Position = props.position or UIConfiguration.default.position,
        BackgroundTransparency = 1,
        ImageTransparency = props.transparency or 0,
        ImageColor3 = props.color,
        AutomaticSize = scope:Computed(function(use)
            local current = use(props.automaticSize)
            return current or Enum.AutomaticSize.None
        end),
        Image = props.image or "",
        ScaleType = props.imageType,
        SizeConstraint =  props.sizeConstraint,

        Rotation = props.rotation,
    }
end