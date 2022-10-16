local potionScaling = {}
local config = require("KKB.Alchemical Additions.config")
local potion_list = require("KKB.Alchemical Additions.potion_list")

potionScaling.loadedPotions = {}

function dict_size(d)
    len = 0
    for k,v in pairs(d) do
        len = len + 1
    end
    return len
end

---@param effect tes3effect
--Get corresponding potion templates for a given tes3effect
function potionScaling.getPotions(effect)
    ---@type tes3magicEffect
    local baseEffect = tes3.getMagicEffect(effect.id)
    local key = "e"..effect.id
    if baseEffect.targetsAttributes then
        key=key.."_"..effect.attribute
    elseif baseEffect.targetsSkills then
        key=key.."_"..effect.skill
    end
    return potionScaling.loadedPotions[key]
end

--Potion scaling function
--[[Params:
    targetPotions - potions to fill gaps in for
    referencePotions - potions to use as reference (by default Levitate/Invisibility)
    tier - tier of potion to use as comparison point. If nil, copy entire reference potion table
    scaleMagnitude - whether magnitude will be scaled
    scaleDuration - whether duration will be scaled
    scaleValue -- whether value will be scaled
]]
function potionScaling.scalePotions(params)
    --Copy for nonexistent potions
    if not params.tier then
        for k,v in pairs(params.referencePotions) do
            params.targetPotions[k] = {}
            for property in pairs(v) do
                params.targetPotions[k][property] = v[property]
            end
            --Nonexistent potions don't have ids!
            params.targetPotions[k].id = nil
        end
        return
    end

    local referencePotion = params.referencePotions[params.tier]
    local targetPotion = params.targetPotions[params.tier]
    local mag_ratio = 1.0
    local dur_ratio = 1.0
    local val_ratio = 1.0
    if params.scaleMagnitude then
        mag_ratio = targetPotion.m / referencePotion.m
    end
    if params.scaleDuration then
        dur_ratio = targetPotion.d / referencePotion.d
    end
    if params.scaleValue then
        val_ratio = targetPotion.v / referencePotion.v
    end


    --Scale potions.
    for k,v in pairs(params.referencePotions) do
        if k ~= params.tier then
            params.targetPotions[k] = {}
            if params.scaleMagnitude then
                params.targetPotions[k].m = mag_ratio * v.m
            end
            if params.scaleDuration then
                params.targetPotions[k].d = dur_ratio * v.d
            end
            if params.scaleValue then
                params.targetPotions[k].v = val_ratio * v.v
            end
        end
    end

end

--Get all possible premade potion ids for a given effect
---@param gameEff tes3magicEffect
function potionScaling.getValidPotionIds(gameEff)
    local eff_id = gameEff.id
    local potion_ids = {"e"..eff_id}
    if gameEff.targetsAttributes then
        potion_ids = {}
        for _, stat in pairs(tes3.attribute) do table.insert(potion_ids, "e"..eff_id.."_"..stat) end
    elseif gameEff.targetsSkills then
        potion_ids = {}
        for _, stat in pairs(tes3.skill) do table.insert(potion_ids, "e"..eff_id.."_"..stat) end
    end
    return potion_ids
end


--Loads non-player made potions into memory
--Fixes gaps for Feather, Slowfall, Water Breathing, Water Walking, Detect X, Dispel, Telekinesis and Fortify Attack where they're missing certain potion tiers
    --For effects with magnitude+duration, compare the highest quality existing potion with its Levitate counterpart and get their magnitude/duration/value ratio. Apply these ratios to the reference potion to get the target.
    --Just magnitude (only Dispel): Again Levitate and scale magnitude
    --Just duration: Invisibility, scale duration
    --No duration, no magnitude: Recall
--For effects with no potions at all, copy Levitate
--Potion table loading function
function potionScaling.loadPotions()
    for _, eff_id in pairs(tes3.effect) do
        ---@type tes3magicEffect
        local gameEff = tes3.getMagicEffect(eff_id)
        local potion_ids = potionScaling.getValidPotionIds(gameEff)
        --effect_potions_id - key for the table containing all the b/c/s/q/e potions for a given effect
        for _, effect_potions_id in pairs(potion_ids) do
            --Initialize potion tables for effects with 0 potions
            if not potion_list[effect_potions_id] then
                potion_list[effect_potions_id] = {}
            end
            --effect_potions - b/c/s/q/e potions for a given effect
            local effect_potions = potion_list[effect_potions_id]
            --Table containing the relevant loaded potion information
            potionScaling.loadedPotions[effect_potions_id] = {}
            --tier - b/c/s/q/e, potion_id - game ID of corresponding potion
            for tier, potion_id in pairs(effect_potions) do
                local potion = tes3.getObject(potion_id)
                if not potion then
                    effect_potions[tier] = nil
                else
                    --Do not consider the possibility of mods adding multi-effect potions
                    pEff = potion.effects[1]
                    --In case some mod adds potions with variable strengths, average out
                    local m = pEff.max
                    if m then
                        m=0.5*(pEff.max+pEff.min)
                    end
                    potionScaling.loadedPotions[effect_potions_id][tier] = {id=potion_id,m=m, d=pEff.duration, v=potion.value}
                end
            end
        end
    end

    --Fix gaps
    --for eff, potions in pairs(potion_list) do
    for _, eff_id in pairs(tes3.effect) do
        local potion_ids = {"e"..eff_id}
        ---@type tes3magicEffect
        local gameEff = tes3.getMagicEffect(eff_id)
        potion_ids = potionScaling.getValidPotionIds(gameEff)
        for _, potion_id in pairs(potion_ids) do
            local potions = potionScaling.loadedPotions[potion_id]
            if dict_size(potions) < 5 then
                --Get highest quality potion
                local best_tier = nil
                if next(potions) then
                    for _, tier in pairs{"e","q","s","c","b"} do
                        if potions[tier] and tes3.getObject(potions[tier].id) then
                            best_tier = tier
                            break
                        end
                    end
                end

                local scale_eff
                if gameEff.hasNoMagnitude == true and gameEff.hasNoDuration == false then
                    scale_eff = config.defaultScalingEffectD
                elseif gameEff.hasNoDuration == false then
                    scale_eff = config.defaultScalingEffectM
                else
                    scale_eff = config.defaultScalingEffectNone
                end
                local referencePotions = potionScaling.loadedPotions["e"..scale_eff]
                potionScaling.scalePotions{targetPotions=potions,
                referencePotions=referencePotions,
                tier=best_tier,
                scaleMagnitude=not gameEff.hasNoMagnitude,
                scaleDuration=not gameEff.hasNoDuration,
                scaleValue=true}
            end
        end
    end
end

return potionScaling