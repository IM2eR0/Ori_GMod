_ServerName = "Air度假休闲"

surface.CreateFont("_ORITEXT1", {
	font = "Tahoma",
	size = 40,
	weight = 550
})

surface.CreateFont("_ORITEXT2", {
	font = "Tahoma",
	size = 80,
	weight = 550
})

surface.CreateFont("_ORITEXT3", {
	font = "Tahoma",
	size = 60,
	weight = 550
})

net.Receive("OriginalSnow:GenderSeletor",function(len,ply)
    if not frame then
        local _h2 = 250
        local G = LocalPlayer():GetNWString("性别","未选择")

        if G ~= "未选择" then
            _h2 = 300
        end

        local frame = vgui.Create("DFrame")
        frame:SetSize(700,600)
        frame:Center()
	    frame:SetVisible(true)
	    frame:SetTitle("")
	    frame:SetDraggable(false)
	    frame:MakePopup()
        frame:SetScreenLock(true)
        frame:ShowCloseButton(false)
        frame.Paint = function()
            surface.SetDrawColor(58, 58, 58, 200)
            surface.DrawRect(0, 0, frame:GetWide(), frame:GetTall())
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawOutlinedRect(0, 0, frame:GetWide(), frame:GetTall())
        end

        local label = vgui.Create ("DLabel", frame)
	    label:SetPos(20,20)
        label:SetSize(400, 80)
        label:SetTextColor(Color(255, 255, 255))
        label:SetFont("_ORITEXT1")
	    label:SetText("\t欢迎游玩 ".._ServerName.." ！")

        local label = vgui.Create ("DLabel", frame)
	    label:SetPos(20,60)
        label:SetSize(400, 80)
        label:SetTextColor(Color(255, 255, 255))
        label:SetFont("_ORITEXT1")
	    label:SetText("请在下方选择你的性别 ！")

        local label = vgui.Create ("DLabel", frame)
        label:SetPos(20,frame:GetTall()-60)
        label:SetSize(400,40)
        label:SetTextColor(Color(255, 0, 0))
        label:SetFont("_ORITEXT1")
        label:SetText("注意：一旦设置后无法修改")

        local button1 = vgui.Create("DButton", frame)
	    button1:SetText("男")
        button1:SetFont("_ORITEXT2")
	    button1:SetTextColor(Color(255, 255, 255))
	    button1:SetPos(40, frame:GetTall()/4 )
	    button1:SetSize(300, _h2)
	    button1.Paint = function(self, w, h)
		    draw.RoundedBox(5,0,0, w, h, Color(124, 226, 255)) 
	    end
	    button1.DoClick = function()
            net.Start("OriGender:male")
            net.SendToServer(len, ply)
            frame:Close()
	    end

        local button = vgui.Create("DButton", frame)
	    button:SetText("女")
        button:SetFont("_ORITEXT2")
	    button:SetTextColor(Color(255, 255, 255))
	    button:SetPos(frame:GetWide() /2, frame:GetTall()/4 )
	    button:SetSize(300, _h2)
	    button.Paint = function(self, w, h)
		    draw.RoundedBox(5,0,0, w, h, Color(255, 124, 207)) 
	    end
	    button.DoClick = function()
            net.Start("OriGender:female")
            net.SendToServer(len, ply)
            frame:Close()
	    end

        if G == "未选择" then
            local button = vgui.Create("DButton", frame)
	        button:SetText("暂不选择（不愿透露）")
            button:SetFont("_ORITEXT3")
	        button:SetTextColor(Color(255, 255, 255))
	        button:SetPos(40, frame:GetTall()/1.5 + 10)
	        button:SetSize(610, 100)
	        button.Paint = function(self, w, h)
		        draw.RoundedBox(5,0,0, w, h, Color(138, 138, 138)) 
	        end
	        button.DoClick = function()
                net.Start("OriGender:none")
                net.SendToServer(len, ply)
                frame:Close()
	        end
        end

        local label = vgui.Create ("DLabel", frame)
	    label:SetPos(frame:GetWide() - 120 , frame:GetTall() - 60)
        label:SetSize(400, 80)
        label:SetTextColor(Color(255, 255, 255))
	    label:SetText("性别选择系统 v0.2\nBy 初雪 OriginalSnow")
    end
end)

net.Receive("OriGender:Sync",function()
    MyGender = net.ReadTable() or {}
end)

local PlyMeta = FindMetaTable("Player")
function PlyMeta:GetGender()
    return self:GetNWString("性别")
end
function PlyMeta:GetGenderColor()
    if self:GetNWString("性别") == "男孩子" then
        return Color(124, 226, 255)
    end
    if self:GetNWString("性别") == "女孩子" then
        return Color(255, 124, 207)
    end
    if self:GetNWString("性别") == "未选择" then
        return Color(255,255,255)
    end
end


MsgC(Color(255, 0, 0),"呜喵~ 性别插件已经载入了喵~\n")