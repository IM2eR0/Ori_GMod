if SERVER then
	AddCSLuaFile("sent_smokespawn.lua")
end

print("sent_smokespawn loads!")

if CLIENT then
	print("client loads sent_smokespawn")
end

ENT.Type = "anim"
--ENT.Base = "base_entity"
 
ENT.PrintName		= "Smokespawn"
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= "Unique Class name"
ENT.Instructions	= "Don't use it"

if SERVER then

function ENT:Initialize()
 
	self:SetModel( "models/weapons/w_grenade.mdl" )
	--self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:SetNoDraw( true )
	
end
  

end