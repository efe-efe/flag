function OnStartTouchRadiant(trigger)
	local hero_index = trigger.activator:GetEntityIndex()
    local hero = EntIndexToHScript(hero_index)
    
    if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
        hero:SetInDeliveryZone(true)
    end
end

function OnEndTouchRadiant(trigger)
    local hero_index = trigger.activator:GetEntityIndex()
    local hero = EntIndexToHScript(hero_index)
    
    if hero:GetTeam() == DOTA_TEAM_GOODGUYS then
        hero:SetInDeliveryZone(false)
    end
end

function OnStartTouchDire(trigger)
	local hero_index = trigger.activator:GetEntityIndex()
    local hero = EntIndexToHScript(hero_index)
    
    if hero:GetTeam() == DOTA_TEAM_BADGUYS then
        hero:SetInDeliveryZone(true)
    end
end
function OnEndTouchDire(trigger)
    local hero_index = trigger.activator:GetEntityIndex()
    local hero = EntIndexToHScript(hero_index)
    
    if hero:GetTeam() == DOTA_TEAM_BADGUYS then
        hero:SetInDeliveryZone(false)
    end
end