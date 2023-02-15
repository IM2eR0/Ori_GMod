local AddHook = Mutators.RegisterHooks("大蛋头", {
	"Lava.PostPlayerRagdolled"
})
local Vectors = {
	Big = Vector(5, 5, 5),
	Normal = Vector(1, 1, 1)
}

hook.Add("Lava.PostPlayerSpawn", "大蛋头", function(Player)
	Player:OnBoneExisting("ValveBiped.Bip01_Head1", function(bid)
		if Mutators.IsActive("大蛋头") then
			Player:ManipulateBoneScale(bid, Vectors.Big)
		elseif not Mutators.IsActive("大蛋头") then
			Player:ManipulateBoneScale(bid, Vectors.Normal)
		end
	end)
end)

Mutators.RegisterNewEvent("大蛋头", "各种鸟事蜂拥而至，大家的头都变大了.", function()
	for Player in Values(player.GetAll()) do
		Player:OnBoneExisting("ValveBiped.Bip01_Head1", function(bid)
			Player:ManipulateBoneScale(bid, Vectors.Big)
		end)
	end

	AddHook(function(Player, Ragdoll)
		Ragdoll:OnBoneExisting("ValveBiped.Bip01_Head1", function(bid)
			Ragdoll:ManipulateBoneScale(bid, Vectors.Big)
		end)
	end)
end, function()
	for Player in Values(player.GetAll()) do
		Player:OnBoneExisting("ValveBiped.Bip01_Head1", function(bid)
			Player:ManipulateBoneScale(bid, Vectors.Normal)
		end)
	end
end)