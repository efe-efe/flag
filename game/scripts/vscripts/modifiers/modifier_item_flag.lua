modifier_item_flag = class({})

function modifier_item_flag:IsDebuff()      return  true    end
function modifier_item_flag:IsPurgable()    return  false   end

function modifier_item_flag:OnCreated()
    if IsServer() then
        self:OnIntervalThink()
        self:StartIntervalThink(1.0)
    end
end

function modifier_item_flag:OnIntervalThink()
    EmitSoundOn("Hero_Chen.DivineFavor.Cast", self:GetParent())

    local efx_index = ParticleManager:CreateParticle("particles/flag/constant_aoe.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(efx_index, 5, Vector(1, 0, 0))
    ParticleManager:ReleaseParticleIndex(efx_index)

    efx_index = ParticleManager:CreateParticle("particles/flag/overhead.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(efx_index, 1, Vector(255, 136, 0))
    ParticleManager:ReleaseParticleIndex(efx_index)
end

function modifier_item_flag:CheckState()
    local state = {
		[MODIFIER_STATE_INVISIBLE] = false,
    }

    return state
end

function modifier_item_flag:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}

	return funcs
end

function modifier_item_flag:GetModifierMoveSpeedBonus_Percentage()
    return -25
end

function modifier_item_flag:GetModifierProvidesFOWVision()
	return 1
end

function modifier_item_flag:GetTexture()
    return "flag_modifier"
end