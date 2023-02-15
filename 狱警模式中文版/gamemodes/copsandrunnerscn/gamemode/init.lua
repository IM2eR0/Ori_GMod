Msg("Init.lua loads!")

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "countdown.lua" )

include( "player.lua" )
include( "shared.lua" )
include( "countdown.lua" )

util.AddNetworkString( "hasjail" )
util.AddNetworkString( "hassmoke" )
util.AddNetworkString( "hassmokespawn" ) 

resource.AddFile("models/props_sdk/jail.mdl")
resource.AddFile("sound/copsandrunners/cnrball_pixel.wav")
resource.AddFile("sound/copsandrunners/sent_cnrball_pixel.vtf")
resource.AddFile("sound/copsandrunners/sent_cnrball_pixel.vmt")

local SteamGroupLink = "http://steamcommunity.com/groups/teasofficial/memberslistxml/?xml=1"

devrmodel = 0
devcmodel = 0
lew_rmodel = 0
lew_cmodel = 0                                               -----------------------------------------------------
roz_rmodel = 0                                               --                 SERVER OWNERS:                  --
roz_cmodel = 0                                               -- I ask of you that you do not remove the rewards --
scob_rmodel = 0    -- These are part of the rewards          --   as they are given by me to people who helped  --
scob_cmodel = 0                                              --     make the game, to be used on all servers.   --
wolf_rmodel = 0                                              -----------------------------------------------------
wolf_cmodel = 0
eric_rmodel = 0
eric_cmodel = 0
devtags = { }

rainbowrewards = {
"STEAM_0:0:30508793",

}
rainbowactivated = { }
bBallPixel = { }                                 -- Rewards for handling players who have activated them
inCNRgroup = { }

function GM:PlayerCanSeePlayersChat( text, teamchat, listener, speaker)
	if text == "/rainbowsmoke 1" or text == "/rainbowsmoke 0" then return false end
	if text == "/betatag 1" or text == "/betatag 0" then return false end
	if text == "/betarmodel 1" or text == "/betarmodel 0" then return false end
	if text == "/betacmodel 1" or text == "/betacmodel 0" then return false end
	if text == "/devtag 1" or text == "/devtag 0" then return false end
	if text == "/rewardstest" then return false end
	
	-- The actual team chat function:	
		if teamchat then
			if listener:Team() == speaker:Team() then return true end
			if speaker:Team() == 1 and listener:Team() == 5 then return true end
			if speaker:Team() == 2 and (listener:Team() == 3 or listener:Team() == 4) then return true end
			if speaker:Team() == 3 and (listener:Team() == 2 or listener:Team() == 4) then return true end
			if speaker:Team() == 4 and (listener:Team() == 2 or listener:Team() == 3) then return true end
			if speaker:Team() == 5 and listener:Team() == 1 then return true end
		end
		
		if !teamchat then return true end
end

function teamChat( ply, message, teamchat)
	if ply:IsUserGroup() == "nt" or ply:IsAdmin() then
		if message == "/rainbowsmoke 1" then
			table.insert( rainbowactivated, ply:SteamID() )
			ply:C_msg("彩虹烟雾已启用。")
			return ""
		end

		if message == "/rainbowsmoke 0" then
			if table.HasValue( rainbowactivated, ply:SteamID() ) then
				table.remove( rainbowactivated, table.KeyFromValue( rainbowactivated, ply:SteamID() ) )
				ply:C_msg("彩虹烟雾已禁用。")
			end
			return ""
		end
	end
end
hook.Add("PlayerSay", "teamChat", teamChat)

concommand.Add("CheckStatus", function()
	print("狱警数量: "..team.NumPlayers(1).."")
	print("逃犯数量: "..team.NumPlayers(2).."")
	print("囚犯数量: "..team.NumPlayers(3).."")
	print("烟雾弹放置点持有者数量: "..team.NumPlayers(4).."")
	print("监狱长数量: "..team.NumPlayers(5).." (But there should always be 1)\n")
	print("狱警比例: "..GetConVar( "cnr_coppercentage" ):GetFloat() )
	print("烟雾弹放置点持有者比例: "..GetConVar( "cnr_armedrunners" ):GetInt())
	print("疾跑速度倍数: "..GetConVar( "cnr_speedmultiplier" ):GetFloat())
	print("回合时间: "..GetConVar( "cnr_timelimit" ):GetInt())
end, function() end, "Prints a list of status messages to the server console", {FCVAR_SERVER_CAN_EXECUTE} )


--[[ TEAM ASSIGNING ]]--

function GM:PlayerInitialSpawn( ply )
	-- If there's more than 1 player on the server, call RoundRestart
	if #player.GetAll() == 2 then
		RoundRestart()
		return
	end
	
 -- If jail doesn't exist, assign players regularly
if not IsValid( jail ) then
		-- If there are more players compared to the Cop Percentage, assign the player to Cops!
		if #player:GetAll() >= ((team.NumPlayers(1) + team.NumPlayers(5)) / GetConVar( "cnr_coppercentage" ):GetFloat()) and team.NumPlayers(5) > 0 then
			ply:SetCop()
		end
		-- If there are less Armed Runners than the set amount, assign as Armed Runner!
		if team.NumPlayers(4) < GetConVar( "cnr_armedrunners" ):GetInt() and #player:GetAll() < (team.NumPlayers(1) + 1) / GetConVar( "cnr_coppercentage" ):GetFloat()
			and team.NumPlayers(5) > 0 and ply:Team() != (5 or 2 or 3 or 4) then
			ply:SetArmedRunner()
		end
		-- If there are less players compared to the Cop Percentage, assign player as Runner!
		if #player:GetAll() < ((team.NumPlayers(1) + 1) / GetConVar( "cnr_coppercentage" ):GetFloat()) and team.NumPlayers(4) >= GetConVar( "cnr_armedrunners" ):GetInt() 
			and team.NumPlayers(5) > 0 then
			ply:SetRunner()
		end
end

-- However if jail exists, spawn players jailed, but also assign regular Cops!
if IsValid( jail ) == true then
	if #player:GetAll() >= (team.NumPlayers(1) + team.NumPlayers(5)) / GetConVar( "cnr_coppercentage" ):GetFloat() and team.NumPlayers(5) > 0 then
		ply:SetCop()
	else
		timer.Simple(0.1, function() ply:SetJailed() end)
	end
end

if table.HasValue( rainbowrewards, ply:SteamID() ) then
	ply:C_msg("你可以使用彩虹烟雾弹，按下右键来切换!")
end

http.Fetch( SteamGroupLink,
	function(body)
		local playerIDStartIndex = string.find( tostring(body), "<steamID64>"..ply:SteamID64().."</steamID64>" )
			if playerIDStartIndex == nil then
				
			else
				ply:C_Msg("你已经成功加入了服务器组！你现在享有 弹力球皮肤 < The Banter Brigade >")
				table.insert( inCNRgroup, ply:SteamID() )
			end
	end,
	function()
	end
)

end

function GM:PlayerSpawn(jailedspawner)
	if (jailedspawner:Team() == 3 or jailedspawner:Team() == 2 or jailedspawner:Team() == 4) and IsValid( jail ) then
		jailedspawner:SetJailed()
	end
end


function GM:PlayerSwitchFlashlight(ply, SwitchOn)
     return true
end

function GM:PlayerCanPickupWeapon(ply, weapon)
	if weapon:GetClass() == "cnr_smokegrenade"
	or weapon:GetClass() == "weapon_crowbar" 
	or weapon:GetClass() == "cnr_hands" 
	or weapon:GetClass() == "cnr_jail" 
	or weapon:GetClass() == "weapon_stunstick"
	or weapon:GetClass() == "cnr_smokespawn"
	or weapon:GetClass() == "cnr_stunstick"
	or weapon:GetClass() == "cnr_teststunstick" 
	or weapon:GetClass() == "test"
	or weapon:GetClass() == "test2"
	or weapon:GetClass() == "test3" then
		return true
	else return false
	end
end

concommand.Add( "ForceRoundRestart",RoundRestart, function() end, "Forces a round restart", {FCVAR_SERVER_CAN_EXECUTE} )

concommand.Add("cnr_preset_1.0", function()
game.ConsoleCommand("cnr_instafree 1\n")
game.ConsoleCommand("cnr_preptime 1\n")
game.ConsoleCommand("cnr_copextraspeed 1.25\n")
game.ConsoleCommand("cnr_wardenafk 0\n")
game.ConsoleCommand("cnr_jailmindist 1\n")
game.ConsoleCommand("cnr_jailmaxdist 2\n")
end, function() end, "Changes all ConVars that were changed to their 1.0 state", {FCVAR_SERVER_CAN_EXECUTE})

concommand.Add("cnr_preset_1.1", function()
game.ConsoleCommand("cnr_instafree 0\n")
game.ConsoleCommand("cnr_preptime 20\n")
game.ConsoleCommand("cnr_copextraspeed 1.1\n")
game.ConsoleCommand("cnr_wardenafk 15\n")
game.ConsoleCommand("cnr_jailmindist 1000\n")
game.ConsoleCommand("cnr_jailmaxdist 2000\n")
end, function() end, "Changes all ConVars that were changed to their 1.1 state", {FCVAR_SERVER_CAN_EXECUTE})