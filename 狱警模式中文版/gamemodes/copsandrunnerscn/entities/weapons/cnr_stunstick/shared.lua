-- once agian, damn bandwagon
if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName			= "警棍"	
	SWEP.Author				= ""
	SWEP.DrawAmmo 			= false
	SWEP.DrawCrosshair 		= true
	SWEP.ViewModelFOV			= 65
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes		= false
	
	SWEP.Slot				= 0
	SWEP.SlotPos			= 1
	SWEP.IconLetter			= "C"
end

SWEP.Spawnable				= false
SWEP.AdminSpawnable			= true

SWEP.ViewModel 				= "models/weapons/v_stunstick.mdl"
SWEP.WorldModel 			= "models/weapons/w_stunbaton.mdl" 
SWEP.HoldType				= "melee"


SWEP.Weight						= 5
SWEP.AutoSwitchTo				= false
SWEP.AutoSwitchFrom				= false

SWEP.Primary.ClipSize			= -1
SWEP.Primary.Damage				= 20 -- real damage
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic			= true
SWEP.Primary.Ammo				= "none"

SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Damage			= 50
SWEP.Secondary.Automatic		= true
SWEP.Secondary.Ammo			= "none"

SWEP.MissSound 				= Sound("weapons/stunstick/stunstick_swing1.wav")
SWEP.WallSound 				= Sound("weapons/stunstick/stunstick_impact2.wav")
SWEP.DeploySound			= Sound("weapons/stunstick/spark1.wav")

	swingCur = CurTime()
	jailtable = {}


/*---------------------------------------------------------
Initialize
---------------------------------------------------------*/
function SWEP:Initialize() 
   
 	self:SetWeaponHoldType( self.HoldType ) 
	
	util.PrecacheSound("weapons/stunstick/stunstick_swing1.wav")
	util.PrecacheSound("weapons/stunstick/stunstick_impact1.wav")
	util.PrecacheSound("weapons/stunstick/stunstick_impact2.wav")
	util.PrecacheSound("weapons/stunstick/stunstick_impact3.wav")

	jailtable = {}

 end 

/*---------------------------------------------------------
Deploy
---------------------------------------------------------*/
function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
	self.Weapon:EmitSound( self.DeploySound, 50, 100 )
	return true
end

/*---------------------------------------------------------
SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.1)
	swingCur = CurTime() - 0.3
end

/*---------------------------------------------------------
PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	if SERVER then self.Owner:LagCompensation( true ) end
	swingCur = CurTime()
	
	if table.Count(jailtable) <= 0 then
		for k,v in pairs(ents.FindByClass("prop_physics")) do
			if v:GetModel() == "models/props_sdk/jail.mdl" then
				table.insert(jailtable, v)
				--print("Added "..v:EntIndex() )
			end
		end
	end

	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 100 )
	tr.filter = table.Add( {self.Owner}, jailtable )
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )

	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	if !(GetConVar( "cnr_jailmaxdist" ):GetInt() < GetConVar( "cnr_jailmindist" ):GetInt()) then
		if IsValid( jail ) then
			local jaildistance = self.Owner:GetPos():Distance( jail:GetPos() )
			if jaildistance <= GetConVar( "cnr_jailmindist" ):GetInt() then
				self.Weapon:SetNextPrimaryFire(CurTime() + 0.6)
			elseif jaildistance >= GetConVar( "cnr_jailmaxdist" ):GetInt() then
				self.Weapon:SetNextPrimaryFire(CurTime() + 0.3)
			else
				self.Weapon:SetNextPrimaryFire(CurTime() + 0.6 - (((jaildistance - GetConVar( "cnr_jailmindist" ):GetInt()) / (GetConVar( "cnr_jailmaxdist" ):GetInt() - GetConVar( "cnr_jailmindist" ):GetInt())) * 0.3) )
			end
		else
			self.Weapon:SetNextPrimaryFire(CurTime() + 0.3)
		end
	else
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.3)
	end
	
	if ( trace.Hit ) then

		if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 1
			bullet.Force  = 1000
			bullet.Damage = 35
			self.Owner:FireBullets(bullet) 
			self.Weapon:EmitSound( self.WallSound )
		elseif trace.Entity:GetClass() == "sent_cnrball" or trace.Entity:GetClass() == "sent_cnrball_pixel" then
			if SERVER then
				local bouncyBallPhys = trace.Entity:GetPhysicsObject()
					if !(bouncyBallPhys && IsValid( bouncyBallPhys )) then end
				bouncyBallPhys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() *  1000000)
			end
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			if trace.Entity:GetClass() == "sent_cnrball_pixel" then
				trace.Entity:EmitSound( "copsandrunners/sent_cnrball_pixel" )
			else
				trace.Entity:EmitSound( "garrysmod/balloon_pop_cute.wav" )
			end
		else
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 1
			bullet.Damage = 50
			self.Owner:FireBullets(bullet) 
			self.Weapon:EmitSound( self.WallSound )		
		end
	self:ImpactEffect( trace );
	else
		self.Weapon:EmitSound(self.MissSound,100,math.random(90,120))
		self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
	end
	if SERVER then self.Owner:LagCompensation( false ) end
end

/*---------------------------------------------------------
Reload
---------------------------------------------------------*/
function SWEP:Reload()

	return false
end

/*---------------------------------------------------------
OnRemove
---------------------------------------------------------*/
function SWEP:OnRemove()

return true
end

/*---------------------------------------------------------
Holster
---------------------------------------------------------*/
function SWEP:Holster()

	return true
end

/*---------------------------------------------------------
ShootEffects
---------------------------------------------------------*/
function SWEP:ShootEffects()

end

function SWEP:ImpactEffect( trace )

//#ifndef CLIENT_DLL

	local	data = EffectData();

	data:SetNormal( trace.HitNormal );
	data:SetOrigin( trace.HitPos + ( trace.HitNormal * 4.0 ) );

	util.Effect( "StunstickImpact", data );

//#endif

	//FIXME: need new decals
	--util.ImpactTrace( traceHit, self.Owner );

end



if CLIENT then
local white = Color(180,180,180) 
local beamMat = CreateMaterial("beamMaterial"..CurTime() , "UnlitGeneric", {
	["$additive"] = 1,
	["$basetexture"] = "sprites/lgtning"
});

local sprites = {
Material( "sprites/light_glow02_add_noz" ),
Material( "sprites/light_glow02_add" ),
Material( "effects/blueflare1" )
}

hook.Add( "PostDrawViewModel", "stunstick", function(ViewModel, ply, weapon )
	if IsValid(ViewModel) and IsValid(weapon) and ply:Alive() and weapon:GetClass() == "cnr_stunstick" then
		local size = 12 - math.Clamp((CurTime() - swingCur)*1.25,0,1)*12
		local eyepos = EyePos()
		local eyeangles = EyeAngles()
		 
		if size != 0 then
			for i=1,9 do 
				local ID = ViewModel:LookupAttachment("spark" .. i .. "a")
				local attach = ViewModel:GetAttachment( ID )
				cam.Start3D(eyepos,eyeangles)
					render.SetMaterial( sprites[math.random(1,3)] )
					render.DrawSprite( attach.Pos, size, size, white) 
				cam.End3D()
			end
			
			for i=1,9 do 
				local ID = ViewModel:LookupAttachment("spark" .. i .. "b")
				local attach = ViewModel:GetAttachment( ID )
				cam.Start3D(eyepos,eyeangles)
					render.SetMaterial( sprites[math.random(1,3)] )
					render.DrawSprite( attach.Pos, size, size, white) 
				cam.End3D()
			end
			
			if math.random(1,3) == 3 then
				local attach = ViewModel:GetAttachment( math.random(1,18) )
				local posTables = {attach.Pos}
				for i=1,3 do
					local Rand = VectorRand()*3
					local offset = attach.Ang:Forward()*Rand.x + attach.Ang:Right()*Rand.y  + attach.Ang:Up()*Rand.z
					local pos = posTables[i]
					
					cam.Start3D(eyepos,eyeangles)
						render.SetMaterial( beamMat )
						render.DrawBeam( pos, pos + offset, 3.25-i, 1, 1.25, white )
					cam.End3D()
					table.insert(posTables, pos + offset)
				end
			end
		end
	end
end)
end



--
-- Stunstick Effects - Thanks to Josh 'Acecool' Moser for help with this!
--

--
-- Definitions
--
local STUN_STICK            = Material( "effects/stunstick" ); -- draw.GetMaterial( "effects/stunstick" );
CONVERSION_UNITS_TO_INCHES  = 4 / 3;
CONVERSION_UNITS_TO_MPH     = CONVERSION_UNITS_TO_INCHES * 17.6;

--
-- Effects Helper-Function
--
-- Input is Player, Emitter, Position, Material, Table of options
local function StunStickEffect( _p, _e, _pos, _mat, _tab )
    local p = _e:Add( _mat, _pos )
    p:SetLifeTime(0)
    p:SetDieTime( math.Rand( 0.10, 0.25 ) )
    p:SetEndSize( 35 )
    p:SetStartSize( _tab.startsize )
    p:SetStartAlpha( _tab.alpha )
    p:SetEndAlpha( 0 )
    p:SetStartLength( 1 )
    p:SetEndLength( 0 )
    p:SetVelocity( Vector( 0, 0, 5 ) + ( VectorRand( ) * 15 ) )
    -- p:SetGravity( Vector( 0, 0, -100 ) )
end

--
-- Thirdperson effects
--
hook.Add( "PostPlayerDraw", "StunStickEffectsThird", function( _p )
if math.random(1,3) == 1 then
    -- If the player is in a vehicle, don't even bother
    if ( IsValid( _p:GetVehicle( ) ) ) then return; end
	--print("no vehicle")

    -- If the weapon isn't valid, don't bother
    local _w = _p:GetActiveWeapon( );
    if ( !IsValid( _w ) ) then return; end
	--print("valid weapon")

    -- If they're not using the correct weapon, don't bother
    if ( _w:GetClass( ) != "cnr_stunstick" || _w:GetClass( ) != "cnr_stunstick" ) then return; end
	--print("correct weapon")

    local _muzzle = _w:LookupAttachment( "1" );
    local _attachment = _w:GetAttachment( _muzzle );
    local _pos = _attachment.Pos + _attachment.Ang:Forward( ) * 2.4;
    local _e = ParticleEmitter( _pos );

    -- Declarations
    local _sin = math.abs( math.sin( CurTime( ) * 25 ) ) * 3; //math.sinwave( 25, 3, true )

    -- Set the drawing material, render the two sprites; the smaller brighter one, the larger very transparent one and pulse based on sin
    render.SetMaterial( STUN_STICK );
    render.DrawSprite( _pos, 5 + _sin, 5 + _sin, Color( 255, 255, 255, 155 ) );
    render.DrawSprite( _pos, 20 + _sin, 20 + _sin, Color( 255, 255, 255, 10 ) );

    -- If they're running / moving faster than 10mph, don't render the next set of effects because they look like hot metal shavings falling
    if ( _p:GetVelocity( ):Length( ) / CONVERSION_UNITS_TO_MPH > 50 ) then return; end
    
    -- Update emitter position, and call the helper-functions for the effects.
    _e:SetPos( _pos );
    StunStickEffect( _p, _e, _pos, "effects/stunstick", { startsize = 10, alpha = 75 } );
    StunStickEffect( _p, _e, _pos, "trails/physbeam", { startsize = 10, alpha = 235 } );
    StunStickEffect( _p, _e, _pos, "effects/tool_tracer", { startsize = 5, alpha = 75 } );
    StunStickEffect( _p, _e, _pos, "sprites/tp_beam001", { startsize = 5, alpha = 75 } );
    StunStickEffect( _p, _e, _pos, "trails/electric", { startsize = 5, alpha = 75 } );
end
end );