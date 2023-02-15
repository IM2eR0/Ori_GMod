util.AddNetworkString( "lava_unstuck" )
local Values = Values

hook.Add("Lava.FullTick", "CachePlayerPositions", function()
	for Player in Values( player.GetAll() ) do
		local Stuck = Player:CheckHullCollision()
		if not Stuck then
			Player.m_LastValidPosition = Player:GetPos()
		elseif Player:GetMoveType() ~= 8 and Player:Alive() and Stuck then
			Player:SetPos( Player.m_LastValidPosition )
		end
	end
end)

net.Receive( "lava_unstuck", function( _, Player )
	Player.m_NextUnstuckTime = Player.m_NextUnstuckTime or CurTime()

	if Player.m_NextUnstuckTime > CurTime() then
		Notification.ChatAlert( "请稍等片刻再尝试使用解除卡住. ", Player )
	else
		if Player:GetVelocity():Length2D() > 1 then
			return Notification.ChatAlert( "停下!.", Player  )
		end
		if not Player:CheckHullCollision() then
			return Notification.ChatAlert( "你没卡住哦.", Player )
		end

		Player.m_NextUnstuckTime = CurTime() + 30
		Player:SetPos( Player.m_LastValidPosition )
	end
end)