local config = require("KKB.Alchemical Additions.config")
local potionScaling = require("KKB.Alchemical Additions.potionScaling")
local common = require("KKB.Alchemical Additions.common")
local npcBrewing = require("KKB.Alchemical Additions.npcBrewing")
local potion_list = require("KKB.Alchemical Additions.potion_list")


local potionBrewing = {}
potionBrewing.deletePotions = {}

-- Add bonus skill progression based on the number of effects.
-- Taken from G7's code
---@param e potionBrewedEventData
function potionBrewing.bonusProgress(e)
    if npcBrewing.active == true or config.useBonusProgress == false then
        return
    end
    ---@type tes3alchemy
    local potion = e.object
    local alchemy = tes3.skill.alchemy + 1
    local progress = tes3.mobilePlayer.skillProgress
    local skills = tes3.dataHandler.nonDynamicData.skills

    for i, effect in ipairs(potion.effects) do
        if not effect.object then
            --mwse.log("Extra alch: "..i)
            --mwse.log("Old progress: "..progress[alchemy])
            progress[alchemy] = progress[alchemy] + (
                skills[alchemy].actions[1] * (i-1) * 0.01 * config.bonusProgressMult
            )
            --mwse.log("New progress: "..progress[alchemy])
            break        
        end
    end
end


--Serialize a potion based purely on the properties visible to the player
function potionBrewing.serializePotion(p)
	local s = p.name.."─"..p.value.."─"..p.weight.."─"..p.icon.."─"..p.mesh
	for _, eff in pairs(p.effects) do
		if eff then
			s = s.."─"..eff.id
			if eff.min and eff.max then
				s = s.."─"..eff.min.."─"..eff.max
			end
			s = s.."─"..(eff.attribute or eff.skill)
			if eff.duration then
				s = s.."─"..eff.duration
			end
			if eff.radius then
				s = s.."─"..eff.radius
			end
		end
	end
	return s
end

--Copy a tes3alchemy object into another table
function potionBrewing.copyPotionTable(p)
	local potionTable = {}
	potionTable.name = p.name
	potionTable.value = p.value
	potionTable.weight = p.weight
	potionTable.icon = p.icon
	potionTable.mesh = p.mesh
	potionTable.effects = {}
	for i, eff in ipairs(p.effects) do
		if eff then
			potionTable.effects[i] = {}
			potionTable.effects[i].id = eff.id
			potionTable.effects[i].min = eff.min
			potionTable.effects[i].max = eff.max
			potionTable.effects[i].duration = eff.duration
			potionTable.effects[i].attribute = eff.attribute
			potionTable.effects[i].skill = eff.skill
			potionTable.effects[i].radius = eff.radius
		end
	end
	return potionTable
end

function potionBrewing.roundPotionTable(p)
    local function round(x) return math.floor(x+0.5) end
    p.value = round(p.value)
    p.weight = 0.01 * round(100*p.weight)
	for i, eff in ipairs(p.effects) do
		if eff then
			eff.min = round(eff.min)
			eff.max = round(eff.max)
			eff.duration = round(eff.duration)
			eff.radius = round(eff.radius)
		end
	end
    return p
end

--Creates new potion using original as a template and a table to supply data
---@param originalPotion tes3alchemy
function potionBrewing.createNewPotion(originalPotion, newPotionTable)
	local newPotion = originalPotion:createCopy{}
	for _, k in pairs{"name", "value", "weight", "icon", "mesh"} do
		newPotion[k] = newPotionTable[k]
	end
	for i, eff in ipairs(newPotionTable.effects) do
		for _, k in pairs{"id","min","max","duration","attribute","skill","radius"} do
			newPotion.effects[i][k] = eff[k]
		end
	end
	return newPotion
end

--In case we get an alchemy levelup while still in the menu
---@param e skillRaisedEventData
function potionBrewing.levelUpdate(e)
    common.stats = common.getStats(common.currentBrewer)
end


--Scale brewed potions according to new formula
---@param e potionBrewedEventData
function potionBrewing.rescalePotion(e)
    --If potion scaling is turned off nothing to see here!
    if config.scalePotions == false then
        return
    end
    local currentStrength = common.calcStrength(math.max(1,common.stats.Alchemy),
     math.max(1,common.stats.Intelligence),
     math.max(1,common.stats.Luck),
     e.mortar
    )

    --Get the two potion tiers we're in between
    local lowTier = "b"
    local currentTier = "b"
    local bestTierStrength = common.basePotionThresholds.b
    for tier, tierStrength in pairs(common.basePotionThresholds) do
        if bestTierStrength <= tierStrength and currentStrength >= tierStrength then
            currentTier = tier
            bestTierStrength = tierStrength
        end
    end
    lowTier = common.tierList_it[common.tierList_ti[currentTier]-1]
    if not lowTier then lowTier = "b" currentTier="c" end
    --if currentStrength > common.basePotionThresholds.e then lowTier = "e" end

    --Get table we'll modify to avoid messing with the savefile data too much
    --After we're done modifying it we'll copy it into a proper potion object
    local newPotionTable = potionBrewing.copyPotionTable(e.object)
    local totalPotionValue = 0

    --Scale each effect using alchemy strength
    ---@param effect tes3effect
    for effIndex, effect in ipairs(newPotionTable.effects) do
        if effect.id >= 0 then
            ---@type tes3magicEffect
            local baseEffect = tes3.getMagicEffect(effect.id)
            local base_potions = potionScaling.getPotions(effect)
            local mSlope
            local dSlope
            --if lowTier == "e" and currentTier == "e" then
            --    lowTier = "q"
            --end
            local lowPotion = base_potions[lowTier]
            local highPotion = base_potions[currentTier]

            --Adjust the magnitude/duration so the effect is scaled linearly between the appropriate potion tiers.
            --For anything past exclusive, just keep using the Quality->Exclusive slope.
            --Scaling magnitude
            if baseEffect.hasNoMagnitude == false then
                mSlope = common.alchSlope(lowTier, base_potions[lowTier].m, currentTier, highPotion.m)
                effect.max = lowPotion.m + mSlope * (currentStrength - common.basePotionThresholds[lowTier])
                --effect.max = lowPotion.m + mSlope * (highPotion.m - lowPotion.m)
            end

            --Scaling duration
            if baseEffect.hasNoDuration == false then
                dSlope = common.alchSlope(lowTier, base_potions[lowTier].d, currentTier, highPotion.d)
                effect.duration = lowPotion.d + dSlope * (currentStrength - common.basePotionThresholds[lowTier])
                --effect.duration = lowPotion.d + mSlope * (highPotion.d - lowPotion.d)
            end

            --Alembic/calcinator/retort bonuses
            local boost
            --Only calcinator
            if not (e.alembic or e.retort) and e.calcinator then
                boost = config.otherTools.only_c * e.calcinator.quality
                if baseEffect.hasNoMagnitude == false then effect.max = effect.max + boost end
                if baseEffect.hasNoDuration == false then effect.duration = effect.duration + boost end
            --Calcinator + Retort/Alembic
            else
                ---Positive effects
                if not baseEffect.isHarmful then
                    boost = 0
                    --RCP
                    if e.retort and e.calcinator then
                        boost = config.otherTools.rcp_r * e.retort.quality + config.otherTools.rcp_c * e.calcinator.quality
                    --RP
                    elseif e.retort then
                        boost = config.otherTools.rp_r * e.retort.quality
                    end
                    if baseEffect.hasNoMagnitude == false then effect.max = effect.max + boost end
                    if baseEffect.hasNoDuration == false then effect.duration = effect.duration + boost end
                --Negative effects
                else
                    boost = 1
                    --ACN
                    if e.alembic and e.calcinator then
                        boost = config.otherTools.acn_a * e.alembic.quality + config.otherTools.acn_c * e.calcinator.quality
                    --AN
                    elseif e.alembic then
                        boost = config.otherTools.an_a * e.alembic.quality + config.otherTools.an_a_scalar
                    end
                    if baseEffect.hasNoMagnitude == false then effect.max = effect.max / boost end
                    if baseEffect.hasNoDuration == false then effect.duration = effect.duration / boost end
                end
            end
            

            --Ingredient bonuses
            if config.randomizeIngredients then
                local bestMultiplier = 0
                local numWithEff = 0
                local effStat = effect.attribute or effect.skill
                for _, ingredient in pairs(e.ingredients) do
                    local ingredientData = tes3.player.data.KKB_AA.rolledIngredients[ingredient.id]
                    local effInstances = 0
                    for i, effectId in ipairs(ingredient.effects) do
                        if effectId == effect.id and ((not baseEffect.targetsAttributes and not baseEffect.targetsSkills) or (ingredientData[i][3] == effStat)) then
                            effInstances = effInstances + 1
                            bestMultiplier = math.max(bestMultiplier, ingredientData[i][1])
                        end
                    end
                    numWithEff = numWithEff + math.min(effInstances, 1)
                end

                if numWithEff > 1 then
                    if effect.max then effect.max = effect.max * bestMultiplier end
                    if effect.duration then effect.duration = effect.duration * bestMultiplier end
                end
            end

            --Min always == max
            effect.min = effect.max

            --Scaling value
            --Value is scaled as a % of exclusive potion mag/duration (whichever ratio is lower) applied to exclusive potion value

            local valueSign =1
            if baseEffect.isHarmful==true then
                valueSign = -1
            end
            local ePotion = base_potions.e
            local valueRatio = 1.0
            if baseEffect.hasNoDuration == false and baseEffect.hasNoMagnitude == false then
                valueRatio = math.min(effect.max / ePotion.m, effect.duration / ePotion.d)
            elseif baseEffect.hasNoDuration == false then
                valueRatio = effect.duration / ePotion.d
            elseif baseEffect.hasNoMagnitude == false then
                valueRatio = effect.max / ePotion.m
            end
            totalPotionValue = totalPotionValue + valueSign * valueRatio * ePotion.v
        end
    end
    totalPotionValue = math.max(totalPotionValue, 0)
    --Fix new value
    newPotionTable.value = totalPotionValue

    --Calcinator weight reduction, if enabled
    if config.calcWeightReduce==true and e.calcinator then
        newPotionTable.weight = newPotionTable.weight / (config.otherTools.c_wmult * e.calcinator.quality + config.otherTools.c_wscalar)
    end

    --Pick icon/mesh
    local iconReferencePotions = potion_list["e"..config.defaultScalingEffectM]
    local newIcon = tes3.getObject(iconReferencePotions["b"]).icon
    local newMesh = tes3.getObject(iconReferencePotions["b"]).mesh

    local cur_value = tes3.getObject(iconReferencePotions["b"]).value
    for _, potionId in pairs(iconReferencePotions) do
        local refPotion = tes3.getObject(potionId)
        if refPotion.value >= cur_value and refPotion.value <= newPotionTable.value then
            cur_value = refPotion.value
            newIcon = refPotion.icon
            newMesh = refPotion.mesh
        end 
    end
    newPotionTable.icon = newIcon
    newPotionTable.mesh = newMesh

    --Check if we've already brewed a potion identical to the new potion
    local uniquePotionID = potionBrewing.serializePotion(potionBrewing.roundPotionTable(newPotionTable))
    local newPotionID
    if tes3.player.data.KKB_AA.potionLibrary[uniquePotionID] == nil then
        --Save new potion to an actual tes3alchemy object
        newPotionID = potionBrewing.createNewPotion(e.object, newPotionTable)
        tes3.player.data.KKB_AA.potionLibrary[uniquePotionID] = {id=newPotionID}
    else
        --Appropriate potion already exists
        newPotionID = tes3.player.data.KKB_AA.potionLibrary[uniquePotionID].id
    end

    potionBrewing.deletePotions[e.object] = true
    tes3.addItem{reference=tes3.mobilePlayer, item=newPotionID}


    -- For mod compatibility - custom event with identical API to potionBrewed but with new potion
    local newEventData = {}
    for k,v in pairs(e) do
        newEventData[k] = v
    end
    newEventData.object = newPotionID
    event.trigger("KKB_AA_potionBrewed", newEventData)
end

--Get rid of any stray unmodified potions
--Also reset npcBrewing variables
function potionBrewing.cleanUpPotions(e)
    for id, _ in pairs(potionBrewing.deletePotions) do
        local count = tes3.getItemCount{reference=tes3.mobilePlayer, item=id}
        tes3.removeItem{reference=tes3.mobilePlayer, item=id, count=count}
    end
    potionBrewing.deletePotions = {}
    npcBrewing.active = false
    common.currentBrewer = tes3.mobilePlayer
end

--Get stats of current brewer
---@param e uiActivatedEventData
function potionBrewing.fixStats(e)
    e.element:registerBefore("destroy", npcBrewing.removeExtraTools)
    common.stats = common.getStats(common.currentBrewer)
end

return potionBrewing