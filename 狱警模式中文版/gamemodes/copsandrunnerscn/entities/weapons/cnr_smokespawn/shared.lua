if SERVER then

	AddCSLuaFile( "shared.lua" )

	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
else

	SWEP.PrintName			= "烟雾弹生成器"
	SWEP.Slot				= 2
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true

	SWEP.ViewModelFOV		= 60

	function SWEP:DrawWeaponSelection( x, y, w, h, alpha )
	end

	function SWEP:DrawHUD()
	end

end

SWEP.Author			= "Zet0r"
SWEP.Contact		= "youtube.com/Zet0rz"
SWEP.Purpose		= "Place a Smoke Grenade Spawnpoint for the Cops and Runners gamemode"
SWEP.Instructions	= "Let the gamemode give you it"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.HoldType = "grenade"

SWEP.ViewModel	= "models/weapons/cstrike/c_c4.mdl"
SWEP.WorldModel	= "models/weapons/w_c4.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"


--if SERVER then
function SWEP:SecondaryAttack()
local smokeSpawned = false
	local ground = self.Owner:GetGroundEntity()
	if ground:IsWorld() == false then
		if SERVER then self.Owner:SendLua("notification.AddLegacy(\"你需要站在空旷地区才能放置烟雾弹刷新点!\", NOTIFY_ERROR, 5)") end
	elseif ground:IsWorld() == true then
		if SERVER then
			-- Spawns the Smoke Spawnpoint entity!
			local smokepoint=ents.Create("sent_smokespawn")
			smokepoint:SetPos(self.Owner:GetPos() + Vector(0,0,15))
			smokepoint:Spawn()
			
			local smokespawn=ents.Create("prop_dynamic")
			smokespawn:SetModel("models/props_junk/trafficcone001a.mdl")
			smokespawn:SetMaterial("models/props_combine/portalball001_sheet")
			smokespawn:SetPos(self.Owner:GetPos() + Vector(0,0,15))
			smokespawn:SetAngles(Angle(180, 0, 0))
			smokespawn:Spawn()
			smokespawn:SetMoveType(MOVETYPE_NONE)
			smokespawn:DrawShadow( false )
			smokespawn:SetName("smokespawnpoint")
			smokespawn:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			
			local smokeghost=ents.Create("prop_dynamic")
			smokeghost:SetModel("models/weapons/w_grenade.mdl")
			smokeghost:SetPos(self.Owner:GetPos() + Vector(0,0,35))
			smokeghost:SetAngles(Angle(45, 0, 0))
			smokeghost:SetMaterial("models/wireframe")
			smokeghost:Spawn()
			--smokeghost:SetMoveType(MOVETYPE_NONE)
			smokeghost:DrawShadow( false )
			smokeghost:SetName("smokeghostpoint")
			smokeghost:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			--smokeghost:SetCustomCollisionCheck( true )
			smokeghost:EmitSound("weapons/sentry_spot_client.wav", 100, 100)
			umsg.Start("hassmokespawn", self.Owner)
					umsg.Bool(false)
				umsg.End()
				local function Spin()
					if IsValid( smokeghost ) then
                        smokeghost:SetAngles(smokeghost:GetAngles() + Angle(0,3,0))
					for k, v in pairs(player.GetAll()) do
						if smokeSpawned == true then
							if v:GetPos():Distance(smokeghost:GetPos()- Vector(0,0,30)) < 20 and (v:Team() == 2 or v:Team() == 4) then
								if not v:HasWeapon("cnr_smokegrenade") then
									v:Give("cnr_smokegrenade")
										umsg.Start("hassmoke", v)
											umsg.Bool(true)
										umsg.End()
									smokeSpawned = false
									smokeghost:SetMaterial("models/wireframe")
									timer.Start("SmokeSpawnTime" .. smokeghost:EntIndex())
								end
							end
						end
					end
					end
				end
				hook.Add("Tick","Spinner".. smokeghost:EntIndex(), Spin)
				
			timer.Create("SmokeSpawnTime" .. smokeghost:EntIndex(), GetConVar( "cnr_smokedelay" ):GetFloat(), 0, function()
			--print("TIMER FIRED ")
				if IsValid(smokeghost) and smokeSpawned == false then
					smokeghost:SetMaterial("")
					smokeSpawned = true
				timer.Stop("SmokeSpawnTime" .. smokeghost:EntIndex())
				end
			end)
			timer.Start("SmokeSpawnTime" .. smokeghost:EntIndex())
			if SERVER then self.Owner:SendLua("notification.AddLegacy(\"烟雾弹刷新点已成功放置!\", NOTIFY_GENERIC, 3)") end
		end		
		if SERVER then
			self.Owner:StripWeapon("cnr_smokespawn")
		end
		if CLIENT then
			RunConsoleCommand("use", "cnr_hands")
		end
	else
		if SERVER then
			self.Owner:SendLua("notification.AddLegacy(\"未知错误, 请通知管理员!\", NOTIFY_ERROR, 5)")
		end
	end
end
--end



