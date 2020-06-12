modifier_item_swiftness_potion = class({})

function modifier_item_swiftness_potion:OnCreated()
    self.ms_pct = self:GetAbility():GetSpecialValueFor("ms_pct")

    if IsServer() then
        self.efx_index = ParticleManager:CreateParticle("particles/generic_gameplay/rune_haste_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        self:GetAbility():SpendCharge()
    end
end

function modifier_item_swiftness_potion:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.efx_index, false)
        ParticleManager:ReleaseParticleIndex(self.efx_index)
    end
end

function modifier_item_swiftness_potion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}

	return funcs
end

function modifier_item_swiftness_potion:GetModifierMoveSpeedBonus_Percentage()
    return self.ms_pct
end

function modifier_item_swiftness_potion:GetTexture()
    return "item_swiftness_potion"
end