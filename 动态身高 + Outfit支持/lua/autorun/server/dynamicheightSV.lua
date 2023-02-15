util.AddNetworkString("Ori:ViewCCHeiget")

net.Receive("Ori:ViewCCHeiget",function(len,ply)
    local i = net.ReadInt(32)
	local i2 = net.ReadInt(32)
    ply:SetViewOffset( Vector( 0, 0, i ) )
	ply:SetViewOffsetDucked(Vector(0, 0, i2))
end)
print("[初雪 OriginalSnow] 动态视角插件 SV 已加载！")