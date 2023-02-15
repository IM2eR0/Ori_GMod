SWEP.Author			= "初雪 OriginalSnow"
SWEP.PrintName		= "变性药"
SWEP.Instructions	= "鼠标左键：重新选择性别！\n\n绝对不是可乐！！！"

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
SWEP.WorldModel = "models/props_junk/PopCan01a.mdl"
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.DrawAmmo = false

function SWEP:Initialize()
	self:SetHoldType( "normal" )
end

SWEP.NextPrimaryAttack = 0
function SWEP:PrimaryAttack()

	if CLIENT then return end
    if ( self.NextPrimaryAttack > CurTime() ) then
        return
    end
    self.NextPrimaryAttack = CurTime() + self.Primary.Delay

    net.Start("OriginalSnow:GenderSeletor")
    net.Send(self.Owner)
	self.Owner:StripWeapon(self:GetClass())
end

function SWEP:SecondaryAttack()
    return
end