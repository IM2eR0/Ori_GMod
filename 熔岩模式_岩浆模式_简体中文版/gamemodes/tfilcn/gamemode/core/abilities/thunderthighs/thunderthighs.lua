

local function func( Player )
	if Player:IsValid() and Player:HasAbility("迅雷") and Player:LookupBone("ValveBiped.Bip01_R_Thigh") then
		if ( Player:GetBonePosition( Player:LookupBone("ValveBiped.Bip01_R_Thigh")).z ) > Lava.GetLevel() then
			return false
		end
	end
end

hook.Add("Lava.ShouldRenderDamageOverlay", "ThunderThighs", func )
hook.Add("Lava.ShouldTakeLavaDamage", "ThunderThighs", func )
hook.Add("GetFallDamage", "AvoidFallDamageTT", function(Player)
	if Player:HasAbility("迅雷") then return false end
end)

Abilities.Register("迅雷", [[因为往复的运动(?)
    熔岩直到你的屁股也不会烫伤你
	你猜猜为什么呢~~
	同时你免疫摔落伤害]], "1f9b5-1f3fc" )

