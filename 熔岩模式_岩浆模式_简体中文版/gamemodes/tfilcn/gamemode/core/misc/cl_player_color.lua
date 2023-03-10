CreateClientConVar( "lava_player_color", "random", true, true )

local function PlayerColorPanel()
	local CurrentColor = table.Copy( pColor() )
	local Panel = InitializePanel( "LavaColorSelector", "DPanel" )
	Panel:SetSize( ScrW() / 7, ScrH() / 3 )
	Panel:Center()
	Panel.Paint = function( self, w, h )
		draw.Rect( 0, 0, w, h, CurrentColor )
	end

	local c = Panel:Add( "DColorMixer" )
	c:Dock( FILL )
	c:DockMargin( ScrH() / 100, ScrH() / 100, ScrH() / 100, ScrH() / 100 )
	c:SetAlphaBar( false )
	c.ValueChanged = function( self )
		CurrentColor = CurrentColor:CopyFrom( self:GetColor() )
	end

	local db = Panel:Add( "DLabel" )
	db:Dock( BOTTOM )
	db:SetText( "保存" )
	db:SetMouseInputEnabled( true )
	db:SetFont( "lava_color_picker_text" )
	db:SetContentAlignment( 5 )
	db:DockMargin( ScrH() / 100, 0, ScrH() / 100, ScrH() / 100 )
	db.Paint = function( self, w, h )
		draw.Rect( 0, 0, w, h, self.Hovered and CurrentColor + 50 or CurrentColor - 50 )
	end
	db.DoClick = function( self )
		GetConVar( "lava_player_color" ):SetString( CurrentColor.r .. "_" .. CurrentColor.g .. "_" .. CurrentColor.b )
		Panel:Remove()
	end


	local db = Panel:Add( "DLabel" )
	db:Dock( BOTTOM )
	db:SetText( "在复活时随机选择" )
	db:SetMouseInputEnabled( true )
	db:SetFont( "lava_color_picker_text" )
	db:SetContentAlignment( 5 )
	db:DockMargin( ScrH() / 100, 0, ScrH() / 100, ScrH() / 100 )
	db.Paint = function( self, w, h )
		draw.Rect( 0, 0, w, h, self.Hovered and CurrentColor + 50 or CurrentColor - 50 )
	end

	db.DoClick = function( self )
		GetConVar( "lava_player_color" ):SetString( "random" )
		Panel:Remove()
	end

	return Panel
end


hook.Add("Lava.PopulateWidgetMenu", "AddColorWidget", function( Context )
	Context.NewWidget( "更改玩家配色", "1f3a8", PlayerColorPanel )
end)
