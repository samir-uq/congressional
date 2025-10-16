
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UiLabs = require(ReplicatedStorage.Packages.UiLabs)
local ChamberDataContainer = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.ChamberDataContainer)
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
}

local Dependency = {
    Container = Container,
    Text = Text,
    Button = Button,
    ChamberDataContainer = ChamberDataContainer
}

local Story: UiLabs.FusionStory = {
    fusion = Fusion,
    controls = Controls,
    story = function(props: UiLabs.FusionProps)
        local scope = props.scope:innerScope(Dependency) :: Fusion.Scope<typeof(Fusion)&typeof(Dependency)>
        local controls = props.controls

        return scope:Hydrate(scope:Container {
            size = UDim2.fromScale(1,1),
        }) {
            [Children] =  {
               scope:ChamberDataContainer {
                visible = controls.visible,
                electInformation = {
                    {
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },

                    {
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },{
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },

                    {
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },{
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },

                    {
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },{
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },

                    {
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },{
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },

                    {
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },{
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },

                    {
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },{
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },

                    {
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },{
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },

                    {
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },{
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Republican",
                        state = "Maryland"
                    },

                    {
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },{
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },

                    {
                        name = "Samir Adhikari",
                        district = "3",
                        termStartYear = "2020",
                        party = "Democratic",
                        state = "Maryland"
                    },
                }
               }
            }
        }

    end
}

return Story