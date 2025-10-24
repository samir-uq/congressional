local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Background = require(ReplicatedStorage.Shared.Client.Interface.Components.Congress.Background)
local Button = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Button)
local Container = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Container)
local Layout = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Layout)
local Text = require(ReplicatedStorage.Shared.Client.Interface.Components.Default.Text)
local ColorPallete = require(ReplicatedStorage.Shared.Client.Interface.MetaData.ColorPallete)
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
    Text = Text
}

type scope = Fusion.Scope<typeof(Fusion) & typeof(Dependency)>
type state<T> = Fusion.UsedAs<T>

function Interface.Create(scope: scope, props: {
    visible: state<boolean>,
    currentFrame: Fusion.Value<string>,
})
    scope = scope:innerScope(Dependency)
    return scope:Hydrate(scope:Container {
        size = UDim2.fromScale(1,1)
    }) {
        [Children] = Child {
            scope:Hydrate( scope:Text {
                disableShadow = true,
                color = Color3.new(1,1,1),
                text = "Simulated Interface",
                size = UDim2.fromScale(1, 0.1),
                position = UDim2.fromScale(0.5, 0.3),
                textSize = 100,
                anchorPoint = Vector2.new(0.5, 0.5),
            }) {
                Visible = props.visible
            },


            scope:Hydrate(scope:Container {
                size = UDim2.fromScale(0.8, 0.4),
                anchorPoint = Vector2.new(0.5, 1),
                position = UDim2.fromScale(0.5, 0.85)
            }) {
                [Children] = Child {
                    scope:Layout {
                        wraps = true,
                        padding = UDim.new(0.1, 0),
                        animationSide = "top",
                        fillDir = Enum.FillDirection.Horizontal,
                        verticalAlignment = Enum.VerticalAlignment.Bottom,
                        horizontalAlignment = Enum.HorizontalAlignment.Center,
                        loadOrigin = "center",
                        visible = props.visible,
                        content = scope:Computed(function(use)
                            local buttons = {}
                            for _, item in {"Create Sim Bill", "Create Global  Bill", "Create UGT"} do --"View Amendments", "View Bills", 
                                local buttonComponent = scope:Button {
                                    roundness = 0.2,
                                    color = ColorPallete.whiteTwo,
                                    visible = props.visible,
                                    size = UDim2.fromScale(0.38, 0.15),
                                    onClick = function()
                                        props.currentFrame:set(item)
                                    end
                                }

                                scope:Hydrate(buttonComponent:FindFirstChildWhichIsA("ImageButton") :: any) {
                                    [Children] = Child {
                                        scope:Text {
                                            text = item,
                                            color = Color3.new(),
                                            disableShadow = true,
                                            size = UDim2.fromScale(0.8, 0.8)
                                        }
                                    }
                                }

                                table.insert(buttons, buttonComponent)
                            end

                            return buttons
                        end)
                    }
                }
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
        }
    }
end

function Interface.Start()

end

return Interface