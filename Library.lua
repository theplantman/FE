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
            local Table
            if Arguments["Character"] then
                Table = Arguments["Character"]:GetChildren()
            else
                Table = game.Players.LocalPlayer.Character:GetDescendants()
            end
            for Index, Part in pairs(Table) do
                if (Arguments["Type"] or "Normal") == "Normal" and Part.ClassName:match("Part") and Part.ClassName ~= "ParticleEmitter" and Part.Name ~= "HumanoidRootPart" then
                    Part.Velocity = Vector3.new(35, 35, 35)
                elseif Arguments["Type"] == "Special" and Part.ClassName:match("Part") and Part.ClassName ~= "ParticleEmitter" then
                    Part.Velocity = Vector3.new(35, 35, 35)
                end
            end
        end)
    elseif Arguments["Action"] == "Attach" and Arguments["Attach"] and Arguments["AttachTo"] then
        if Arguments["Attach"].Name ~= "Torso" then
            Arguments["Attach"]:BreakJoints()
        end
        local Attachment1 = Instance.new("Attachment")
        Attachment1.Parent = Arguments["Attach"]
        Attachment1.Position = Vector3.new()
        local Attachment2 = Instance.new("Attachment")
        Attachment2.Name = "Important"
        Attachment2.Parent = Arguments["AttachTo"]
        Attachment2.Position = Arguments["Position"] or Vector3.new()
        Attachment2.Rotation = Arguments["Orientation"] or Vector3.new()
        local AlignPosition = Instance.new("AlignPosition")
        AlignPosition.Parent = Arguments["Attach"]
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
    elseif Arguments["Action"] == "Reanimate" then
        local OldCharacter = game.Players.LocalPlayer.Character
        Library:Execute({
            ["Action"] = "NetBypass",
            ["Character"] = OldCharacter,
            ["Type"] = "Special"
        })
        game.Players.LocalPlayer.Character.Archivable = true
        local FakeCharacter = game.Players.LocalPlayer.Character:Clone()
        FakeCharacter.Parent = game.Players.LocalPlayer.Character
        for Index, Part in pairs(FakeCharacter:GetChildren()) do
            if Part.ClassName:match("Part") and Part.ClassName ~= "ParticleEmitter" then
                if Part.Name == "Head" then
                    Part.face.Transparency = 1
                end
                Part.Transparency = 1
            elseif Part.ClassName == "Accessory" then
                Part:Destroy()
            end
        end
        game.RunService.Stepped:Connect(function()
            for Index, Part in pairs(OldCharacter:GetChildren()) do
                if Part.ClassName:match("Part") and Part.ClassName ~= "ParticleEmitter" and Part.CanCollide == true then
                    Part.CanCollide = false
                end
            end
        end)
        for Index, Part in pairs(OldCharacter:GetChildren()) do
            if Part.ClassName:match("Part") and Part.ClassName ~= "ParticleEmitter" and FakeCharacter:FindFirstChild(Part.Name) and Part.Name ~= "Head" then
                Library:Execute({
                    ["Action"] = "Attach",
                    ["Attach"] = Part,
                    ["AttachTo"] = FakeCharacter[Part.Name]
                })
            end
        end
        game.Players.LocalPlayer.Character = FakeCharacter
        game.Workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
        return OldCharacter
    elseif Arguments["Action"] == "Lerp" and Arguments["Part"]:FindFirstChild("Important") then
        task.spawn(function()
            for Index = 0.1, 1, 0.1 do
                Arguments["Part"].Important.Position = Arguments["Part"].Important.Position:Lerp(Arguments["Position"] or Vector3.new(), Index)
                Arguments["Part"].Important.Rotation = Arguments["Part"].Important.Rotation:Lerp(Arguments["Rotation"] or Vector3.new(), Index)
                task.wait((Arguments["Speed"] or 1) / 10)
            end
        end)
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
