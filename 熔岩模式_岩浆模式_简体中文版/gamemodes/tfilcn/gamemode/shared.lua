GM.Name = "熔岩逃生"
GM.Author = "圹夜Yasushi"
GM.Email = "i@teasmc.cn"
GM.Website = "https://bbs.teasmc.cn"

local acl = AddCSLuaFile
local inc = include
local sp = SortedPairs
local ff = file.Find
local string = string
local hook = hook

function IncludeDirectory(dir, cl, sv )
	cl, sv = cl or "cl_", sv or "sv_"
	local files, folders = ff(dir .. "/*", "LUA")

	for _, file in sp(files) do
		if hook.Call( "Lava.ShouldLoadFile", nil, dir, file ) == false then return end

		if string.StartWith( file, cl ) then
			acl( dir .. "/" .. file )
			if CLIENT then
				inc( dir .. "/" .. file )
			end
		elseif string.StartWith( file, sv ) then
			inc( dir .. "/" .. file )
		else
			acl( dir .. "/" .. file )
			inc( dir .. "/" .. file )
		end
	end

	for _, folder in sp(folders) do
		IncludeDirectory(dir .. "/" .. folder, cl, sv )
	end
end

IncludeDirectory("tfilcn/gamemode/libraries")
hook.Call("Lava.PostInitLibraryFiles")

IncludeDirectory("tfilcn/gamemode/core")
hook.Call("Lava.PostInitGamemodeFiles")

IncludeDirectory("tfilcn/gamemode/modules")
hook.Call("Lava.PostInitModuleFiles")