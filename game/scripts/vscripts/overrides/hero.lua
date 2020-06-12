function CDOTA_BaseNPC_Hero:SetInDeliveryZone(state)
    self.in_delivery_zone = state
end

function CDOTA_BaseNPC_Hero:GetInDeliveryZone()
    return self.in_delivery_zone
end