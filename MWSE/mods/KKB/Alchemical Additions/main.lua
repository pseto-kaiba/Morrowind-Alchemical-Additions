local config = require("KKB.Alchemical Additions.config")
local common = require("KKB.Alchemical Additions.common")
-- Setup MCM.
local function registerModConfig()
	--config.defaultStrengthThresholds = common.calcDefaultStrengthThresholds()
	
	mwse.mcm.registerMCM(require("KKB.Alchemical Additions.mcm"))
end
event.register("modConfigReady", registerModConfig)

local randomizeEffects = require("KKB.Alchemical Additions.randomizeEffects")
local potionScaling = require("KKB.Alchemical Additions.potionScaling")
local potionBrewing = require("KKB.Alchemical Additions.potionBrewing")
local npcBrewing = require("KKB.Alchemical Additions.npcBrewing")
local filtering = require("KKB.Alchemical Additions.filtering")
local uiAdditions = require("KKB.Alchemical Additions.uiAdditions")



local function onLoaded(e)
	-- Init the table for all the savefile data if empty
	if not tes3.player.data.KKB_AA then
		tes3.player.data.KKB_AA = {}
	end
	--Table for all the ingredients the player has seen so far
	if not tes3.player.data.KKB_AA.rolledIngredients then
		tes3.player.data.KKB_AA.rolledIngredients = {}
	end
	--Table for all the potions the player has made -> prevent bloating the savefile with potion IDs each time a new potion is brewed
	--Also prevents making unstackable potions - if a potion would be made identical to an existing potion, just give the player that potion instead
	if not tes3.player.data.KKB_AA.potionLibrary then
		tes3.player.data.KKB_AA.potionLibrary = {}
	end

	--All of the player's recipes
	if not tes3.player.data.KKB_AA.recipeLibrary then
		tes3.player.data.KKB_AA.recipeLibrary = {}
	end

	--Init random seed for player, used for rolling ingredients
	if not tes3.player.data.KKB_AA.randomSeed then
		tes3.player.data.KKB_AA.randomSeed = math.random(10000000)
	end

	--Calculate potion strength thresholds
	common.basePotionThresholds = common.calcDefaultStrengthThresholds()

	--Current batch brew setting.
	if not tes3.player.data.KKB_AA.currentBatch then
		tes3.player.data.KKB_AA.currentBatch = 1
	end

	--Load all premade potions
	potionScaling.loadPotions()

	--Set current brewer to player
	common.currentBrewer = tes3.mobilePlayer
	npcBrewing.active = false

	--Bookkeeping for some necessary evil globals
	uiAdditions.currentRecipeIngredient = nil
	uiAdditions.batchMode = false
end

local function initialized()
	event.register("uiActivated", potionBrewing.fixStats, { filter = "MenuAlchemy" } )
	event.register("uiActivated", uiAdditions.addButtons, { filter = "MenuAlchemy" } )
	event.register("uiActivated", filtering.activateFilter, { filter = "MenuInventorySelect" } )
	event.register("uiActivated", npcBrewing.enterConversation, { filter = "MenuDialog" } )
	event.register("exerciseSkill", npcBrewing.blockNPCProgress)
	event.register("skillRaised", potionBrewing.levelUpdate)
	event.register("potionBrewSkillCheck", npcBrewing.brewChance)
	event.register("potionBrewed", potionBrewing.rescalePotion)
	event.register("potionBrewed", potionBrewing.bonusProgress)
	event.register("disposition", common.saveDisposition)
	event.register("uiObjectTooltip", randomizeEffects.onIngredientToolTip)
	event.register("loaded", onLoaded)
	event.register("menuExit", potionBrewing.cleanUpPotions)
	--event.register("menuExit", npcBrewing.cleanActor)
	mwse.log("Kukaibo's alchemy mod loaded!")
end
event.register("initialized", initialized)
--initialized()

--mwse.log("Kukaibo's alchemy add-on mod is loaded!")