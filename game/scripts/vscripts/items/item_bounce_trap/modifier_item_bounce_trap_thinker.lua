modifier_item_bounce_trap_thinker = class({})

function modifier_item_bounce_trap_thinker:OnCreated(params)
    if IsServer() then 
        self.team = params.team

        self.efx_index = ParticleManager:CreateParticle("particles/econ/items/wisp/wisp_relocate_channel_ti7.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.efx_index, 0, self:GetParent():GetOrigin()) 
        ParticleManager:SetParticleControl(self.efx_index, 1, self:GetParent():GetOrigin()) 

        EmitSoundOn("Hero_Rattletrap.Taunt.Robot", self:GetParent())

    end
end

function modifier_item_bounce_trap_thinker:OnDestroy()
    if IsServer() then
        local bounce_trap = CreateUnitByName("npc_dota_bounce_trap", self:GetParent():GetOrigin(), true, nil, nil, self.team)

        ParticleManager:DestroyParticle(self.efx_index, false)
        ParticleManager:ReleaseParticleIndex(self.efx_index)

        local efx_index = ParticleManager:CreateParticle("particles/econ/items/lina/lina_ti7/lina_spell_light_strike_array_ti7_gold_impact_sparks.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(efx_index, 0, self:GetParent():GetOrigin()) 
        
        EmitSoundOn("Hero_Rattletrap.Power_Cogs", self:GetParent())
    end
end