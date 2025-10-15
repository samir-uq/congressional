local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Background = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.Background)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Interface = {}

local LocalPlayer = Players.LocalPlayer

local scoped = Fusion.scoped
local peek = Fusion.peek
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Child = Fusion.Child

local Dependency = {
    Container = Container
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>

function Interface.Create(scope: scope, props: {

})
    scope = scope:innerScope(Dependency)
    return scope:Hydrate(scope:Container {
        size = UDim2.fromScale(1,1)
    }) {
        [Children] = Child {

        }
    }
end

function Interface.Start()

end

return Interface