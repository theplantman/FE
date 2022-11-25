local Library = {
    ["MetaTable"] = getrawmetatable(game),
    ["AttachObjects"] = {}
}
function Library:Execute(Arguments)
    if Arguments["Action"] == "NetBypass" then
        game.RunService.Heartbeat:Connect(function()
            settings().Physics.AllowSleep = false
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
            sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", 1000)
            for Index, Part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if Part.ClassName:match("Part") and Part.ClassName ~= "ParticleEmitter" and Part.Name ~= "HumanoidRootPart" then
                    Part.Velocity = Vector3.new(35, 35, 35)
                end
            end
        end)
    elseif Arguments["Action"] == "Attach" and Arguments["Attach"] and Arguments["AttachTo"] then
        Arguments["Attach"]:BreakJoints()
        local Attachment1 = Instance.new("Attachment")
        Attachment1.Parent = Arguments["Attach"]
        Attachment1.Position = Vector3.new()
        local Attachment2 = Instance.new("Attachment")
        Attachment2.Parent = Arguments["AttachTo"]
        Attachment2.Position = Arguments["Position"] or Vector3.new()
        Attachment2.Rotation = Arguments["Orientation"] or Vector3.new()
        local AlignPosition = Instance.new("AlignPosition")
        AlignPosition.Parent = Arguments['Attach']
        AlignPosition.Attachment0 = Attachment1
        AlignPosition.Attachment1 = Attachment2
        AlignPosition.RigidityEnabled = false
        AlignPosition.ReactionForceEnabled = false
        AlignPosition.MaxForce = 9e999
        AlignPosition.MaxVelocity = 9e999
        AlignPosition.Responsiveness = 9e999
        local AlignOrientation = Instance.new("AlignOrientation")
        AlignOrientation.Parent = Arguments["Attach"]
        AlignOrientation.Attachment0 = Attachment1
        AlignOrientation.Attachment1 = Attachment2
        AlignOrientation.ReactionTorqueEnabled = false
        AlignOrientation.MaxTorque = 9e999
        AlignOrientation.MaxAngularVelocity = 9e999
        AlignOrientation.Responsiveness = 9e999
        Library["AttachObjects"][Attachment1] = Attachment1
        Library["AttachObjects"][Attachment2] = Attachment2
        Library["AttachObjects"][AlignPosition] = AlignPosition
        Library["AttachObjects"][AlignOrientation] = AlignOrientation
    end
end
Library["OldNameCall"] = Library["MetaTable"]["__namecall"]
setreadonly(Library["MetaTable"], false)
Library["MetaTable"]["__namecall"] = function(self, ...)
    if getnamecallmethod():lower() == "kick" or getnamecallmethod():lower() == "shutdown" then
        return nil
    elseif Library["AttachObjects"][self] and getnamecallmethod():lower() == "destroy" then
        return nil
    end
    return Library["OldNameCall"](self, ...)
end
setreadonly(Library["MetaTable"], true)
return Library
