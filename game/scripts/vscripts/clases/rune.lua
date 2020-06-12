Rune = Rune or class({}, nil, Item)

RuneTypes = {
    HASTE = 0,
    DAMAGE = 1,
    REGENERATION = 2,
    INVISIBILITY = 3,
}

local RUNE_ITEM_NAMES = {
    [RuneTypes.HASTE] = "item_haste_rune",
    [RuneTypes.DAMAGE] = "item_damage_rune",
    [RuneTypes.REGENERATION] = "item_regeneration_rune",
    [RuneTypes.INVISIBILITY] = "item_invisibility_rune",
}

local RUNE_PARTICLES = {
    [RuneTypes.HASTE] = "particles/generic_gameplay/rune_haste.vpcf",
    [RuneTypes.DAMAGE] = "particles/generic_gameplay/rune_doubledamage.vpcf",
    [RuneTypes.REGENERATION] = "particles/generic_gameplay/rune_regeneration.vpcf",
    [RuneTypes.INVISIBILITY] = "particles/generic_gameplay/rune_invisibility.vpcf",
}

local RUNE_SOUNDS = {
    [RuneTypes.HASTE] = "Rune.Haste",
    [RuneTypes.DAMAGE] = "Rune.DD",
    [RuneTypes.REGENERATION] = "Rune.Regen",
    [RuneTypes.INVISIBILITY] = "Rune.Invis",
}

local RUNE_DURATIONS = {
    [RuneTypes.HASTE] = 5.0,
    [RuneTypes.DAMAGE] = 20.0,
    [RuneTypes.REGENERATION] = 10.0,
    [RuneTypes.INVISIBILITY] = 20.0,
}


local RUNE_MODIFIER_NAME = {
    [RuneTypes.HASTE] = "modifier_item_haste_rune",
    [RuneTypes.DAMAGE] = "modifier_item_damage_rune",
    [RuneTypes.REGENERATION] = "modifier_item_regeneration_rune",
    [RuneTypes.INVISIBILITY] = "modifier_item_invisibility_rune",
}


function Rune:constructor(type, origin)
    self.type = type
    self.origin = origin
    self.picked = false

    self:SetItem(CreateItem(RUNE_ITEM_NAMES[self.type], nil, nil))
    self:SetDrop(CreateItemOnPositionForLaunch(self.origin, self.item))
    self.item:LaunchLootInitialHeight(false, 0, 50, 0.5, self.origin)

    local efx_index = ParticleManager:CreateParticle(RUNE_PARTICLES[self.type], PATTACH_ABSORIGIN_FOLLOW, self.drop)
end

function Rune:OnPickup(event)
    local owner = EntIndexToHScript(event.HeroEntityIndex)
    
    owner:AddNewModifier(owner, nil, RUNE_MODIFIER_NAME[self.type], { duration = RUNE_DURATIONS[self.type] })
    EmitSoundOn(RUNE_SOUNDS[self.type], owner)

    self.picked = true
    self:Remove()
end

function Rune:IsPicked()
    return self.picked
end