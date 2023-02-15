--models/props_phx/games/chess/white_queen.mdl, models/props_combine/portalball001_sheet
hook.Add("HUDPaint", "DrawJiffy", function()
	if LocalPlayer():HasAbility("时空猎手(误)") and LocalPlayer():Alive() then
		if LocalPlayer():KeyDown(IN_SPEED) then
			if not IsValid(JiffyPointer) then
				JiffyPointer = ClientsideModel("models/props_phx/games/chess/white_queen.mdl")
				JiffyPointer:SetMaterial("models/props_combine/portalball001_sheet")
			end

			JiffyPointer:SetNoDraw(false)

			local tR = util.TraceLine{
				start = LocalPlayer():EyePos(),
				mask = MASK_ALL,
				endpos = LocalPlayer():EyePos() + LocalPlayer():GetAimVector() * 200,
				filter = LocalPlayer()
			}

			local tR2 = util.TraceHull{
				start = tR.HitPos,
				mask = MASK_ALL,
				endpos = tR.HitPos + Vector(0, 0, 64),
				mins = Vector(-16, -16, 1),
				maxs = Vector(16, 16, 71)
			}

			if tR2.Hit or LocalPlayer():GetMoveType() == 9 then
				JiffyPointer:SetColor(Color(255, 0, 0))
			else
				JiffyPointer:SetColor(Color(0, 255, 0))
			end

			JiffyPointer:SetPos(tR.HitPos)
		elseif IsValid(JiffyPointer) then
			JiffyPointer:SetNoDraw(true)
		end

		if LocalPlayer():GetAbilityMeter() ~= 100 then
			draw.WebImage(Emoji.Get("1f4a5"), ScrW() / 2, ScrH() - ScrH() / 5, ScrH() / 6, ScrH() / 6, pColor():Alpha(150), 0)
			draw.WebImage(Emoji.Get("1f4a5"), ScrW() / 2, ScrH() - ScrH() / 5, (LocalPlayer():GetAbilityMeter() / 100) * ScrH() / 6, (LocalPlayer():GetAbilityMeter() / 100) * ScrH() / 6, nil, 0)
		end
	elseif IsValid(JiffyPointer) then
		JiffyPointer:Remove()
		JiffyPointer = nil
	end
end)


hook.Add("Lava.ShouldDrawCrosshair", "JiffyJerry", function( Player )
	if Player:Alive() and Player:HasAbility("时空猎手(误)") and Player:KeyDown( IN_SPEED ) then
		return false
	end
end)

hook.Add("SetupMove", "JiffyJerry", function(Player, Movedata)
	if Player:HasAbility("时空猎手(误)") then
		Player:UpdateAbilityMeter()
		if not Player:Alive() then return end
		if Movedata:KeyDown(IN_SPEED) and Player:KeyPressedNoSpam(IN_RELOAD, Movedata) and Player:CanUseAbility() and Player:GetAbilityMeter() == 100 then
			local tR = util.TraceLine{
				start = Player:EyePos(),
				mask = MASK_ALL,
				endpos = Player:EyePos() + Player:GetAimVector() * 200,
				filter = Player
			}

			local tR2 = util.TraceHull{
				start = tR.HitPos,
				mask = MASK_ALL,
				endpos = tR.HitPos + Vector(0, 0, 64),
				mins = Vector(-16, -16, 1),
				maxs = Vector(16, 16, 71)
			}

			if not tR2.Hit and Player:GetMoveType() ~= 9 then
				Player:EmitSound("vo/npc/Barney/ba_ohyeah.wav")
				Player:ShiftAbilityMeter(-100)
				Movedata:SetOrigin(tR.HitPos)
			end
		else
			Player:ShiftAbilityMeter(FrameTime() * 30)
		end
	end
end)

Abilities.Register("时空猎手(误)", [[你拥有隐身与瞬移的技能！ 按住 SHIFT + R 进行传送！]], "1f31f")