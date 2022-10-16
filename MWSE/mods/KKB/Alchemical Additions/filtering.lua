local config = require("KKB.Alchemical Additions.config")
local common = require("KKB.Alchemical Additions.common")
local filtering = {}
filtering.availableEffects = {}
filtering.availableSchools = {}
filtering.availableValues = {}
filtering.availableWeights = {}
filtering.activeEffectFilters = {}
filtering.activeSchoolFilters = {}
filtering.activeWeightFilters = {}
filtering.activeValueFilters = {}
filtering.UIexp_searchbar= nil
filtering.UIexp_searchText = nil
filtering.OR_filter = false
--1: OFF, 2: <=, 3: ==, 4: >=
filtering.vwModes = {"OFF", "<=", "==", ">="}
filtering.valueMode = 1
filtering.weightMode = 1
filtering.valueIndex = 1
filtering.weightIndex = 1

function filtering.cycleTable(e, table, property)
    filtering[property] = 1 + filtering[property] % #table
    e.forwardSource.text = table[filtering[property]]
    tes3ui.updateInventorySelectTiles()
end

--Get effects, schools, value and weight on an ingredient
---@param ingredient tes3ingredient
function filtering.getIngredientInfo(ingredient)
    local effects = {}
    local schools = {}
    for i=1,4 do
        if ingredient.effects[i] > -1 then
            local baseEffect = tes3.getMagicEffect(ingredient.effects[i])
            local school = baseEffect.school
            local effKey = "e"..ingredient.effects[i]
            if (baseEffect.targetsAttributes or baseEffect.targetsSkills) then
                local stat = ingredient.effectAttributeIds[i] or ingredient.effectSkillIds[i]
                effKey = effKey.."_"..stat
            end
            effects[effKey] = i
            schools["s"..school] = i
        end
    end
    return effects, schools, 0.01*math.floor(100*ingredient.value), 0.01*math.floor(100*ingredient.weight), ingredient.name
end
--Gets all effects the player has access to among his ingredients
--Also gets weights and values
function filtering.getAllAvailableEffects()
    local TV = {}
    local TW = {}
    local numVisibleEffs = math.min(4, math.floor(tes3.mobilePlayer:getSkillStatistic(tes3.skill.alchemy).current / tes3.findGMST('fWortChanceValue').value))
    --mwse.log("NVE: "..numVisibleEffs)
    for _, stack in pairs(tes3.mobilePlayer.inventory) do
        if stack.object.objectType == tes3.objectType["ingredient"] then
            ---@type tes3ingredient
            local ingredient = stack.object
            local ingredientEffects, ingredientSchools, value, weight, _ = filtering.getIngredientInfo(ingredient)
            
            --[[
            local numEffs = 1
            for _, eff in pairs(ingredientEffects) do
                if numEffs <= numVisibleEffs then
                    filtering.availableEffects[eff] = true
                end
                numEffs = numEffs + 1
            end
            numEffs = 1
            for _,school in pairs(ingredientSchools) do
                if numEffs <= numVisibleEffs then
                    filtering.availableSchools[school] = true
                end
                numEffs = numEffs + 1
            end
            ]]
            --mwse.log(ingredient.id)
            for eff, index in pairs(ingredientEffects) do
                if index <= numVisibleEffs then
                    filtering.availableEffects[eff] = true
                end
            end
            for school, index in pairs(ingredientSchools) do
                if index <= numVisibleEffs then
                    filtering.availableSchools[school] = true
                end
            end
            --table.insert(filtering.availableValues, value)
            --table.insert(filtering.availableWeights, weight)
            TV[value] = value
            TW[weight] = weight
        end
    end
    for k,v in pairs(TV) do table.insert(filtering.availableValues, k) end
    for k,v in pairs(TW) do table.insert(filtering.availableWeights, k) end
    table.sort(filtering.availableValues)
    table.sort(filtering.availableWeights)
end

function filtering.checkActiveFilters(activeFilters, ingInfo)
    local numCheckedFilters = 0
    for filter, active in pairs(activeFilters) do
        if active==true then
            numCheckedFilters = numCheckedFilters + 1
            --mwse.log("Testing filter: "..filter)
            --mwse.log(ingInfo[filter])
            --mwse.log("IngInfo keys: ")
            --for k,v in pairs(ingInfo) do print(k.." "..v) end
            if filtering.OR_filter == false and not ingInfo[filter] then
                return false
            elseif filtering.OR_filter==true and ingInfo[filter] then
                return true
            end
        end
    end
    return not filtering.OR_filter or numCheckedFilters == 0
end

function filtering.numericalFilters(x, f, mode)
    if mode == 1 then return true
    elseif mode == 2 and x <= f then return true
    elseif mode == 3 and x == f then return true
    elseif mode == 4 and x >= f then return true
    else return false
    end
end

function filtering.UI_expCompatibility()
    --mwse.log("I'm in.")
    local MIS = tes3ui.findMenu("MenuInventorySelect")
   -- mwse.log(MIS)
    if not MIS then return end
    local FSB = MIS:findChild("UIEXP:FiltersearchBlock")
    --mwse.log(FSB)
    if not FSB then return end
    filtering.UIexp_searchText = FSB.text
    --mwse.log(FSB.text)
    if not filtering.UIexp_searchText then filtering.UIexp_searchText = "" end
    _, _, filtering.UIexp_searchText = string.find(filtering.UIexp_searchText, "(.*)\t+")
    if not filtering.UIexp_searchText then filtering.UIexp_searchText = "" end
    tes3ui.updateInventorySelectTiles()
end
--event.register("UIEXP:updatedInventorySelectTiles", filtering.UI_expCompatibility)

--Check if an ingredient is filtered out
---@param ingredient tes3ingredient
function filtering.checkEffectFilterApplies(ingredient)
    local ingredientEffects, ingredientSchools, value, weight, name = filtering.getIngredientInfo(ingredient)
    --mwse.log("Testing ingredient: "..ingredient.id)
    --UI expansion compatibility
    --filtering.UIexp_searchbar = tes3ui.findMenu("MenuInventorySelect"):findChild("UIEXP:FiltersearchBlock")

    --[[
    if filtering.UIexp_searchText then
        --local filterText = tes3ui.findMenu("MenuInventorySelect"):findChild("UIEXP:FiltersearchBlock").text
        mwse.log("Filtertest: "..filtering.UIexp_searchText)
        local filterText = filtering.UIexp_searchText
        local match = string.find(name, filterText)
        if not match then return false end
    end]]
    if filtering.checkActiveFilters(filtering.activeEffectFilters, ingredientEffects) == false then
        return false
    end
    if filtering.checkActiveFilters(filtering.activeSchoolFilters, ingredientSchools) == false then
        return false
    end
    if filtering.numericalFilters(value, filtering.availableValues[filtering.valueIndex], filtering.valueMode) == false then
        return false
    end
    if filtering.numericalFilters(weight, filtering.availableWeights[filtering.weightIndex], filtering.weightMode) == false then
        return false
    end
    return true
end

---@param element tes3uiElement
---@param w number
---@param h number
function filtering.setWH(element, w, h)
    element.width = element.parent.width * w
    element.height = element.parent.height * h
end

---Create filter menu
---@param e uiActivatedEventData
function filtering.createFilterMenu(e)
    local inventorySelectMenu = e.element
    local idFilterMenu = tes3ui.registerID("KKB_AA:AlchFilterMenu")
    local filterMenu = tes3ui.createMenu{id=idFilterMenu, fixedFrame=true}
    tes3ui.enterMenuMode(idFilterMenu)

    inventorySelectMenu:registerBefore("unfocus", function(e)
        if not e.forwardSource then return true end
		return e.forwardSource.id == inventorySelectMenu.id or e.forwardSource.id == idFilterMenu
	end)
	filterMenu:registerBefore("unfocus", function(e)
        if not e.forwardSource then return true end
		return e.forwardSource.id == inventorySelectMenu.id or e.forwardSource.id == idFilterMenu
	end)

    filterMenu.alpha = 1
	filterMenu.absolutePosAlignX = nil
	filterMenu.absolutePosAlignY = nil
    filterMenu.autoHeight = false
    filterMenu.autoWidth = false
    filterMenu.width=480
    filterMenu.height=500
    filterMenu:updateLayout()
    local filterContainer = filterMenu:createBlock{}
    --filterContainer.autoWidth = true
    --filterContainer.autoHeight = true
    --filterContainer.widthProportional = 1.0
    --filterContainer.heightProportional = 1.0
    filtering.setWH(filterContainer,1.0,1.0)

    filterContainer.flowDirection = "top_to_bottom"

    filtering.getAllAvailableEffects()

    local schoolEffectBlock = filterContainer:createBlock{}
    --schoolEffectBlock.autoWidth = true
    --schoolEffectBlock.autoHeight = true
    --schoolEffectBlock.widthProportional = 1.0
    --schoolEffectBlock.heightProportional = 0.7
    filtering.setWH(schoolEffectBlock,0.9,0.8)
    local schoolEffectPaneBlock = schoolEffectBlock:createBlock{}
    filtering.setWH(schoolEffectPaneBlock, 1.0, 1.0)
    schoolEffectBlock.flowDirection = "top_to_bottom"
    local effectScroll = schoolEffectPaneBlock:createVerticalScrollPane{id="KKB_AA:EffectFilterPane"}
    effectScroll.borderLeft=10
    effectScroll.borderRight = 80
    schoolEffectBlock.borderBottom = 5
    local sortedEffectTable = {}
    for eff, active in pairs(filtering.availableEffects) do
        if active==true then
            local und_pos = eff:find("_")
            local stat
            local key
            if not und_pos then
                key = eff:sub(2)
                stat = nil
            else
                key = eff:sub(2, und_pos -1)
                stat = eff:sub(und_pos + 1)
            end
            local baseEffect = tes3.getMagicEffect(key)
            local attParam = nil
            local skillParam = nil
            if baseEffect.targetsAttributes then
                attParam = tonumber(stat)
            elseif baseEffect.targetsSkills then
                skillParam = tonumber(stat)
            end
            local fullName = tes3.getMagicEffectName{effect=tonumber(key), attribute=attParam, skill=skillParam}
            table.insert(sortedEffectTable, {eff=eff, fullName=fullName})
        end
    end
    table.sort(sortedEffectTable, function(x,y) return x.fullName<y.fullName end)
    local defaultColor
    for i, eff in pairs(sortedEffectTable) do
        local effClick = effectScroll:createTextSelect{id="KKB_AA:EffectSelectText_"..eff.eff, text=eff.fullName}
        local und_pos = eff.eff:find("_")
        local stat
        local key
        if not und_pos then
            key = eff.eff:sub(2)
        else
            key = eff.eff:sub(2, und_pos -1)
        end
        effClick:setPropertyInt("school", tes3.getMagicEffect(tonumber(key)).school)
        defaultColor = effClick.color
        local effFilterID = eff.eff
        if not (filtering.activeEffectFilters[effFilterID] == true) then
            effClick.color = {0.5,0.5,0.5}
        end
        effClick:registerAfter("click", function (e)
            if not filtering.activeEffectFilters[effFilterID] then
                filtering.activeEffectFilters[effFilterID] = true
            else
                filtering.activeEffectFilters[effFilterID] = not filtering.activeEffectFilters[effFilterID]
            end
            --mwse.log("Filter key: "..effFilterID)
            --mwse.log(filtering.activeEffectFilters[effFilterID])
            tes3ui.updateInventorySelectTiles()
        end)
        effClick:registerAfter("mouseLeave", function(e)
            local uiobj = e.forwardSource
            --mwse.log("Leaving object with id: "..uiobj.id)
            if not filtering.activeEffectFilters[effFilterID] or filtering.activeEffectFilters[effFilterID]==false then
                uiobj.color={0.5,0.5,0.5}
            else
                --uiobj.color={1.0,1.0,1.0}
                uiobj.color = defaultColor
            end
            uiobj:getTopLevelMenu():updateLayout()
        end)
    end


    local schoolScroll = schoolEffectPaneBlock:createVerticalScrollPane{id="KKB_AA:SchoolFilterPane"}
    local sortedSchoolTable = {}
    local schoolNames = {"Alteration", "Conjuration", "Destruction", "Illusion", "Mysticism", "Restoration"}
    for school, active in pairs(filtering.availableSchools) do
        if active == true then
            local key = school:sub(2)
            local fullName = schoolNames[tonumber(key)+1]
            table.insert(sortedSchoolTable, {school=school, fullName=fullName})
        end
    end
    table.sort(sortedSchoolTable, function(x,y) return x.fullName<y.fullName end)
    for i, school in pairs(sortedSchoolTable) do
        local schoolClick = schoolScroll:createTextSelect{id="KKB_AA:SchoolSelectText_"..school.school, text=school.fullName}
        schoolClick:setPropertyInt("school", tonumber(school.school:sub(2)))
        local schoolFilterID = school.school
        if not (filtering.activeSchoolFilters[schoolFilterID] == true) then
            schoolClick.color = {0.5,0.5,0.5}
        end
        schoolClick:registerAfter("click", function (e)
            if not filtering.activeSchoolFilters[schoolFilterID] then
                filtering.activeSchoolFilters[schoolFilterID] = true
            else
                filtering.activeSchoolFilters[schoolFilterID] = not filtering.activeSchoolFilters[schoolFilterID]
            end
            --mwse.log("Filter key: "..schoolFilterID)
            --mwse.log(filtering.activeSchoolFilters[schoolFilterID])
            --Also hide relevant filters from the effect scroller
            for _, effClick in pairs(effectScroll.children[1].children[1].children) do
                local eS = effClick:getPropertyInt("school")
                local effVisible = false
                local numSchoolFiltersChecked = 0
                for schoolID, active in pairs(filtering.activeSchoolFilters) do
                    if active == true then
                        local sS = tonumber(schoolID:sub(2))
                        numSchoolFiltersChecked = numSchoolFiltersChecked + 1
                        if eS == sS then
                            effVisible = true
                            break
                        end
                    end
                end
                effClick.visible = numSchoolFiltersChecked == 0 or effVisible
            end
            filterMenu:updateLayout()
            tes3ui.updateInventorySelectTiles()
        end)
        schoolClick:registerAfter("mouseLeave", function(e)
            local uiobj = e.forwardSource
            if not filtering.activeSchoolFilters[schoolFilterID] or filtering.activeSchoolFilters[schoolFilterID]==false then
                uiobj.color={0.5,0.5,0.5}
            else
                --uiobj.color={1.0,1.0,1.0}
                uiobj.color = defaultColor
            end
            uiobj:getTopLevelMenu():updateLayout()
        end)

    end

    local valueWeightBlock = filterContainer:createBlock{}
    filtering.setWH(valueWeightBlock,1.0,0.1)
    --valueWeightBlock.autoWidth= true
    --valueWeightBlock.autoHeight = true
    --valueWeightBlock.widthProportional = 1.0
    --valueWeightBlock.heightProportional = 0.2
    --valueWeightBlock.heightProportional = 0.2
    --valueWeightBlock.childAlignX = -1
    local valueBlock = valueWeightBlock:createBlock{}

    --valueBlock.autoWidth = true
    --valueBlock.autoHeight = true
    filtering.valueIndex = #(filtering.availableValues)
    valueBlock:createLabel{text="Value: "}
    valueBlock.childAlignY = 0.5
    local valueButton = valueBlock:createButton{id="KKB_AA:ValueModeButton", text=filtering.vwModes[1]}
    --mwse.log("FV: "..filtering.availableValues[filtering.valueIndex])
    local valueAmount = valueBlock:createButton{id="KKB_AA:ValueAmountButton"}
    valueAmount.text = filtering.availableValues[filtering.valueIndex]
    valueButton:register("click", function(e) filtering.cycleTable(e, filtering.vwModes, "valueMode") end)
    valueAmount:register("click", function(e) filtering.cycleTable(e, filtering.availableValues, "valueIndex") end)
    --valueBlock.widthProportional = 0.5
    --valueBlock.heightProportional = 1.0
    filtering.setWH(valueBlock,0.5,1.0)

    local weightBlock = valueWeightBlock:createBlock{}
    --weightBlock.autoWidth = true
   -- weightBlock.autoHeight = true
    filtering.weightIndex = 1
    weightBlock:createLabel{text="Weight: "}
    weightBlock.childAlignY = 0.5
    local weightButton = weightBlock:createButton{id="KKB_AA:WeightModeButton", text=filtering.vwModes[1]}
    weightButton:register("click", function(e) filtering.cycleTable(e, filtering.vwModes, "weightMode") end)
    --mwse.log("FW: "..filtering.availableWeights[filtering.weightIndex])
    local weightAmount = weightBlock:createButton{id="KKB_AA:WeightAmountButton"}
    weightAmount.text = filtering.availableWeights[filtering.weightIndex]
    weightAmount:register("click", function(e) filtering.cycleTable(e, filtering.availableWeights, "weightIndex") end)
    --weightBlock.widthProportional = 0.5
    --weightBlock.heightProportional = 1.0
    filtering.setWH(weightBlock,0.5,1.0)

    local buttonBlock = filterContainer:createBlock{}
    --buttonBlock.widthProportional = 1.0
    --buttonBlock.heightProportional = 0.1
    --buttonBlock.autoWidth = true
    --buttonBlock.autoHeight = true
    --buttonBlock.heightProportional = 0.1
    filtering.setWH(buttonBlock,1.0,0.1)
    local resetButton = buttonBlock:createButton{id="KKB_AA:FilterResetButton", text="Reset Filter"}
    resetButton:registerAfter("click", function(e)
        for _, filterClick in pairs(effectScroll.children[1].children[1].children) do
            --mwse.log("Color reset!")
            filterClick.color = {0.5,0.5,0.5}
            filterClick.visible = true
            --filterClick:updateLayout()
            --filterClick:triggerEvent("mouseLeave")
        end
        for _, filterClick in pairs(schoolScroll.children[1].children[1].children) do
            --mwse.log("Color reset!")
            filterClick.color = {0.5,0.5,0.5}
            --filterClick:updateLayout()
            --filterClick:triggerEvent("mouseLeave")
        end
        filtering.activeEffectFilters = {}
        filtering.activeSchoolFilters = {}
        filtering.activeWeightFilters = {}
        filtering.activeValueFilters = {}
        filtering.valueIndex = #filtering.availableValues
        filtering.weightIndex = 1
        filtering.valueMode = 1
        filtering.weightMode = 1
        valueButton.text = filtering.vwModes[filtering.valueMode]
        weightButton.text = filtering.vwModes[filtering.weightMode]
        valueAmount.text = filtering.availableValues[filtering.valueIndex]
        weightAmount.text = filtering.availableWeights[filtering.weightIndex]
        tes3ui.updateInventorySelectTiles()
        tes3ui.findMenu("KKB_AA:AlchFilterMenu"):updateLayout()
     end)
     local OR_text = "AND"
     if filtering.OR_filter == true then OR_text = "OR" end
     local ORbutton = buttonBlock:createButton{id="KKB_AA:FilterORButton", text=OR_text}
     ORbutton:register("click", function(e)
        local ORbutton = e.forwardSource
        filtering.OR_filter = not filtering.OR_filter
        local OR_text = "AND"
        if filtering.OR_filter == true then OR_text = "OR" end
        ORbutton.text=OR_text
        tes3ui.updateInventorySelectTiles()
    end)
    common.createToolTip(ORbutton, "Controls whether filtering is done by requiring all school/effect filters to apply or just one of them.")



     filterMenu.positionY = inventorySelectMenu.positionY
     filterMenu.positionX = inventorySelectMenu.positionX + inventorySelectMenu.width + 10
    --Evil menu magic that somehow gets the menu positions right
    --[[
	inventorySelectMenu:updateLayout()
	filterMenu.positionY = inventorySelectMenu.positionY
	filterMenu.positionX = inventorySelectMenu.positionX + inventorySelectMenu.width + 10
	filterMenu:updateLayout()
	filterMenu.autoWidth = true
    filterMenu.autoHeight = true
	filterMenu:updateLayout()
	filterMenu.autoHeight = false
	filterMenu:updateLayout()]]
	inventorySelectMenu:updateLayout()
    --filterMenu.width=600
    --filterMenu.height=800
    filterMenu:updateLayout()
    filterMenu.width = filterMenu.width + 30
    filterMenu:updateLayout()
    return filterMenu
end

---@param e filterInventorySelectEventData
function filtering.invSelectFilter(e)
    if config.filtering == false or common.currentlyLoading then
        return
    end
    if e.type ~= "ingredient" then
        tes3ui.findMenu("KKB_AA:AlchFilterMenu").visible = false
        return
    else
        tes3ui.findMenu("KKB_AA:AlchFilterMenu").visible = true
    end
    if not e.item.objectType or e.item.objectType ~= tes3.objectType["ingredient"] then
         e.filter = false
    end
    if e.filter == false then
        return
    else
        e.filter = filtering.checkEffectFilterApplies(e.item)
    end
end

---Clean up event handlers
---@param e tes3uiEventData
function filtering.cleanEvents(e)
    --event.unregister("uiActivated", filtering.createFilterMenu, {filter="MenuInventorySelect"})
    event.unregister("filterInventorySelect", filtering.invSelectFilter, {type="ingredient"})
    e.forwardSource:unregisterAfter("destroy", filtering.cleanEvents)
    tes3ui.findMenu("KKB_AA:AlchFilterMenu"):destroy()
end

---@param e uiActivatedEventData
function filtering.activateFilter(e)
    local alchMenu = tes3ui.findMenu("MenuAlchemy")
    if config.filtering == false or common.currentlyLoading or (not alchMenu or alchMenu.visible==false) then
        return
    end
    --event.register("uiActivated", filtering.createFilterMenu, {filter="MenuInventorySelect"})
    local filterMenu = filtering.createFilterMenu{element=e.element}
    event.register("filterInventorySelect", filtering.invSelectFilter, {type="ingredient"})
    tes3ui.updateInventorySelectTiles()
    --filtering.UIexp_searchbar = tes3ui.findMenu("MenuInventorySelect"):findChild("UIEXP:FiltersearchBlock")
    e.element:registerAfter("destroy", filtering.cleanEvents)
    filterMenu:registerAfter("destroy", function()
        filtering.availableEffects = {}
        filtering.availableSchools = {}
        filtering.availableValues = {}
        filtering.availableWeights = {}
    end)
end



return filtering
