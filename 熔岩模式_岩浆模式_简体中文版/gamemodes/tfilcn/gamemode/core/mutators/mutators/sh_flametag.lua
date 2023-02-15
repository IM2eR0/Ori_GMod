local AddHook = Mutators.RegisterHooks("燃不起来的博人转", {
	"PlayerShouldTakeDamage",
	"Think",
	"PlayerTick"
})

Mutators.RegisterNewEvent("燃不起来的博人转", "一个玩家阅读了博人转后燃起来了！只要靠近你你也会燃起来！拥抱他人吧！", function()
	if SERVER then
		local Player = Mutators.GetRandomPlayerForEvent("燃不起来的博人转")
		if not IsValid( Player ) then return end
		Mutators.DesignateSpecialPlayer(Player)

		if Mutators.GetSpecialPlayer() then
			local sPlayer = Mutators.GetSpecialPlayer()
			sPlayer:SetModel("models/player/charple.mdl")
			sPlayer:SetWalkSpeed( 100 )
			sPlayer:SetRunSpeed( 200 )
			Notification.SendType( "Mutator", sPlayer:Nick() .. " 阅读了博人转，燃起来了!" )
			if SERVER then
				sPlayer:Ignite(500, 128)
				sPlayer.PreferedAbility = sPlayer:GetAbility()
				sPlayer:SetAbility("$none")
			end

			AddHook(function(Player, Attacker)
				if Player == sPlayer and IsValid(Attacker) and Attacker:GetClass() == "entityflame" and Attacker:GetPos().z > Lava.GetLevel() then return false end
			end)
			AddHook(function() end)
		end
	end
	if CLIENT then
		AddHook( function() end)
		AddHook( function()	end)
	end
	AddHook( function( Player )
		local Special = Mutators.GetSpecialPlayer()
		if Player ~= Special and IsValid( Special ) then
			if SERVER and Player:GetPos():Distance( Special:GetPos() ) < 75 then
				Player:Ignite( 0.1, 0 )
			end
		end
	end)
end, function()
	Mutators.ClearSpecialPlayer()
end)