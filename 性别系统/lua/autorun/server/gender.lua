util.AddNetworkString("OriginalSnow:GenderSeletor")
util.AddNetworkString("OriGender:male")
util.AddNetworkString("OriGender:female")
util.AddNetworkString("OriGender:none")
util.AddNetworkString("OriGender:Sync")

local OriginalSnow = OriginalSnow or {}

function OriginalSnow.SQLQuery(query, callBack)
    local SQLQuery = sql.Query(query) or {}
    if callBack then
        callBack(SQLQuery)
    end
end

hook.Add("Initialize", "OriGenderSeletor:Initialize", function()
    OriginalSnow.SQLQuery("CREATE TABLE IF NOT EXISTS OriGender(steam_id TEXT, Gender TEXT Default '未选择')")
end)

function GenderSync(table, ply)
    net.Start("OriGender:Sync")
    net.WriteTable(table)
    net.Send(ply)
end

hook.Add("PlayerInitialSpawn", "OriGenderSeletor:PlayerInitialSpawn", function(ply)
    if not IsValid(ply) or not ply:IsPlayer() then
        return
    end
    if not istable(ply.Gender_Info) then
        ply.Gender_Info = {}
    end

    OriginalSnow.SQLQuery("SELECT * FROM OriGender WHERE steam_id = '" .. ply:SteamID() .. "'", function(tbl)
        if #tbl == 0 then
            OriginalSnow.SQLQuery("INSERT INTO OriGender (steam_id) VALUES ('" .. ply:SteamID() .. "')")
            ply.Gender_Info["i"] = '未选择'
            ply:SetNWString("性别","未选择")
            net.Start("OriginalSnow:GenderSeletor")
            net.Send(ply)
        else
            if tbl[1].Gender == '未选择' then
                ply.Gender_Info["i"] = '未选择'
                ply:SetNWString("性别","未选择")
                net.Start("OriginalSnow:GenderSeletor")
                net.Send(ply)
            else
                ply.Gender_Info["i"] = tbl[1].Gender
                ply:SetNWString("性别",tbl[1].Gender)
            end
        end
    end)
    GenderSync(ply.Gender_Info, ply)
end)
net.Receive("OriGender:male",function(len,ply)
    ply:SendLua("chat.AddText('喵喵~ 你的性别已经被设置为了 ',Color(124, 226, 255),'男孩子',Color(255,255,255),' 哦！')")
    ply.Gender_Info["i"] = "男孩子"
	ply:SetNWString("性别","男孩子")
    OriginalSnow.SQLQuery("UPDATE OriGender SET Gender = '男孩子' WHERE steam_id = '" .. ply:SteamID() .. "'")
    GenderSync(ply.Gender_Info, ply)
end)

net.Receive("OriGender:female",function(len,ply)
    ply:SendLua("chat.AddText('喵喵~ 你的性别已经被设置为了 ',Color(255, 124, 207),'女孩子',Color(255,255,255),' 哦！')")
    ply.Gender_Info["i"] = "女孩子"
	ply:SetNWString("性别","女孩子")
    OriginalSnow.SQLQuery("UPDATE OriGender SET Gender = '女孩子' WHERE steam_id = '" .. ply:SteamID() .. "'")
    GenderSync(ply.Gender_Info, ply)
end)

net.Receive("OriGender:none",function(len,ply)
    ply:SendLua("chat.AddText('喵喵~ 没关系，我下次再问你~ ')")
end)

local PlyMeta = FindMetaTable("Player")

function PlyMeta:GetGender()
    return self.Gender_Info["i"]
end

function PlyMeta:GetGenderColor()
    if self.Gender_Info["i"] == "男孩子" then
        return Color(124, 226, 255)
    end
    if self.Gender_Info["i"] == "女孩子" then
        return Color(255, 124, 207)
    end
    if self.Gender_Info["i"] == "未选择" then
        return Color(255,255,255)
    end
end

hook.Add("PlayerSay","初雪预留的测试接口_重新打开性别设置面板",function(ply,args)
    if ply:SteamID() == "STEAM_0:1:161319794" and args == "1" then
        net.Start("OriginalSnow:GenderSeletor")
        net.Send(ply)
        return ""
    end
	
	if args == "选择性别" then
		if ply.Gender_Info["i"] == "未选择" then
			net.Start("OriginalSnow:GenderSeletor")
			net.Send(ply)
			return ""
		else
			ply:SendLua("chat.AddText('你已经选择过了哦~')")
			return ""
		end
	end
end)

MsgC(Color(255, 0, 0),"呜喵~ 性别插件已经载入了喵~\n")