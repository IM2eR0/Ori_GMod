

hook.Add("GetFallDamage", "AvoidFallDamageHH", function(Player, Speed )
	if Player:HasAbility("青蛙") then
		if not Player:Crouching() then
			Player:SetVelocity( ( Player:GetAimVector() * 0.35 ):SetZ( 1.5 ) * ( Speed*0.75 ) )
		end
		return ( CalculateBaseFallDamage( Speed ) * 0.75 ):min( 5 )
	end
end)

Abilities.Register("青蛙", [[你的脚底下好像有个蹦床，
    你跳下来的高度越高，你反弹的高度也越高，
    而且你好像有那个大病，你停不下来。
	除非你在落地前保持蹲下，
	好在你最多只能摔落5点血量]], "1f438" )

