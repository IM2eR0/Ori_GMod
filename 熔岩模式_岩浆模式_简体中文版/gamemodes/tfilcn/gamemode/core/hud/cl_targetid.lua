local WebElements = WebElements
local x = NULL
local bPos = Vector()
local cam = cam
local draw = draw

function GM:HUDDrawTargetID()
end

hook.Add("PostDrawTranslucentRenderables", "ThisThing", function()
	x = LocalPlayer():EyeEntity()

	if x:IsValid() and (x:IsPlayer() or x.m_Player) then
		x:OnBoneExisting("ValveBiped.Bip01_Head1", function(bid)
			bPos = x:GetBonePosition(bid) + Vector(0, 0, 15)
			x = x.m_Player or x

			cam.Wrap3D2D(function()
				local Wide, Tall = FontFunctions.GetSize(x:Nick(), "ChatFont")
				draw.RoundedBox(4, -Wide / 2 - Tall * 1.5 - Tall / 5, -Tall / 5, Tall * 1.5, Tall * 1.5, (x:PlayerColor() - 75))
				draw.RoundedBox(4, -Wide / 2 - Tall * 1.5, 0, Tall * 1.5, Tall * 1.5, (x:PlayerColor() - 50))
				draw.SimpleText(x:Nick(), "ChatFont", -Wide / 2 + Tall / 5, (Tall * 1.5) / 2, x:PlayerColor(), 0, 1)
				draw.WebImage(Emoji.Get(x:EmojiID()), -Wide / 2 - Tall * 1.5, 0, Tall * 1.5, Tall * 1.5)
			end, bPos - LocalPlayer():GetForward() * 5, Angle(0, 270 + EyeAngles().y, 90), 0.25)
		end)
	end
end)