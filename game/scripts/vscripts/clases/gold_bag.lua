GoldBag = GoldBag or class({}, nil, Item)

function GoldBag:constructor(origin, gold)
    self.origin = origin
    self.gold = gold
    self.picked = false

    local scale = (gold/100)
    if scale > 1.3 then 
        scale = 1.3
    end

    self:SetItem(CreateItem("item_gold_bag", nil, nil))
    self:SetDrop(CreateItemOnPositionForLaunch(self.origin, self.item))
    self.item:LaunchLootInitialHeight(false, 0, 50, 0.5, self.origin)
    self.drop:SetModelScale(scale)

    local efx_index = ParticleManager:CreateParticle("particles/generic_gameplay/rune_bounty.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.drop)
end

function GoldBag:OnPickup(event)
    local owner = EntIndexToHScript(event.HeroEntityIndex)
    PlayerResource:ModifyGold( owner:GetPlayerID(), self.gold, true, 0 )
    SendOverheadEventMessage( owner, OVERHEAD_ALERT_GOLD, owner, self.gold, nil )

    EmitSoundOn("Rune.Bounty", owner)
    self:Remove()
end

function GoldBag:IsPicked()
    return self.picked
end