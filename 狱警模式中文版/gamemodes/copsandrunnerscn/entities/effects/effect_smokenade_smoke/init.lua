local smokeparticles = {
      Model("particle/particle_smokegrenade"),
      Model("particle/particle_noisesphere")
   };

--Main function
function EFFECT:Init(data)
	--Create particle emitter
	local emitter = ParticleEmitter(data:GetOrigin())
		--Amount of particles to create
		for i=0, 128 do
			--Safeguard
			if !emitter then return end

			local Pos = (data:GetOrigin() + Vector( math.Rand(-32,32), math.Rand(-32,32), math.Rand(-32,32) ) + Vector(0,0,64))
			local particle = emitter:Add( table.Random(smokeparticles), Pos )
			if (particle) then
				particle:SetVelocity(VectorRand() * math.Rand(1520,5540))
				particle:SetLifeTime(0)
				particle:SetDieTime(math.Rand(15, 17))
					local randomnum = math.random(242,255)
				particle:SetColor(255,255,255)
				particle:SetLighting(false)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)
					local Size = math.Rand(182,212)
				particle:SetStartSize(Size)
				particle:SetEndSize(Size)
				particle:SetRoll(math.Rand(-360, 360))
				particle:SetRollDelta(math.Rand(-0.21, 0.21))
				particle:SetAirResistance(math.Rand(520,620))
				particle:SetGravity( Vector(0, 0, math.Rand(-42, -82)) )
				particle:SetCollide(true)
				particle:SetBounce(0.42)
				particle:SetLighting(1)
			end
		end
	--We're done with this emitter
	emitter:Finish()
end

--Kill effect
function EFFECT:Think()
return false
end

--Not used
function EFFECT:Render()
end