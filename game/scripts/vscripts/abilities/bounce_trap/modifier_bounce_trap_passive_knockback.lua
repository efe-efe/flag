modifier_bounce_trap_passive_knockback = class({})

function modifier_bounce_trap_passive_knockback:IsHidden()         return true     end
function modifier_bounce_trap_passive_knockback:IsPurgable()       return false    end
function modifier_bounce_trap_passive_knockback:GetAttributes()    return MODIFIER_ATTRIBUTE_MULTIPLE  end

function modifier_bounce_trap_passive_knockback:OnCreated(params)
    self.distance = params.distance or 0
    self.duration = params.duration or 0
    self.direction = Vector(params.direction_x, params.direction_y, 0):Normalized()
    self.parent = self:GetParent()

    if IsServer() then
        self.origin = self.parent:GetOrigin()
        self.hVelocity = self.distance/self.duration

        if self.distance > 0 then
            if self:ApplyHorizontalMotionController() == false then 
                self:Destroy()
                return
            end
        end
    end
end

function modifier_bounce_trap_passive_knockback:OnDestroy( params )
    if IsServer() then
        self:GetParent():InterruptMotionControllers(true)
    end
end


function modifier_bounce_trap_passive_knockback:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_bounce_trap_passive_knockback:GetOverrideAnimation( params )
    return ACT_DOTA_FLAIL
end

function modifier_bounce_trap_passive_knockback:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function modifier_bounce_trap_passive_knockback:UpdateHorizontalMotion( me, dt )
	local parent = self:GetParent()
	local target = self.direction * self.distance * (dt/self.duration)

	parent:SetOrigin( parent:GetOrigin() + target )
end

function modifier_bounce_trap_passive_knockback:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end