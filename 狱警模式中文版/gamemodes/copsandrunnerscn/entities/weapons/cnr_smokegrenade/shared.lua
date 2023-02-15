if SERVER then

	AddCSLuaFile( "shared.lua" )

	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
else

	SWEP.PrintName			= "烟雾弹"
	SWEP.Slot				= 2
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

SWEP.HoldType = "grenade"

SWEP.ViewModel	= "models/weapons/v_grenade.mdl"
SWEP.WorldModel	= "models/weapons/w_grenade.mdl"

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


function SWEP:PrimaryAttack()
	self:SendWeaponAnim(ACT_VM_THROW)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
if SERVER then
	if table.HasValue( rainbowactivated, self.Owner:SteamID() ) then
	timer.Simple(0.11, function()
		local smokegrenade=ents.Create("prop_physics")
		smokegrenade:SetModel("models/weapons/w_grenade.mdl")
		smokegrenade:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 45))
		smokegrenade:SetAngles(self.Owner:EyeAngles())
		smokegrenade:Spawn()
		local smokephys = smokegrenade:GetPhysicsObject()
			if !(smokephys && IsValid( smokephys )) then smokegrenade:Remove() return end
		smokephys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() *  3000)
		umsg.Start("hassmoke", self.Owner)
			umsg.Bool(false)
		umsg.End()
		self.Owner:StripWeapon("cnr_smokegrenade")
		
		timer.Simple(1.5, function()
			if IsValid( smokegrenade ) then
			local sfx = EffectData()
				sfx:SetOrigin(smokegrenade:GetPos())
				util.Effect("effect_smokenade_rainbow",sfx)
				smokegrenade:Remove()
			end
			end)
		
	end)
	
	else
		timer.Simple(0.11, function()
		local smokegrenade=ents.Create("prop_physics")
		smokegrenade:SetModel("models/weapons/w_grenade.mdl")
		smokegrenade:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 45))
		smokegrenade:SetAngles(self.Owner:EyeAngles())
		smokegrenade:Spawn()
		local smokephys = smokegrenade:GetPhysicsObject()
			if !(smokephys && IsValid( smokephys )) then smokegrenade:Remove() return end
		smokephys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() *  3000)
		umsg.Start("hassmoke", self.Owner)
			umsg.Bool(false)
		umsg.End()
		self.Owner:StripWeapon("cnr_smokegrenade")
		
		timer.Simple(1.5, function()
			if IsValid( smokegrenade ) then
			local sfx = EffectData()
				sfx:SetOrigin(smokegrenade:GetPos())
				util.Effect("effect_smokenade_smoke",sfx)
				smokegrenade:Remove()
			end
			end)
		
	end)
	end
end

	if CLIENT then
		RunConsoleCommand("use", "cnr_hands")
	end
end

function SWEP:SecondaryAttack()
	if SERVER then
		if table.HasValue(rainbowrewards, self.Owner:SteamID() ) then
			if table.HasValue( rainbowactivated, self.Owner:SteamID() ) then
				table.remove( rainbowactivated, table.KeyFromValue( rainbowactivated, self.Owner:SteamID() ) )
				self.Owner:SendLua("notification.AddLegacy(\"Standard Issue Smoke Grenades equipped!\", NOTIFY_UNDO, 3)")
			else
				table.insert( rainbowactivated, self.Owner:SteamID() )
				self.Owner:SendLua("notification.AddLegacy(\"Exclusive Rainbow Smoke Grenades equipped!\", NOTIFY_UNDO, 3)")
			end
		else return end
	end
end






