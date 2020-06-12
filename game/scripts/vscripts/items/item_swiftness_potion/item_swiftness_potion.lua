LinkLuaModifier("modifier_item_swiftness_potion", "items/item_swiftness_potion/modifier_item_swiftness_potion", LUA_MODIFIER_MOTION_NONE)
item_swiftness_potion = class({})

function item_swiftness_potion:OnSpellStart()
    if IsServer() then
        EmitSoundOn("Rune.Haste", self:GetCaster())
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_swiftness_potion", { duration = self:GetSpecialValueFor("duration") })
    end
end
