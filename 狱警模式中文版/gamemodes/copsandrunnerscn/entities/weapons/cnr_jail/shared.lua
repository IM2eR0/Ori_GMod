if SERVER then

	AddCSLuaFile( "shared.lua" )

	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
else

	SWEP.PrintName			= "监狱放置点"
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true

	SWEP.ViewModelFOV		= 60

	function SWEP:DrawWeaponSelection( x, y, w, h, alpha )
		-- draw.DrawText("Hands","Default",x + w * 0.44,y + h * 0.20,Color(0,50,200,alpha),1)
	end

	function SWEP:DrawHUD()
	end

end

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.HoldType = "normal"

SWEP.ViewModel	= "models/weapons/v_slam.mdl"
SWEP.WorldModel	= "models/weapons/w_slam.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"


function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self.CurHoldType = self.HoldType
	self:DrawShadow(false)
end



function SWEP:SecondaryAttack()
	if SERVER then
		if preparing then self.Owner:SendLua("notification.AddLegacy(\"你不能在准备期间放置监狱.\", NOTIFY_GENERIC, 5)") return end
		local ground = self.Owner:GetGroundEntity()
		if self.Owner:Crouching() then
			self.Owner:SendLua("notification.AddLegacy(\"你需要站起来才能放置监狱!\", NOTIFY_ERROR, 5)")
		elseif ground:IsWorld() == false then
			self.Owner:SendLua("notification.AddLegacy(\"你必须站在空旷地区才能放置监狱!\", NOTIFY_ERROR, 5)")
		elseif ground:IsWorld() == true then
				-- Spawns the Jail Entity
				jailpoint=ents.Create("sent_jail")
				jailpoint:SetPos(self.Owner:GetPos())
				jailpoint:Spawn()
			
				jail=ents.Create("prop_physics")
				jail:SetModel("models/props_sdk/jail.mdl")
				jail:SetPos(self.Owner:GetPos())
				jail:SetMaterial("models/props_combine/portalball001_sheet")
				jail:Spawn()
				jail:SetMoveType(MOVETYPE_NONE)
				jail:DrawShadow( false )
				jail:SetName("jailring")
				jail:SetCustomCollisionCheck( true )
				jail:EmitSound("weapons/teleporter_ready.wav", 511, 100)
			
				jaildown=ents.Create("prop_physics")
				jaildown:SetModel("models/props_sdk/jail.mdl")
				jaildown:SetMaterial("models/props_combine/portalball001_sheet")
				jaildown:DrawShadow( false )
				jaildown:SetAngles(Angle(180,0,0) )
				jaildown:SetPos(self.Owner:GetPos() + Vector(0,0,1))
			
				self.Owner:C_msg( "监狱已成功放置!")
				umsg.Start("hasjail", self.Owner)
						umsg.Bool(false)
					umsg.End()
				self.Owner:StripWeapon("cnr_jail")
				RunConsoleCommand("use", "cnr_stunstick")
		else
			self.Owner:SendLua("notification.AddLegacy(\"未知错误, 请通知管理员!\", NOTIFY_ERROR, 5)")
		end
	end
end