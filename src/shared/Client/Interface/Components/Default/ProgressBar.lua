
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Container = require(script.Parent.Container)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local StateData = require(ReplicatedStorage.Shared.Client.Interface.MetaData.StateData)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child


local Dependency = {
    Container = Container
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>
return function (scope: scope, props: {
    size: state<UDim2>?,
    position: state<UDim2>?,
    anchorPoint: state<Vector2>?,

    percentage: state<number>,
    direction: state<"left"|"right"|"up"|"down"|"center-up"|"center-side">,
    disableCompress: state<boolean>?,
    children: state<Instance?>?,
    compressSize: state<number>?,
    disableSpring: boolean?,
    stateData: string?
})
    scope = scope:innerScope(Dependency) :: scope
    local percentage = props.percentage
    if not props.disableSpring then
        percentage = scope:Spring(props.percentage, StateData.GetSpring(props.stateData or "progress"), StateData.GetDamp(props.stateData or "progress"))
    end

    local compressSpring = scope:Spring(scope:Computed(function(use, scope)
        local final: number = use(props.percentage)
        local current: number = use(percentage)

        if use(props.disableCompress) then
            return 1
        end

        if math.abs(final-current) < 0.03 then return 1 else return (use(props.compressSize or 0.9)) end
    end), StateData.GetSpring("compression"), StateData.GetDamp("compression"))


    local posComp = scope:Computed(function(use, scope)
        local direction = use(props.direction)
        return UDim2.fromScale(
            if (direction == "left") then 1 elseif (direction == "right") then 0 else 0.5,
            if (direction == "down") then 1 elseif (direction == "up") then 0 else 0.5)
    end)

    local anchorComp = scope:Computed(function(use, scope)
        local direction = use(props.direction)
        return Vector2.new(
            if (direction == "left") then 1 elseif (direction == "right") then 0 else 0.5,
            if (direction == "down") then 1 elseif (direction == "up") then 0 else 0.5)
        end)

    return scope:Hydrate(scope:Container(props :: any)) {
        [Children] = Child {
            scope:Hydrate(scope:Container {
                size = scope:Computed(function(use, scope)
                    local percentage = use(percentage) or 0
                    local direction = use(props.direction)
                    local def = use(compressSpring)

                    local oneOver = percentage
                    return UDim2.fromScale(
                        if (direction == "left" or direction == "right" or direction == "center-side") then oneOver else def,
                        if (direction == "up" or direction == "down" or direction == "center-up") then oneOver else def)
                    end),
                position = posComp,
                anchorPoint = anchorComp,
                canvasFrame = false,
            }) {
                ClipsDescendants = true,
                [Children] = Child {
                    scope:Hydrate(scope:Container {
                        size = scope:Computed(function(use, scope)
                            local percentage = use(percentage) or 0
                            local direction = use(props.direction)
                            if percentage == 0 then percentage = 1 end

                            local oneOver = 1 / percentage
                            local def = 1 / use(compressSpring)
                            return UDim2.fromScale(
                                if (direction == "left" or direction == "right" or direction == "center-side") then oneOver else def,
                                if (direction == "up" or direction == "down" or direction == "center-up") then oneOver else def)
                        end),
                        position = posComp,
                        anchorPoint = anchorComp,
                        canvasFrame = false,
                    }) {
                        [Children] = props.children
                    }
                }
            }
        }
    }
end