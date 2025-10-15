
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local StateData = require(ReplicatedStorage.Shared.Client.Interface.MetaData.StateData)
local UIConfiguration = require(ReplicatedStorage.Shared.Client.Interface.MetaData.UIConfiguration)
local DelayValue = require(ReplicatedStorage.Shared.Client.Interface.Utils.DelayValue)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

local Dependency = {

}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>
return function (scope: scope, props: {
    obj: state<GuiBase3d>,
    animationSide: state<"left"|"right"|"top"|"bottom">?,
    visible: state<boolean>,
    animDelay: state<number>,
    animNameScale: string?,
    animNamePos: string?,
    animNameAnchor: string?,
})
    scope = scope:innerScope(Dependency) :: scope

    props.visible = DelayValue(props.visible, scope, props.animDelay)
    local visibleDelay = DelayValue(props.visible, scope, 0.5)

    local scale = scope:Computed(function(use, scope: scope)
        if use(props.visible) then
            return UDim2.fromScale(1,1)
        end
        return UDim2.new()
    end)
    local scaleSpring = scope:Spring(scale, StateData.GetSpring(props.animNameScale or "buttonScale"), StateData.GetDamp(props.animNameScale or "buttonDamp"))

    local anchor = scope:Computed(function(use, scope: scope)
        local configData = use(props.animationSide or "bottom")
        local animationData = UIConfiguration.button.animationPos[configData]

        if use(props.visible) then
            return UIConfiguration.default.anchorPoint
        end
        return animationData.idleAnchorPoint
    end)
    local anchorSpring = scope:Spring(anchor, StateData.GetSpring(props.animNameAnchor or "buttonAnchor"), StateData.GetDamp(props.animNameAnchor or "buttonAnchor"))

    local pos = scope:Computed(function(use, scope: scope)
        local configData = use(props.animationSide or "bottom")
        local animationData = UIConfiguration.button.animationPos[configData]

        if use(props.visible) then
            return UIConfiguration.default.position
        end
        return animationData.inactivePosition
    end)
    local posSpring = scope:Spring(pos, StateData.GetSpring(props.animNamePos or "buttonPosition"), StateData.GetDamp(props.animNamePos or "buttonPosition"))

    return scope:Hydrate(props.obj :: any) {
        AnchorPoint = anchorSpring,
        Size = scaleSpring,
        Position = posSpring,
        Visible = scope:Computed(function(use)
            if use(props.visible) then
                return true
            end

            return use(visibleDelay)
        end)
    }
end