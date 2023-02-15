local draw = draw
local sCol = Color( 0, 141, 255 )
local pColor = pColor
local m_ShouldDrawHelperScreen
local NextHelperPress = CurTime()
local tab = {
	["$pp_colour_colour"] = 0,
	["$pp_colour_contrast"] = 0.5,
}

hook.Add( "HUDPaint", "CheckHelper", function()
	if LocalPlayer():Alive() then
		if not cookie.GetString("$lava.helperscreen") then
			m_ShouldDrawHelperScreen = true
			cookie.Set("$lava.helperscreen", "FAAAAT")
		end
		hook.Remove( "HUDPaint", "CheckHelper" )
	end
end)

hook.Add("RenderScreenspaceEffects", "Helpscreen", function()
	if not m_ShouldDrawHelperScreen or not LocalPlayer():Alive() then return end

	DrawColorModify( tab )
end)

hook.Add("PostRenderVGUI", "DrawHelperscreen", function()
	if not m_ShouldDrawHelperScreen or not LocalPlayer():Alive() then return end

	draw.WebImage( Emoji.Get( "2753" ), ScrW()/2 + ScrH()/40, ScrH() * 0.125, ScrH()/15, ScrH()/15, nil, ( CurTime() * 5 ):sin() * -15 )
	draw.WebImage( Emoji.Get( "2754" ), ScrW()/2 - ScrH()/40, ScrH() * 0.125, ScrH()/15, ScrH()/15, nil, ( CurTime() * 5 ):sin() * 15 )
	draw.SimpleText( "帮助界面", "lava_help_title", ScrW()/2, ScrH() * 0.2, sCol + 50, 1, 1 )
	draw.SimpleText( "你可以通过按下 F2 来关闭此界面，当然再按一下还能打开.", "lava_help_title_sub", ScrW()/2, ScrH() * 0.35, sCol, 1, 1 )

	draw.SimpleText( "<<< 你的能力 (按住C键更改能力)", "lava_help_title_subsub", ScrW()/4.9, ScrH() * 0.91, sCol, 0, 1 )

	draw.SimpleText( "你的蛋蛋数量 >>>", "lava_help_title_subsub", ScrW()*0.87, ScrH() * 0.91, sCol, 2, 1 )
	draw.SimpleText( "把蛋蛋扔到别人脸上，可以临时弄瞎他.", "lava_help_title_subsub", ScrW()*0.83, ScrH() * 0.94, sCol, 2, 1 )
	draw.SimpleText( "当你成功把蛋蛋扔到别人脸上后会获得额外鸡蛋.", "lava_help_title_subsub", ScrW()*0.83, ScrH() * 0.97, sCol, 2, 1 )

	draw.SimpleText( "当前回合时间. >>>", "lava_help_title_subsub", ScrW() * 0.87, ScrH()/10, sCol, 2)
	draw.SimpleText( "这不是钟，别看错了.", "lava_help_title_subsub", ScrW() * 0.86, ScrH()/10 + ScrH()/40, sCol, 2)

	draw.SimpleText( "当前回合状态. >>>", "lava_help_title_subsub", ScrW() * 0.87, ScrH()/4 - ScrH()/60, sCol, 2)


	draw.SimpleText( "<<< 你距离熔岩的高度(米)", "lava_help_title_subsub", ScrW()/7, ScrH() * 0.72, sCol, 0, 1 )


	draw.SimpleText( "<<< 你的排名(相对其他玩家距离熔岩的高度).", "lava_help_title_subsub", ScrW()/5.5, ScrH() * 0.79, sCol, 0, 1 )


	draw.SimpleText( "你的血量", "lava_help_title_subsub", ScrW()/50, ScrH() * 0.63, sCol, 0, 1 )
	draw.SimpleText( "vvv", "lava_help_title_subsub", ScrW()/47, ScrH() * 0.655, sCol, 0, 1 )


	draw.SimpleText( "<<< 按住C打开一些菜单.", "lava_help_title_subsub", ScrW()/10, ScrH()/8, sCol, 0, 1 )

	draw.SimpleText( "按住 Q 进入 EmojiSense 模式.", "lava_help_title_subsub", ScrW()*0.98, ScrH()/2, sCol, 2, 1 )
	draw.SimpleText( "可以用 +zoom (默认B键) 来进行高级缩放.", "lava_help_title_subsub", ScrW()*0.98, ScrH()*0.53, sCol, 2, 1 )
end)

hook.Add("Think", "HelperScreen",function()
	if input.IsKeyDown( KEY_F2 ) and NextHelperPress < CurTime() then
		NextHelperPress = CurTime() + 0.25
		m_ShouldDrawHelperScreen = not m_ShouldDrawHelperScreen
	end
end)