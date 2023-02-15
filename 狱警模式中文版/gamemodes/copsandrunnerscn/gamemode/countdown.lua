local hud_countdown_config = {
    seconds     = GetConVar( "cnr_timelimit" ):GetInt(); -- How many seconds to count-down from
    started     = -1; -- holder var
    timebuffer  = GetConVar( "cnr_preptime" ):GetInt(); -- Delay the start by this many seconds after starting to allow time for networking
    font        = "Default"; -- Font to use
    text        = "%s 剩余时间!"; -- Formatted string for seconds remaining...
    text_color  = Color( 255, 255, 255, 255 ); -- Text Color
};


timer.Adjust( "Countdown", hud_countdown_config.seconds + hud_countdown_config.timebuffer, function( )
            hook.Call( "CountDownHasExpired", GAMEMODE );
	end );

function UpdateNewseconds()
if SERVER then
	hud_countdown_config.seconds = GetConVar( "cnr_timelimit" ):GetInt()
	hud_countdown_config.timebuffer = GetConVar( "cnr_preptime" ):GetInt()
	timer.Adjust( "Countdown", hud_countdown_config.seconds + hud_countdown_config.timebuffer, function( )
		hook.Call( "CountDownHasExpired", GAMEMODE );
	end );
	CountDownNetworkSeconds( hud_countdown_config.seconds );
end
end


-- Server stuff

if ( SERVER ) then

    -- Vars
    util.AddNetworkString( "CountDown" );
	util.AddNetworkString( "CountDownSeconds" );

    -- Networking 
    local function CountDownNetwork( _started, _p )
        -- Ready the net message
        net.Start( "CountDown" );
            -- Write the data as a string to avoid loss of precision
            net.WriteString( tostring( _started ) );

        -- Are we sending to one/several player( s ), or everyone?
        if ( _p && ( _p:IsPlayer( ) || istable( _p ) ) ) then
            net.Send( _p );
        else
            net.Broadcast( );
        end
    end
	
	function CountDownNetworkSeconds( _seconds, _p )
        -- Ready the net message
        net.Start( "CountDownSeconds" );
            -- Write the data as a string to avoid loss of precision
            net.WriteString( tostring( _seconds ) );

        -- Are we sending to one/several player( s ), or everyone?
        if ( _p && ( _p:IsPlayer( ) || istable( _p ) ) ) then
            net.Send( _p );
        else
            net.Broadcast( );
        end
    end

    -- This is the function that should be called to initiate the timer when the round restarts
    function CountDownStart( )
        -- Save the time started; useful for late joiners...
        hud_countdown_config.started = CurTime( ) + hud_countdown_config.timebuffer;

        -- Network the data
        CountDownNetwork( hud_countdown_config.started );

        -- Set a timer on the server so the server knows when the timer ends; the client will so why not the server?...
        timer.Start("Countdown")
    end

    -- Debugging - use this to force the timer to start
    --[[concommand.Add( "dev_display", function( _p, _cmd, _args )
        if ( !IsValid( _p ) || !_p:IsAdmin( ) ) then return; end
        CountDownStart( );
    end );]]

    -- Hooks
    hook.Add( "PlayerInitialSpawn", "CountDown:InitialSpawn", function( _p )
        -- Let the new-joiner in on the timer action
        CountDownNetwork( hud_countdown_config.started, _p );
    end );
else

    -- Receive the networked data
	
	net.Receive( "CountDownSeconds", function( _len )
        -- Log the start time
        hud_countdown_config.seconds = tonumber( net.ReadString( ) );
	end );
	
    net.Receive( "CountDown", function( _len )
        -- Log the start time
        hud_countdown_config.started = tonumber( net.ReadString( ) );

        -- Add the drawing hook
        hook.Add( "HUDPaint", "CountDown:HUDPaint", function( )
            -- Make sure the player IsValid
            local _p = LocalPlayer( );
            if ( !IsValid( _p ) ) then return; end

            -- Variables
            local _elapsed = math.Clamp( CurTime( ) - hud_countdown_config.started, 0, hud_countdown_config.seconds );
            local _remaining = math.Clamp( hud_countdown_config.seconds - _elapsed, 0, hud_countdown_config.seconds );
            local _percent = ( _elapsed / hud_countdown_config.seconds ) * 100;
            local _text = string.format( hud_countdown_config.text, tostring( math.Round( _remaining ) ) );
			_angle = (_percent * 3.6) * -1;

            -- Remove hook if over with.
            -- if ( _remaining <= 0 ) then -- Both logically sound...
            if ( _elapsed >= hud_countdown_config.seconds ) then
                -- This lets you make function GM:CountDownHasExpired( ) to draw something else, or whatever...
                hook.Call( "CountDownHasExpired", GAMEMODE );
                hook.Remove( "HUDPaint", "CountDown:HUDPaint" );
            end

        end );
    end );
end