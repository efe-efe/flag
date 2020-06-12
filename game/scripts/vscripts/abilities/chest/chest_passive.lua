chest_passive = class({})
LinkLuaModifier("modifier_chest_passive", "abilities/chest/modifier_chest_passive", LUA_MODIFIER_MOTION_NONE)

function chest_passive:GetIntrinsicModifierName()
    return "modifier_chest_passive"
end
