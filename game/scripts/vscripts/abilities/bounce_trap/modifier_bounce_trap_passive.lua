modifier_bounce_trap_passive = class({})
local AOE_INTERVAL = 1.0

function modifier_bounce_trap_passive:OnCreated(params)
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.bounces = self:GetAbility():GetSpecialValueFor("bounces")
    self.counter = 1

    if IsServer() then
        self:SetDuration(self:GetAbility():GetSpecialValueFor("trap_duration"), true)
        self:SetStackCount(self.bounces)
        self:OnIntervalThink()
        self:StartIntervalThink(0.03)
    end
end

function modifier_bounce_trap_passive:OnDestroy()
    if IsServer() then
        EmitSoundOn("Hero_Rattletrap.Power_Cog.Destroy", self:GetParent())
        local efx_index = ParticleManager:CreateParticle("particles/bounce_trap/explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:ReleaseParticleIndex(efx_index)
        

		self:GetParent():ForceKill(false)
        UTIL_Remove(self)
    end
end

function modifier_bounce_trap_passive:OnIntervalThink()
    self.counter = self.counter - 1

    if self.counter == 0 then
        local efx_index = ParticleManager:CreateParticle("particles/bounce_trap/aoe_indicator.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControl(efx_index, 2, Vector(self.radius, 1, 1))
        ParticleManager:ReleaseParticleIndex(efx_index)

        self.counter = AOE_INTERVAL * 30
    end

	local units = FindUnitsInRadius(
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
    
    local damage_table = {
        attacker = self:GetAbility():GetCaster(),
        damage = self:GetAbility():GetAbilityDamage(),
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility()
    }
    for _,unit in pairs(units) do
        if unit ~= self:GetParent() and not unit:IsMagicImmune() then
            local direction = (unit:GetOrigin() - self:GetParent():GetOrigin()):Normalized()

            if not unit:HasModifier("modifier_bounce_trap_passive_knockback") then
                unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_bounce_trap_passive_knockback", {
                    duration = 0.3,
                    direction_x = direction.x,
                    direction_y = direction.y,
                    distance = 300
                })

                damage_table.victim = unit
                ApplyDamage( damage_table )

                self:DecrementStackCount()
                EmitSoundOn("Hero_Rattletrap.Power_Cogs_Impact", unit)
               
                local efx_index = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
                ParticleManager:SetParticleControlEnt(
                    efx_index,
                    1,
                    unit,
                    PATTACH_POINT_FOLLOW,
                    "attach_hitloc",
                    unit:GetOrigin(), -- unknown
                    true -- unknown, true
                )
            end
        end
	end
end

function modifier_bounce_trap_passive:OnStackCountChanged(old)
    if IsServer() then
        if self:GetStackCount() == 0 then
            self:Destroy()
        end
    end
end

function modifier_bounce_trap_passive:DeclareFunctions()
    local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function modifier_bounce_trap_passive:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}

	return state
end


function modifier_bounce_trap_passive:OnDeath( params )
    if IsServer() then
        if params.unit ~= self:GetParent() then return end
        
        self:Destroy()
    end
end

function modifier_bounce_trap_passive:GetEffectName()
    return "particles/units/heroes/hero_rattletrap/rattletrap_cog_ambient.vpcf"
end

function modifier_bounce_trap_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

