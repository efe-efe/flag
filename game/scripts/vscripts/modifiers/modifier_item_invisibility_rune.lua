modifier_item_invisibility_rune = class({})

function modifier_item_invisibility_rune:OnCreated()
	local delay_time = 2.0
	self.hidden = false

	if IsServer() then
		self:StartIntervalThink(delay_time)
	end
end

function modifier_item_invisibility_rune:OnIntervalThink()
	self.hidden = true
end

function modifier_item_invisibility_rune:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_EVENT_ON_ATTACK,
	}

	return funcs
end

function modifier_item_invisibility_rune:GetModifierInvisibilityLevel()
	return 1
end

function modifier_item_invisibility_rune:OnAbilityExecuted( params )
	if IsServer() then
		if self.hidden == false then return end
		if params.ability == self:GetAbility() then return end
		if params.unit ~= self:GetParent() then return end

		self:Destroy()
	end
end

function modifier_item_invisibility_rune:OnAttack( params )
	if IsServer() then
		if self.hidden == false then return end
		if params.attacker ~= self:GetParent() then return end

		self:Destroy()
	end
end

function modifier_item_invisibility_rune:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = self.hidden,
	}

	return state
end

function modifier_item_invisibility_rune:GetTexture()
    return "invisibility_rune"
end