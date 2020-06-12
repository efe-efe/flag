Item = Item or class({})

function Item:constructor()
    self.item = nil
    self.drop = nil
end

function Item:SetItem(item)
	self.item = item

    self.item.GetParentEntity = function(item)
        return self
    end
end

function Item:OnExecutePickupItemOrder()
    return true
end

function Item:SetDrop(drop)
	self.drop = drop
end

function Item:Remove()
    UTIL_Remove(self.item)
    UTIL_Remove(self.drop)
    self.item = nil
    self.drop = nil
end