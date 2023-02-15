

hook.Add("Lava.PlayerPushPlayer", "Iron Fist", function( Attacker, Victim )
	if Attacker:HasAbility("无情铁手") then
		Victim:SetVelocity(Attacker:GetForward():SetZ(-0.2) * 1500)
		return true
	end
end)

hook.Add("Lava.PostPlayerSpawn", "Iron Fist", function( Player )
	if Player:HasAbility("无情铁手") then
		Player:SetRunSpeed( Player:GetRunSpeed() * 0.8 )
		Player:SetWalkSpeed( Player:GetWalkSpeed() * 0.8 )
	end
end)

Abilities.Register("无情铁手", [[我他奶奶的终于练成了金刚屠龙麒麟臂！我要用我的麒麟臂把你们推飞！！！]], "1f91c-1f3fc" )