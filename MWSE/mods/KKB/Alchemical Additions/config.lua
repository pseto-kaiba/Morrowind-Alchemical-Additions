local config = mwse.loadConfig("KKB.Alchemical Additions", {
	npcBrewing = true,
	uiAdditions = true,
	filtering = true,
	potionNameFormatting = true,
	useBaseValues = true,
	useBaseConstValues = true,
	scalePotions = true,
	allowedClasses = {
	["ALCHEMIST"] = true,
	["APOTHECARY"] = true,
	["PRIEST"] = true,
	["HEALER"] = true,
	["WISE WOMAN"] = true,
	["ALCHEMIST SERVICE"] = true,
	["APOTHECARY SERVICE"] = true,
	["PRIEST SERVICE"] = true,
	["HEALER SERVICE"] = true,
	["WISE WOMAN SERVICE"] = true},
	potionStats = {b={A=5,I=40,L=50,M=1},c={A=25,I=50,L=50,M=1},s={A=40,I=50,L=50,M=2},q={A=65,I=65,L=50,M=3},e={A=80,I=80,L=70,M=4}},
	mortars = {"apparatus_a_mortar_01","apparatus_j_mortar_01","apparatus_m_mortar_01","apparatus_g_mortar_01","apparatus_sm_mortar_01"},
	strengthContribution = {alchWeight=1.0, intWeight=0.1, lckWeight=0.1},
	randomizeIngredients = true,
	ingredientValueThresholds = {t0=1,t1=20,t2=50,t3=100,t4=200,t5=500},
	ingredientValueMeans = {m0=1.0, m1=1.1,m2=1.2,m3=1.3,m4=1.4,m5=1.5},
	randomizeIngredientsScale = 0.1,
	potionValues={b=5,c=15,s=35,q=80,e=175},
	calcWeightReduce = true,
	otherTools = {rcp_r=2, rcp_c=1, rp_r=2, acn_a=2, acn_c=3, an_a_scalar=1, an_a=1, only_c=2, c_wmult=0.5, c_wscalar=0.75},
	defaultScalingEffectM = 10,
	defaultScalingEffectD = 39,
	defaultScalingEffectNone = 61,
	AA_debug = false,
	batch_vals = {1,5,10,20},
	useBonusProgress=true,
	bonusProgressMult=10,
})

return config