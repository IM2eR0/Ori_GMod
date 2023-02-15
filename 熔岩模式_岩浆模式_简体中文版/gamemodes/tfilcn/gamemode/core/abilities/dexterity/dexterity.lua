hook.Add("GetFallDamage", "LessenFallDamageDexitrity", function(Player, Speed )
	if Player:HasAbility("杂技师") then return CalculateBaseFallDamage( Speed )/2.5 end
end)

hook.Add("Lava.PostPlayerSpawn", "AddDexterity", function( Player )
	if Player:HasAbility("杂技师") then
		Player:SetRunSpeed( 400 )
		Player:SetWalkSpeed( 300 )
		Player:SetJumpPower( 400 )
	end
end)

Abilities.Register("杂技师", [[你拥有双倍的跳跃高度与奔跑速度
	而且你会获得60%的摔落伤害减免]], "1f938-1f3fb-200d-2640-fe0f",
	function( Player )
		Player:SetRunSpeed( 400 )
		Player:SetWalkSpeed( 300 )
		Player:SetJumpPower( 400 )
	end, function( Player )
		Player:SetRunSpeed( 225 )
		Player:SetWalkSpeed( 175 )
		Player:SetJumpPower( 250 )
	end )
