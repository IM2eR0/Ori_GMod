if SERVER then

	AddCSLuaFile( "shared.lua" )

	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
else

	SWEP.PrintName			= "空手"
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

SWEP.ViewModel	= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel	= "models/weapons/w_crowbar.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

--local bBallIndex = 0
local ballType = 2


function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	self.CurHoldType = self.HoldType
	self:DrawShadow(false)
end


function SWEP:Deploy()
		self.Owner:SetWalkSpeed(260 * GetConVar( "cnr_speedmultiplier" ):GetFloat())
		self.Owner:SetRunSpeed(520 * GetConVar( "cnr_speedmultiplier" ):GetFloat())
		self.Owner:DrawViewModel(false)
end

function SWEP:Holster()
		self.Owner:SetWalkSpeed(200 * GetConVar( "cnr_speedmultiplier" ):GetFloat())
		self.Owner:SetRunSpeed(400 * GetConVar( "cnr_speedmultiplier" ):GetFloat())
			timer.Destroy("ThrowPower"..self.Owner:UserID())
			hook.Remove( "HUDPaint", "PaintThrowForce" )
	return true
end

function SWEP:DrawWorldModel()

end

function SWEP:PrimaryAttack()
	if self.Owner:Team() != 3 then return end
	
	local shootpower = 0
	local fullycharged = false
	if CLIENT then
		hook.Add( "HUDPaint", "PaintThrowForce", function( )
			draw.SimpleText( shootpower/100 .."%", "Default", ScrW() / 2, ScrH() / 2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
		end)
	end
	
	timer.Create("ThrowPower"..self.Owner:UserID(), 0.1, 0, function()
		shootpower = shootpower + 100
		if shootpower > 100000 then 
			shootpower = 100000 
			if fullycharged == false then
				self.Owner:EmitSound("vo/medic_autochargeready02.wav",100,100)
				fullycharged = true
			end
		end
		--print(shootpower)
		
		if IsValid(self) and !self.Owner:KeyDown(IN_ATTACK) then
		
			if SERVER then
				if IsValid( bBalls[self.Owner:UserID()] ) and (bBalls[self.Owner:UserID()]:GetClass() == "sent_cnrball" or bBalls[self.Owner:UserID()]:GetClass() == "sent_cnrball_pixel") then 
					bBalls[self.Owner:UserID()]:Remove() 
					table.remove( bBalls, self.Owner:UserID() )
				end
				if IsValid(self.Owner) and table.HasValue( bBallPixel, self.Owner:SteamID() ) then bouncyBall = ents.Create("sent_cnrball_pixel")
					else bouncyBall = ents.Create("sent_cnrball") end
				--bouncyBall = ents.Create("sent_cnrball_pixel")
				bouncyBall:SetBallSize( math.random(35, 25) )
				bouncyBall:SetCollisionGroup(COLLISION_GROUP_WEAPON)
				bouncyBall:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 45))
				--bouncyBall:SetAngles(self.Owner:EyeAngles())
				bouncyBall:Spawn()
				bouncyBall:Activate()
				--bouncyBall:SetOwner(self.Owner)
				table.insert(bBalls, self.Owner:UserID(), bouncyBall)
				--bBallIndex = bouncyBall:EntIndex()
				--print(bouncyBall:GetOwner())
				local bouncyBallPhys = bouncyBall:GetPhysicsObject()
					if !(bouncyBallPhys && IsValid( bouncyBallPhys )) then bouncyBall:Remove() return end
				bouncyBallPhys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() *  shootpower)
				--bouncyBall:SetMoveType(MOVETYPE_NONE)
			end
			self:SetNextPrimaryFire( CurTime() + 0.3)
			
			timer.Destroy("ThrowPower"..self.Owner:UserID())
			hook.Remove( "HUDPaint", "PaintThrowForce" )
		end 
	end)
	
end

function SWEP:OnRemove()
	if IsValid(self.Owner) then
		timer.Destroy("ThrowPower"..self.Owner:UserID())
	end
	hook.Remove( "HUDPaint", "PaintThrowForce" )
end

function onDisconnect(player)
	timer.Destroy("ThrowPower"..player:UserID() )
end
hook.Add( "PlayerDisconnected", "disconnectTimerDestroy", onDisconnect )

function SWEP:SecondaryAttack()
if self.Owner:Team() != 3 then return end
	if SERVER then
		if table.HasValue( inCNRgroup, self.Owner:SteamID() ) then
			if table.HasValue( bBallPixel, self.Owner:SteamID() ) then
				table.remove( bBallPixel, table.KeyFromValue(bBallPixel, self.Owner:SteamID() ) )
				self.Owner:SendLua("notification.AddLegacy(\"已切换至 默认弹力球皮肤!\", NOTIFY_UNDO, 3)")
			else
				table.insert( bBallPixel, self.Owner:SteamID() )
				self.Owner:SendLua("notification.AddLegacy(\"已切换至 像素弹力球皮肤!\", NOTIFY_UNDO, 3)")
			end
		--else self.Owner:ChatPrint("You need to join our Steam Group to use custom Bouncy Balls. Type !joincnrgroup to join now! (Opens in Overlay)") 
		else return end
	end
end