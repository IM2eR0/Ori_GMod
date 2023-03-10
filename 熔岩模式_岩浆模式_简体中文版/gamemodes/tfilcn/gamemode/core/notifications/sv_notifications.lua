local Notification = {}
local net = net
local ServerLog = ServerLog
local util = util
Notification.Presets = {}
util.AddNetworkString("lava_notification")
util.AddNetworkString("lava_chatalert")

function Notification.Create(Text, Table, Player)
	if hook.Call("Lava.NotificationDispatch", nil, Text, Table, Player) == false then return end
	ServerLog( Text .. "\n" )
	net.Start("lava_notification")
	net.WriteTable(Table)
	net.WriteString(Text)
	net.Send(IsValid( Player ) and Player or player.GetAll())
end

function Notification.SendType(Type, Text, Player)
	if hook.Call("Lava.NotificationDispatch", nil, Text, Notification.Presets[Type], Player) == false then return end
	ServerLog( Text .. "\n" )
	net.Start("lava_notification")
	net.WriteTable(Notification.Presets[Type])
	net.WriteString(Text)
	net.Send(IsValid( Player ) and Player or player.GetAll())
end

function Notification.ChatAlert( Text, Player )
	net.Start("lava_chatalert")
	net.WriteString( Text )
	net.Send(IsValid( Player ) and Player or player.GetAll())
end

function Notification.CreateType(TypeName, Data)
	Notification.Presets[TypeName] = Data
end

Notification.CreateType("General", {
	SOUND = "ambient/water/drip2.wav",
	TIME = 5,
	ICON = "1f31f"
})

Notification.CreateType("Join", {
	SOUND = "garrysmod/save_load4.wav",
	TIME = 6,
	ICON = "1f31d"
})

Notification.CreateType("Enter", {
	SOUND = "garrysmod/save_load1.wav",
	TIME = 6,
	ICON = "1f31e"
})

Notification.CreateType("Leave", {
	SOUND = "garrysmod/save_load2.wav",
	TIME = 6,
	ICON = "1f31a"
})

Notification.CreateType("Winner", {
	SOUND = "garrysmod/save_load3.wav",
	TIME = 10,
	ICON = "1f396"
})

Notification.CreateType("Mutator", {
	SOUND = "npc/scanner/scanner_siren1.wav",
	TIME = 10,
	ICON = "1f387"
})

Notification.CreateType("Chance", {
	SOUND = "garrysmod/save_load3.wav",
	TIME = 6,
	ICON = "1f3b2"
})

Notification.CreateType("AFK", {
	SOUND = "plats/elevbell1.wav",
	TIME = 9,
	ICON = "1f4a4"
})

Notification.CreateType("AFKBack", {
	SOUND = "plats/elevbell1.wav",
	TIME = 9,
	ICON = "1f440"
})

gameevent.Listen("player_connect")
gameevent.Listen("player_disconnect")

hook.Add("player_connect", "JoinNotif", function(data)
	Notification.SendType("Join", data.name .. " ??????????????????")
end)

hook.Add("player_disconnect", "JoinNotif", function(data)
	Notification.SendType("Leave", data.name .. " ?????????????????? ( " .. data.reason .. " )")
end)

hook.Add("PlayerInitialSpawn", "EnteredServer", function(Player)
	Notification.SendType("Enter", Player:Nick() .. " ???????????????")
end)

_G.Notification = Notification