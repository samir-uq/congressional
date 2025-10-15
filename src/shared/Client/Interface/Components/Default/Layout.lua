
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Container = require(script.Parent.Container)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local PopoutAnimation = require(ReplicatedStorage.Shared.Client.Interface.Components.Animations.PopoutAnimation)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child
local Out = Fusion.Out

local Dependency = {
    Container = Container,
    PopoutAnimation = PopoutAnimation
}

local inverses = {
    left = "right",
    right = "left",
    center = "edge",
    edge = "center"
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>
return function (scope: any, props: {
    padding: state<UDim|UDim2>?,
    size: state<UDim2>?,
    fillDir: state<Enum.FillDirection>?,
    maxFillDir: state<number>?,
    startCorner: state<Enum.StartCorner>?,
    sortOrder: state<Enum.SortOrder>?,
    wraps: state<boolean>?,
    horizontalAlignment: state<Enum.HorizontalAlignment>?,
    verticalAlignment: state<Enum.VerticalAlignment>?,
    horizontalFlex: state<Enum.UIFlexAlignment>?,
    verticalFlex: state<Enum.UIFlexAlignment>?,
    itemLineAlign: state<Enum.ItemLineAlignment>?,
    automaticSize: state<Enum.AutomaticSize>?,

    content: state<any>,
    visible: state<boolean>,
    loadTime: state<number>?,
    animationSide: state<"left"|"right"|"top"|"bottom">?,
    disableLayout: state<boolean>?,
    loadOrigin: state<"left"|"center"|"edge"|"right">?,
    inversedSetup: state<boolean>?,
    uiConfigs: state<{any}>?,

    animNameScale: string?,
    animNamePos: string?,
    animNameAnchor: string?,
})
    local scope: scope = scope:innerScope(Dependency)
    local totalCount = scope:Computed(function(use, scope: scope)
        return #use(props.content)
    end)

    return scope:Hydrate(scope:Container {
        size = UDim2.fromScale(1, 1),
        automaticSize = props.automaticSize,
    }) {
        [Children] = Child {
            scope:Computed(function(use, scope: scope): Instance?
                local size = use(props.size)
                local disabled = use(props.disableLayout)
                if disabled then
                    return nil
                end
                if size then
                    return scope:New "UIGridLayout" {
                        CellPadding = props.padding,
                        CellSize = props.size,
                        FillDirection = props.fillDir,
                        FillDirectionMaxCells = props.maxFillDir,
                        SortOrder = props.sortOrder,
                        StartCorner = props.startCorner,
                        HorizontalAlignment = props.horizontalAlignment,
                        VerticalAlignment = props.verticalAlignment
                    }
                else
                    return scope:New "UIListLayout" {
                        Padding = props.padding,
                        FillDirection = props.fillDir,
                        SortOrder = props.sortOrder,
                        Wraps = props.wraps,
                        HorizontalAlignment = props.horizontalAlignment,
                        HorizontalFlex = props.horizontalFlex,
                        ItemLineAlignment = props.itemLineAlign,
                        VerticalAlignment = props.verticalAlignment,
                        VerticalFlex = props.verticalFlex
                    }
                end
            end),

            scope:Computed(function(use, scope: scope)
                return use(props.uiConfigs)
            end),

            scope:ForPairs(props.content, function(use, scope: scope, index: number, obj: any): (number, Instance?)
                obj = use(obj)
                if not obj then return index, nil end
                local count = use(totalCount)


                local container = scope:Hydrate(scope:Container {
                    size = obj.Size,
                    position = obj.Position,
                    anchorPoint = obj.AnchorPoint,
                    automaticSize = obj.AutomaticSize,
                }) {
                    SizeConstraint = obj.SizeConstraint,
                    ZIndex = obj.ZIndex,
                    LayoutOrder = obj.LayoutOrder,
                    Name = "Layout"
                }
                obj = scope:Hydrate(obj) {
                    Size = UDim2.fromScale(1,1),
                    Position = UDim2.fromScale(0.5, 0.5),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    SizeConstraint = Enum.SizeConstraint.RelativeXY
                }
                if not obj or not container or not scope then
                    return index, nil
                end

                return index, scope:Hydrate(container) {
                    [Children] = Child {
                        obj:FindFirstChildWhichIsA("UIAspectRatioConstraint"), 
                        scope:PopoutAnimation({
                            obj = obj,
                            animationSide = props.animationSide,
                            visible = props.visible,
                            animNameAnchor = props.animNameAnchor,
                            animNamePos = props.animNamePos,
                            animNameScale = props.animNameScale,
                            animDelay = scope:Computed(function(use, scope: scope)
                                local loadType = use(props.loadOrigin)
                                local loadTime = use(props.loadTime or 0)
                                local visible = use(props.visible)
                                local inversed = use(props.inversedSetup)

                                if inversed and visible then
                                   loadType = inverses[loadType]
                                end

                                local newIndex = 0
                                if loadType == "left" then
                                    newIndex = index - 1
                                elseif loadType == "right" then
                                    newIndex = count - index
                                elseif loadType == "center" then
                                    local coreCenter = count / 2
                                    if coreCenter % 1 == 0 then
                                        newIndex = math.min(math.abs(coreCenter - index), math.abs(coreCenter + 1 - index))
                                    else
                                        newIndex = math.abs(math.round(coreCenter) - index)
                                    end
                                elseif loadType == "edge" then
                                    newIndex = math.min(math.abs(1 - index), math.abs(count - index))
                                end

                                return (loadTime :: number) * (newIndex :: any)
                            end)
                        })
                    }
                }
            end)
        }
    }
end