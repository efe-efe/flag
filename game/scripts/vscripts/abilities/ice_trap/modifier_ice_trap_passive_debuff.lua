modifier_ice_trap_passive_debuff = class({})

function modifier_ice_trap_passive_debuff:CheckState()
	local state = {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end

function modifier_ice_trap_passive_debuff:GetEffectName()
	return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end

function modifier_ice_trap_passive_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end