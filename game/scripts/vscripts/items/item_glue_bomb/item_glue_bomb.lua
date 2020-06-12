LinkLuaModifier("modifier_item_glue_bomb_thinker", "items/item_glue_bomb/modifier_item_glue_bomb_thinker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_glue_bomb", "items/item_glue_bomb/modifier_item_glue_bomb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_glue_bomb_critical", "items/item_glue_bomb/modifier_item_glue_bomb_critical", LUA_MODIFIER_MOTION_NONE)

item_glue_bomb = class({})

function item_glue_bomb:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

function item_glue_bomb:OnAbilityPhaseStart()    
    self:GetCaster():StartGesture(ACT_DOTA_ATTACK)
    return true
end

function item_glue_bomb:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    self.radius = self:GetSpecialValueFor( "radius" )

    local vision_radius = self.radius
	local speed = 1300 --self:GetSpecialValueFor( "speed" )

    local target = CreateModifierThinker(
        self:GetCaster(), 
        self, 
        nil, 
        { duration = FrameTime() },
        self:GetCursorPosition(), 
        self:GetCaster():GetTeamNumber(), 
        false
    )
	local info = {
			EffectName = "particles/glue_bomb/glue_bomb_projectile.vpcf",
			Ability = self,
			iMoveSpeed = speed,
			Source = self:GetCaster(),
			Target = target,
			bDodgeable = true,
			bProvidesVision = true,
			iVisionTeamNumber = self:GetCaster():GetTeamNumber(),
			iVisionRadius = vision_radius,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, 
            ExtraData = {
                caster = 1
            }
		}

	ProjectileManager:CreateTrackingProjectile( info )
    EmitSoundOn("Hero_Alchemist.UnstableConcoction.Throw", caster)

end

function item_glue_bomb:OnProjectileHit(hTarget, vLocation)
    EmitSoundOn("Hero_Alchemist.UnstableConcoction.Stun", self:GetCaster())

    local units = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		vLocation,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

    local damage_table = {
        attacker = self:GetCaster(),
        damage = self:GetAbilityDamage(),
        damage_type = self:GetAbilityDamageType(),
        ability = self
    }

    for _,unit in pairs(units) do
        if not unit:IsMagicImmune() then
            damage_table.victim = unit
            ApplyDamage( damage_table )

            unit:AddNewModifier(self:GetCaster(), self, "modifier_item_glue_bomb_critical", { duration = self:GetSpecialValueFor("critical_slow_duration") })
        end
    end
            
    CreateModifierThinker(
        self:GetCaster(), 
        self, 
        "modifier_item_glue_bomb_thinker", 
        { duration = self:GetSpecialValueFor("duration") },
        vLocation, 
        self:GetCaster():GetTeamNumber(), 
        false
    )

    local efx_index = ParticleManager:CreateParticle("particles/glue_bomb/explosion.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(efx_index, 0, vLocation)
    ParticleManager:ReleaseParticleIndex(efx_index)

    UTIL_Remove(hTarget)
    self:SpendCharge()
end