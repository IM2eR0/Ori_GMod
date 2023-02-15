SWEP.Author			= "初雪 OriginalSnow"
SWEP.PrintName		= "性别检测仪"

SWEP.Instructions	= "鼠标左键：检测对方性别！"

SWEP.Slot = 5
SWEP.SlotPos = 9

SWEP.Category			= "初雪の小宝库"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.NumShots		= -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay			= 1
SWEP.Primary.NumShots		= -1
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Secondary.Delay		= 1

SWEP.ViewModel = Model( "models/weapons/c_arms.mdl" )
SWEP.WorldModel = "models/props_lab/reciever01b.mdl"
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.DrawAmmo = false

function SWEP:Initialize()
	self:SetHoldType( "normal" )
end

SWEP.NextPrimaryAttack = 0
function SWEP:PrimaryAttack()
    if CLIENT then
        if ( self.NextPrimaryAttack > CurTime() ) then
			return
		end
		self.NextPrimaryAttack = CurTime() + self.Primary.Delay

        local tr = self.Owner:GetEyeTrace().Entity
        if not tr:IsValid() or not tr:IsPlayer() then return end
        chat.AddText(tr:Name().." 是 ",tr:GetGenderColor(),tr:GetGender())
    end
end

SWEP.NextSecondaryAttack = 0
function SWEP:SecondaryAttack()
    if CLIENT then
        if ( self.NextSecondaryAttack > CurTime() ) then
			return
		end
		self.NextSecondaryAttack = CurTime() + self.Secondary.Delay

        chat.AddText(self.Owner:Name().." 是 ",self.Owner:GetGenderColor(),self.Owner:GetGender())
    end
end