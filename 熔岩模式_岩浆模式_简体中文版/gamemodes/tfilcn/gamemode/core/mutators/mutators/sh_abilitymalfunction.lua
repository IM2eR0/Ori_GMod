

local AddHook = Mutators.RegisterHooks("技能狂暴", {
	"Tick",
})
local m_NextCycleTime

Mutators.RegisterNewEvent("技能狂暴", "从现在开始！你会每30秒切换一次能力！", function()
	AddHook( function()
		if CLIENT then return end

		m_NextCycleTime = m_NextCycleTime or CurTime()

		if m_NextCycleTime <= CurTime() then
			for Player in Values( player.GetAll() ) do
				if not Player:Alive() then continue end
				local OldAbility = Player:GetAbility()
				if Abilities.Skills[ OldAbility ] and Abilities.Skills[ OldAbility ][ 4 ] then
					Abilities.Skills[ OldAbility ][ 4 ]( Player )
				end

				repeat
					Player:SetAbility( table.Random( table.GetKeys( Abilities.Skills ) ) )
				until OldAbility ~= Player:GetAbility() and Player:GetAbility() ~= "Limpy Larry"

				if Abilities.Skills[ Player:GetAbility() ] and Abilities.Skills[ Player:GetAbility() ][ 3 ] then
					Abilities.Skills[ Player:GetAbility() ][ 3 ]( Player )
				end

				Notification.ChatAlert( "你的新能力是 " .. Player:GetAbility() .. "!", Player )
			end
			m_NextCycleTime = CurTime() + 30
		end
	end )
end,
function()
	m_NextCycleTime = nil
end)