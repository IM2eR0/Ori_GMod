
hook.Add( "Lava.FistsSecondaryAttack", "AddEggz", function( Player, Weapon )
	if Player:HasAbility("鸡蛋法师") then
		Weapon:SetEggs( 4 )
	end
end)

hook.Add( "Lava.PlayerEggDispatched", "AddEggz", function( Player, Weapon, Egg )
	if Player:HasAbility("鸡蛋法师") then
		Egg:GetPhysicsObject():EnableGravity( false )
		return 1536
	end
end)

Abilities.Register("鸡蛋法师", [[你拥有无限的鸡蛋，并且你的鸡蛋拥有更大的力量
	但你奶奶的你从哪来的那么多鸡蛋???]], "1f921" )

