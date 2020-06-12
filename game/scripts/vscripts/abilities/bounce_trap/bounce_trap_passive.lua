bounce_trap_passive = class({})
LinkLuaModifier( "modifier_bounce_trap_passive", "abilities/bounce_trap/modifier_bounce_trap_passive", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_bounce_trap_passive_knockback", "abilities/bounce_trap/modifier_bounce_trap_passive_knockback", LUA_MODIFIER_MOTION_HORIZONTAL )

function bounce_trap_passive:GetIntrinsicModifierName()
    return "modifier_bounce_trap_passive"
end