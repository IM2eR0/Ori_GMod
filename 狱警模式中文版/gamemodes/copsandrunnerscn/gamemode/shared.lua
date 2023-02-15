GM.Name 	= "狱警模式"
GM.Author 	= "初雪 OriginalSnow & YurIsLuv" 
GM.Email 	= "i@teasmc.cn" 
GM.Website 	= "N/A" 

print("\n\n\t> 核心驱动文件 已加载 <\n\n")

if SERVER then
	resource.AddWorkshop(2889955037)
end

local Player = FindMetaTable('Player')

if CLIENT then
    function cnr2_msg(msg)
        chat.AddText(Color(255,255,255),"[",Color(0,234,255),"提示",Color(255,255,255),"] ",msg)
    end
end

net.Receive("cnr2.msg",function()
    local msg = net.ReadString()
    
    cnr2_msg(msg)
end)

net.Receive('C_SendNotification', function(length)
    local str = net.ReadString()
    notification.AddLegacy(str, NOTIFY_GENERIC, 5)
end)

if SERVER then
    util.AddNetworkString('cnr2.msg')

    function Player:C_msg(...)
        local str = table.concat({...}, '')
    
        net.Start('cnr2.msg')
        net.WriteString(str)
        net.Send(self)
    end

    function C_Broadcast(...)
        local str = table.concat({...}, '')
    
        net.Start('cnr2.msg')
        net.WriteString(str)
        net.Broadcast()
    end

    util.AddNetworkString('C_SendNotification')

    function Player:C_Notify(...)
        local str = table.concat({...}, '')
    
        net.Start('C_SendNotification')
        net.WriteString(str)
        net.Send(self)
    end

    function B_Notify(...)
        local str = table.concat({...}, '')
    
        net.Start('C_SendNotification')
        net.WriteString(str)
        net.Broadcast()
    end
    
end


Msg("Main Shared.lua loads")

preparing = false
copswin = false
runnerswin = false

jailtable = {}
bBalls = {}

--[[ ConVars ]]--

--if not ConVarExists( "cnr_jailsize" ) then CreateConVar( "cnr_jailsize", 300, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY } ) end
if not ConVarExists( "cnr_coppercentage" ) then CreateConVar( "cnr_coppercentage", 0.2, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY } ) end
if not ConVarExists( "cnr_timelimit" ) then CreateConVar( "cnr_timelimit", 180, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY } ) end
if not ConVarExists( "cnr_armedrunners" ) then CreateConVar( "cnr_armedrunners", 1, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY } ) end
if not ConVarExists( "cnr_postroundtime" ) then CreateConVar( "cnr_postroundtime", 10, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY } ) end
if not ConVarExists( "cnr_speedmultiplier" ) then CreateConVar( "cnr_speedmultiplier", 1, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY } ) end
if not ConVarExists( "cnr_smokedelay" ) then CreateConVar( "cnr_smokedelay", 15, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_REPLICATED } ) end
if not ConVarExists( "cnr_instafree" ) then CreateConVar( "cnr_instafree", 0, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY } ) end
if not ConVarExists( "cnr_crowdamage" ) then CreateConVar( "cnr_crowdamage", 15, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_SERVER_CANNOT_QUERY } ) end
if not ConVarExists( "cnr_preptime" ) then CreateConVar( "cnr_preptime", 15, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY } ) end
if not ConVarExists( "cnr_copextraspeed" ) then CreateConVar( "cnr_copextraspeed", 1.1, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY } ) end
if not ConVarExists( "cnr_wardenafk" ) then CreateConVar( "cnr_wardenafk", 20, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY } ) end
if not ConVarExists( "cnr_jailmindist" ) then CreateConVar( "cnr_jailmindist", 1000, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY } ) end
if not ConVarExists( "cnr_jailmaxdist" ) then CreateConVar( "cnr_jailmaxdist", 2000, { FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY } ) end


--[[ TEAM SETUP ]]--

team.SetUp(1, "Cop", Color(255, 0, 0, 255) ) -- Team 1 will be the Cops
team.SetUp(2, "Runner", Color(0, 0, 255, 255) ) -- Team 2 are the free Robbers
team.SetUp(3, "Jailed", Color(0, 0, 255, 255) ) -- Team 3 are the jailed Robbers
-- Team 3 has same color as the Runners

team.SetUp(4, "Armed Runner", Color(0, 0, 255, 255) ) -- The Runner that gets to place a Smoke Spawn
team.SetUp(5, "Warden", Color(255, 0, 0, 255) ) -- The cop that gets to place the Jail
team.SetUp(6, "Unassigned", Color(0, 0, 0, 0) ) -- Unassigned players used when the round restarts

function GM:Initialize()
	self.BaseClass.Initialize( self )
	print( "\n\t游戏模式载入完成\n" )
end

-- New Function for Round Restart
function RoundRestart()
	timer.Destroy("RoundLimit")
	timer.Destroy("ClockRotation")
	timer.Destroy("SmokeSpawnTime")

	rotationArrow = 0
	local allplayers={}
		table.Add(allplayers, player.GetAll())
		for i = 1, table.Count(allplayers) do
			local everyplayer = allplayers[i]
			if SERVER then everyplayer:StripWeapons() end
			everyplayer:SetTeam(6) -- Sets all players to Unassigned team
		end
			-- Randomly sets a Warden and removes him from the table
			local randomply = math.random(1,table.Count(allplayers))
			for k,v in pairs(allplayers) do
				if k == randomply then
					v:SetWarden()
					table.remove(allplayers, k)
				end
			end
			-- Randomly assigns Cops based on percentage from the remaining unassigned and removes them from the table
		if team.NumPlayers(6) > 0 then
			local copcount = 0
			while #player:GetAll() > ((copcount + team.NumPlayers(5)) / GetConVar( "cnr_coppercentage" ):GetFloat()) do
				local randomply = math.random(1,table.Count(allplayers))
				for k,v in pairs(allplayers) do
					if k == randomply then
						v:SetCop()
						table.remove(allplayers, k)
						copcount = copcount + 1
					end
				end
			end
		end
			
			-- Time to set the Armed Runners, if there are still people left
		if team.NumPlayers(6) >= 1 then
			local armedcount = 0
			while armedcount < GetConVar( "cnr_armedrunners" ):GetInt() do
			if team.NumPlayers(6) >= 1 then
				local randomply = math.random(1,table.Count(allplayers))
				for k,v in pairs(allplayers) do
					if k == randomply then
						v:SetArmedRunner()
						table.remove(allplayers, k)
						armedcount = armedcount + 1
					end
				end
			else armedcount = GetConVar( "cnr_armedrunners" ):GetInt()
			end
			end
		end
			
		while team.NumPlayers(6) >= 1 do
			-- We set the remaining players to become regular Runners here
			for i = 1, table.Count(allplayers) do
				local remainingply = allplayers[i]
				remainingply:SetRunner()
			end
		end
		
	-- Empties the table of all unassigned players, ready to be refilled next time
	table.Empty(allplayers)
	game.CleanUpMap()
	if IsValid( jail ) then
		jail:Remove()
	end
	if IsValid( smokespawn ) then
		smokespawn:Remove()
	end
	if IsValid( smokeghost ) then
		smokeghost:Remove()
	end
	postround = false
	
	-- Spawns every player
	for i = 1, #player.GetAll() do
		local everyplayer = player.GetAll()[i]
		everyplayer:Spawn()
		everyplayer:CrosshairEnable()
		everyplayer:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		if everyplayer:HasWeapon("cnr_smokespawn") then
			umsg.Start("smokespawnreset", everyplayer)
			umsg.End()
		else umsg.Start("smokespawnresetfalse", everyplayer)
			umsg.End()
		end

		if everyplayer:HasWeapon("cnr_hands") then
			everyplayer:C_Notify("按 2 切换到撬棍帮助狱友逃脱")
			everyplayer:C_Notify("按 1 切换到空手跑的速度更快")
		end
	end
	umsg.Start("roundrestart", player.GetAll())
	umsg.End()
	-- Makes the game know that the jail doesn't exist after a restart
	
timer.Create("RoundLimit", GetConVar( "cnr_timelimit" ):GetInt() + GetConVar( "cnr_preptime" ):GetInt(), 1, function() 
	--PrintMessage( HUD_PRINTCENTER, "Time's up! The remaining Runners has Escaped!" )
	for i = 1, #player.GetAll() do
		victorians = player.GetAll()[i]
		victorians:SendLua("surface.PlaySound( \"/ambient/alarms/warningbell1.wav\" )")
		if victorians:Team() == 2 or victorians:Team() == 4 then
			victorians:AddFrags( math.Clamp(math.Round(((team.NumPlayers(2) + team.NumPlayers(4)) / ( team.NumPlayers(4) + team.NumPlayers(3) + team.NumPlayers(2) ))*5), 1, 5) )
		end
	end
	umsg.Start("timesup")
	umsg.End()
	timer.Stop("RoundLimit")
	postround = true
	runnerswin = true
	copswin = false
	timer.Simple(GetConVar( "cnr_postroundtime" ):GetInt(), RoundRestart )
end)

postround = false
copswin = false
runnerswin = false
preparing = true
	timer.Simple(GetConVar( "cnr_preptime" ):GetInt(), function()
		preparing = false
		for k,v in pairs(player.GetAll()) do
			v:SendLua("surface.PlaySound( \"/HL1/fvox/bell.wav\" )")
			v:SetCollisionGroup(COLLISION_GROUP_NONE)
		end
	end)
UpdateNewseconds()
rotationArrow = 0
-- Timer for the Clock to count down!
CountDownStart( )
timer.Start("RoundLimit")

C_Broadcast( "新回合开始! 准备阶段将在 "..GetConVar( "cnr_preptime" ):GetInt().." 秒后结束!" )

-- Warden AFK timer kick
timer.Simple(1, function()
	if GetConVar( "cnr_wardenafk" ):GetInt() != 0 then
		timer.Create("WardenAFKTimer", GetConVar( "cnr_wardenafk" ):GetInt(), 1, function()
			RoundRestart()

			C_Broadcast( "上一局监狱长挂机了太久, 回合已重新开始!" )

			hook.Remove("KeyPress", "WardenKeyPressAFKCanceller")
			for k,v in pairs(player.GetAll()) do v:SendLua("surface.PlaySound( \"/ambient/alarms/warningbell1.wav\" )") end
		end)
		hook.Add("KeyPress", "WardenKeyPressAFKCanceller", function(ply, key) if ply:Team() == 5 then timer.Destroy("WardenAFKTimer") hook.Remove("KeyPress", "WardenKeyPressAFKCanceller") end end)
	end
end)

end

-- New collision function
function GM:ShouldCollide( ent1, ent2 )
	
		if ent1:GetModel() == "models/props_sdk/jail.mdl" then
			if ent2:IsPlayer() and ent2:Team() == 3 then return true end
			return false
		end
		
		if ent2:GetModel() == "models/props_sdk/jail.mdl" then
			if ent1:IsPlayer() and ent1:Team() == 3 then return true end
			return false
		end
	
	return true
end 

postround = true

function Victory()
if (team.NumPlayers(2) == 0 and team.NumPlayers(4) == 0) and #player.GetAll() > 1 and postround == false then
	--PrintMessage( HUD_PRINTCENTER, "All runners were jailed! The Cops win the round!" )
	postround = true
	copswin = true
	runnerswin = false
	UpdateNewseconds()
	timer.Stop("RoundLimit")
	timer.Stop("Countdown")
	for i = 1, #player.GetAll() do
		victorians = player.GetAll()[i]
		victorians:SendLua("surface.PlaySound( \"/ambient/alarms/warningbell1.wav\" )")
		if victorians:Team() == 1 or victorians:Team() == 5 then
			if SERVER then victorians:AddFrags(5) end
		end
	end
	if SERVER then
		umsg.Start("alljailed")
		umsg.End()
	end
	timer.Simple(GetConVar( "cnr_postroundtime" ):GetInt(), RoundRestart )
end

if team.NumPlayers(5) == 0 and #player.GetAll() > 1 and postround == false then
	--PrintMessage( HUD_PRINTCENTER, "The Warden has rage quit! The Runners escape!" )
	postround = true
	runnerswin = true
	copswin = false
	UpdateNewseconds()
	timer.Stop("RoundLimit")
	timer.Stop("Countdown")
	for i = 1, #player.GetAll() do
		victorians = player.GetAll()[i]
		victorians:SendLua("surface.PlaySound( \"/ambient/alarms/warningbell1.wav\" )")
		if victorians:Team() == 2 or victorians:Team() == 4 then
			if SERVER then victorians:AddFrags(1) end
		end
	end
	if SERVER then umsg.Start("ragequit")
	umsg.End() end
	timer.Simple(GetConVar( "cnr_postroundtime" ):GetInt(), RoundRestart )
end
	
end
hook.Add("Captured", "captureWin", Victory)

function Quit(ent)
	if IsValid( ent ) and ent:IsPlayer() then
		Victory()
		if SERVER then
		if timer.Exists("ThrowPower"..ent:UserID()) then
			timer.Destroy("ThrowPower"..ent:UserID())
		end
		if IsValid( bBalls[ent:UserID()] ) and (bBalls[ply:UserID()]:GetClass() == "sent_cnrball" or bBalls[ply:UserID()]:GetClass() == "sent_cnrball_pixel") then 
			bBalls[ent:UserID()]:Remove()
			table.remove( bBalls, ent:UserID() )
		end
		if table.HasValue(inCNRgroup, ent:SteamID()) then table.remove( inCNRgroup, table.KeyFromValue( inCNRgroup, ent:SteamID() ) ) end
		end
	end
end
hook.Add("EntityRemoved", "quit", Quit)

function playerDisconnected(ply)
	--if SERVER then
		if timer.Exists("ThrowPower"..ply:UserID()) then
			timer.Destroy("ThrowPower"..ply:UserID())
		end
		if IsValid( bBalls[ply:UserID()] ) and (bBalls[ply:UserID()]:GetClass() == "sent_cnrball" or bBalls[ply:UserID()]:GetClass() == "sent_cnrball_pixel") then 
			bBalls[ply:UserID()]:Remove()
			table.remove( bBalls, ply:UserID() )
		end
	--end
end
hook.Add( "PlayerDisconnected", "playerdisconnected", playerDisconnected)

function GM:Think()
	if SERVER and #player.GetAll() > 1 and !postround and !frozen then
		SetGlobalInt("TimeLeft",math.Round(timer.TimeLeft("RoundLimit")))
		SetGlobalInt("TimeLimit",math.Round(cvars.Number("cnr_timelimit")))
	end
end