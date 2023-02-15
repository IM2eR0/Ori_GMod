local ply = FindMetaTable("Player")

local teamColors = {}

-- Team 0 -> All Cops
-- Team 1 -> All Runners

teamColors[1] = Vector(1, 0, 0) -- Cops color: Red
teamColors[2] = Vector(0, 0, 1) -- Runners color: Blue


--[[ TEAM ARMING ]]--

-- Function to set player as Warden
function ply:SetWarden()
	self:SetTeam( 5 )
	self:SetModel("models/player/combine_soldier_prisonguard.mdl")
	self:SetPlayerColor( teamColors[1] )
	self:SetHealth( 100 )
	self:StripWeapons()
	self:Give("cnr_stunstick")
	self:Give("cnr_jail")
	self:Freeze( false )
	--self:SetCustomCollisionCheck( true )
	self:SetWalkSpeed( (260 * GetConVar( "cnr_copextraspeed" ):GetFloat() ) * GetConVar( "cnr_speedmultiplier" ):GetFloat() )
	self:SetRunSpeed( (520 * GetConVar( "cnr_copextraspeed" ):GetFloat() )* GetConVar( "cnr_speedmultiplier" ):GetFloat() )
	self:SetNoCollideWithTeammates( false )
	umsg.Start("hasjail", self)
		umsg.Bool(true)
	umsg.End()

	-- Alert that the player is Warden
	for k, v in pairs(player.GetAll()) do
		v:C_msg(self:GetName().." 是本局的监狱长!")
	end
end

-- Function to set player as Cop
function ply:SetCop()
	self:SetTeam( 1 )
	self:SetModel("models/player/combine_soldier.mdl")
	
	self:SetPlayerColor( teamColors[1] )
	self:SetHealth( 100 )
	self:StripWeapons()
	self:Give("cnr_stunstick")
	self:Freeze( false )
	--self:SetCustomCollisionCheck( true )
	self:SetWalkSpeed( (260 * GetConVar( "cnr_copextraspeed" ):GetFloat() ) * GetConVar( "cnr_speedmultiplier" ):GetFloat() )
	self:SetRunSpeed( (520 * GetConVar( "cnr_copextraspeed" ):GetFloat() ) * GetConVar( "cnr_speedmultiplier" ):GetFloat() )
	self:SetNoCollideWithTeammates( false )

	-- Alert that the player is a Cop
	for k, v in pairs(player.GetAll()) do
		v:C_msg(self:GetName().." 是本局的狱警!")
	end
end

-- Function to set player as Runner
function ply:SetRunner()
	self:SetTeam( 2 )
	self:SetModel("models/player/kleiner.mdl")
	
	self:SetPlayerColor( teamColors[2] )
	self:SetHealth( 100 )
	self:StripWeapon("weapon_stunstick")
	self:StripWeapon("cnr_jail")
	self:StripWeapon("cnr_smokespawn")
	self:StripWeapon("cnr_stunstick")
	self:Give("weapon_crowbar")
	self:Give("cnr_hands")
	self:Freeze( false )
	self:SetPos(self:GetPos() + Vector(0,0,5))
	--self:SetCustomCollisionCheck( true )
	self:SetWalkSpeed( 200 * GetConVar( "cnr_speedmultiplier" ):GetFloat() )
	self:SetRunSpeed( 400 * GetConVar( "cnr_speedmultiplier" ):GetFloat() )
	self:SetNoCollideWithTeammates( false )
end

-- Function to set player as Jailed Runner
function ply:SetJailed()
	self:SetTeam( 3 )
	self:SetModel("models/player/kleiner.mdl")
	
	self:SetPlayerColor( teamColors[2] )
	self:SetHealth( 100 )
	self:Freeze( false )
	self:SetVelocity( (self:GetVelocity() * 0) )
	self:SetPos( jail:GetPos() + Vector(0,0,10) )
	self:StripWeapon("weapon_stunstick")
	self:StripWeapon("cnr_jail")
	self:StripWeapon("weapon_crowbar")
	self:StripWeapon("cnr_smokespawn")
	self:StripWeapon("cnr_smokegrenade")
	self:StripWeapon("cnr_stunstick")
	umsg.Start("hassmokespawn", self)
		umsg.Bool(false)
	umsg.End()
	umsg.Start("hassmoke", self)
		umsg.Bool(false)
	umsg.End()
	self:Give( "cnr_hands" )
	--self:SetCustomCollisionCheck( true )
	self:EmitSound("coach/coach_go_here.wav",100,100)
	self:SetWalkSpeed( 200 * GetConVar( "cnr_speedmultiplier" ):GetFloat() )
	self:SetRunSpeed( 400 * GetConVar( "cnr_speedmultiplier" ):GetFloat() )
	self:SetNoCollideWithTeammates( true )
	hook.Call("Captured")
end

-- Function to set player as Armed Runner
function ply:SetArmedRunner()
	self:SetTeam( 4 )
	self:SetModel("models/player/kleiner.mdl")
	
	self:SetPlayerColor( teamColors[2] )
	self:SetHealth( 100 )
	self:StripWeapon("weapon_stunstick")
	self:StripWeapon("cnr_jail")
	self:Give( "weapon_crowbar" )
	self:Give( "cnr_hands" )
	self:Give( "cnr_smokespawn" )
	self:StripWeapon("cnr_stunstick")
	self:Freeze( false )
	--self:SetCustomCollisionCheck( true )
	self:SetWalkSpeed( 200 * GetConVar( "cnr_speedmultiplier" ):GetFloat() )
	self:SetRunSpeed( 400 * GetConVar( "cnr_speedmultiplier" ):GetFloat() )
	self:SetNoCollideWithTeammates( false )
end

--[[ CATCHING AND FREEING ]]--

function GM:PlayerHurt(ply, attacker, remaininghealth, dmgnumber)
if !postround then

local curHealth = ply:Health()
if IsValid( jail ) then -- Tagging only works if Jail has been placed
  	-- local variables to verify whether it was a cop or another runner, or maybe the environment, that did the damage
  	local foundCop = false;
	local foundRunner = false;


    	-- Find attacker, check his team and call it
			if attacker:IsPlayer() and (attacker:Team() == 1 or attacker:Team() == 5) then
				foundCop = true;
			end
			if attacker:IsPlayer() and (attacker:Team() == 2 or attacker:Team() == 4) then
				foundRunner = true;
			end

    -- If an attacker has been found
    if foundCop == true then

			-- Find catched runner, jail him
				if ply:Team() == 2 or ply:Team() == 4 then
					ply:SetJailed()
					B_Notify(attacker:GetName().." 抓到了 "..ply:GetName().."!")
					ply:SetHealth(100)
					attacker:EmitSound("coach/coach_go_here.wav",100,100)
					attacker:AddFrags(1)
				elseif ply:Team() == 3 then 
					ply:SetHealth(100)
					if ply:GetPos():Distance(jail:GetPos()) >= 170 then ply:SetJailed() end
				end
				
	elseif foundRunner == true then

			-- Find jailed runner, free him
				if ply:Team() == 3 then
					if GetConVar( "cnr_instafree" ):GetInt() != 0 then
						ply:SetRunner()
						B_Notify(attacker:GetName().." 救出了 "..ply:GetName().."!")
						ply:SetHealth(100)
						attacker:AddFrags(1)
					else
						if ply:Health() <= GetConVar( "cnr_crowdamage" ):GetInt() - 25 then
							ply:SetRunner()
							B_Notify(attacker:GetName().." 救出了 "..ply:GetName().."!")
							ply:SetHealth(100)
						else
							ply:SetHealth(curHealth - GetConVar( "cnr_crowdamage" ):GetInt() + 25 ) -- The +25 is to negate the Crowbars normal damage
							attacker:AddFrags(1)
						end
					end
				end
	else
		-- If an attacker wasn't found, it means the player was hurt by the environment,
		-- so his health is set back to 100 here
		ply:SetHealth( 100 )
	end
-- If Jail doesn't exist but a player was hurt, set his health back to 100
else ply:SetHealth( 100 )
end
if attacker:GetClass() == "trigger_hurt" then
	ply:Kill()
end
if attacker:GetClass() == "prop_physics" and dmgnumber >= 75 then
	ply:Kill()
end
if attacker:GetClass() == "func_door" and dmgnumber >= 75 then
	ply:Kill()
end
if attacker:GetClass() == "func_movelinear" and dmgnumber >= 75 then
	ply:Kill()
end
if attacker:IsPlayer() and attacker != ply and dmgnumber >= 75 then
	ply:Kill()
end
if ply:Team() != 3 then
	ply:SetHealth( 100 ) -- Failsafe, in case anything goes wrong, it always sets health to 100
end

-- Victory Killing. The Victors can kill the loosers.
else
	if copswin then
		if attacker:IsPlayer() and ((attacker:Team() == 2 or attacker:Team() == 4) or (ply:Team() == 1 or ply:Team() == 5)) then
			ply:SetHealth(100)
		end
	end
	if runnerswin then
		if attacker:IsPlayer() and (((attacker:Team() == 1 or attacker:Team() == 5) and ply:Team() != 3) or (ply:Team() == 2 or ply:Team() == 4)) then
			ply:SetHealth(100)
		end
	end

end
end

function GM:GetFallDamage( fallplayer, speed )
	speed = speed - 580
		if speed * (100/(1024-580)) >= 75 then
			timer.Simple(0.2, function() fallplayer:Kill() end)
		end
end

-- Here we set timers up to respawn players and rearm them, then jail them if jail exists
function playerRespawning( victim, weapon, killer )
	if victim:Team() == 2 then
		if IsValid( jail ) then
			timer.Simple(4, function() victim:Spawn() victim:Give("cnr_hands") end)
			timer.Simple(0, function() victim:SetTeam(3) hook.Call("Captured") end)
		else
			timer.Simple(4, function() victim:Spawn() victim:Give("cnr_hands") victim:Give("weapon_crowbar") end)
		end
	elseif victim:Team() == 4 then
		if IsValid( jail ) then
			timer.Simple(4, function() victim:Spawn() victim:Give("cnr_hands") end)
			timer.Simple(0, function() victim:SetTeam(3) hook.Call("Captured") end)
		else
			timer.Simple(4, function() victim:Spawn() victim:Give("cnr_hands") victim:Give("weapon_crowbar")
			umsg.Start("hassmokespawn")
				umsg.Bool(false)
			umsg.End() end)
		end
	elseif victim:Team() == 3 then
		timer.Simple(4, function() if IsValid(victim) then victim:Spawn() end end)
		timer.Simple(0, function() victim:SetTeam(3) hook.Call("Captured") end)
	elseif victim:Team() == 1 then
		timer.Simple(4, function() victim:Spawn() victim:Give("cnr_stunstick") end)
	elseif victim:Team() == 5 then
		if IsValid( jail ) then
			timer.Simple(4, function() victim:Spawn() victim:Give("cnr_stunstick") end)
		else timer.Simple(4, function() victim:Spawn() victim:Give("cnr_jail") victim:Give("cnr_stunstick") end)
		end
	elseif victim:Team() == 0 then victim:Spawn()
	end
end
hook.Add("PlayerDeath", "Respawning", playerRespawning)

function GM:PlayerDeathThink( player )
end

hook.Add("PlayerSay","Debug",function (ply,text)
	if text == "!!msg" then
		ply:C_msg("114514")
		C_Broadcast("114514")
		return ""
	end
end)