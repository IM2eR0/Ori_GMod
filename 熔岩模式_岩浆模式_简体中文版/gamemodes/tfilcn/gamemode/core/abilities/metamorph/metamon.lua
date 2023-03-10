
hook.Add( "Lava.PlayerPushPlayer", "METAMON", function( Attacker, Victim )
	if Victim:HasAbility("战五渣") then
		Victim:SetAbilityMeter( (Victim:GetAbilityMeter() + 1):min( 11 ) )
		Victim:SetAbilityInUse( true )
		timer.Simple( 1.5, function()
			if IsValid( Victim ) then
				Victim:SetAbilityInUse( false )
			end
		end)
	end
	if Attacker:HasAbility("战五渣") then
		Victim:SetVelocity(Attacker:GetForward():SetZ(Victim:OnGround() and 0.2 or -0.2) * ( 210 * Attacker:GetAbilityMeter() ) )
		Victim.m_LastShovedBy = Attacker
		Victim.m_LastShovedTime = CurTime()
		Attacker:SetAbilityMeter( 0 )
		return true
	end
end)

local Metamat = Material("models/props_combine/com_shield001a")

hook.Add("PlayerRender", "DrawMETAMON", function( Player )
	if Player:HasAbility("战五渣") and Player:IsAbilityInUse() then
		render.MaterialOverride( Metamat )
		Player:DrawModel()
		render.MaterialOverride()
		return true
	end
end)

hook.Add("Lava.PostPlayerSpawn", "METAMON", function( Player )
	Player:SetAbilityMeter( 0 )
end)

hook.Add("PlayerTick", "MetamonAutoregen", function( Player )
	if Player:HasAbility("战五渣") then
		Player:SetAbilityMeter( (Player:GetAbilityMeter() + FrameTime()/25 ):min( 11 ) )
	end
end)

hook.Add("HUDPaint", "DRAWMON", function()
	if LocalPlayer():HasAbility("战五渣") and LocalPlayer():Alive() then
		draw.Rect( ScrW()/2, ScrH() * 0.9, ScrW()*0.4 + WebElements.Edge * 2, ScrH()/25 + WebElements.Edge, pColor(), nil, 0 )
		draw.WebImage( WebElements.PowerMeter, ScrW()/2, ScrH() * 0.9, ScrW()*0.4, ScrH()/25, nil, 0)
		draw.WebImage( Emoji.Get( "1f4a5" ), (ScrW()*0.3 + (( CurTime() * (LocalPlayer():GetVelocity():Length2D()/20):max( 4 ) ) ):cos() * 5):max( ScrW()*0.3 ) + ( LocalPlayer():GetAbilityMeter():min( 10 )/10 ) * ScrW()*0.4, ScrH() * 0.895, ScrH()/20, ScrH()/20, nil, 0 )
	end
end)

Abilities.Register("战五渣", [[你是个战五渣，推不动人，但是你可以吸取别人的力量，别人越推你你越猛。]], "1f47e",
	function( Player )
		Player:SetAbilityMeter( 0 )
	end)