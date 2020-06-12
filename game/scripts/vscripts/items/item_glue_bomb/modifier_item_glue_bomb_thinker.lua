modifier_item_glue_bomb_thinker = class({})

function modifier_item_glue_bomb_thinker:IsAura()
	return true
end
function modifier_item_glue_bomb_thinker:GetModifierAura()
	return "modifier_item_glue_bomb"
end
function modifier_item_glue_bomb_thinker:GetAuraRadius()
	return self.radius
end
function modifier_item_glue_bomb_thinker:GetAuraDuration()
	return self.slow_linger
end
function modifier_item_glue_bomb_thinker:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end
function modifier_item_glue_bomb_thinker:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_glue_bomb_thinker:OnCreated(params)
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.slow_linger = self:GetAbility():GetSpecialValueFor("slow_linger")

    if IsServer() then
        AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), self.radius, self:GetDuration(), false)

        self.efx_index = ParticleManager:CreateParticle("particles/glue_bomb/aoe.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.efx_index, 0, self:GetParent():GetOrigin())
        ParticleManager:SetParticleControl(self.efx_index, 1, Vector(250, 0, 0))
    end
end

function modifier_item_glue_bomb_thinker:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.efx_index, false)
        ParticleManager:ReleaseParticleIndex(self.efx_index)
    end
end