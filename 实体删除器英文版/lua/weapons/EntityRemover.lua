--[[




##     ##    ###    ########  ########    ########  ##    ##                                               
###   ###   ## ##   ##     ## ##          ##     ##  ##  ##                                                
#### ####  ##   ##  ##     ## ##          ##     ##   ####                                                 
## ### ## ##     ## ##     ## ######      ########     ##                                                  
##     ## ######### ##     ## ##          ##     ##    ##                                                  
##     ## ##     ## ##     ## ##          ##     ##    ##                                                  
##     ## ##     ## ########  ########    ########     ##                                                  
                                                                                                           
                                                                                                           
                                                                                                           
                                                                                                           
                                                                                                           
                                                                                                           
                                                                                                           
 #######  ########  ####  ######   #### ##    ##    ###    ##        ######  ##    ##  #######  ##      ## 
##     ## ##     ##  ##  ##    ##   ##  ###   ##   ## ##   ##       ##    ## ###   ## ##     ## ##  ##  ## 
##     ## ##     ##  ##  ##         ##  ####  ##  ##   ##  ##       ##       ####  ## ##     ## ##  ##  ## 
##     ## ########   ##  ##   ####  ##  ## ## ## ##     ## ##        ######  ## ## ## ##     ## ##  ##  ## 
##     ## ##   ##    ##  ##    ##   ##  ##  #### ######### ##             ## ##  #### ##     ## ##  ##  ## 
##     ## ##    ##   ##  ##    ##   ##  ##   ### ##     ## ##       ##    ## ##   ### ##     ## ##  ##  ## 
 #######  ##     ## ####  ######   #### ##    ## ##     ## ########  ######  ##    ##  #######   ###  ###








 

]]

SWEP.PrintName		        = "Entity Remover V2"
SWEP.Author		            = "初雪 OriginalSnow"
SWEP.Category		        = "OriginalSnow"
SWEP.Instructions	        = "Mouse1 - Shoot\nMouse2 - Change Shoot Mode\nR - Change Auto Shoot"

SWEP.Spawnable              = true
SWEP.AdminOnly              = true
SWEP.AdminSpawnable 		= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1

SWEP.Auto = 1

SWEP.Primary.Automatic		= true

SWEP.Primary.Ammo		    = "none"
SWEP.Unlimited              = 21474836470
SWEP.Primary.Force 	    	= SWEP.Unlimited
SWEP.Primary.Delay          = 0.01

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		    = "none"

SWEP.Slot		        	= 1
SWEP.SlotPos			    = 1
SWEP.DrawAmmo			    = false
SWEP.DrawCrosshair		    = true

SWEP.ViewModel              = Model( "models/weapons/c_smg1.mdl" )
SWEP.WorldModel             = Model( "models/weapons/w_smg1.mdl" )
SWEP.ViewModelFOV = 80
SWEP.UseHands				= true

SWEP.Damage = 99999999

SWEP.NextReload = 0.5

SWEP.RemoveMode = 1
SWEP.ShootMode = 1

A = {
    'weapons/airboat/airboat_gun_lastshot1.wav',
    'weapons/airboat/airboat_gun_lastshot2.wav',
}

local lastEntity = lastEntity or CurTime()

if CLIENT then
    surface.CreateFont("CInfo", {
	    font = "Tahoma",
	    size = 25,
	    weight = 600
    })
end

function SWEP:Reload()
    if ( self.NextReload > CurTime() ) then return end
	
    self.NextReload = CurTime() + 0.5

    if self.RemoveMode == 1 then
        self.RemoveMode = 0

        if CLIENT then
            self.Owner:PrintMessage(HUD_PRINTCENTER, 'Switched to Killer Mode')
        end
    else
        self.RemoveMode = 1

        if self.ShootMode == 3 then
            self.ShootMode = 1
        end

        if CLIENT then
            self.Owner:PrintMessage(HUD_PRINTCENTER, 'Switched to Remove Mode')
        end
    end
end

function SWEP:Think()
    local pos = self.Owner:GetPos()
	local tr = self.Owner:GetEyeTrace()

    self.Owner:SetHealth(self.Owner:GetMaxHealth())

    SetGlobalInt("E_A_N", self.RemoveMode)
    SetGlobalInt("E_B_N", self.ShootMode)
end

function SWEP:SecondaryAttack()

    if ( self.NextReload > CurTime() ) then return end
	
    self.NextReload = CurTime() + 0.5

    if self.ShootMode == 1 then

        self.ShootMode = 2
        self.Primary.Automatic = false

        if CLIENT then
            self.Owner:PrintMessage(HUD_PRINTCENTER, 'Semi-Automatic Mode')
        end

    elseif self.ShootMode == 2 and self.RemoveMode == 0 then

        self.ShootMode = 3

        self.Primary.Automatic = false

        if CLIENT then
            self.Owner:PrintMessage(HUD_PRINTCENTER, 'Shotgun Mode')
        end
        
    elseif self.ShootMode == 3 then
        self.Primary.Automatic = true

        self.ShootMode = 1

        if CLIENT then
            self.Owner:PrintMessage(HUD_PRINTCENTER, 'Full-Automatic Mode')
        end
    else
        self.Primary.Automatic = true

        self.ShootMode = 1

        if CLIENT then
            self.Owner:PrintMessage(HUD_PRINTCENTER, 'Full-Automatic Mode')
        end
    end

end

function SWEP:PrimaryAttack(ply)

    local ShootSound = Sound( table.Random(A) )

    local trace = {}
		trace.start = self.Owner:GetShootPos()

		trace.endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 20^14

        if self.ShootMode == 3 then
            local bullet = {}
		    bullet.Num = math.random(7, 10)
		    bullet.Src = self.Owner:GetShootPos()
		    bullet.Dir = self.Owner:GetAimVector()
		    bullet.Spread = Vector( 0.1 , 0.1 , 0)
		    bullet.Tracer = 1
            bullet.TracerName = "ToolTracer"
		    bullet.Force = self.Primary.Force
		    bullet.Damage = util.TraceLine(trace).Entity:Health()
		    bullet.AmmoType = self.Primary.Ammo

	        self:ShootEffects()
	        self.Owner:FireBullets( bullet )
        end

		trace.filter = self.Owner
	local tr = util.TraceLine(trace)

    if SERVER then

        if self.RemoveMode == 0 and tr.Entity:IsPlayer() then
            PrintMessage(HUD_PRINTCENTER, self.Owner:Name()..' killed '..tr.Entity:Name())
            local d = DamageInfo()

	        d:SetDamage( tr.Entity:Health() )
            d:SetAttacker( self.Owner )
            d:SetDamageType( DMG_DISSOLVE )

            tr.Entity:TakeDamageInfo( d )

            if tr.Entity:HasGodMode() then
                tr.Entity:Kill()
            end
        end

        if self.RemoveMode == 1 then

            local te = tr.Entity

            if te:GetClass() != 'worldspawn' then
                local d = DamageInfo()

	            d:SetDamage( tr.Entity:Health() )
                d:SetAttacker( self.Owner )
                d:SetDamageType( DMG_DISSOLVE )

                te:TakeDamageInfo( d )

                if te:IsNPC() then
                    te:SetHealth( 0 )
                    d:SetDamage( 1 )
                    te:TakeDamageInfo( d )
                    return
                end

                if te:IsPlayer() then
                    PrintMessage(HUD_PRINTCENTER, self.Owner:Name()..' killed '..te:Name())
                    d:SetDamage( tr.Entity:Health() )

                    if te:HasGodMode() then
                        te:Kill( d )
                    end

                end

                te:Remove()

            end

        end

    end

    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

    local effectdata = EffectData()
		effectdata:SetOrigin(self.Owner:GetEyeTrace().HitPos)
		effectdata:SetNormal(tr.HitNormal)
		effectdata:SetEntity(entity)
		effectdata:SetAttachment( 1 )

    if self.ShootMode ~= 3 then
        util.Effect('selection_indicator',effectdata)
    end

	local Kill = EffectData()
	    Kill:SetOrigin(self.Owner:GetEyeTrace().HitPos)
		Kill:SetStart(self.Owner:GetShootPos())
		Kill:SetAttachment(1)
		Kill:SetEntity(self)

    if self.ShootMode ~= 3 then
        util.Effect('ToolTracer',effectdata)
    end

    if self.RemoveMode == 1 then
        util.Effect("balloon_pop",effectdata)
    end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:EmitSound( ShootSound )

end

hook.Add( "HUDPaint", "EntityRemover_HUDPaint", function()
    local E_A_N = GetGlobalInt("E_A_N")
    local E_B_N = GetGlobalInt("E_B_N")
    local XML_A_N
    local XML_B_N
    
    if E_A_N == 1 then
        XML_A_N = "Remove Mode"
    elseif E_A_N == 0 then
        XML_A_N = "Killer Mode"
    else
        XML_A_N = "Error"
    end

    if E_B_N == 1 then
        XML_B_N = "Full-Automatic"
    elseif E_B_N == 2 then
        XML_B_N = "Semi-Automatic"
    elseif E_B_N == 3 then
        XML_B_N = "Shotgun"
    else
        XML_B_N = "Error"
    end

    local haswep_N = LocalPlayer():HasWeapon("entityremover")
    
    if haswep_N then
        local wep_N =  LocalPlayer():GetActiveWeapon():GetClass()

        if wep_N == "entityremover" then
            draw.SimpleTextOutlined( XML_A_N.." | "..XML_B_N, "CInfo", (ScrW() / 2) ,( ScrH() - 80) , Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, Color(0,0,0))
        end
    end

end)