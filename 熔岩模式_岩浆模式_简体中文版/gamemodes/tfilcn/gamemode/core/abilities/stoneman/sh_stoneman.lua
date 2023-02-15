
hook.Add("Lava.PlayerPushPlayer", "Stoneman", function( Attacker, Victim )
	if Victim:HasAbility("石头人") and not Attacker:HasAbility("石头人") then
		Attacker:SetVelocity( -( Attacker:GetForward() * 1100 ):SetZ( 0 ) )
		return true
	end
end)

Abilities.Register("石头人", [[荆棘 X！击退抗性 X！(MC乱入)]], "1f5ff" )
