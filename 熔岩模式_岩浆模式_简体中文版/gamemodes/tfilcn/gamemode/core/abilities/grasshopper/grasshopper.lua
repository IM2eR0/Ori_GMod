
hook.Add("SetupMove", "Grasshopper", function( Player, Movedata )
	if Player:HasAbility("蚂蚱") then
		Player.m_JumpsLeft = Player.m_JumpsLeft or 3
		if Player:OnGround() then
			Player.m_JumpsLeft = 3
		end
		if not Player.m_HasApeJumped and Player.m_JumpsLeft > 0 and not Player:OnGround() and Player:KeyDown( 2 ) then
			Player.m_HasApeJumped = true
			Player.m_JumpsLeft = Player.m_JumpsLeft - 1
			local CurrentVelocity = Movedata:GetVelocity()
			local ShouldBlockFall
			if CurrentVelocity.z < 0 then
				ShouldBlockFall = true
			end
			Movedata:SetVelocity( CurrentVelocity:SetZ( 0 ) + ( ( Player:GetJumpPower() + ( ShouldBlockFall and CurrentVelocity.z or 0 ))* Vector( 0, 0, 1 ) * 1.2 ) )
		elseif not Player:KeyDown(2) then
			Player.m_HasApeJumped = nil
		end
	end
end)

hook.Add("GetFallDamage", "AvoidFallDamageGrass", function(Player, Speed)
	if Player:HasAbility("蚂蚱") then return CalculateBaseFallDamage( Speed )/4 end
end)


Abilities.Register("蚂蚱", [[嗯，看起来你变成了一只蚂蚱，所以你可以进行三段跳了，并且会减免75%的摔落伤害，跳跃高度略高于其他玩家]], "1f997" )