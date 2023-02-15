Msg("cl_hud.lua loads!")

CreateClientConVar( "cnr_hints", 1, true, false)

surface.CreateFont("NotEP", {
	font = "Tahoma",
	size = 50,
	weight = 600
})

surface.CreateFont("A", {
	font = "Tahoma",
	size = 18,
	weight = 600
})

surface.CreateFont("RoundEnd", {
	font = "CloseCaption_Bold",
	size = 60,
	weight = 600
})

surface.CreateFont("HEALTH", {
	font = "CloseCaption_Bold",
	size = 40,
	weight = 600
})

surface.CreateFont("PlaceJail", {
	font = "CloseCaption_Bold",
	size = 28,
	weight = 600
})

surface.CreateFont("HudInfo", {
	font = "Tahoma",
	size = 25,
	weight = 600
})

surface.CreateFont("HudInfo2", {
	font = "Tahoma",
	size = 40,
	weight = 600
})

surface.CreateFont("JOB", {
	font = "Tahoma",
	size = 60,
	weight = 600
})

-- Let's start by hiding the default HUD
function hidehud(name)
	for k, v in pairs({"CHudHealth", "CHudBattery"})do
		if name == v then return false end
	end
end
-- , "CHudWeaponSelection"
hook.Add("HUDShouldDraw", "HideTheHud", hidehud)

function GetSERVER()
	local TimeLeft = GetGlobalInt("TimeLeft")
end
hook.Add("Think","GetSERVER",GetSERVER)

local hints = {
"狱警的移速要高于逃跑者!",
"狱警玩家远离监狱会获得电棍攻速提升",
"被抓住后让队友将你的生命值敲为0来获得自由!",
"烟雾弹刷新点每隔 "..GetConVar( "cnr_smokedelay" ):GetFloat().." 秒创建一颗烟雾弹!",
"输入该指令来关闭提示 \"cnr_hints 0\"",
"被抓住后可以点击左键发射弹力球!",
"弹力球只有被抓住的玩家和狱警可见!",
"按住左键来给弹力球蓄力",
"弹力球最大蓄力值为 1000%",
"准备阶段时所有玩家无碰撞",
"监狱无法在准备阶段放置",
"若出现BUG, 请及时反馈给管理员",
"玩家不会受到跌落伤害, 除非伤害大于75",
"当玩家死亡时, 会重生在监狱里(如果有的话)",
"空手状态时移动速度最快!",
"救出队友来获得分数!",
"作者:Zet0rz, 文本汉化:YurIsLuv，贴图被初雪干掉了",
"善用烟雾弹躲避狱警追捕!",
"爆炸物可以同时杀死多个玩家!",
"若玩家对你造成75或更高伤害, 则会被秒杀",
"使用爆炸物或陷阱来对玩家造成秒杀伤害 (伤害≥75)",
"利用爆炸油桶来伤害周围的玩家!",
"加入茶会官方STEAM组来解锁 <<< 像素弹力球 >>> 皮肤",
"欢迎加入QQ群: 1149179462",
"精神病权限组可以享受彩虹烟雾弹",
}

-- Now we draw the custom HUD
local smokeState = 25
local handsState = 25
local jailState = 25
local stunState = 255 -- You spawn with the Stunstick out as a Cop or Warden
local crowState = 255 -- You spawn with the Crowbar out as a Runner or Armed Runner
local hasjail = true
local hassmokespawn = true
local hassmoke = false
_angle = 0
_freezeangle = 0
if CLIENT then postround = false end

local alljailed = false
local timesup = false
local ragequit = false

local wepcool = true
timer.Create("Wepswitch", 0.2, 0, function() wepcool = true timer.Stop("Wepswitch") end)
local hint_cool = true

surface.CreateFont( "CnRJailedHealth", {
	font = "Arial",
	size = 1003,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = false,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )



Arrowrotation = 0
devtags = { }
betatags = { }
goldbetatags = { }

function getClockRotation( um )
	Arrowrotation = um:ReadFloat()
end
usermessage.Hook("ClockRotation", getClockRotation)


--[[

]]--

function getHasJail( um )
	if um:ReadBool() == false then
		hasjail = false
	end
end
usermessage.Hook("hasjail", getHasJail)

function getHasSmokeSpawn( um )
	if um:ReadBool() == false then
		hassmokespawn = false
	end
	--print("it was recieved")
end
usermessage.Hook("hassmokespawn", getHasSmokeSpawn)

function getHasSmoke( um )
	if um:ReadBool() == true then
		hassmoke = true
	elseif um:ReadBool() == false then
		hassmoke = false
	end
	--print("it was recieved")
end
usermessage.Hook("hassmoke", getHasSmoke)

function getRoundRestarted( um )
		hasjail = true
		hassmoke = false
		Arrowrotation = 0
		postround = false
		frozen = false
		alljailed = false
		timesup = false
		ragequit = false
	end
usermessage.Hook("roundrestart", getRoundRestarted)

function getRageQuit( um )
	ragequit = true
	postround = true
	--print("Player has recieved that the Warden left")
end
usermessage.Hook("ragequit", getRageQuit)

function getSmokeSpawnReset( um )
	hassmokespawn = true
	--print("player has smokespawn recieved")
end
usermessage.Hook("smokespawnreset", getSmokeSpawnReset)

function getSmokeSpawnResetFalse( um )
	hassmokespawn = false
	--print("player has no smokespawn recieved")
end
usermessage.Hook("smokespawnresetfalse", getSmokeSpawnResetFalse)


function getAllJailed( um )
	alljailed = true
	postround = true
	--print("Player has recieved that all runners were jailed!")
end
usermessage.Hook("alljailed", getAllJailed)

function getTimesUp( um )
	timesup = true
	postround = true
	--print("Player has recieved that the time is up!")
end
usermessage.Hook("timesup", getTimesUp)


-- Dev tag awarded to the creator of the Gamemode
function getDevTags( um )
	local devply = um:ReadEntity() 
	table.insert(devtags, devply)
	print(devply)
end
usermessage.Hook("devtag", getDevTags)

function getDevTagsRemove( um )
	local devply = um:ReadEntity() 
	table.remove(devtags, 1)
	print(devply:Nick().." removed from table")
end
usermessage.Hook("devtagremove", getDevTagsRemove)

-- Beta tags awarded to friends who helped me test, as well as random players who helped along the way
function getBetaTags( um )
	local betaply = um:ReadEntity() 
	table.insert(betatags, betaply)
	print(betaply)
end
usermessage.Hook("betatag", getBetaTags)

function getBetaTagsRemove( um )
	local betaply = um:ReadEntity()
	for k,v in pairs(betatags) do
		if v:UniqueID() == betaply:UniqueID() then
			table.remove(betatags, k)
		end
	end
	print(betaply:Nick().." removed from table")
end
usermessage.Hook("betatagremove", getBetaTagsRemove)


-- Golden Beta tags awarded to the loyal friends who went into the game only to help, or friends and strangers who found bugs and helped greatly!
function getGoldBetaTags( um )
	local goldbetaply = um:ReadEntity() 
	table.insert(goldbetatags, goldbetaply)
	print(goldbetaply)
end
usermessage.Hook("goldbetatag", getGoldBetaTags)

function getGoldBetaTagsRemove( um )
	local goldbetaply = um:ReadEntity()
	for k,v in pairs(goldbetatags) do
		if v:UniqueID() == goldbetaply:UniqueID() then
			table.remove(goldbetatags, k)
		end
	end
	print(goldbetaply:Nick().." removed from table")
end
usermessage.Hook("goldbetatagremove", getGoldBetaTagsRemove)

local RBC = Color(255,255,255,0)

-- Starting with the Cops
function PaintHud()

	if #player.GetAll() < 2 then
		draw.SimpleTextOutlined( "人数不足，请耐心等待玩家", "NotEP", (ScrW() / 2) ,( ScrH() - 20) , Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
		return
	end

	local ply = LocalPlayer()
	local weapon = LocalPlayer():GetActiveWeapon()
	local nowep = weapon.PrintName
	if weapon and IsValid(weapon) then
		nowep = nowep or "撬棍"
	end

	draw.SimpleTextOutlined(nowep, "NotEP", (ScrW() - 20 ) ,( ScrH() - 20 ) , Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))

	-- draw.RoundedBoxEx(0, 10, ScrH() - 70 , 120, 60, RBC, true, true, true, true )

	if LocalPlayer():Team() == 2 then
		WHO = "逃犯"
		RBC = Color(0,255,255)
	end

	if LocalPlayer():Team() == 3 then
		WHO = "囚犯"
		RBC = Color(155,155,155)
		
		draw.SimpleTextOutlined( LocalPlayer():Health().."%", "HEALTH", (ScrW() / 2) ,( ScrH() - 20) , Color(0,100,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
		
			if GetConVar("cnr_hints"):GetInt() == 1 then
				if hint_cool then
					timer.Simple(math.random(3,10), function() 
						local randomhint = math.random(1, table.Count(hints))
						notification.AddLegacy(hints[randomhint], NOTIFY_GENERIC, 8)
						surface.PlaySound( "ambient/water/drip"..math.random(1, 4)..".wav" )
					end)
					timer.Simple(math.random(40,60), function()
							hint_cool = true
						end)
					hint_cool = false
				end
			end
	end

	if LocalPlayer():Team() == 4 then
		WHO = "烟雾弹"
		RBC = Color(0,229,255)

		if LocalPlayer():HasWeapon("cnr_smokespawn") then
			draw.SimpleTextOutlined( "你有烟雾弹生成器, 按 3 右键放置", "HEALTH", (ScrW() /2 ) ,( ScrH() - 70 ) , Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
		end
	end

	if LocalPlayer():Team() == 5 then
		WHO = "监狱长"
		RBC = Color(255,0,0)

		if LocalPlayer():HasWeapon("cnr_jail") then
			draw.SimpleTextOutlined( "你是狱长，按下 2 右键放置监狱", "HEALTH", (ScrW() /2 ) ,( ScrH() - 70 ) , Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
		end

		draw.SimpleTextOutlined( "剩余逃犯：".. (#team.GetPlayers(2) + #team.GetPlayers(4)), "HEALTH", (ScrW() / 2) ,( ScrH() - 20) , Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))

	end

	if LocalPlayer():Team() == 1 then
		WHO = "狱警"
		RBC = Color(255,0,0)

		draw.SimpleTextOutlined( "剩余逃犯：".. (#team.GetPlayers(2) + #team.GetPlayers(4)), "HEALTH", (ScrW() / 2) ,( ScrH() - 20) , Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
	end

	draw.SimpleTextOutlined(WHO, "JOB", 20 , ScrH() - 20, RBC, TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM, 2,Color(0,0,0) )

	local ltime = GetGlobalInt("TimeLeft") or "nil"
	local lctime = GetGlobalInt("TimeLimit")

	if timesup or alljailed or ragequit then
		draw.SimpleTextOutlined("回合结束！ ", "HudInfo2", 20 , ScrH() - 80,Color( 255, 255, 255), TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM, 2,Color(0,0,0))
	elseif ltime > lctime then
		draw.SimpleTextOutlined("准备时间: ".. (ltime-lctime) .."秒", "HudInfo2", 20 , ScrH() - 80,Color( 255, 255, 255), TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM, 2,Color(0,0,0))
	elseif ltime <= lctime then
		draw.SimpleTextOutlined("剩余时间: "..ltime.."秒", "HudInfo2", 20 , ScrH() - 80,Color( 255, 255, 255), TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM, 2,Color(0,0,0))
	else
		draw.SimpleTextOutlined("时间变量错误！", "HudInfo2", 20 , ScrH() - 80,Color( 100, 0, 0), TEXT_ALIGN_LEFT,TEXT_ALIGN_BOTTOM, 2,Color(0,0,0))
	end
	
	if alljailed == true then
		draw.SimpleTextOutlined( "所有玩家均被抓捕，回合结束！", "RoundEnd", (ScrW() / 2) ,( ScrH() / 2) , Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
	end
	
	if timesup == true then
		draw.SimpleTextOutlined( "回合时间到！逃犯胜利！", "RoundEnd", (ScrW() / 2) ,( ScrH() / 2) , Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
	end
	
	if ragequit == true then 
		draw.SimpleTextOutlined( "监狱长退出了游戏，回合结束！", "RoundEnd", (ScrW() / 2) ,( ScrH() / 2) , Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
	end



-- Time to draw the icons over jail and smokespawns
if LocalPlayer():Team() == 5 or LocalPlayer():Team() == 1 then
	jailpoint = ents.FindByClass("sent_jail")
	if table.Count(jailpoint) > 0 then
		for i = 1, table.Count(jailpoint) do
			jailpointpos = (jailpoint[i]:GetPos() + Vector(0,0,25) ):ToScreen()
			draw.SimpleTextOutlined("监狱","HudInfo",jailpointpos.x - 25, jailpointpos.y - 50,Color(255,0,0,255),TEXT_ALIGN_TOP,TEXT_ALIGN_BOTTOM,2,Color(0,0,0))
		end
	end
elseif LocalPlayer():Team() == 2 or LocalPlayer():Team() == 4 then
	smokepoint = ents.FindByClass("sent_smokespawn")
	if table.Count(smokepoint) > 0 then
		for i = 1, table.Count(smokepoint) do
			smokepointpos = (smokepoint[i]:GetPos() + Vector(0,0,25)):ToScreen()
			draw.SimpleTextOutlined("烟雾弹","HudInfo",smokepointpos.x - 25, smokepointpos.y - 50,Color(0,255,255,255),TEXT_ALIGN_TOP,TEXT_ALIGN_BOTTOM,2,Color(0,0,0))
		end
	end
end

for i = 1, table.Count(devtags) do
	local devply = devtags[i]	
	if ((devply:Team() == 1 or devply:Team() == 5) and (LocalPlayer():Team() == 1 or LocalPlayer():Team() == 5))
	or ((devply:Team() == 2 or devply:Team() == 4) and (LocalPlayer():Team() == 2 or LocalPlayer():Team() == 4)) then
		devtagpos = (devply:GetPos() + Vector(0,0,75)):ToScreen()
		surface.SetMaterial( Material("copsandrunners/devgold.png") )
		surface.SetDrawColor(255, 255, 255, 100)
		surface.DrawTexturedRect(devtagpos.x - 25, devtagpos.y - 50, 50, 50)
	end
end

for i = 1, table.Count(betatags) do
	local betaply = betatags[i]	
	if ((betaply:Team() == 1 or betaply:Team() == 5) and (LocalPlayer():Team() == 1 or LocalPlayer():Team() == 5))
	or ((betaply:Team() == 2 or betaply:Team() == 4) and (LocalPlayer():Team() == 2 or LocalPlayer():Team() == 4)) then
		betatagpos = (betaply:GetPos() + Vector(0,0,75)):ToScreen()
		surface.SetMaterial( Material("copsandrunners/beta.png") )
		surface.SetDrawColor(255, 255, 255, 100)
		surface.DrawTexturedRect(betatagpos.x - 25, betatagpos.y - 50, 50, 50)
	end
end

for i = 1, table.Count(goldbetatags) do
	local goldbetaply = goldbetatags[i]	
	if ((goldbetaply:Team() == 1 or goldbetaply:Team() == 5) and (LocalPlayer():Team() == 1 or LocalPlayer():Team() == 5))
	or ((goldbetaply:Team() == 2 or goldbetaply:Team() == 4) and (LocalPlayer():Team() == 2 or LocalPlayer():Team() == 4)) then
		goldbetatagpos = (goldbetaply:GetPos() + Vector(0,0,75)):ToScreen()
		surface.SetMaterial( Material("copsandrunners/betagold.png") )
		surface.SetDrawColor(255, 255, 255, 100)
		surface.DrawTexturedRect(goldbetatagpos.x - 25, goldbetatagpos.y - 50, 50, 50)
	end --[[end

	if LocalPlayer():Alive() then
		if (LocalPlayer():Team() == 1 or LocalPlayer():Team() == 2 or LocalPlayer():Team() == 3 or LocalPlayer():Team() == 4 or LocalPlayer():Team() == 5) then 
		--print("huh...")
		if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_crowbar" then 
			crowState = 255
			handsState = 25
			smokeState = 25
			grenadeState = 25
		end
		if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_hands" then 
			crowState = 25
			handsState = 255
			smokeState = 25
			grenadeState = 25
		end
		
		if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_smokespawn" then 
			crowState = 25
			handsState = 25
			smokeState = 255
			grenadeState = 25
		end
		
		if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_smokegrenade" then 
			crowState = 25
			handsState = 25
			smokeState = 25
			grenadeState = 255
		end
		
		if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_stunstick" then 
			stunState = 255
			if hasjail == true then
				jailState = 25
			end
		end
		if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_jail" then 
			jailState = 255
			stunState = 25
		end
		end
		
		--print("CrowState: "..crowState..", handsState: "..handsState..", smokeState: "..smokeState..", stunState: "..stunState..", jailState: "..jailState)
		--print("Arrowrotation is right now "..Arrowrotation..". rotationArrow is "..rotationArrow)
		
		
		-- Time to set the Weapon selection HUD
		if LocalPlayer():Team() == 2 or LocalPlayer():Team() == 4 then
			surface.SetMaterial( Material("copsandrunners/hands.png") )
			surface.SetDrawColor(handsState, handsState, handsState, 255)
			surface.DrawTexturedRect( ((ScrW() - (ScrW() / 4))+20), ScrH() - 120, 100, 100)
			surface.SetMaterial( Material("copsandrunners/crowbar.png") )
			surface.SetDrawColor(crowState, crowState, crowState, 255)
			surface.DrawTexturedRect( ((ScrW() - (ScrW() / 4))-90), ScrH() - 115, 100, 100)
					if hassmoke == true then
						if hassmokespawn == true then
							surface.SetMaterial( Material("copsandrunners/smoke.png") )
							surface.SetDrawColor(grenadeState, grenadeState, grenadeState, 255)
							surface.DrawTexturedRect( ((ScrW() - (ScrW() / 4))- 310), ScrH() - 120, 100, 100)
						else
							surface.SetMaterial( Material("copsandrunners/smoke.png") )
							surface.SetDrawColor(grenadeState, grenadeState, grenadeState, 255)
							surface.DrawTexturedRect( ((ScrW() - (ScrW() / 4))- 200), ScrH() - 120, 100, 100)
						end
					end
		end
		
		if LocalPlayer():Team() == 4 and hassmokespawn == true then
			surface.SetMaterial( Material("copsandrunners/smokespawn.png") )
			surface.SetDrawColor(smokeState, smokeState, smokeState, 255)
			surface.DrawTexturedRect( ((ScrW() - (ScrW() / 4))-200), ScrH() - 120, 100, 100)
		end
		
		if LocalPlayer():Team() == 5 or LocalPlayer():Team() == 1 then
			surface.SetMaterial( Material("copsandrunners/stunstick.png") )
			surface.SetDrawColor(stunState, stunState, stunState, 255)
			surface.DrawTexturedRect( ((ScrW() - (ScrW() / 4))+20), ScrH() - 120, 100, 100)
		end
		
		if LocalPlayer():Team() == 5 and hasjail == true then
			surface.SetMaterial( Material("copsandrunners/jail.png") )
			surface.SetDrawColor(jailState, jailState, jailState, 255)
			surface.DrawTexturedRect( ((ScrW() - (ScrW() / 4))-90), ScrH() - 125, 100, 100)
		end
		
		if LocalPlayer():Team() == 3 then
			surface.SetMaterial( Material("copsandrunners/jailedhands.png") )
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect( ((ScrW() - (ScrW() / 4))+20), ScrH() - 120, 100, 100)
		end
]]
if wepcool == true then
-- We start with Key 1 (Above Q)
if input.IsKeyDown(KEY_1) then
	-- The Warden. Key 1 will always be the Jailplacer, or nothing if he doesn't have that.
	if LocalPlayer():Team() == 5 then
		if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_jail" then
			RunConsoleCommand("use", "cnr_jail")
			wepcool = false
			timer.Start("Wepswitch")
			LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
		end
	end
	-- Runners Team. Key 1's weapon depends on what weapons you have.
	if LocalPlayer():Team() == 2 then
		if hassmoke == true then
			if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_smokegrenade" then
				RunConsoleCommand("use", "cnr_smokegrenade")
				wepcool = false
				timer.Start("Wepswitch")
				LocalPlayer():EmitSound("weapons/draw_pistol_engineer.wav", 40, 100)
			end
		elseif hassmoke == false then
			if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "weapon_crowbar" then
				RunConsoleCommand("use", "weapon_crowbar")
				wepcool = false
				timer.Start("Wepswitch")
				LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
			end
		end
	end
	-- Team 4, the Armed Runners. Jailed players only have 1 weapon, so they can never switch, so we skip them
	if LocalPlayer():Team() == 4 then
		if hassmoke == true then -- The Smoke grenade always gets slot 1, no matter what you otherwise have.
			if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_smokegrenade" then
				RunConsoleCommand("use", "cnr_smokegrenade")
				wepcool = false
				timer.Start("Wepswitch")
				LocalPlayer():EmitSound("weapons/draw_pistol_engineer.wav", 40, 100)
			end
		elseif hassmoke == false then
			if hassmokespawn == true then 			-- If you have the Smoke Spawn, but no Smoke, Smoke Spawn is the outermost weapon, slot 1.
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_smokespawn" then
					RunConsoleCommand("use", "cnr_smokespawn")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_machete_sniper.wav", 40, 100)
				end
			elseif hassmokespawn == false then 				-- However if you have neither Smoke Spawn OR a Smoke, the Crowbar is number 1.
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "weapon_crowbar" then
					RunConsoleCommand("use", "weapon_crowbar")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
				end
			end
		end
	end
end	-- END OF KEY_1			
-- The cops only have 1 weapon like the Jailed players, so they can't switch

-- We're now at Key 2 (Above Q and W)
if input.IsKeyDown(KEY_2) then
	if LocalPlayer():Team() == 5 then
		if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_stunstick" then 
			RunConsoleCommand("use", "cnr_stunstick")
			wepcool = false
			timer.Start("Wepswitch")
			LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
		end
	end
	-- Time to go to the Runners
	if LocalPlayer():Team() == 2 then
		if hassmoke == true then -- If you DO have a smoke, the Crowbar is number 2.
			if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "weapon_crowbar" then
				RunConsoleCommand("use", "weapon_crowbar")
				wepcool = false
				timer.Start("Wepswitch")
				LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
			end
		elseif hassmoke == false then -- If you have no smoke, the Hands is in slot 2.
			if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_hands" then
				RunConsoleCommand("use", "cnr_hands")
				wepcool = false
				timer.Start("Wepswitch")
				LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
			end
		end
	end
	if LocalPlayer():Team() == 4 then
		if hassmoke == true then
			if hassmokespawn == true then
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_smokespawn" then
					RunConsoleCommand("use", "cnr_smokespawn")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_machete_sniper.wav", 40, 100)
				end
			elseif hassmokespawn == false then
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "weapon_crowbar" then
					RunConsoleCommand("use", "weapon_crowbar")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
				end
			end
		elseif hassmoke == false then
			if hassmokespawn == true then
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "weapon_crowbar" then
					RunConsoleCommand("use", "weapon_crowbar")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
				end
			elseif hassmokespawn == false then
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_hands" then
					RunConsoleCommand("use", "cnr_hands")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
				end
			end
		end
	end
end -- End of KEY_2

-- Time to go to Key 3. Key 3 will always be a shortcut to the Hands or the Stunstick if Key 3 isn't occupied
if input.IsKeyDown(KEY_3) then
	if LocalPlayer():Team() == 5 then
		if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_stunstick" then 
			RunConsoleCommand("use", "cnr_stunstick")
			wepcool = false
			timer.Start("Wepswitch")
			LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
		end
	end
	-- The Runners. Key 3 will always be the Hands, whether the hands actually WERE slot 3, or earlier.
	if LocalPlayer():Team() == 2 then
		if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_hands" then
			RunConsoleCommand("use", "cnr_hands")
			wepcool = false
			timer.Start("Wepswitch")
			LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
		end
	end
	-- However the Armed Runners can have 4 weapons, thus Key 3 can be different things.
	if LocalPlayer():Team() == 4 then
		if hassmoke == true and hassmokespawn == true then
			if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "weapon_crowbar" then
				RunConsoleCommand("use", "weapon_crowbar")
				wepcool = false
				timer.Start("Wepswitch")
				LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
			end
		elseif hassmoke == false or hassmokespawn == false then -- No matter which one, if one of them is false, Key 3 is always the Hands.
			if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_hands" then
				RunConsoleCommand("use", "cnr_hands")
				wepcool = false
				timer.Start("Wepswitch")
				LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
			end
		end
	end
end -- END OF KEY 3

-- Going to Key 4. This key is ALWAYS a shortcut to the Hands and the Stunstick.
if input.IsKeyDown(KEY_4) then
	if LocalPlayer():Team() == 5 then
		if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_stunstick" then 
			RunConsoleCommand("use", "cnr_stunstick")
			wepcool = false
			timer.Start("Wepswitch")
			LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
		end
	end
	if LocalPlayer():Team() == 2 or LocalPlayer():Team() == 4 then
		if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_hands" then
			RunConsoleCommand("use", "cnr_hands")
			wepcool = false
			timer.Start("Wepswitch")
			LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
		end
	end
end -- END OF KEY 4

end -- Ending the IF WEPCOOL == TRUE right here


end -- End of the LocalPlayer():Alive() checker
--print("The HUD was updated")
--print(hassmokespawn)

end
hook.Add( "HUDPaint", "PaintTheHud", PaintHud )

function GM:PlayerBindPress(player, bind, pressed)
	--if wepcool == true then
	-- Let's start with 'invnext'
		if bind == "invnext" then
			if LocalPlayer():Team() == 5 then -- Wardens
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_stunstick" then 
					RunConsoleCommand("use", "cnr_stunstick")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
				end
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_jail" then
					RunConsoleCommand("use", "cnr_jail")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
				end
			end
			if LocalPlayer():Team() == 2 then -- Runners
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_smokegrenade" then
					RunConsoleCommand("use", "weapon_crowbar")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
				elseif LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_crowbar" then
					RunConsoleCommand("use", "cnr_hands")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
				elseif LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_hands" then
					if hassmoke == true then
						RunConsoleCommand("use", "cnr_smokegrenade")
						wepcool = false
						timer.Start("Wepswitch")
						LocalPlayer():EmitSound("weapons/draw_pistol_engineer.wav", 40, 100)
					elseif hassmoke == false then
						RunConsoleCommand("use", "weapon_crowbar")
						wepcool = false
						timer.Start("Wepswitch")
						LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
					end
				end
			end
			if LocalPlayer():Team() == 4 then -- Armed Runners
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_smokegrenade" then
					if hassmokespawn == true then
						RunConsoleCommand("use", "cnr_smokespawn")
						wepcool = false
						timer.Start("Wepswitch")
						LocalPlayer():EmitSound("weapons/draw_machete_sniper.wav", 40, 100)
					elseif hassmokespawn == false then
						RunConsoleCommand("use", "weapon_crowbar")
						wepcool = false
						timer.Start("Wepswitch")
						LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
					end
				elseif LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_smokespawn" then
					RunConsoleCommand("use", "weapon_crowbar")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
				elseif LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_crowbar" then
					RunConsoleCommand("use", "cnr_hands")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
				elseif LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_hands" then
					if hassmoke == true then
						RunConsoleCommand("use", "cnr_smokegrenade")
						wepcool = false
						timer.Start("Wepswitch")
						LocalPlayer():EmitSound("weapons/draw_pistol_engineer.wav", 40, 100)
					elseif hassmoke == false then
						if hassmokespawn == true then
							RunConsoleCommand("use", "cnr_smokespawn")
							wepcool = false
							timer.Start("Wepswitch")
							LocalPlayer():EmitSound("weapons/draw_machete_sniper.wav", 40, 100)
						elseif hassmokespawn == false then
							RunConsoleCommand("use", "weapon_crowbar")
							wepcool = false
							timer.Start("Wepswitch")
							LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
						end
					end
				end
			end
		end
		if bind == "invprev" then
			if LocalPlayer():Team() == 5 then -- Wardens
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_stunstick" then 
					RunConsoleCommand("use", "cnr_stunstick")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
				end
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() != "cnr_jail" then
					RunConsoleCommand("use", "cnr_jail")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
				end
			end
			if LocalPlayer():Team() == 2 then -- Runners
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_smokegrenade" then
					RunConsoleCommand("use", "cnr_hands")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
				elseif LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_hands" then
					RunConsoleCommand("use", "weapon_crowbar")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
				elseif LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_crowbar" then
					if hassmoke == true then
						RunConsoleCommand("use", "cnr_smokegrenade")
						wepcool = false
						timer.Start("Wepswitch")
						LocalPlayer():EmitSound("weapons/draw_pistol_engineer.wav", 40, 100)
					elseif hassmoke == false then
						RunConsoleCommand("use", "cnr_hands")
						wepcool = false
						timer.Start("Wepswitch")
						LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
					end
				end
			end
			if LocalPlayer():Team() == 4 then -- Armed Runners
				if LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_smokespawn" then
					if hassmoke == true then
						RunConsoleCommand("use", "cnr_smokegrenade")
						wepcool = false
						timer.Start("Wepswitch")
						LocalPlayer():EmitSound("weapons/draw_pistol_engineer.wav", 40, 100)
					elseif hassmoke == false then
						RunConsoleCommand("use", "cnr_hands")
						wepcool = false
						timer.Start("Wepswitch")
						LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
					end
				elseif LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_smokegrenade" then
					RunConsoleCommand("use", "cnr_hands")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
				elseif LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "cnr_hands" then
					RunConsoleCommand("use", "weapon_crowbar")
					wepcool = false
					timer.Start("Wepswitch")
					LocalPlayer():EmitSound("weapons/draw_default.wav", 40, 100)
				elseif LocalPlayer():GetActiveWeapon():IsValid() and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_crowbar" then
					if hassmokespawn == true then
						RunConsoleCommand("use", "cnr_smokespawn")
						wepcool = false
						timer.Start("Wepswitch")
						LocalPlayer():EmitSound("weapons/draw_machete_sniper.wav", 40, 100)
					elseif hassmokespawn == false then
						if hassmoke == true then
							RunConsoleCommand("use", "cnr_smokegrenade")
							wepcool = false
							timer.Start("Wepswitch")
							LocalPlayer():EmitSound("weapons/draw_pistol_engineer.wav", 40, 100)
						elseif hassmoke == false then
							RunConsoleCommand("use", "cnr_hands")
							wepcool = false
							timer.Start("Wepswitch")
							LocalPlayer():EmitSound("weapons/draw_melee.wav", 40, 100)
						end
					end
				end
			end
		end
	end
--end