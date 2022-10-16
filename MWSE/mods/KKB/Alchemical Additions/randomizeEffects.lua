local config = require("KKB.Alchemical Additions.config")
local randomizeEffects = {}

--Sums all the charcodes in a string to get a hash to augment our random seed
function hashString(str)
    hash = 0
    for i = 1, #str do
        hash = hash + string.byte(str,i,i)
    end
    return hash
end

function randomizeEffects.getMultiplier(mean, seed_add)
    --Seed to ensure no savescumming
    math.randomseed(tes3.player.data.KKB_AA.randomSeed + seed_add)
    --Gaussian scale param
    local scale = config.randomizeIngredientsScale
    --Gaussian roll
    R = math.sqrt(-2 * scale * scale * math.log(math.random())) *
            math.cos(2 * math.pi * math.random()) + mean
    --We only want multipliers ending in 5
    R = 0.05 * math.floor(R*20 + 0.5)
    return R
end

function randomizeEffects.displayMultipliers(tooltip, ingredient)
    local effectIndex = 1
    local effectBlockId = tes3ui.registerID('HelpMenu_effectBlock')
    for i, effectBlock in pairs(tooltip:findChild('PartHelpMenu_main').children) do
        if effectBlock.id == effectBlockId then
            local checkUnknown = effectBlock:   findChild("HelpMenu_effectIcon").text == "?"
            if checkUnknown == false then
                effectBlock:createLabel(
                    {   id="KKB_AA:MultiplierLabel"..effectIndex,
                        text=" "..tes3.player.data.KKB_AA.rolledIngredients[ingredient.id][effectIndex][1].."x"}
                )
            end
            effectIndex = effectIndex + 1
        end
    end
end

---@param e uiObjectTooltipEventData
function randomizeEffects.onIngredientToolTip(e)
	local ingredient = e.object
	if e.object.objectType ~=  tes3.objectType.ingredient then
        return true
    end
    --Assign multipliers to an ingredient on first mouseouver
    if not tes3.player.data.KKB_AA.rolledIngredients[ingredient.id] then
        tes3.player.data.KKB_AA.rolledIngredients[ingredient.id] = {}
        mean = config.ingredientValueThresholds.t0
        thresh = 1
        for k,v in pairs(config.ingredientValueThresholds) do
            if tonumber(v) > thresh and ingredient.value >=tonumber(v) then
                mkey = "m"..k:sub(2)
                mean = config.ingredientValueMeans[mkey]
                thresh = tonumber(v)
            end
        end
        for i, effect in ipairs(ingredient.effects) do
            multiplier = randomizeEffects.getMultiplier(mean, 1000*i+effect+hashString(ingredient.id))
            table.insert(tes3.player.data.KKB_AA.rolledIngredients[ingredient.id], {multiplier, effect, ingredient.effectAttributeIds[i] or ingredient.effectSkillIds[i]})
        end
    end
    --Display multipliers on mouseover
    if config.randomizeIngredients == true then
        randomizeEffects.displayMultipliers(e.tooltip, ingredient)
    end
end

return randomizeEffects 