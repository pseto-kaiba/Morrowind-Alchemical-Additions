local common = {}
local config = require("KKB.Alchemical Additions.config")
--Calculate alchemy strength based on stats

function common.calcLevels(A,I,L)
	return config.strengthContribution.alchWeight*A+
	config.strengthContribution.intWeight*I+
	config.strengthContribution.lckWeight*L
end

function common.calcStrength(A,I,L,mortar)
	local q = mortar.quality
	return q*common.calcLevels(A,I,L)
end
common.stats = {}
---@type tes3mobileActor
common.currentBrewer = nil


---@type dispositionEventData
function common.saveDisposition(e)
    common.lastDisposition = math.max(math.min(e.disposition,100),0)
end

---@param mobile tes3mobileNPC
function common.getBarterStats(mobile)
    return {M=math.min(100, mobile.mercantile.current),L=math.min(100, mobile.luck.current)*0.1, P=math.min(10, 0.2*mobile.personality.current), F=mobile.fatigue.normalized}
end

---@param npc tes3mobileActor
---@param basePrice number
---@param selling boolean
function common.barterOffer(npc, basePrice, selling)
    if npc.actorType == tes3.actorType.creature then
        return math.max(1,basePrice)
    end
    local pcStats = common.getBarterStats(tes3.mobilePlayer)
    local npcStats = common.getBarterStats(npc)
    local pcTerm = (common.lastDisposition - 50 + pcStats.M + pcStats.L + pcStats.P) * pcStats.F
    local npcTerm = (npcStats.M + npcStats.L + npcStats.P) * npcStats.F
    local multiplier = 0.5
    if tes3.hasCodePatchFeature(tes3.codePatchFeature.mercantileFix) then
        multiplier = 0.3125
    end
    local buyTerm = 0.01 * (100 - multiplier * (pcTerm - npcTerm))
    local sellTerm = 0.01 * (50 - multiplier * (npcTerm - pcTerm))
    local x = buyTerm
    if selling==true then
            x = math.min(buyTerm, sellTerm)
    end
    local offerPrice
    if x < 1 then
        offerPrice = math.floor(x*basePrice)
    else
        offerPrice = basePrice + math.floor((x-1)*basePrice)
    end
    return math.max(1, offerPrice)
end


--Calculate strengths used for default thresholds
function common.calcDefaultStrengthThresholds()
	local cur_mortar = tes3.getObject(config.mortars[config.potionStats.b.M])
	local bStrength = common.calcStrength(config.potionStats.b.A,config.potionStats.b.I,
	config.potionStats.b.L,cur_mortar)
	cur_mortar = tes3.getObject(config.mortars[config.potionStats.c.M])
	local cStrength = common.calcStrength(config.potionStats.c.A,config.potionStats.c.I,
	config.potionStats.c.L,cur_mortar)
	cur_mortar = tes3.getObject(config.mortars[config.potionStats.s.M])
	local sStrength = common.calcStrength(config.potionStats.s.A,config.potionStats.s.I,
	config.potionStats.s.L,cur_mortar)
	cur_mortar = tes3.getObject(config.mortars[config.potionStats.q.M])
	local qStrength = common.calcStrength(config.potionStats.q.A,config.potionStats.q.I,
	config.potionStats.q.L,cur_mortar)
	cur_mortar = tes3.getObject(config.mortars[config.potionStats.e.M])
	local eStrength = common.calcStrength(config.potionStats.e.A,config.potionStats.e.I,
	config.potionStats.e.L,cur_mortar)
	return {b=bStrength, c=cStrength, s=sStrength, q=qStrength, e=eStrength}
end


common.basePotionThresholds = {}
common.tierList_ti = {b=1,c=2,s=3,q=4,e=5}
common.tierList_it = {"b","c","s","q","e"}

--Slope between two points on the default potion strength thresholds - default potion power graphs
function common.alchSlope(tier1, ep1, tier2, ep2)
	if tier1 == tier2 then return 0 end
	local s1 = common.basePotionThresholds[tier1]
	local s2 = common.basePotionThresholds[tier2]
	return (ep2-ep1)/(s2-s1)
end

--Get total of all disallowed boosts
function common.disallowedBoosts(actor, effect_id, stat_id, allowed_boosts, stat_is_skill)
	local disallowed_total = 0
	local att_field = "attributeId"
	if stat_is_skill == true then
		att_field = "skill_id"
	end
	--Go through all of the player's active magic effects
	for _, activeEffect in pairs(actor:getActiveMagicEffects{effect=effect_id}) do
		--If effect and stat id match up and the boost is not allowed add it to sum
		if not allowed_boosts[activeEffect.instance.source.id] and activeEffect[att_field] == stat_id then
			disallowed_total = disallowed_total + activeEffect.magnitude
		end
	end
	return disallowed_total
end

---Create tooltip for a UI element
---@param e tes3uiElement
function common.createToolTip(e, text)
    e:register("help", function() 
        local tooltip = tes3ui.createTooltipMenu()
        local tooltipBlock = tooltip:createBlock{}
        tooltipBlock.flowDirection = "top_to_bottom"
        tooltipBlock.autoHeight = true
        tooltipBlock.autoWidth = true
        tooltipBlock:createLabel{text=text}
        return tooltipBlock
    end)
end

--Get stats adjusted to remove non-constant effect alchemy-relevant Fortify enchantments
--- @param actor tes3mobileActor
function common.getFortifyBoosts(actor)
	--Get current INT, LUCK, Alchemy
	local cur_int = actor.intelligence.current
	local cur_luck = actor.luck.current
	local cur_alch = actor:getSkillStatistic(tes3.skill.alchemy).current
	--Keep track of all CE enchantments affecting the player
	local active_CE_enchantments = {}
	if config.AA_debug then
		--mwse.log("Current brewer: ")
		--mwse.log(common.currentBrewer) 
	end
	for _, stack in pairs(actor.reference.object.equipment) do
		---@type tes3enchantment
		local enchantment = stack.object.enchantment
		--Only consider enchanted gear with CE enchantments
		if enchantment and enchantment.castType == tes3.enchantmentType.constant then
			active_CE_enchantments[enchantment.id] = true
		end
	end

	cur_int = cur_int - common.disallowedBoosts(actor, tes3.effect.fortifyAttribute, tes3.attribute.intelligence, active_CE_enchantments, false)
	cur_luck = cur_luck - common.disallowedBoosts(actor, tes3.effect.fortifyAttribute, tes3.attribute.luck, active_CE_enchantments, false)
	cur_alch = cur_alch - common.disallowedBoosts(actor, tes3.effect.fortifySkill, tes3.skill.alchemy, active_CE_enchantments, true)
	return {Intelligence=cur_int, Luck=cur_luck, Alchemy=cur_alch}
end

--Retrieves an actor's skills and attributes relevant to alchemy
--Wrapper function that, depending on toggle, gets either current stats, min(current,base) stats or current with all non-CE Fortify stats subtracted
--- @param actor tes3mobileActor
function common.getStats(actor)
	local stats = {Intelligence=actor.intelligence.current, Luck=actor.luck.current, Alchemy=actor:getSkillStatistic(tes3.skill.alchemy).current}
	if config.useBaseValues == false then
	--Current stats
	elseif config.useBaseConstValues == false then
	--Base stats
		stats.Intelligence = math.min(stats.Intelligence, actor.intelligence.base)
		stats.Luck = math.min(stats.Luck, actor.luck.base)
		stats.Alchemy = math.min(stats.Alchemy, actor:getSkillStatistic(tes3.skill.alchemy).base)
	else
	--Base+CE stats
		stats = common.getFortifyBoosts(actor)
	end
	return stats
end

return common