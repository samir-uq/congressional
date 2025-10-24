local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InfoDisplayCircle = require(script.Parent.InfoDisplayCircle)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child
local Out = Fusion.Out

local seatDiameterPx = 100
local gapFactor = 1.5
local Dependency = {
    Container = Container,
    InfoDisplayCircle = InfoDisplayCircle
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>
return function (scope: any, props: {
    electInformation: state<{
       { name: state<string>?,
        state: state<string>?,
        district: state<string>?,
        party: state<string>?,
        termStartYear: state<string>?}
    }>,
    visible: state<boolean>,
    diameter: number?,
    center: number,
})
    local scope: scope = scope:innerScope(Dependency)
    local seatDiam = props.diameter or seatDiameterPx

    local absoluteSize = scope:Value(Vector2.new())
    scope:Hydrate(workspace.CurrentCamera) {
        [Out "ViewportSize"] = absoluteSize
    }

    -- reactive center positions
    local centerX = scope:Computed(function(use)
        return use(absoluteSize).X / 2
    end)

    local centerY = scope:Computed(function(use)
        return use(absoluteSize).Y * (1 - props.center)
    end)

    -- derived constants
    local rowStep = seatDiam * gapFactor
    local innerRadius = seatDiam * 1.2

    return scope:Hydrate(scope:Container {
        size = UDim2.fromScale(1, 1)
    }) {
        [Children] = Child {
            scope:ForPairs(props.electInformation, function(use, seatScope: any, index, info)
                -- recompute geometry reactively
                local W, H = use(absoluteSize).X, use(absoluteSize).Y
                local cx, cy = use(centerX), use(centerY)

                -- determine how many seats can fit in the current radius
                local radius = innerRadius
                local remaining = index
                local seatsInRow = math.floor((math.pi * radius) / seatDiam)
                while remaining > seatsInRow do
                    remaining -= seatsInRow
                    radius += rowStep
                    seatsInRow = math.floor((math.pi * radius) / seatDiam)
                end

                -- seat position along arc (π → 0 for left→right)
                local theta = math.pi - (math.pi * (remaining - 0.5) / seatsInRow)
                local posX = cx + radius * math.cos(theta)
                local posY = cy - radius * math.sin(theta)

                return index, seatScope:InfoDisplayCircle {
                    name = info.name,
                    state = info.state,
                    district = info.district,
                    party = info.party,
                    termStartYear = info.termStartYear,
                    visible = props.visible,

                    size = seatScope:Computed(function(use)
                        local a = use(absoluteSize)
                        return UDim2.fromScale(seatDiam *.9 / a.X, seatDiam * .9 / a.Y)
                    end),

                    position = seatScope:Computed(function(use)
                        local a = use(absoluteSize)
                        return UDim2.fromScale(posX / a.X, posY / a.Y)
                    end)
                }
            end)
        }
    }
end