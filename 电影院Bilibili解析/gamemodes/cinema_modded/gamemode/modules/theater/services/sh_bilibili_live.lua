--[[
             Cinema Modded Bilibili Live Support
                   Powered by OriginalSnow

        You can edit this code.But you cant upload anymore.
]]

-- Last update : 2023/2/3

local SERVICE = {}

SERVICE.Name = "哔哩哔哩直播"
SERVICE.IsTimed = false
SERVICE.Dependency = DEPENDENCY_PARTIAL

local META_URL = "https://live.bilibili.com/%s"

function SERVICE:Match( url )
	return url.host:match("live.bilibili.com") and string.find( url.path, "/[%w*].")
end

if CLIENT then
    local PLAYURL = "https://live.bilibili.com/%s"

    function SERVICE:LoadProvider( vi, p )
        p:OpenURL( PLAYURL:format( vi:Data() ) )
    end
end

function SERVICE:GetURLInfo( url )
    local info = {}
    if url.host:match("live.bilibili.com") then
        info.Data = string.match(url.path,"[%w*]+")
    end
    return info.Data and info or false
end

function SERVICE:GetVideoInfo( ID , onSuccess, onFailure )
    local f = Format("https://api.live.bilibili.com/room/v1/Room/get_info?room_id=%s",ID)
    local info = {}

    local onReceive = function(b,l,h,c)
        http.Fetch(f,function(r,s)
            if s == 0 then
                return onFailure( "Theater_RequestFailed" )
            end

            local rT = util.JSONToTable(r)
            local data = rT.data

            if data.live_status ~= 1 then -- 禁止点播未开播直播间
                return onFailure( "Theater_RequestFailed" )
            end

            info.title = "直播："..data.title
            info.thumbnail = data.user_cover

            if onSuccess then
                pcall(onSuccess, info)
            end
        end)
    end

    local url = META_URL:format( ID )
    self:Fetch( url, onReceive, onFailure )
end
theater.RegisterService( "bilibili_live", SERVICE )