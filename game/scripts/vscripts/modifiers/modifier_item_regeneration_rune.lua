modifier_item_regeneration_rune = class({})

function modifier_item_regeneration_rune:OnCreated()
    if IsServer() then
        self.efx_index = ParticleManager:CreateParticle("particles/generic_gameplay/rune_regen_owner.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

        self:StartIntervalThink(0.25)
    end
end

function modifier_item_regeneration_rune:OnIntervalThink()
    if  self:GetParent():GetMaxMana() == self:GetParent():GetMana() and
        self:GetParent():GetMaxHealth() == self:GetParent():GetHealth()
    then
        self:Destroy()
    end

    local heal = self:GetParent():GetMaxHealth() * 0.015
    local mana = self:GetParent():GetMaxMana() * 0.015

    self:GetParent():Heal(heal, self:GetParent())
    self:GetParent():GiveMana(mana)
end


function modifier_item_regeneration_rune:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.efx_index, false)
        ParticleManager:ReleaseParticleIndex(self.efx_index)
    end
end

function modifier_item_regeneration_rune:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function modifier_item_regeneration_rune:OnTakeDamage(params)
    if IsServer() then
		if params.unit == self:GetParent() then
            if params.attacked:IsRealHero() then
                self:Destroy()
            end
        end
	end
end

function modifier_item_regeneration_rune:GetTexture()
    return "regeneration_rune"
end