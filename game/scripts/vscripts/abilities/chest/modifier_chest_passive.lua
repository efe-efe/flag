modifier_chest_passive = class({})

function modifier_chest_passive:IsPurgable()    return  false   end
function modifier_chest_passive:OnCreated()
    if IsServer() then
        self.base_glow_efx = ParticleManager:CreateParticle("particles/chest/base_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self.health = 6
		self.max_health = self.health
		self.hero_attack = self.health/3
    end
end

function modifier_chest_passive:OnDestroy()
    if IsServer() then
        ParticleManager:DestroyParticle(self.base_glow_efx, false)
        ParticleManager:ReleaseParticleIndex(self.base_glow_efx)
    end
end

function modifier_chest_passive:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function modifier_chest_passive:GetModifierIncomingDamage_Percentage()
	return -100
end

function modifier_chest_passive:OnAttacked(params)
	if params.target ~= self:GetParent() then return end

	if params.attacker:IsHero() then
		self.health = math.max(self.health - self.hero_attack, 0)
	else
		self.health = math.max(self.health - 1, 0)
	end
	self:GetParent():SetHealth( self.health/self.max_health * self:GetParent():GetMaxHealth() )
end

function modifier_chest_passive:OnDeath( params )
    if IsServer() then
        if params.unit ~= self:GetParent() then return end

        local experience = RandomFloat(90, 300)
        
		for i = 1, PlayerResource:GetPlayerCountForTeam(params.attacker:GetTeamNumber()) do
			local player_id = PlayerResource:GetNthPlayerIDOnTeam(params.attacker:GetTeamNumber(), i)
			local hero = PlayerResource:GetSelectedHeroEntity(player_id)

			if hero then
                hero:AddExperience(experience, 0, false, false)
                local efx_index = ParticleManager:CreateParticle("particles/generic_gameplay/outpost_reward.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
                ParticleManager:ReleaseParticleIndex(efx_index)
			end
		end

        local drops = RandomInt(2, 5)

        for i = 0, drops do
            local dice = RandomFloat(1, 100)
            local drop_radius = RandomFloat( 1, 100 )
            local origin = self:GetParent():GetOrigin() + RandomVector(drop_radius)
            local drop = nil

            if dice > 0 and dice <= 50 then
                drop = "item_gold_bag"
            end
            if dice > 50 and dice <= 70 then
                drop = "item_swiftness_potion"
            end
            if dice > 70 and dice <= 80 then
                drop = "item_glue_bomb"
            end
            if dice > 80 and dice <= 90 then
                drop = "item_bounce_trap"
            end
            if dice > 90 and dice <= 100 then
                drop = "item_ice_trap"
            end

            if drop == "item_gold_bag" then
                local gold = RandomFloat( 100, 250 )

                GoldBag(
                    origin,
                    gold
                )
            else
                local item = CreateItem(drop, nil, nil)
                local drop = CreateItemOnPositionForLaunch(origin, item)
                item:LaunchLootInitialHeight(false, 0, 50, 0.5, origin)
            end
        end
        
        EmitSoundOnLocationWithCaster(self:GetParent():GetOrigin(), "Hero_Furion.ForceOfNature", self:GetParent())
        self:GetParent():AddNoDraw()	
        
        local efx_index = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(efx_index, 0, self:GetParent():GetOrigin())
        ParticleManager:ReleaseParticleIndex(efx_index)

        efx_index = ParticleManager:CreateParticle("particles/econ/items/zeus/arcana_chariot/zeus_arcana_blink_compression.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(efx_index, 0, self:GetParent():GetOrigin())
        ParticleManager:SetParticleControl(efx_index, 1, self:GetParent():GetOrigin())
        ParticleManager:ReleaseParticleIndex(efx_index)
        
    end
end

function modifier_chest_passive:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	}

	return state
end

function modifier_chest_passive:GetEffectName()
    return "particles/generic_gameplay/rune_bounty_first.vpcf"
end

function modifier_chest_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
