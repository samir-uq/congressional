
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UiLabs = require(ReplicatedStorage.Packages.UiLabs)
local InfoDisplayCircle = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.InfoDisplayCircle)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Text = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Text)


local Scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local Child = Fusion.Child

local Controls = {
    visible = true,
    color = Color3.fromRGB(0,0,255),
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
            size = UDim2.fromScale(1,1),
        }) {
            [Children] =  {
                scope:InfoDisplayCircle {
                    visible = controls.visible,
                    color = controls.color,
                }
            }
        }

    end
}

return Story