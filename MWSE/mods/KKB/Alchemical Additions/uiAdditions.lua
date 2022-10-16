local config = require("KKB.Alchemical Additions.config")
local common = require("KKB.Alchemical Additions.common")
local potionBrewing = require("KKB.Alchemical Additions.potionBrewing")
local npcBrewing = require("KKB.Alchemical Additions.npcBrewing")
local uiAdditions = {}
uiAdditions.ingredientSelects = {"MenuAlchemy_ingredient_one", "MenuAlchemy_ingredient_two", "MenuAlchemy_ingredient_three", "MenuAlchemy_ingredient_four"}
uiAdditions.batchMode = false
uiAdditions.currentRecipeIngredient = nil
uiAdditions.oldName = nil

function uiAdditions.resetName(e)
    if config.potionNameFormatting == false then return end
    local potion_name = tes3ui.findMenu("MenuAlchemy"):findChild("MenuAlchemy_potion_name")
    potion_name.text = uiAdditions.old_name.."|"
    tes3ui.acquireTextInput(potion_name)
end

function uiAdditions.formatName()
    local alchMenu = tes3ui.findMenu("MenuAlchemy")
    local effect_pane = alchMenu:findChild("MenuAlchemy_effectarea"):findChild("PartScrollPane_pane")
    local potion_name = alchMenu:findChild("MenuAlchemy_potion_name")

    local ingredientNames = {}
    for i=1,4 do
        ---@type tes3ingredient
        local obj = alchMenu:findChild(uiAdditions.ingredientSelects[i]):getPropertyObject("MenuAlchemy_object")
        if obj then
            ingredientNames[i] = obj.name
        end
    end
	
    local s = string.gsub(potion_name.text, "%%E", function()
        if effect_pane.children[1] == nil then
            return "%E"
        end
        return effect_pane.children[1].children[2].text
    end)
	
	for i, name in ipairs(ingredientNames) do
		if name ~= nil then
			local ingtags = {"A","B","C","D"}
			s = string.gsub(s, "%%"..ingtags[i], name)
		end
	end

    if s:len() > 31 then s = s:sub(1,31) end
    uiAdditions.old_name = potion_name.text
    potion_name.text = s.."|"
    tes3ui.acquireTextInput(potion_name)
end


--Save current recipe in player data
--No two recipes with the same name allowed
function uiAdditions.saveRecipe(alchemyMenu)
    local name = alchemyMenu:findChild("MenuAlchemy_potion_name").text
    if tes3.player.data.KKB_AA.recipeLibrary[name] then
        --tes3.messageBox("A recipe with this name already exists!")
        --return false
    end
    local recipe = {name="", ingredients={}, effects={}, tooltip=""}
    recipe.name = name
    recipe.tooltip = name
    for i=1,4 do
        local ingredient = alchemyMenu:findChild(uiAdditions.ingredientSelects[i]):getPropertyObject("MenuAlchemy_object")
        if ingredient then 
            recipe.ingredients[i] = ingredient.id
            recipe.tooltip = recipe.tooltip.."\n"..ingredient.name
        end
    end
    local effectPane = alchemyMenu:findChild("MenuAlchemy_effectarea"):findChild("PartScrollPane_pane")
    for i, effect in ipairs(effectPane.children) do
        recipe.effects[i] = {name=effect.children[2].text, icon=effect.children[1].contentPath}
    end
    --return recipe
    tes3.player.data.KKB_AA.recipeLibrary[recipe.name] = recipe
    return true
end


--Filter out everything except the ingredient we are currently interested in
---@param e uiActivatedEventData
function uiAdditions.pickIngredient(e)
	local selectMenu = e.element
    common.currentlyLoading = true
	local ingList = selectMenu:findChild("PartScrollPane_pane")
	for _, icon in pairs(ingList.children) do
		if icon then
			local iconObj = icon:getPropertyObject("MenuInventorySelect_object")
			if iconObj and iconObj.id == uiAdditions.currentRecipeIngredient then
				icon:triggerEvent("mouseClick")
				return
			end
		end
	end
	if selectMenu.visible then
		selectMenu:destroy()
	end
    common.currentlyLoading = nil
    event.unregister("uiActivated", uiAdditions.pickIngredient, { filter = "MenuInventorySelect" })
end

--Load current recipe
function uiAdditions.loadRecipe(alchemyMenu, recipe)
    for i, recipeIngredient in ipairs(recipe.ingredients) do
        if recipeIngredient then
            local ingredientSelect = alchemyMenu:findChild(uiAdditions.ingredientSelects[i])
            --Wipe ingredient if already present
            if ingredientSelect:getPropertyObject("MenuAlchemy_object") then
                ingredientSelect:triggerEvent("mouseClick")
            end
            
            --Grab current ingredient from inventory
            uiAdditions.currentRecipeIngredient = recipeIngredient
            event.register("uiActivated", uiAdditions.pickIngredient, { filter = "MenuInventorySelect" })
            common.currentlyLoading = true
            ingredientSelect:triggerEvent("mouseClick")
            common.currentlyLoading = false
            event.unregister("uiActivated", uiAdditions.pickIngredient, { filter = "MenuInventorySelect" })
        end
        uiAdditions.currentRecipeIngredient = nil
        local potionTextField = alchemyMenu:findChild("MenuAlchemy_potion_name")
        potionTextField.text = recipe.name .. "|"
        tes3ui.acquireTextInput(potionTextField)
    end
end

---@param e tes3uiElement
function uiAdditions.recursiveHW(e, first)
    if not e then return end
    if type(e) == 'number' then return end
    for child in pairs(e.children) do
        uiAdditions.recursiveHW(child, false)
    end
    if first == false then
        e.autoHeight = true
        e.autoWidth = true
    end
end


function uiAdditions.supersizeEff(s)
    local ret = string.upper(s)
    ret = ret:gsub("^S\\TX", "S\\B_TX")
    ret = ret:gsub("^ICONS\\S\\TX", "ICONS\\S\\B_TX")
    return ret
end

--Creates recipe menu
---@param e tes3uiEventData
function uiAdditions.createRecipeBook(e)
	--Recipe scroll pane
	local recipeMenu = tes3ui.createMenu{ id = tes3ui.registerID("KKB_AA:MenuRecipe"), fixedFrame = true }
    local alchemyMenu = e.forwardSource:getTopLevelMenu()
	recipeMenu.autoHeight = false recipeMenu.autoWidth = false
	recipeMenu.height = 810
	recipeMenu.width = 810
	recipeMenu.flowDirection = "top_to_bottom"
	local recipeBlock = recipeMenu:createBlock{}
	recipeBlock.widthProportional = 1 recipeBlock.heightProportional = 1.85 recipeBlock.childAlignX = 0.5
	local recipeScrollPane = recipeBlock:createVerticalScrollPane{}
	
	--Buttons + their containers
	local buttonBlock = recipeMenu:createBlock{}
	buttonBlock.widthProportional = 1 buttonBlock.heightProportional = 0.2 buttonBlock.childAlignX = -1 buttonBlock.childAlignY = 0.5
	local addModeBlock = buttonBlock:createBlock{}
	addModeBlock.autoWidth = true addModeBlock.autoHeight = true
	local addButton = addModeBlock:createImage{id=tes3ui.registerID("KKB_AA:AddRecipeButton"), path="Icons\\kkb\\newPotion.tga"}
    common.createToolTip(addButton, "Save a new recipe")
	addButton:registerAfter("mouseClick", function()
		local success = uiAdditions.saveRecipe(alchemyMenu)
		if success==true then recipeMenu:destroy() end
	end)
 
    local wmax = 0
    local sortedRecipeKeys = {}
    for k,v in pairs(tes3.player.data.KKB_AA.recipeLibrary) do table.insert(sortedRecipeKeys, k) end
    table.sort(sortedRecipeKeys)
    for _, k in pairs(sortedRecipeKeys) do
        --mwse.log("Currently handling: "..k)
        local recipe = tes3.player.data.KKB_AA.recipeLibrary[k]
        local currentRecipeBlock = recipeScrollPane:createBlock{}
		local childBorder = currentRecipeBlock:createThinBorder{}
		childBorder.widthProportional = 1 childBorder.heightProportional = 1 childBorder.borderBottom = 3
		childBorder.childAlignX = -1 childBorder.childAlignY = 0.5
        local nameBlock = childBorder:createBlock{}
        --nameBlock.widthProportional=0.4 nameBlock.heightProportional = 1.0
        nameBlock.autoHeight = true
        nameBlock.autoWidth = true
        nameBlock.borderLeft = 20
        --nameBlock.width = 200
        --nameBlock.height = 20
        local ingredientsBlock = childBorder:createBlock{}
        ingredientsBlock.autoHeight = true
        ingredientsBlock.autoWidth = true
        --ingredientsBlock.widthProportional=0.6 ingredientsBlock.heightProportional = 1.0
        --nameBlock.borderLeft = 10
        --nameBlock.borderRight = 10
        --ingredientsBlock.width = 200
        --ingredientsBlock.height = 20
        ingredientsBlock.borderLeft = 20
        ingredientsBlock.borderRight = 20

        local effectsBlock = childBorder:createBlock{}
        effectsBlock.autoHeight = true
        effectsBlock.autoWidth = true
        effectsBlock.borderRight = 20
        effectsBlock.borderLeft = 20
        effectsBlock.flowDirection = "top_to_bottom"
        local firstEffRow = effectsBlock:createBlock{}
        firstEffRow.autoHeight = true
        firstEffRow.autoWidth = true
        local secondEffRow = effectsBlock:createBlock{}
        secondEffRow.autoHeight = true
        secondEffRow.autoWidth = true
        firstEffRow.borderBottom = 5
        local rows = {firstEffRow, secondEffRow}

        local deleteBlock = childBorder:createBlock{}
        deleteBlock.autoHeight = true
        deleteBlock.autoWidth = true
        deleteBlock.borderLeft = 20
        deleteBlock.borderRight = 60
        local deleteButton = deleteBlock:createButton{id="KKB_AA:deleteRecipeButton", text="Delete"}
        deleteButton:registerAfter("click", function(e) 
            e.forwardSource.parent.parent:destroy()
            tes3.player.data.KKB_AA.recipeLibrary[k] = nil
            e.forwardSource:getTopLevelMenu():updateLayout()
        end)
        recipeMenu:updateLayout()

        nameBlock:createLabel{text=recipe.name}
        local tooltip = "Name: " .. recipe.name .. "\nIngredients: "
        for i, ingredient in ipairs(recipe.ingredients) do
            if ingredient then
                local ingredientObject = tes3.getObject(ingredient)
                local ingredientIcon = ingredientObject.icon
                local iconUI = ingredientsBlock:createImage{path = "Icons\\" .. ingredientIcon}
                iconUI.borderAllSides = 2
                tooltip = tooltip .. ingredientObject.name .. ", "
            end
        end
        tooltip = tooltip:sub(1,-3) .. "\nEffects: "
        
        for i, effect in ipairs(recipe.effects) do
            if effect then
                tooltip = tooltip .. effect.name .. ", "
                rows[1+math.floor((i-0.1)/4)]:createImage{path=effect.icon}
            end
        end
        tooltip = tooltip:sub(1,-3)
        common.createToolTip(currentRecipeBlock, tooltip)
        uiAdditions.recursiveHW(recipeBlock, false)
        childBorder.parent.width = 810
        childBorder.parent.height = 50
        recipeMenu:updateLayout()
        currentRecipeBlock:register("click", function(e) 
            uiAdditions.loadRecipe(alchemyMenu, recipe)
            recipeMenu:destroy()
        end)
    end

	local cancelButtonBlock = buttonBlock:createBlock{}
	cancelButtonBlock.autoWidth = true cancelButtonBlock.autoHeight = true
	
	local cancelButton = cancelButtonBlock:createButton{id=tes3ui.registerID("KKB_AA:RecipeCancelButton"), text=tes3.findGMST("sCancel").value}
	cancelButton:register("mouseClick", function() recipeMenu:destroy() end)

    recipeMenu:updateLayout()
end

---Click X times for batch
---@param e tes3uiEventData
function uiAdditions.batchClick(e)
    if uiAdditions.batchMode == true then
        return
    end
    uiAdditions.batchMode = true
    local alchemyMenu = e.forwardSource:getTopLevelMenu()
    local count = nil
    for i, ingredientSelect in ipairs(uiAdditions.ingredientSelects) do
        local ingredientBox = alchemyMenu:findChild(ingredientSelect)
        if ingredientBox:getPropertyObject("MenuAlchemy_object") then
            local countBox = ingredientBox:findChild("MenuAlchemy_count")
            local c
            if countBox then
                c = tonumber(countBox.text)
            else
                c = 1
            end
            if not count or c < count then
                count = c
            end
        end
    end
    count = math.min(count, config.batch_vals[tes3.player.data.KKB_AA.currentBatch])
    if common.currentPrice and config.npcBrewing==true and npcBrewing.active == true then
        local available_gold = tes3.getItemCount{reference=tes3.mobilePlayer, item="gold_001"}
        local num_allowed_potions = math.floor(available_gold/common.currentPrice)
        count = math.min(num_allowed_potions, count)
        if num_allowed_potions == 0 then
            tes3.messageBox("Not enough gold to pay for this potion!")
            uiAdditions.batchMode = false
            return false
        else
            local total_spent_gold = count * common.currentPrice
            tes3.removeItem{reference=tes3.mobilePlayer, item="gold_001", count=total_spent_gold}
            common.currentBrewer.barterGold = common.currentBrewer.barterGold + total_spent_gold
        end
    end
    for i=1,count-1 do
        e.forwardSource:triggerEvent("click")
    end
    uiAdditions.batchMode = false
end

--Add new buttons and labels to MenuAlchemy
---@param e uiActivatedEventData
function uiAdditions.addButtons(e)
    if (not e.newlyCreated) then
		return
	end
    if not (config.uiAdditions or config.scalePotions) then
        return
    end
    local alchemyMenu = e.element
    local createButton = alchemyMenu:findChild("MenuAlchemy_create_button")
    if config.potionNameFormatting then
        createButton:registerBefore("click", uiAdditions.formatName)
        
    end
    
    local nameContainer = alchemyMenu:findChild("MenuAlchemy_potion_name").parent.parent
    local statBlock
    if config.scalePotions then
        alchemyMenu.width = 1.2 * alchemyMenu.width
        nameContainer.childAlignX=-1
        statBlock = nameContainer:createBlock{id="KKB_AA:uiAdditionStatBlock"}
        statBlock.flowDirection = "top_to_bottom"
        statBlock.childAlignX = 1
        statBlock.autoWidth = true
        statBlock.autoHeight = true
        statBlock.borderLeft = 50
        common.createToolTip(statBlock, "Effective stats of current potion brewer.")
        if npcBrewing.active == true then
            statBlock:createLabel{id="KKB_AA:BrewerName", text=common.currentBrewer.reference.object.name}
        end
        --statBlock.visible = true
        for stat, value in pairs(common.stats) do
            local l = statBlock:createLabel{id="KKB_AA:"..stat.."Label", text=stat..": "..value}
            --l.visible=true
        end
    end

    if config.uiAdditions then
        alchemyMenu.width = 1.2 * alchemyMenu.width
        ---@type tes3uiElement
        local buttonContainer = createButton.parent
        buttonContainer.borderTop = 10
        buttonContainer.childAlignX = -1
        local uiAdditionBlock = buttonContainer:createBlock{id="KKB_AA:uiAdditionBlock"}
        uiAdditionBlock.autoWidth = true
        uiAdditionBlock.autoHeight = true
        uiAdditionBlock.borderRight = 5
        buttonContainer:reorderChildren(0, uiAdditionBlock, -1)
        buttonContainer:reorderChildren(2, createButton, 1)

        local recipeBookBlock = uiAdditionBlock:createBlock{id="KKB_AA:recipeBookButtonBlock"}
        recipeBookBlock.autoWidth = true
        recipeBookBlock.autoHeight = true
        local recipeBookButton = recipeBookBlock:createButton{id="KKB_AA:recipeBookButton", text="Open Recipe Book"}
        recipeBookButton:register("click", uiAdditions.createRecipeBook)
        common.createToolTip(recipeBookButton, "Open recipe manager for saving and loading potion recipes.")
        
        local batchBlock = uiAdditionBlock:createBlock{id="KKB_AA:batchBrewBlock"}
        batchBlock.autoWidth = true
        batchBlock.autoHeight = true
        local batchButton = batchBlock:createButton{id="KKB_AA:batchBrewButton", text="Batch: "..config.batch_vals[tes3.player.data.KKB_AA.currentBatch]}
        batchButton:register("click", function(e) 
            tes3.player.data.KKB_AA.currentBatch = 1 + tes3.player.data.KKB_AA.currentBatch % 4
            e.forwardSource.text = "Batch: "..config.batch_vals[tes3.player.data.KKB_AA.currentBatch]
        end)
        common.createToolTip(batchButton, "How many potions to brew at once.")
        batchBlock.childAlignY = 0.5
        if config.npcBrewing==true and npcBrewing.active == true then
            local costLabel = batchBlock:createLabel{id="KKB_AA:PotionCostLabel"}
            local basePrice = common.calcLevels(common.stats.Alchemy, common.stats.Intelligence, common.stats.Luck)
            local price = math.floor(common.barterOffer(common.currentBrewer, basePrice , false))
            price = math.max(price, 1)
            common.currentPrice = price
            costLabel.text = "Cost: "..price
        end
        createButton:registerBefore("click", uiAdditions.batchClick)


    end
    event.register("potionBrewed", uiAdditions.resetName)
    event.register("potionBrewFailed", uiAdditions.resetName)
    alchemyMenu:register("destroy", function() 
        event.unregister("potionBrewed", uiAdditions.resetName)
        event.unregister("potionBrewFailed", uiAdditions.resetName)
    end)
    alchemyMenu:updateLayout()

end



return uiAdditions