surface.CreateFont("RAM_VoteFont", {
	font = "Trebuchet MS",
	size = ScrH() / 30,
	weight = 700,
	antialias = true,
	shadow = true
})

surface.CreateFont("RAM_VoteFontCountdown", {
	font = "Tahoma",
	size = 32,
	weight = 700,
	antialias = true,
	shadow = true
})

surface.CreateFont("RAM_VoteSysButton", {
	font = "Marlett",
	size = 13,
	weight = 0,
	symbol = true
})

MapVote.EndTime = 0
MapVote.Panel = false
local MapLink = "https://image.gametracker.com/images/maps/160x120/garrysmod/${1}.jpg"

net.Receive("RAM_MapVoteStart", function()
	MapVote.CurrentMaps = {}
	MapVote.Allow = true
	MapVote.Votes = {}
	local amt = net.ReadUInt(32)

	for i = 1, amt do
		local map = net.ReadString()
		MapVote.CurrentMaps[#MapVote.CurrentMaps + 1] = map
	end

	MapVote.EndTime = CurTime() + net.ReadUInt(32)

	if (IsValid(MapVote.Panel)) then
		MapVote.Panel:Remove()
	end

	MapVote.Panel = vgui.Create("RAM_VoteScreen")
	MapVote.Panel:SetMaps(MapVote.CurrentMaps)
end)

net.Receive("RAM_MapVoteUpdate", function()
	local update_type = net.ReadUInt(3)

	if (update_type == MapVote.UPDATE_VOTE) then
		local ply = net.ReadEntity()

		if (IsValid(ply)) then
			local map_id = net.ReadUInt(32)
			MapVote.Votes[ply:SteamID()] = map_id

			if (IsValid(MapVote.Panel)) then
				MapVote.Panel:AddVoter(ply)
			end
		end
	elseif (update_type == MapVote.UPDATE_WIN) then
		if (IsValid(MapVote.Panel)) then
			MapVote.Panel:Flash(net.ReadUInt(32))
		end
	end
end)

net.Receive("RAM_MapVoteCancel", function()
	if IsValid(MapVote.Panel) then
		MapVote.Panel:Remove()
	end
end)

net.Receive("RTV_Delay", function()
	chat.AddText(Color(102, 255, 51), "[ 信息 ]", Color(255, 255, 255), "滚动投票已显示！即将切换地图")
end)

local PANEL = {}

function PANEL:Init()
	self:ParentToHUD()
	self.Canvas = vgui.Create("Panel", self)
	self.Canvas:MakePopup()
	self.Canvas:SetKeyboardInputEnabled(false)
	self.countDown = vgui.Create("DLabel", self.Canvas)
	self.countDown:SetTextColor(color_white)
	self.countDown:SetFont("RAM_VoteFontCountdown")
	self.countDown:SetText("")
	self.countDown:SetPos(0, 14)
	self.mapList = vgui.Create("DPanelList", self.Canvas)
	self.mapList:SetDrawBackground(false)
	self.mapList:SetSpacing(4)
	self.mapList:SetPadding(4)
	self.mapList:EnableHorizontal(true)
	self.mapList:EnableVerticalScrollbar()
	self.Voters = {}
end

function PANEL:PerformLayout()
	local cx, cy = chat.GetChatBoxPos()
	self:SetPos(0, 0)
	self:SetSize(ScrW(), ScrH())
	local extra = math.Clamp(300, 0, ScrW() - 640)
	self.Canvas:StretchToParent(0, 0, 0, 0)
	self.Canvas:SetWide(640 + extra)
	self.Canvas:SetTall(ScrH() * 0.8)
	self.Canvas:SetPos(0, 0)
	self.Canvas:CenterHorizontal()
	self.Canvas:SetZPos(0)
	self.mapList:StretchToParent(0, 90, 0, 0)
	local buttonPos = 640 + extra - 31 * 3
end

local star_mat = Material("icon16/star.png")

function PANEL:AddVoter(voter)
	for k, v in pairs(self.Voters) do
		if (v.Player and v.Player == voter) then return false end
	end

	local icon_container = vgui.Create("Panel", self.mapList:GetCanvas())
	local icon = vgui.Create("AvatarImage", icon_container)
	icon:SetSize(16, 16)
	icon:SetZPos(1000)
	icon:SetTooltip(voter:Name())
	icon_container.Player = voter
	icon_container:SetTooltip(voter:Name())
	icon:SetPlayer(voter, 16)

	if MapVote.HasExtraVotePower(voter) then
		icon_container:SetSize(40, 20)
		icon:SetPos(21, 2)
		icon_container.img = star_mat
	else
		icon_container:SetSize(20, 20)
		icon:SetPos(2, 2)
	end

	icon_container.Paint = function(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, s.Player:PlayerColor())

		if (icon_container.img) then
			surface.SetMaterial(icon_container.img)
			surface.SetDrawColor(Color(255, 255, 255))
			surface.DrawTexturedRect(2, 2, 16, 16)
		end
	end

	table.insert(self.Voters, icon_container)
end

function PANEL:Think()
	for k, v in pairs(self.mapList:GetItems()) do
		v.NumVotes = 0
	end

	for k, v in pairs(self.Voters) do
		if (not IsValid(v.Player)) then
			v:Remove()
		else
			if (not MapVote.Votes[v.Player:SteamID()]) then
				v:Remove()
			else
				local bar = self:GetMapButton(MapVote.Votes[v.Player:SteamID()])

				if (MapVote.HasExtraVotePower(v.Player)) then
					bar.NumVotes = bar.NumVotes + 2
				else
					bar.NumVotes = bar.NumVotes + 1
				end

				if (IsValid(bar)) then
					local CurrentPos = Vector(v.x, v.y, 0)
					local NewPos = Vector((bar.x + bar:GetWide()) - 21 * bar.NumVotes - 2, bar.y + (bar:GetTall() * 0.5 - 10), 0)

					if (not v.CurPos or v.CurPos ~= NewPos) then
						v:MoveTo(NewPos.x, NewPos.y, 0.3)
						v.CurPos = NewPos
					end
				end
			end
		end
	end

	local timeLeft = math.Round(math.Clamp(MapVote.EndTime - CurTime(), 0, math.huge))
	self.countDown:SetText(tostring(timeLeft or 0) .. " 秒")
	self.countDown:SizeToContents()
	self.countDown:CenterHorizontal()
end

function PANEL:SetMaps(maps)
	self.mapList:Clear()

	for k, v in RandomPairs(maps) do
		local url = MapLink:fill(v)
		local button = vgui.Create("DButton", self.mapList)
		button.ID = k
		button:SetText(v)

		button.DoClick = function()
			net.Start("RAM_MapVoteUpdate")
			net.WriteUInt(MapVote.UPDATE_VOTE, 3)
			net.WriteUInt(button.ID, 32)
			net.SendToServer()
		end

		do
			local Paint = button.Paint
			local t = button:GenerateColorShift("sma", pColor():Alpha(50) - 50, pColor():Alpha(150) - 25, 128)

			button.Paint = function(s, w, h)
				t[1], t[2] = pColor():Alpha(50) - 50, pColor():Alpha(150) - 25
				draw.RoundedBox(4, 0, 0, w, h, s.Selected and Color(255, 0, 0) or s.sma)
				Paint(s, w, h)
			end

			local t = button:Add("DCirclePanel")
			t:Dock(LEFT)

			t.PaintOver = function(s, w, h)
				s:SetWide(h)
				s.PaintOver = nil
			end

			t.PaintCircle = function(s, w, h)
				if draw.fetch_asset(url):GetName():EndsWith("error") then
					draw.WebImage("https://s1.ax1x.com/2023/02/14/pSTJup8.png", w / 2, h / 2, w, h, nil, button.Hovered and CurTime():sin() * -15 or 0)
				else
					draw.WebImage(url, w / 2, h / 2, w, h, nil, button.Hovered and CurTime():sin() * -15 or 0)
				end

				draw.WebImage(button.Hovered and WebElements.QuadCircle or WebElements.CircleOutline, w / 2, h / 2, w + 2, h + 2, button.sma:Alpha(255), button.Hovered and CurTime():sin() * 720 or 0)
			end
		end

		button:SetTextColor(color_white)
		button:SetContentAlignment(4)
		button:SetTextInset(ScrH() / 15 + WebElements.Edge * 2, 0)
		button:SetFont("RAM_VoteFont")
		local extra = math.Clamp(300, 0, ScrW() - 640)
		button:SetDrawBackground(false)
		button:SetTall(ScrH() / 15)
		button:SetWide(285 + (extra / 2))
		button.NumVotes = 0
		self.mapList:AddItem(button)
	end
end

function PANEL:GetMapButton(id)
	for k, v in pairs(self.mapList:GetItems()) do
		if (v.ID == id) then return v end
	end

	return false
end

function PANEL:Paint()
	--Derma_DrawBackgroundBlur(self)
	local CenterY = ScrH() / 2
	local CenterX = ScrW() / 2
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end

function PANEL:Flash(id)
	self:SetVisible(true)
	local bar = self:GetMapButton(id)

	if (IsValid(bar)) then
		timer.Simple(0.0, function()
			bar.bgColor = Color(0, 255, 255)
			surface.PlaySound("hl1/fvox/blip.wav")
		end)

		timer.Simple(0.2, function()
			bar.bgColor = nil
		end)

		timer.Simple(0.4, function()
			bar.bgColor = Color(0, 255, 255)
			surface.PlaySound("hl1/fvox/blip.wav")
		end)

		timer.Simple(0.6, function()
			bar.bgColor = nil
		end)

		timer.Simple(0.8, function()
			bar.bgColor = Color(0, 255, 255)
			surface.PlaySound("hl1/fvox/blip.wav")
		end)

		timer.Simple(1.0, function()
			bar.bgColor = Color(100, 100, 100)
		end)

		bar.Selected = true
	end
end

derma.DefineControl("RAM_VoteScreen", "", PANEL, "DPanel")