local config = require("KKB.Alchemical Additions.config")
local common = require("KKB.Alchemical Additions.common")
local npcBrewing = {}
npcBrewing.apparatusList = {}

--Don't get skill progress when using NPC brewing
---@param e exerciseSkillEventData
function npcBrewing.blockNPCProgress(e)
    if e.skill==tes3.skill.alchemy and config.npcBrewing==true and config.scalePotions==true and npcBrewing.active == true then
        e.block = true
    end
end

--Calc potion brew chance
---@param e potionBrewSkillCheckEventData
function npcBrewing.brewChance(e)
    if config.npcBrewing == false or npcBrewing.active == false then
        return
    end
    local A = common.stats.Alchemy
    local I = common.stats.Intelligence
    local L = common.stats.Luck
    local x = config.strengthContribution.alchWeight*A+
	config.strengthContribution.intWeight*I+
	config.strengthContribution.lckWeight*L
    local roll = math.floor(100 * math.random())
    if (roll <= x or (config.npcBrewing==true and npcBrewing.active==true)) then
        --e.potionStrength =  e.mortar.quality * x
        e.success = true
    else
        e.potionStrength = -1
        e.success = false
    end
end

--npcBrewing.oldInvVis = false
---@param e tes3uiEventData
function npcBrewing.hideInventory(e)
    if e.forwardSource.visible == true and tes3ui.findMenu("MenuDialog").visible == true then
       e.forwardSource.visible = false
       e.forwardSource:unregisterAfter("update", npcBrewing.hideInventory)
    end
end

function  npcBrewing.onClickBrew(actor, mobileActor, menuDialogue)
    local barterService = menuDialogue:findChild("MenuDialog_service_barter")
    if not barterService then
		return
	end
	local oldApp = actor.aiConfig.bartersApparatus
	actor.aiConfig.bartersApparatus = true

    ---@param e  filterBarterMenuEventData
	local function apparatusFilter(e)
		if e.item.objectType == tes3.objectType.apparatus then
            table.insert(npcBrewing.apparatusList, {id=e.item.id, c=e.tile.count, data=e.itemData})
            return true
		else
			return false
		end
	end
	event.register("filterBarterMenu", apparatusFilter)
	barterService:triggerEvent("mouseClick")
	local menuBarter = tes3ui.findMenu("MenuBarter")
    local menuInventory = tes3ui.findMenu("MenuInventory")
    
	if menuBarter then
		--menuBarter:findChild("MenuBarter_Cancelbutton"):triggerEvent("mouseClick")
        tes3ui.findMenu("MenuInventory").visible=false
        menuBarter:destroy()
        --npcBrewing.oldInvVis = menuInventory.visible
        menuInventory:registerAfter("update", npcBrewing.hideInventory)
        --menuInventory:destroy()
		event.unregister("filterBarterMenu", apparatusFilter)
		for _, app in pairs(npcBrewing.apparatusList) do
			tes3.addItem{ reference = tes3.player, item = app.id, count = app.c, itemData=app.data, playSound = false, updateGUI = true }
		end
        npcBrewing.active = true
        common.currentBrewer = mobileActor
        
		tes3.showAlchemyMenu()
	end
	actor.aiConfig.bartersApparatus = oldApp
end

--Add brewing button to valid npcS
---@param e uiActivatedEventData
function npcBrewing.enterConversation(e)
    local menuDialogue = e.element
	local mobileActor = menuDialogue:getPropertyObject("PartHyperText_actor")
    ---@type tes3npcInstance
    local actor = mobileActor.reference.object
	local classID = string.upper(actor.class.id)
    if not classID or config.npcBrewing==false or not config.allowedClasses[classID] or actor.aiConfig.bartersAlchemy==false or actor.aiConfig.bartersIngredients==false then
		return
	end 
    local divider = menuDialogue:findChild("MenuDialog_topics_pane"):findChild("MenuDialog_divider")
    local topicPane = divider.parent
    local brew = topicPane:createTextSelect{id = tes3ui.registerID("KKB:AA_MenuDialog_brew"), text = "Brew Potions"}
    brew:register("mouseClick", function()
        npcBrewing.onClickBrew(actor, mobileActor, menuDialogue)
    end)
    topicPane:reorderChildren(divider, brew, 1)
    menuDialogue:updateLayout()
    menuDialogue:registerAfter("preUpdate", function(e)
        local brewText = menuDialogue:findChild("MenuDialog_topics_pane"):findChild("KKB:AA_MenuDialog_brew")
        if brewText then
            brewText.visible = true
        end
    end)
end

---@param e tes3uiEventData
function npcBrewing.removeExtraTools(e)
    for _, apparatus in pairs(npcBrewing.apparatusList) do
        tes3.removeItem{reference=tes3.mobilePlayer, item=apparatus.id, count=apparatus.c, itemData=apparatus.data, playSound = false, updateGUI = true}
    end
    npcBrewing.apparatusList = {}
    --tes3ui.findMenu("MenuInventory")
    e.forwardSource:unregisterBefore("destroy", npcBrewing.removeExtraTools)
    --e.forwardSource:unregisterAfter{eventID="destroy", callback=npcBrewing.removeExtraTools}
end

return npcBrewing