Mutators.RegisterNewEvent("巨变化重力", "引力发生了异常，所有人都跳不起来了.", function()
	if SERVER then
		RunConsoleCommand("sv_gravity", 2048 )
	end
end, function()
	if SERVER then
		RunConsoleCommand("sv_gravity", 600 )
	end
end)