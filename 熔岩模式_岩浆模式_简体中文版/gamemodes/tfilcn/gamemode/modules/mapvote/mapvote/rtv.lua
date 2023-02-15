RTV = RTV or {}
RTV.ChatCommands = {"!rtv", "/rtv", "rtv", ".rtv"}
RTV.TotalVotes = 0
RTV.Wait = 60 -- The wait time in seconds. This is how long a player has to wait before voting when the map changes. 
RTV._ActualWait = CurTime() + RTV.Wait
RTV.PlayerCount = MapVote.Config.RTVPlayerCount or 3

function RTV.ShouldChange()
	return RTV.TotalVotes >= math.Round(#player.GetAll() * 0.66)
end

function RTV.RemoveVote()
	RTV.TotalVotes = math.Clamp(RTV.TotalVotes - 1, 0, math.huge)
end

function RTV.Start()
	if GAMEMODE_NAME == "terrortown" then
		net.Start("RTV_Delay")
		net.Broadcast()

		hook.Add("TTTEndRound", "MapvoteDelayed", function()
			MapVote.Start(nil, nil, nil, nil)
		end)
	elseif GAMEMODE_NAME == "deathrun" then
		net.Start("RTV_Delay")
		net.Broadcast()

		hook.Add("RoundEnd", "MapvoteDelayed", function()
			MapVote.Start(nil, nil, nil, nil)
		end)
	else
		Notification.ChatAlert("投票换图已被唤起，即将开始投票")

		timer.Simple(4, function()
			MapVote.Start(nil, nil, nil, nil)
		end)
	end
end

function RTV.AddVote(ply)
	if RTV.CanVote(ply) then
		RTV.TotalVotes = RTV.TotalVotes + 1
		ply.RTVoted = true
		MsgN(ply:Nick() .. " 想要进行滚动投票.")
		Notification.ChatAlert(ply:Nick() .. " has voted to Rock the Vote. (" .. RTV.TotalVotes .. "/" .. math.Round(#player.GetAll() * 0.66) .. ")")

		if RTV.ShouldChange() then
			RTV.Start()
		end
	end
end

hook.Add("PlayerDisconnected", "Remove RTV", function(ply)
	if ply.RTVoted then
		RTV.RemoveVote()
	end

	timer.Simple(0.1, function()
		if RTV.ShouldChange() then
			RTV.Start()
		end
	end)
end)

function RTV.CanVote(ply)
	local plyCount = table.Count(player.GetAll())
	if RTV._ActualWait >= CurTime() then return false, "慢点! 你现在还不能滚动投票" end
	if GetGlobalBool("In_Voting") then return false, "滚动投票正在进行中!" end
	if ply.RTVoted then return false, "你已经申请过滚动投票了!" end
	if RTV.ChangingMaps then return false, "已经有滚动投票显示了，即将切换地图" end
	if plyCount < RTV.PlayerCount then return false, "啊哦，人好像不太够啊!" end

	return true
end

function RTV.StartVote(ply)
	local can, err = RTV.CanVote(ply)

	if not can then
		Notification.ChatAlert(err, ply)

		return
	end

	RTV.AddVote(ply)
end

concommand.Add("rtv_start", RTV.StartVote)

hook.Add("PlayerSay", "RTV Chat Commands", function(ply, text)
	if table.HasValue(RTV.ChatCommands, string.lower(text)) then
		RTV.StartVote(ply)

		return ""
	end
end)