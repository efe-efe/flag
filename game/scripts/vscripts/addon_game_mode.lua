require("util")
require("overrides/hero")
require("clases/item")
require("clases/flag")
require("clases/rune")
require("clases/gold_bag")


THINK_PERIOD = 0.01
RUNE_RESPAWN_TIME = 30.0
FLAG_PICKUP_TIME = 5.0
FLAG_RESPAWN_TIME = 5.0
FLAGS_TO_WIN = 3
CHESTS = 10

_G.STATE_FLAG_BASE = 0
_G.STATE_FLAG_DROPPED = 1
_G.STATE_FLAG_PICKED = 2

DROP_FLAG_SPELLS = {
	["furion_teleportation"] = true,
	["ember_spirit_activate_fire_remnant"] = true,
	["templar_assassin_trap_teleport"] = true,
	["item_tpscroll"] = true,
}

if GameMode == nil then
	GameMode = class({})
end

function Precache(context)
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_chen.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_meepo.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_furion.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_rattletrap.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_tinker.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context )
end

function Activate()
	GameRules.GameMode = GameMode()
	GameRules.GameMode:InitGameMode()
end

function GameMode:InitGameMode()
	self.flags = {}
	self.runes = {}
	self.thinkers = {}
	self.chests = {}

	local score = {}
	score[DOTA_TEAM_GOODGUYS] = 0
	score[DOTA_TEAM_BADGUYS] = 0
	
	GameRules:SetPreGameTime(0.0)
	GameRules:SetUseUniversalShopMode(true)
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1500)
	GameRules:GetGameModeEntity():SetThink("OnThink", self, THINK_PERIOD)
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(self, "ExecuteOrderFilter" ), self)
	GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(self, "ModifyExperienceFilter" ), self)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(self, "ModifyGoldFilter" ), self)

	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( self, "OnItemPickUp"), self )
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(self, "OnGameRulesStateChange"), self)
    ListenToGameEvent("entity_killed", Dynamic_Wrap(self, "OnEntityKilled"), self)
	ListenToGameEvent("dota_player_begin_cast", Dynamic_Wrap(self, "OnPlayerBeginCast"), self)

	LinkLuaModifier("modifier_item_flag", "modifiers/modifier_item_flag", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_item_haste_rune", "modifiers/modifier_item_haste_rune", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_item_damage_rune", "modifiers/modifier_item_damage_rune", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_item_regeneration_rune", "modifiers/modifier_item_regeneration_rune", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_item_invisibility_rune", "modifiers/modifier_item_invisibility_rune", LUA_MODIFIER_MOTION_NONE)
	LinkLuaModifier("modifier_enemy_base", "modifiers/modifier_enemy_base", LUA_MODIFIER_MOTION_NONE)
	
	CustomNetTables:SetTableValue( "game_state", "score", score );

	CustomGameEventManager:RegisterListener("remove_modifier", function(eventSourceIndex, args)
		if args.buff_name ~= "modifier_item_flag" then return end

		local hero = EntIndexToHScript(args.entity_index)

		for _,flag in pairs(self.flags) do
			if flag.entity.state == STATE_FLAG_PICKED then
				if flag.entity.carry == hero then
					flag.timer = FLAG_PICKUP_TIME * 30
					flag.entity:Drop(hero)
				end
			end
		end
	end)
end

function GameMode:Start()
	local radiant_flag_spawn = Entities:FindByName(nil, "radiant_flag"):GetOrigin()
	local dire_flag_spawn = Entities:FindByName(nil, "dire_flag"):GetOrigin()
	local haste_rune_spawns = Entities:FindAllByName("haste_rune_spawn")
	local damage_rune_spawns = Entities:FindAllByName("damage_rune_spawn")
	local regeneration_rune_spawns = Entities:FindAllByName("regeneration_rune_spawn")
	local invisibility_rune_spawns = Entities:FindAllByName("invisibility_rune_spawn")
	local chest_spawns_radiant = Entities:FindAllByName("chest_spawn_radiant")
	local chest_spawns_dire = Entities:FindAllByName("chest_spawn_dire")

	table.insert(self.flags, {
		team = DOTA_TEAM_GOODGUYS,
		entity = Flag(DOTA_TEAM_GOODGUYS, radiant_flag_spawn, function(context, team) self:OnFlagDelivered(team) end),
		origin = radiant_flag_spawn,
		timer = FLAG_PICKUP_TIME * 30,
		respawn_timer = FLAG_RESPAWN_TIME * 30
	})
	table.insert(self.flags, {
		team = DOTA_TEAM_BADGUYS,
		entity = Flag(DOTA_TEAM_BADGUYS, dire_flag_spawn, function(context, team) self:OnFlagDelivered(team) end),
		origin = dire_flag_spawn,
		timer = FLAG_PICKUP_TIME * 30,
		respawn_timer = FLAG_RESPAWN_TIME * 30
	})

	for _,spawn in pairs(haste_rune_spawns) do
		table.insert(self.runes, {
			timer = RUNE_RESPAWN_TIME * 30,
			type = RuneTypes.HASTE,
			entity = Rune(RuneTypes.HASTE, spawn:GetOrigin()),
			origin = spawn:GetOrigin()
		})
	end

	for _,spawn in pairs(damage_rune_spawns) do
		table.insert(self.runes, {
			timer = RUNE_RESPAWN_TIME * 30,
			type = RuneTypes.DAMAGE,
			entity = Rune(RuneTypes.DAMAGE, spawn:GetOrigin()),
			origin = spawn:GetOrigin()
		})
	end

	for _,spawn in pairs(regeneration_rune_spawns) do
		table.insert(self.runes, {
			timer = RUNE_RESPAWN_TIME * 30,
			type = RuneTypes.REGENERATION,
			entity = Rune(RuneTypes.REGENERATION, spawn:GetOrigin()),
			origin = spawn:GetOrigin()
		})
	end

	for _,spawn in pairs(invisibility_rune_spawns) do
		table.insert(self.runes, {
			timer = RUNE_RESPAWN_TIME * 30,
			type = RuneTypes.INVISIBILITY,
			entity = Rune(RuneTypes.INVISIBILITY, spawn:GetOrigin()),
			origin = spawn:GetOrigin()
		})
	end

	for _,spawn in pairs(chest_spawns_radiant) do
		table.insert(self.chests, {
			team = DOTA_TEAM_GOODGUYS,
			origin = spawn:GetOrigin(),
			entity = nil
		})
	end

	for _,spawn in pairs(chest_spawns_dire) do
		table.insert(self.chests, {
			team = DOTA_TEAM_BADGUYS,
			origin = spawn:GetOrigin(),
			entity = nil
		})
	end

	local radiant_chests = 0
	local dire_chests = 0

	while (radiant_chests <= CHESTS) do
		for _,chest in pairs(self.chests) do
			if radiant_chests <= CHESTS and not chest.entity and chest.team == DOTA_TEAM_GOODGUYS then
				local dice = RandomInt(0, 1)
				if dice == 1 then
					chest.entity = CreateUnitByName("npc_dota_chest", chest.origin, true, nil, nil, DOTA_TEAM_NEUTRALS)
					radiant_chests = radiant_chests + 1
				end
			end
		end
	end

	while (dire_chests <= CHESTS) do
		for _,chest in pairs(self.chests) do
			if dire_chests <= CHESTS and not chest.entity and chest.team == DOTA_TEAM_BADGUYS then
				local dice = RandomInt(0, 1)
				if dice == 1 then
					chest.entity = CreateUnitByName("npc_dota_chest", chest.origin, true, nil, nil, DOTA_TEAM_NEUTRALS)
					dire_chests = dire_chests + 1
				end
			end
		end
	end

	
	self:RegisterThinker(0.1, function()
		local players_radiant = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
		local players_dire = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)

		for i = 1, players_radiant do
			local player_id = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, i)
			local hero = PlayerResource:GetSelectedHeroEntity(player_id)

			if hero then

				local experience = 1
				if hero:HasModifier("modifier_enemy_base") then
					experience = 2
				end

				hero:AddExperience(experience, 0, false, false)
			end
		end

		for i = 1, players_dire do
			local player_id = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, i)
			local hero = PlayerResource:GetSelectedHeroEntity(player_id)
			if hero then

				local experience = 1
				if hero:HasModifier("modifier_enemy_base") then
					experience = 2
				end

				hero:AddExperience(experience, 0, false, false)
			end
		end
	end)
	
	self:RegisterThinker(1.0, function()
		local players_radiant = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
		local players_dire = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_BADGUYS)

		for i = 1, players_radiant do
			local player_id = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_GOODGUYS, i)
			local hero = PlayerResource:GetSelectedHeroEntity(player_id)

			if hero then
				PlayerResource:ModifyGold(hero:GetPlayerID(), 2, true, 0)
			end
		end

		for i = 1, players_dire do
			local player_id = PlayerResource:GetNthPlayerIDOnTeam(DOTA_TEAM_BADGUYS, i)
			local hero = PlayerResource:GetSelectedHeroEntity(player_id)
			if hero then
				PlayerResource:ModifyGold(hero:GetPlayerID(), 2, true, 0)
			end
		end
	end)
	
	self:RegisterThinker(0.03, function()
		for _,flag in pairs(self.flags) do
			if not flag.entity then
				flag.respawn_timer = flag.respawn_timer - 1

				if flag.respawn_timer <= 0 then
					flag.entity = Flag(flag.team, flag.origin, function(context, team) self:OnFlagDelivered(team) end)
					flag.respawn_timer = FLAG_RESPAWN_TIME * 30
				end
			elseif flag.entity.state == STATE_FLAG_DROPPED then
				flag.timer = flag.timer - 1
		
				if flag.timer % 30 == 0 then
					flag.entity:EffectsDroppedTick(flag.timer/30)
				end
		
				if flag.timer <= 0 then			
					flag.entity.pinged = false
    				flag.timer = FLAG_PICKUP_TIME * 30
					flag.entity:ReturnToBase()
				end
			elseif flag.entity.state == STATE_FLAG_PICKED then
				if flag.entity.carry:GetInDeliveryZone() then
					local enemy_team = self:GetOppositeTeam(flag.entity.team)
					local enemy_flag = self:GetFlagFromTeam(enemy_team)
		
					if enemy_flag.entity.state == STATE_FLAG_BASE then
						flag.entity:Deliver()
						flag.entity = nil
					end
				end
			end
		end
	end)

	self:RegisterThinker(0.03, function()
		for _,rune in pairs(self.runes) do
			if not rune.entity then
				rune.timer = rune.timer - 1

				if rune.timer <= 0 then
					rune.entity = Rune(rune.type, rune.origin)
				end
			else
				if rune.entity:IsPicked() then
					rune.timer = RUNE_RESPAWN_TIME * 30
					rune.entity = nil
				end
			end
		end
	end)
end

function GameMode:OnItemPickUp(event)
	local item = EntIndexToHScript(event.ItemEntityIndex)

	if item.GetParentEntity then
		local item_entity = item:GetParentEntity()

		if item_entity.OnPickup then
			item_entity:OnPickup(event)
		end
	end
end

function GameMode:OnThink()
    if GameRules:IsGamePaused() then
        return THINK_PERIOD
	end

    local now = Time()
    if GameRules:State_Get() >= DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        for _, thinker in ipairs(self.thinkers) do
            if now >= thinker.next then
                thinker.next = math.max(thinker.next + thinker.period, now)
                thinker.callback()
            end
        end
	end
	
    return THINK_PERIOD
end

function GameMode:OnFlagDelivered(team)
	local players = PlayerResource:GetPlayerCountForTeam(team)

	for i = 1, players do
		local player_id = PlayerResource:GetNthPlayerIDOnTeam(team, i)
		local hero = PlayerResource:GetSelectedHeroEntity(player_id)

		EmitSoundOn("Hero_Chen.HandOfGodHealHero", hero)

		local efx_index = ParticleManager:CreateParticle("particles/econ/items/lina/lina_ti7/lina_spell_light_strike_array_ti7_gold_impact_sparks.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
		ParticleManager:ReleaseParticleIndex(efx_index)

		efx_index = ParticleManager:CreateParticle("particles/econ/taunts/ursa/ursa_unicycle/ursa_unicycle_taunt_spotlight.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
		ParticleManager:ReleaseParticleIndex(efx_index)
	end

	local current_score = CustomNetTables:GetTableValue("game_state", "score")	
	current_score[tostring(team)] = current_score[tostring(team)] + 1

	CustomNetTables:SetTableValue( "game_state", "score", current_score );
	EmitGlobalSound( "ui.npe_objective_given" )
	
	if current_score[tostring(team)] == FLAGS_TO_WIN then
		GameRules:SetGameWinner(team)
	end
end

function GameMode:GetOppositeTeam(team)
	if team == DOTA_TEAM_GOODGUYS then
		return DOTA_TEAM_BADGUYS
	else
		return DOTA_TEAM_GOODGUYS
	end
end

function GameMode:GetFlagFromTeam(team)
	for _,flag in pairs(self.flags) do
		if flag.team == team then
			return flag
		end
	end
end

function GameMode:GetFirstHeroOnTeam(team)
	local player_id = PlayerResource:GetNthPlayerIDOnTeam(team, 1)
	return PlayerResource:GetSelectedHeroEntity(player_id)
end

function GameMode:OnGameRulesStateChange(event)
    local state = GameRules:State_Get()
    
	if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        self:Start()
    end
end

function GameMode:OnEntityKilled(event)
	local killed = EntIndexToHScript( event.entindex_killed )

	for _,flag in pairs(self.flags) do
		if flag.entity and flag.entity.state == STATE_FLAG_PICKED then
			if flag.entity.carry == killed then
				flag.entity:Drop(killed)
			end
		end
	end

	if killed:IsRealHero() then
		if killed:IsReincarnating() == true then
			return nil
		else
			local time = RandomFloat(5, 15)
			killed:SetTimeUntilRespawn(time)
		end
	end
end

function GameMode:RegisterThinker(period, callback)
    local timer = {}
    timer.period = period
    timer.callback = callback
    timer.next = Time() + period

    self.thinkers = self.thinkers or {}

    table.insert(self.thinkers, timer)
end

function GameMode:ExecuteOrderFilter(filter_table)
	local order_type = filter_table["order_type"]
	if ( order_type ~= DOTA_UNIT_ORDER_PICKUP_ITEM or filter_table["issuer_player_id_const"] == -1 ) then
		return true
	else
		local item = EntIndexToHScript( filter_table["entindex_target"] )
		if item == nil then
			return true
		end

		local contained_item = item:GetContainedItem()
		if contained_item == nil then
			return true
		end

		if contained_item.GetParentEntity then
			return contained_item:GetParentEntity():OnExecutePickupItemOrder(filter_table)
		end
	end
	return true
end

function GameMode:ModifyExperienceFilter(filter_table)
	if filter_table.reason_const == 2 then
		filter_table.experience = filter_table.experience * 3
		return true
	end

	return true
end

function GameMode:ModifyGoldFilter(filter_table)
	if filter_table.reason_const == 14 then
		filter_table.gold = filter_table.gold * 3
		return true
	end

	return true
end

function GameMode:OnPlayerBeginCast(event)
	local hero = PlayerResource:GetSelectedHeroEntity(event.PlayerID)
	local ability_name = event.abilityname

	--print(ability_name, DROP_FLAG_SPELLS[ability_name] and "TRUE" or "FALSE")

	if DROP_FLAG_SPELLS[ability_name] then
		for _,flag in pairs(self.flags) do
			if flag.entity then
				if flag.entity.state == STATE_FLAG_PICKED then
					if flag.entity.carry == hero then
						flag.timer = FLAG_PICKUP_TIME * 30
						flag.entity:Drop(hero)
					end
				end
			end
		end
	end
end
