modifier_item_glue_bomb_critical = class({})

function modifier_item_glue_bomb_critical:IsDebuff()
	return true
end

function modifier_item_glue_bomb_critical:OnCreated()
    self.ms_pct = self:GetAbility():GetSpecialValueFor("ms_pct")

    if IsServer() then
        self.efx_index = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_spring_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    end
end

function modifier_item_glue_bomb_critical:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.efx_index, false)
        ParticleManager:ReleaseParticleIndex(self.efx_index)
    end
end

function modifier_item_glue_bomb_critical:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_item_glue_bomb_critical:GetModifierMoveSpeedBonus_Percentage()
    return -self.ms_pct * 2
end

function modifier_item_glue_bomb_critical:GetTexture()
    return "item_glue_bomb"
end