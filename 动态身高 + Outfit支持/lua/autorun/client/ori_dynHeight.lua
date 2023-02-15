hook.Add("OutfitApply","模型更改后动态视角设置",function()
    local height_max = 64
    local height_min = 16

    local entity = ents.CreateClientside("base_anim")
    local entity2 = ents.CreateClientside("base_anim")

    entity:SetModel(LocalPlayer():GetModel())
    entity2:SetModel(LocalPlayer():GetModel())

    entity:ResetSequence(entity:LookupSequence("idle_all_01"))
    local bone = entity:LookupBone("ValveBiped.Bip01_Neck1")
    if bone then
        height_max = entity:GetBonePosition(bone).z + 5
    end

    entity2:ResetSequence(entity:LookupSequence("cidle_all"))
    local bone2 = entity2:LookupBone("ValveBiped.Bip01_Neck1")
    if bone2 then
        height_min = entity2:GetBonePosition(bone2).z + 5
    end

    entity:Remove()
    entity2:Remove()

    net.Start("Ori:ViewCCHeiget")
    net.WriteInt(height_max ,32)
	net.WriteInt(height_min ,32)
    net.SendToServer()
end)
print("[初雪 OriginalSnow] 动态视角插件 CL 已加载！")