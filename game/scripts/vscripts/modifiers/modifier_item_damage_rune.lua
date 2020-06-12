modifier_item_damage_rune = class({})

function modifier_item_damage_rune:OnCreated()
    if IsServer() then
        self.efx_index = ParticleManager:CreateParticle("particles/generic_gameplay/rune_doubledamage_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    end
end

function modifier_item_damage_rune:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.efx_index, false)
        ParticleManager:ReleaseParticleIndex(self.efx_index)
    end
end


function modifier_item_damage_rune:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
    }
    return funcs
end


function modifier_item_damage_rune:GetModifierBaseDamageOutgoing_Percentage()
    return 100
end

function modifier_item_damage_rune:GetTexture()
    return "damage_rune"
end