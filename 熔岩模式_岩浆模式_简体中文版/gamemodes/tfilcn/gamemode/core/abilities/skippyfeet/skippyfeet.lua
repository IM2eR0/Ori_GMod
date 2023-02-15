local Timer = Timer
local Entity = Entity
local Vector = Vector
local FrameDelay = FrameDelay

hook.Add("Lava.ShouldTakeLavaDamage", "SkippyFeet", function(Player)
	if not Player:HasAbility("臭袜子") then return end
	Player:SetGroundEntity( Entity( 0 ) )
	FrameDelay( function()
		Player:SetPos(Player:GetPos() + Vector(0, 0, 5))
		Player:SetVelocity(Player:GetAimVector():SetZ(1) * 250)
	end)
end)

hook.Add("GetFallDamage", "AvoidFallDamage", function(Player)
	if Player:HasAbility("臭袜子") then return false end
end)

hook.Add("Lava.PostPlayerSpawn", "HalfenHealth", function( Player )
	if Player:HasAbility("臭袜子") then
		Player:SetMaxHealth( 30 )
		Player:SetHealth( 30 )
	end
end)

Abilities.Register("臭袜子", [[袜子很臭！
	熔岩很烫！
	臭袜子与熔岩进行化学反应，让你芜湖起飞！
	臭袜子能保你命，保你摔不死，还能保你更耐烫(熔岩伤害-50%)]], "1f9b6-1f3fd", function( Player )
		Player:SetMaxHealth( 30 )
		Player:SetHealth( 30 )
	end,
	function( Player )
		Player:SetMaxHealth( 100 )
		Player:SetHealth( 100 )
	end)