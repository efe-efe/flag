Flag = Flag or class({}, nil, Item)

local FLAG_ITEM_NAMES = {
    [DOTA_TEAM_GOODGUYS] = "item_radiant_flag",
    [DOTA_TEAM_BADGUYS] = "item_dire_flag",
}

function Flag:constructor(team, origin, on_deliver)
    self.team = team
    self.base_origin = origin
    self.state = STATE_FLAG_BASE
    self.carry = nil
    self.callback = on_deliver

    self:SetItem(CreateItem(FLAG_ITEM_NAMES[self.team], nil, nil))
    self:SetDrop(CreateItemOnPositionForLaunch(self.base_origin, self.item))
    self.item:LaunchLootInitialHeight(false, 0, 50, 0.5, self.base_origin)
    self.drop:SetForwardVector(Vector(0, -1))
    self:EffectsReturn(self.base_origin, self.base_origin)
end

function Flag:ReturnToBase()
    self:StopEffectsDroppedTick()
    self:EffectsReturn(self:GetAbsOrigin(), self.base_origin)
    
    self:Remove()

    self:SetItem(CreateItem(FLAG_ITEM_NAMES[self.team], nil, nil))
    self:SetDrop(CreateItemOnPositionForLaunch(self.base_origin, self.item))
    self.item:LaunchLootInitialHeight(false, 0, 50, 0.5, self.base_origin)
    self.drop:SetForwardVector(Vector(0, -1))
    self.state = STATE_FLAG_BASE
end

function Flag:Pickup(hero)
    self:EffectsPicked(hero)
    
    if self.team == hero:GetTeam() then
        self:ReturnToBase()
    else
        self:Remove()

        self:StopEffectsDroppedTick()

        local enemy_team = GameRules.GameMode:GetOppositeTeam(self.team)
        hero:AddNewModifier(GameRules.GameMode:GetFirstHeroOnTeam(enemy_team), nil, "modifier_item_flag", {})
        self.carry = hero
        self.state = STATE_FLAG_PICKED
    end
end

function Flag:Drop(hero)
    local origin = self:GetAbsOrigin() -- To prevent LaunchLootInitialHeight delay bugs
    
    hero:RemoveModifierByName(tostring("modifier_item_flag"))
    self:EffectsDrop(hero)

    AddFOWViewer(self.team, self:GetAbsOrigin(), 250, 5.0, false)

    self:SetItem(CreateItem(FLAG_ITEM_NAMES[self.team], nil, nil))
    self:SetDrop(CreateItemOnPositionForLaunch(origin, self.item))
    self.item:LaunchLootInitialHeight(false, 0, 50, 0.5, origin)
    self.drop:SetForwardVector(Vector(0, -1))
    self.carry = nil
    self.state = STATE_FLAG_DROPPED

    CustomGameEventManager:Send_ServerToAllClients("flag_dropped", { location = self:GetAbsOrigin() })
end

function Flag:Deliver()
    self.state = STATE_FLAG_BASE
    self.carry:RemoveModifierByName("modifier_item_flag")
    self.carry = nil
    self:Remove()

    local enemy_team = GameRules.GameMode:GetOppositeTeam(self.team)
    self:callback(enemy_team)
end

function Flag:OnExecutePickupItemOrder(filter_table)
    local hero = nil

    for _,unit in pairs(filter_table.units) do
        hero = EntIndexToHScript(unit)
    end

    if hero == nil then return false end

    if  hero:GetTeam() ~= self.team or
        self.state ~= STATE_FLAG_BASE
    then
        return true
    end

    local direction = (self:GetAbsOrigin() - hero:GetAbsOrigin()):Normalized()
    local distance = (self:GetAbsOrigin() - hero:GetAbsOrigin()):Length2D() - 100
    local position = hero:GetAbsOrigin() + direction * distance

    ExecuteOrderFromTable({
		UnitIndex = hero:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = position
    })
    return false
end

function Flag:OnPickup(event)
    PrintTable(event)
    local owner = EntIndexToHScript(event.HeroEntityIndex)
    self:Pickup(owner)
end

function Flag:GetAbsOrigin()
    if self.state == STATE_FLAG_PICKED then
        return self.carry:GetAbsOrigin()
    else
        return self.drop:GetAbsOrigin()
    end
end

function Flag:EffectsReturn(prev_position, next_position)
    EmitSoundOnLocationWithCaster(prev_position, "Hero_Chen.HolyPersuasionCast", nil)
    EmitSoundOnLocationWithCaster(prev_position, "Hero_Meepo.Poof.End00", nil)
    EmitSoundOnLocationWithCaster(next_position, "Hero_Chen.HandOfGodHealHero", nil)

    local efx_index = ParticleManager:CreateParticle("particles/neutral_fx/neutral_item_drop_lvl5.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(efx_index, 0, next_position)
    ParticleManager:ReleaseParticleIndex(efx_index)

    local efx_index = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_blink_end_v2.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(efx_index, 0, prev_position)
    ParticleManager:ReleaseParticleIndex(efx_index)
end

function Flag:EffectsDroppedTick(time)
    self:StopEffectsDroppedTick()
    EmitSoundOn("NeutralLootDrop.Spawn", self.drop)

    self.efx_index_tick = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_curse_counter_stack_number.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.efx_index_tick, 0, self:GetAbsOrigin() + Vector(0,0, 300))
    ParticleManager:SetParticleControl(self.efx_index_tick, 1, Vector(0, time, 0))

    local efx_index = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_geomagentic_grip_caster.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(efx_index, 0, self:GetAbsOrigin())
    ParticleManager:SetParticleControl(efx_index, 10, self:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(efx_index)

    efx_index = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_thuderstrike_aoe_discharge_c.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(efx_index, 0, self:GetAbsOrigin())
    ParticleManager:SetParticleControl(efx_index, 2, self:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(efx_index)
end

function Flag:StopEffectsDroppedTick()
    if self.efx_index_tick then
        ParticleManager:DestroyParticle(self.efx_index_tick, false)
        ParticleManager:ReleaseParticleIndex(self.efx_index_tick)
        self.efx_index_tick = nil
    end
end

function Flag:EffectsPicked(hTarget)
    EmitSoundOn("Hero_Chen.HandOfGodHealHero", hTarget)

    local efx_index = ParticleManager:CreateParticle("particles/econ/events/ti9/shovel/shovel_baby_roshan_spawn_burst.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
    ParticleManager:SetParticleControl(efx_index, 1, hTarget:GetOrigin())
    ParticleManager:SetParticleControl(efx_index, 3, hTarget:GetOrigin())
    ParticleManager:ReleaseParticleIndex(efx_index)
end

function Flag:EffectsDrop(hTarget)
    EmitSoundOn("Hero_Meepo.Poof.End00", hTarget)
    
    local efx_index = ParticleManager:CreateParticle("particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_blink_start_v2.vpcf", PATTACH_ABSORIGIN_FOLLOW, hTarget)
    ParticleManager:ReleaseParticleIndex(efx_index)
end
