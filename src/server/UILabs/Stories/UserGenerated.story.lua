
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local UiLabs = require(ReplicatedStorage.Packages.UiLabs)
local UserGeneratedDisplay = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.UserGeneratedDisplay)
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
    title = "Hey",
    publisher = 744265165,
    publishDate = 20,
    lean = -1,
    content = "hello hello",
    authenticated = false
}

local Dependency = {
    Container = Container,
    Text = Text,
    Button = Button,
    UserGeneratedDisplay = UserGeneratedDisplay,
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
              scope:UserGeneratedDisplay {
                visible = controls.visible,
                title = controls.title,
                publisher = controls.publisher,
                publishDate = controls.publishDate,
                lean = controls.lean,
                content = controls.content,
                authenticated = controls.authenticated,
                id = "{90737baa-0191-4a44-9658-5e36e8eae16c}"
              }
            }
        }

    end
}

return Story