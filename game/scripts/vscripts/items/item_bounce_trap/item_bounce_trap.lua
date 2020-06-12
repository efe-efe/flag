
LinkLuaModifier( "modifier_item_bounce_trap_thinker", "items/item_bounce_trap/modifier_item_bounce_trap_thinker", LUA_MODIFIER_MOTION_NONE )
item_bounce_trap = class({})

function item_bounce_trap:GetAOERadius()
	return self:GetSpecialValueFor("radius")
end

function item_bounce_trap:CastFilterResultLocation(vLocation)	
	if IsServer() then
		local in_trigger = false
		local CHECKINGRADIUS = self:GetSpecialValueFor("radius")
	  
		  for _,thing in pairs(Entities:FindAllInSphere(vLocation, CHECKINGRADIUS))  do
	  
			  if (thing:GetName() == "trigger_no_trap") then
				in_trigger = true
			  end
	  
		  end
		  
		  if in_trigger then
			return UF_FAIL_CUSTOM
		end
	end

	return UF_SUCCESS
end

function item_bounce_trap:GetCustomCastErrorLocation()
	return "The flag is too close"
end

function item_bounce_trap:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    CreateModifierThinker(
		caster, -- player source
		self, -- ability source
		"modifier_item_bounce_trap_thinker", -- modifier name
		{ duration = self:GetSpecialValueFor("delay"), team = caster:GetTeam()}, -- kv
		point,
		caster:GetTeamNumber(),
		false
	)

	self:SpendCharge()
end