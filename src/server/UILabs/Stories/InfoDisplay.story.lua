
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UiLabs = require(ReplicatedStorage.Packages.UiLabs)
local InfoDisplayCircle = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.InfoDisplayCircle)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Text = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Text)
local ColorPallete = require(ReplicatedStorage.Shared.Client.Interface.MetaData.ColorPallete)


local Scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

local Controls = {
    visible = true,
    color = ColorPallete.Democratic,
    name = "",
    state = "",
    district = "",
    party = "",
    startYear = ""
}

local Dependency = {
    Container = Container,
    Text = Text,
    Button = Button,
    InfoDisplayCircle = InfoDisplayCircle
}

local Story: UiLabs.FusionStory = {
    fusion = Fusion,
    controls = Controls,
    story = function(props: UiLabs.FusionProps)
        local scope = props.scope:innerScope(Dependency) :: Fusion.Scope<typeof(Fusion)&typeof(Dependency)>
        local controls = props.controls

        return scope:Hydrate(scope:Container {
            size = UDim2.fromScale(1/2,1/2),
        }) {
            [Children] =  {
                scope:InfoDisplayCircle {
                    visible = controls.visible,
                    color = controls.color,
                    name = controls.name,
                    state = controls.state,
                    district = controls.district,
                    party = controls.party,
                    termStartYear = controls.startYear
                }
            }
        }

    end
}

return Story