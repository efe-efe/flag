function OnStartTouchRadiant(trigger)
	local hero_index = trigger.activator:GetEntityIndex()
    local hero = EntIndexToHScript(hero_index)
    
    if hero:GetTeam() == DOTA_TEAM_BADGUYS then
        hero:AddNewModifier(hero, nil, "modifier_enemy_base", {})
    end
end

function OnEndTouchRadiant(trigger)
    local hero_index = trigger.activator:GetEntityIndex()
    local hero = EntIndexToHScript(hero_index)
    
    if hero:GetTeam() == DOTA_TEAM_BADGUYS then
        hero:RemoveModifierByName("modifier_enemy_base")
    end
end

function OnStartTouchDire(trigger)
	local hero_index = trigger.activator:GetEntityIndex()
    local hero = EntIndexToHScript(hero_index)
    
    if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
        hero:AddNewModifier(hero, nil, "modifier_enemy_base", {})
    end
end
function OnEndTouchDire(trigger)
    local hero_index = trigger.activator:GetEntityIndex()
    local hero = EntIndexToHScript(hero_index)
    
    if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
        hero:RemoveModifierByName("modifier_enemy_base")
    end
end