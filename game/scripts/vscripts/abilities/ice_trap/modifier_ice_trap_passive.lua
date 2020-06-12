modifier_ice_trap_passive = class({})
local AOE_INTERVAL = 1.0

function modifier_ice_trap_passive:OnCreated(params)
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.counter = 1
    self.delay = self:GetAbility():GetSpecialValueFor("proc_delay") * 30
    self.root_duration = self:GetAbility():GetSpecialValueFor("root_duration")
    self.activated = false

    if IsServer() then
        self:SetDuration(self:GetAbility():GetSpecialValueFor("trap_duration"), true)
        self:OnIntervalThink()
        self:StartIntervalThink(0.03)

        self.glow_efx = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.glow_efx, 60, Vector(0, 25, 255))

        self.aoe_efx = ParticleManager:CreateParticle("particles/econ/items/ancient_apparition/ancient_apparation_ti8/ancient_ice_vortex_ti8.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(self.aoe_efx, 5, Vector(self.radius, self.radius, self.radius))
    end
end

function modifier_ice_trap_passive:OnDestroy()
    if IsServer() then
        EmitSoundOn("Hero_Rattletrap.Power_Cog.Destroy", self:GetParent())
        local efx_index = ParticleManager:CreateParticle("particles/bounce_trap/explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:ReleaseParticleIndex(efx_index)
        
        ParticleManager:DestroyParticle(self.glow_efx, false)
        ParticleManager:ReleaseParticleIndex(self.glow_efx)
     
        ParticleManager:DestroyParticle(self.aoe_efx, false)
        ParticleManager:ReleaseParticleIndex(self.aoe_efx)

		self:GetParent():ForceKill(false)
        UTIL_Remove(self)
    end
end

function modifier_ice_trap_passive:OnIntervalThink()
    self.counter = self.counter - 1

    if self.counter == 0 then
        local efx_index = ParticleManager:CreateParticle("particles/ice_trap/aoe_indicator.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(efx_index, 2, Vector(self.radius, 1, 1))
        ParticleManager:ReleaseParticleIndex(efx_index)

        self.counter = AOE_INTERVAL * 30
    end

    local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		self:GetAbility():GetAbilityTargetTeam(),	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
    )

    if self.activated then
        self.delay = self.delay - 1

        if self.delay == 0 then

            local damage_table = {
                attacker = self:GetAbility():GetCaster(),
                damage = self:GetAbility():GetAbilityDamage(),
                damage_type = self:GetAbility():GetAbilityDamageType(),
                ability = self:GetAbility()
            }

            for _,enemy in pairs(enemies) do
                if not enemy:IsMagicImmune() and not enemy:HasModifier("modifier_ice_trap_passive_debuff") then
                    damage_table.victim = enemy
                    ApplyDamage( damage_table )

                    enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_ice_trap_passive_debuff", { duration = self.root_duration })

                    EmitSoundOn("Hero_Rattletrap.Power_Cogs_Impact", enemy)
                    
                    local efx_index = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
                    ParticleManager:SetParticleControlEnt(
                        efx_index,
                        1,
                        enemy,
                        PATTACH_POINT_FOLLOW,
                        "attach_hitloc",
                        enemy:GetOrigin(), -- unknown
                        true -- unknown, true
                    )
                end
                
                EmitSoundOn("Hero_Ancient_Apparition.IceBlast.Target", self:GetParent())
            end

            self:Destroy()
        end
    end

    if #enemies > 0 and self.activated == false then
        self.activated = true
        EmitSoundOnLocationWithCaster(self:GetParent():GetOrigin(), "Hero_Techies.LandMine.Priming", nil)
    end
end

function modifier_ice_trap_passive:DeclareFunctions()
    local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
	}
	return funcs
end

function modifier_ice_trap_passive:GetModifierInvisibilityLevel()
	return 1
end

function modifier_ice_trap_passive:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVISIBLE] = not self.activated,
	}

	return state
end


function modifier_ice_trap_passive:OnDeath( params )
    if IsServer() then
        if params.unit ~= self:GetParent() then return end
        
        self:Destroy()
    end
end

function modifier_ice_trap_passive:GetEffectName()
    return "particles/econ/courier/courier_wyvern_hatchling/courier_wyvern_hatchling_ice_c.vpcf"
end

function modifier_ice_trap_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

