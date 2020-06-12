modifier_item_haste_rune = class({})

function modifier_item_haste_rune:OnCreated()
    if IsServer() then
        self.efx_index = ParticleManager:CreateParticle("particles/generic_gameplay/rune_haste_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    end
end

function modifier_item_haste_rune:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.efx_index, false)
        ParticleManager:ReleaseParticleIndex(self.efx_index)
    end
end


function modifier_item_haste_rune:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
    }
    return funcs
end


function modifier_item_haste_rune:GetModifierMoveSpeed_Absolute()
    return 550
end

function modifier_item_haste_rune:GetTexture()
    return "haste_rune"
end