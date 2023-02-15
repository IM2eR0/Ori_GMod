local PLAYER = {}

PLAYER.DisplayName = "熔岩模式基础"
PLAYER.WalkSpeed = 175
PLAYER.RunSpeed = 225
PLAYER.CrouchedWalkSpeed = 0.2
PLAYER.JumpPower = 250
PLAYER.MaxHealth = 100
PLAYER.StartHealth = 100
PLAYER.TeammateNoCollide = false

function PLAYER:Spawn()
	self.Player:SetCanZoom( false )
end

player_manager.RegisterClass("lava_default", PLAYER, "player_default" )