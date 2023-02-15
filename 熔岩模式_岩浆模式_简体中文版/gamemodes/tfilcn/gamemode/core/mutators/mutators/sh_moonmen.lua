Mutators.RegisterNewEvent("轻量化重力", "引力发生了异常，尽享低重力带来的快感吧！.", function()
	if SERVER then
		RunConsoleCommand("sv_gravity", 200 )
	end
end, function()
	if SERVER then
		RunConsoleCommand("sv_gravity", 600 )
	end
end)