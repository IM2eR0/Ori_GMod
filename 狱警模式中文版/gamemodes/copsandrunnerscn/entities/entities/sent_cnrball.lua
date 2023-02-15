
AddCSLuaFile()

local BounceSound = Sound( "garrysmod/balloon_pop_cute.wav" )

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Bouncy Ball"
ENT.Author			= "Garry Newman"
ENT.Information		= "An edible bouncy ball"
ENT.Category		= "Fun + Games"

ENT.Editable		= true
ENT.Spawnable		= true
ENT.AdminOnly		= false
ENT.RenderGroup		= RENDERGROUP_BOTH

function ENT:SetupDataTables()

	self:NetworkVar( "Float", 0, "BallSize", { KeyName = "ballsize", Edit = { type = "Float", min = 4, max = 128, order = 1 } } )
	self:NetworkVar( "Vector", 0, "BallColor", { KeyName = "ballcolor", Edit = { type = "VectorColor", order = 2 } } )

end

-- This is the spawn function. It's called when a client calls the entity to be spawned.
-- If you want to make your SENT spawnable you need one of these functions to properly create the entity
--
-- ply is the name of the player that is spawning it
-- tr is the trace from the player's eyes 
--
function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end
	
	local size = math.random( 16, 48 )
	local SpawnPos = tr.HitPos + tr.HitNormal * size
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetBallSize( size )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

--[[---------------------------------------------------------
   Name: Initialize
-----------------------------------------------------------]]
function ENT:Initialize()

	if ( SERVER ) then

		local size = self:GetBallSize() / 2
		util.AddNetworkString( "bSound" )
	
		-- Use the helibomb model just for the shadow (because it's about the same size)
		self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
		
		-- Don't use the model's physics - create a sphere instead
		self:PhysicsInitSphere( size, "metal_bouncy" )
		
		-- Wake the physics object up. It's time to have fun!
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:Wake()
		end
		
		-- Set collision bounds exactly
		self:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) )

		local i = math.random( 9, 20 ) -- [1-4] Default 4 colors, [1-8] Additional Colors, [9-20] All color mixes
		
		if ( i == 0 ) then
			self:SetBallColor( Vector( 1, 0.3, 0.3 ) )
		elseif ( i == 1 ) then
			self:SetBallColor( Vector( 0.3, 1, 0.3 ) )
		elseif ( i == 2 ) then
			self:SetBallColor( Vector( 1, 1, 0.3 ) )
		elseif ( i == 3 ) then
			self:SetBallColor( Vector( 0.2, 0.3, 1 ) )
		elseif ( i == 4 ) then
			self:SetBallColor( Vector( 0.1, 1, 0.4 ) )
		elseif ( i == 5 ) then
			self:SetBallColor( Vector( 0, 1, 0 ) )
		elseif ( i == 6 ) then
			self:SetBallColor( Vector( 0.5, 0, 1 ) )
		elseif ( i == 7 ) then
			self:SetBallColor( Vector( 1, 0.3, 0.1 ) )
		elseif ( i == 8 ) then
			self:SetBallColor( Vector( 1, 0.1, 0.1 ) )
		elseif ( i == 9 ) then
			self:SetBallColor( Vector( 1, 0, 0 ) )
		elseif ( i == 10 ) then
			self:SetBallColor( Vector( 1, 0.2, 0 ) )
		elseif ( i == 11 ) then
			self:SetBallColor( Vector( 1, 1, 0 ) )
		elseif ( i == 12 ) then
			self:SetBallColor( Vector( 0.3, 1, 0 ) )
		elseif ( i == 13 ) then
			self:SetBallColor( Vector( 0, 1, 0 ) )
		elseif ( i == 14 ) then
			self:SetBallColor( Vector( 0, 1, 0.3 ) )
		elseif ( i == 15 ) then
			self:SetBallColor( Vector( 0, 1, 1 ) )
		elseif ( i == 16 ) then
			self:SetBallColor( Vector( 0, 0.5, 1 ) )
		elseif ( i == 17 ) then
			self:SetBallColor( Vector( 0, 0, 1 ) )
		elseif ( i == 18 ) then
			self:SetBallColor( Vector( 0.4, 0, 1 ) )
		elseif ( i == 19 ) then
			self:SetBallColor( Vector( 1, 0, 1 ) )
		elseif ( i == 20 ) then
			self:SetBallColor( Vector( 1, 0, 0.3 ) )
		end
		

		self:NetworkVarNotify( "BallSize", self.OnBallSizeChanged )
		
	else 
	
		self.LightColor = Vector( 0, 0, 0 )
	
	end
	
end

function ENT:OnBallSizeChanged( varname, oldvalue, newvalue )

	local delta = oldvalue - newvalue

	local size = self:GetBallSize() / 2.1
	self:PhysicsInitSphere( size, "metal_bouncy" )
	
	size = self:GetBallSize() / 2.6
	self:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) )

	self:PhysWake()

end

if ( CLIENT ) then

local matBall = Material( "sprites/sent_ball" )

function ENT:Draw()
	if LocalPlayer():Team() == 4 or LocalPlayer():Team() == 2 then self:DrawShadow(false) return end
	local pos = self:GetPos()
	local vel = self:GetVelocity()

	render.SetMaterial( matBall )
	
	local lcolor = render.ComputeLighting( self:GetPos(), Vector( 0, 0, 1 ) )
	local c = self:GetBallColor()
	
	lcolor.x = c.r * ( math.Clamp( lcolor.x, 0, 1 ) + 0.5 ) * 255
	lcolor.y = c.g * ( math.Clamp( lcolor.y, 0, 1 ) + 0.5 ) * 255
	lcolor.z = c.b * ( math.Clamp( lcolor.z, 0, 1 ) + 0.5 ) * 255
	
	render.DrawSprite( pos, self:GetBallSize(), self:GetBallSize(), Color( lcolor.x, lcolor.y, lcolor.z, 255 ) )
	
end

end


--[[---------------------------------------------------------
   Name: PhysicsCollide
-----------------------------------------------------------]]
function ENT:PhysicsCollide( data, physobj )
	
	-- Play sound on bounce
	if ( data.Speed > 60 && data.DeltaTime > 0.2 ) then

		local pitch = 32 + 128 - self:GetBallSize()
		--self:EmitSound( BounceSound, 75, math.random( pitch - 10, pitch + 10 ) )
		net.Start("bSound")
			net.WriteEntity(self)
			net.WriteInt(pitch, 32)
		net.Send( table.Add(team.GetPlayers(3), table.Add(team.GetPlayers(1), team.GetPlayers(5))) )
		--print("Not awesome")

	end
	
	-- Bounce like a crazy bitch
	local LastSpeed = math.max( data.OurOldVelocity:Length(), data.Speed )
	local NewVelocity = physobj:GetVelocity()
	NewVelocity:Normalize()
	
	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )
	
	local TargetVelocity = NewVelocity * LastSpeed * 0.9
	
	physobj:SetVelocity( TargetVelocity )
	
end

if CLIENT then
	function ballEmitSound(ent)
		local bBall = net.ReadEntity()
		local pitch = net.ReadInt(32) 
		--print("hey")
		if IsValid(bBall) then bBall:EmitSound( BounceSound, 75, math.random( pitch - 10, pitch + 10) ) end
	end

		net.Receive("bSound", ballEmitSound)
end

--[[---------------------------------------------------------
   Name: OnTakeDamage
-----------------------------------------------------------]]
function ENT:OnTakeDamage( dmginfo )

	-- React physically when shot/getting blown
	self:TakePhysicsDamage( dmginfo )
	
end


--[[---------------------------------------------------------
   Name: Use
-----------------------------------------------------------]]
function ENT:Use( activator, caller )

	self:Remove()

end
