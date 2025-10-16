local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local StateDataManager = require(ReplicatedStorage.Shared.Client.Handlers.StateDataManager)
local Background = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.Background)
local ChamberDataContainer = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.ChamberDataContainer)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Layout = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Layout)
local Text = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Text)
local ColorPallete = require(ReplicatedStorage.Shared.Client.Interface.MetaData.ColorPallete)
local StateData = require(ReplicatedStorage.Shared.Configs.Data.StateData)
local Interface = {}

local LocalPlayer = Players.LocalPlayer

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Child = Fusion.Child

local Dependency = {
    Container = Container,
    Button = Button,
    Layout = Layout,
    Text = Text,
    ChamberDataContainer = ChamberDataContainer
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>

local forkedInfo: Fusion.Value<any>

function Interface.Create(scope: scope, props: {
    visible: state<boolean>,
    currentFrame: Fusion.Value<string>,
})

    forkedInfo = scope:Value({})

    local electorData = scope:Computed(function(use)
        local final = {}
        local fetched = use(forkedInfo)


        for stateIdentifier, peoopleList in fetched do
            for index, people in peoopleList do
                
                local latestChamber = nil
                local latestYear = 0
                for _, termInfo in people.terms.item do
                    local chamber = termInfo.chamber
                    local startYear = termInfo.startYear

                    if startYear > latestYear then
                        latestChamber = chamber
                        latestYear = startYear
                    end
                end

                if latestChamber == "Senate" then
                    continue
                end


                table.insert(final, {
                    people.name,
                    tostring(latestYear),
                    people.partyName,
                    people.state,
                    index,
                    table.find(StateData.StateID, stateIdentifier),
                })
            end
        end

        table.sort(final, function(A,B)
            if A[6] == B[6] then
                return A[5] < B[5]
            end

            return A[6] < B[6]
        end)

        local dict = {}

        for index, data in final do
            table.insert(dict, {
                name = data[1],
                termStartYear = data[2],
                party = data[3],
                state = data[4],
                district = data[5],
            })
        end

        return dict
    end)
    scope = scope:innerScope(Dependency)
    return scope:Hydrate(scope:Container {
        size = UDim2.fromScale(1,1)
    }) {
        Visible = props.visible,
        [Children] = Child {
            scope:Text {
                disableShadow = true,
                color = Color3.new(1,1,1),
                text = "House of Representatives",
                size = UDim2.fromScale(1, 0.1),
                position = UDim2.fromScale(0.5, 0),
                anchorPoint = Vector2.new(0.5, 0)
            },

            scope:Computed(function(use)
                local button = scope:Button {
                    color = ColorPallete.whiteTwo,
                    visible = props.visible,
                    size = UDim2.fromScale(0.15, 0.08),
                    position = UDim2.fromScale(0.5, 0.94),
                    roundness = 0.1,
                    onClick = function()
                        props.currentFrame:set("Menu")
                    end
                }

                scope:Hydrate(button:FindFirstChildWhichIsA("ImageButton") :: ImageButton) {
                    [Children] = Child {
                        scope:Text {
                            disableShadow = true,
                            text = "Return",
                        }
                    }
                }

                return button
            end),

            scope:Hydrate(scope:Container {
                size = UDim2.fromScale(1,1),
                anchorPoint = Vector2.new(0.5, 1),
                position = UDim2.fromScale(0.5, 0.9)
            }) {
                [Children] = Child {
                    scope:ChamberDataContainer {
                        visible = props.visible,
                        electInformation = electorData,
                        diameter = 37,
                        center = 0.05
                    }
                }
            },
        }
    }
end

function Interface.Start()
    StateDataManager.GetSignals().Members:Connect(function()
        if not forkedInfo then return end
        forkedInfo:set(StateDataManager.Get().Members)
    end)
end

return Interface