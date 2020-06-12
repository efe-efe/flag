ice_trap_passive = class({})
LinkLuaModifier( "modifier_ice_trap_passive", "abilities/ice_trap/modifier_ice_trap_passive", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ice_trap_passive_debuff", "abilities/ice_trap/modifier_ice_trap_passive_debuff", LUA_MODIFIER_MOTION_NONE )

function ice_trap_passive:GetIntrinsicModifierName()
    return "modifier_ice_trap_passive"
end