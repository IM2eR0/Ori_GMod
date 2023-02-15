hook.Add("Lava.PostPlayerSpawn", "CASPER", function(Player)
	if Player:HasAbility("灵魂") then
		Player:SetRunSpeed(Player:GetRunSpeed() * 1.3)
		Player:SetWalkSpeed(Player:GetWalkSpeed() * 1.3)
		Player:SetAvoidPlayers(false)
	end

	Player:CollisionRulesChanged()
end)

hook.Add("ShouldCollide", "DisableCasperCollisions", function(A, B)
	if A:IsPlayer() and B:IsPlayer() and (A:HasAbility("Casper") or B:HasAbility("Casper")) then return false end
end)

hook.Add("SetupMove", "CASPER", function(Player, Movedata, Command)
	if Player:HasAbility("灵魂") then
		Player:UpdateAbilityMeter()
		if not Player:Alive() then return end

		if Command:KeyDown(IN_RELOAD) and Player:CanUseAbility() and Movedata:GetVelocity().z > -25 and not Player:OnGround() then
			Player:SetGroundEntity(Entity(0))
			Movedata:RemoveKey(2)
			Movedata:RemoveKey(4)
			Command:RemoveKey(2)
			Command:RemoveKey(4)
			Player:SetAbilityInUse( true )
			Player:ShiftAbilityMeter(-FrameTime() * 15)
		else
			Player:SetAbilityInUse( false )
			Player:ShiftAbilityMeter( FrameTime() * 15 )
		end
	end
end)

local White = color_white
local m_Meter

hook.Add("HUDPaint", "CasperMeter", function()
	m_Meter = LocalPlayer():GetAbilityMeter()
	if m_Meter == 100 or not LocalPlayer():HasAbility("灵魂") or not LocalPlayer():Alive() then return end
	draw.WebImage(Emoji.Get("1f47b"), ScrW() / 2, ScrH() - ScrH() / 10, ScrH() / 7, ScrH() / 7, pColor():Alpha(100), 0)
	draw.WebImage(Emoji.Get("1f47b"), ScrW() / 2, ScrH() - ScrH() / 10, m_Meter / 100 * ScrH() / 7, m_Meter / 100 * ScrH() / 7, White:Alpha(LocalPlayer():HasUsedUpAbility() and 100 or 255), 0)
end)

local GhostMat = Material("models/shiny")

hook.Add("PlayerRender", "CASPERMAT", function(Player)
	if Player:HasAbility("灵魂") and Player:IsAbilityInUse() and not Player:OnGround() then
		render.MaterialOverride(GhostMat)
		Player:DrawModel()
		render.MaterialOverride()

		return true
	end
end)

hook.Add("CalcMainActivity", "CASPERANIM", function(Player)
	if Player:HasAbility("灵魂") and not Player:OnGround() and Player:IsAbilityInUse() then return ACT_HL2MP_SWIM, -1 end
end)

Abilities.Register("灵魂", [[你不会与其他玩家发生碰撞，并且移动速度比其他人稍快。 在路径狭窄的地图上非常有用。 您也可以按住 R 在地面上悬停一段有限的时间。 ]], "1f47b", function(Player)
	Player:CollisionRulesChanged()
	Player:SetRunSpeed(225 * 1.3)
	Player:SetWalkSpeed(175 * 1.3)
end, function(Player)
	Player:CollisionRulesChanged()
	Player:SetRunSpeed(225)
	Player:SetWalkSpeed(175)
end)