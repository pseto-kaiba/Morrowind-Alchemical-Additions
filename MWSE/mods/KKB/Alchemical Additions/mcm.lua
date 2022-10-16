local config = require("KKB.Alchemical Additions.config")

local function saveConfig()
	mwse.saveConfig("KKB.Alchemical Additions", config)
end


local easyMCMConfig = {
	name = "Alchemical Additions",
	template = "Template",
	pages = {
		{
			label = "Base Settings",
			class = "SideBarPage",
			components = {
				{
					label = "Scale potions?",
					class = "OnOffButton",
					description = "When enabled, scales player-made potions to be more similar to premade ones (more info in the Potion Thresholds tab.)",
					variable = {
						id = "scalePotions",
						class = "TableVariable",
						table = config,
					},
				},
				{
					label = "NPC Potion brewing service?",
					class = "OnOffButton",
					description = "When enabled, Alchemists, Apothecaries, Priests, Healers and Ashlander Wise Women who barter in both potions and ingredients will also offer to brew potions for the player, using any combination of theirs and the player's owned apparatus. Potions brewed this way are added to their inventory. Requires potion scaling on to work.",
					variable = {
						id = "npcBrewing",
						class = "TableVariable",
						table = config,
					},
				},
				{
					label = "Randomize ingredient potency?",
					class = "OnOffButton",
					description = "When enabled, on each playthrough different ingredients will have different effect strengths, affecting potions in a way similar to Skyrim.",
					variable = {
						id = "randomizeIngredients",
						class = "TableVariable",
						table = config,
					},
				},
				{
					label = "UI additions?",
					class = "OnOffButton",
					description = "When enabled, adds buttons for batch brewing, reusing the last brewed recipe and an option to save and load potion recipes.",
					variable = {
						id = "uiAdditions",
						class = "TableVariable",
						table = config,
					},
				},
				{
					label = "Filtering?",
					class = "OnOffButton",
					description = "When enabled, allows filtering ingredients by effect, school and skill/attribute.",
					variable = {
						id = "filtering",
						class = "TableVariable",
						table = config,
					},
				},
				{
					label = "Use bonus progress?",
					class = "OnOffButton",
					description = "When enabled, if brewing potions with multiple effects, each extra effect gives 10% (configurable below) more skill progress.",
					variable = {
						id = "useBonusProgress",
						class = "TableVariable",
						table = config,
					},
				},
				{
					class="Slider",
					label="Bonus progress multiplier",
					description="% of extra alchemy skill progress per extra potion effect. Default 10%.",
					min=1,
					max=100,
					variable = {
						id = "bonusProgressMult",
						class = "TableVariable",
						table = config
					},
				},
				{
					label = "Potion name formatting?",
					class = "OnOffButton",
					description = "When enabled, inputting %E in the potion name field produces the name of the first effect, while %A, %B, %C and %D produce the names of the first through fourth ingredient respectively.",
					variable = {
						id = "potionNameFormatting",
						class = "TableVariable",
						table = config,
					},
				},				
				{
					label = "Use base values?",
					class = "OnOffButton",
					description = "When enabled, stat values higher than the base will not contribute to alchemy.",
					variable = {
						id = "useBaseValues",
						class = "TableVariable",
						table = config,
					},
				},
				{
					label = "Base + constant effect values?",
					class = "OnOffButton",
					description = "When enabled along with the above setting, Constant Effect enchantment Fortify effects are also allowed to contribute.",
					variable = {
						id = "useBaseConstValues",
						class = "TableVariable",
						table = config,
					},
				},
				{
					label = "Debug?",
					class = "OnOffButton",
					description = "Write debug messages to log.",
					variable = {
						id = "AA_debug",
						class = "TableVariable",
						table = config,
					},
				},
			},
			sidebarComponents = {
				{
					label = "Alchemy Additions",
					class = "Info",
					text = "This mod aims to introduce several new additions to Morrowind's alchemy skill along with rebalancing fixes and general QOL."},
			},
		},
		{
			label = "Potion Scaling & Default Potion Thresholds",
			class = "SideBarPage",
			components = {
				{
					label = "Alchemy level contribution: ",
					class="TextField",
					description = "Default value=1.0",
					variable = {
						id = "alchWeight",
						class = "TableVariable",
						numbersOnly=true,
						table = config.strengthContribution
					}
				},
				{
					label = "Intelligence level contribution: ",
					class="TextField",
					description = "Default value=0.1",
					variable = {
						id = "intWeight",
						class = "TableVariable",
						numbersOnly=true,
						table = config.strengthContribution
					}
				},
				{
					label = "Luck level contribution: ",
					class="TextField",
					description = "Default value=0.1",
					variable = {
						id = "lckWeight",
						class = "TableVariable",
						numbersOnly=true,
						table = config.strengthContribution
					}
				},
				{
					class="Category",
					label="Default Potion IDs",
					description="Effect IDs which pick which premade potions unknown potions are scaled off. Effects which modify skills/attributes must be followed by an underscore and then the appropriate stat ID (e.g. Fortify Strength would be 79_0). The magnitude+duration reference potion's values are also used to determine potion icon+mesh based off value.",
					components={
						{
							label = "Magnitude",
							class="TextField",
							description = "Default value=10 (Levitate)",
							variable = {
								id = "defaultScalingEffectM",
								class = "TableVariable",
								table = config
							},
						},
						{
							label = "Only Duration",
							class="TextField",
							description = "Default value=39 (Invisibility)",
							variable = {
								id = "defaultScalingEffectD",
								class = "TableVariable",
								numbersOnly=true,
								table = config
							},
						},
						{
							label = "No Magnitude/Duration",
							class="TextField",
							description = "Default value=61 (Recall)",
							variable = {
								id = "defaultScalingEffectNone",
								class = "TableVariable",
								numbersOnly=true,
								table = config
							},
						}
					},
				},
				{
					class="Category",
					label = "Bargain Potion Stats",
					components=
					{
						{
							class="SideBySideBlock",
							components = 
							{
								{
									label = "Alchemy ",
									class="TextField",
									description = "Default value=5",
									variable = {
										id = "A",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.b
									}
								},
								{
									label = "Intelligence ",
									class="TextField",
									description = "Default value=40",
									variable = {
										id = "I",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.b
									}
								},
								{
									label = "Luck ",
									class="TextField",
									description = "Default value=50",
									variable = {
										id = "L",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.b
									}
								},
							},
						},
						{
							class="Slider",
							label="Mortar & Pestle level",
							description="\n1 - Apprentice\n 2 - Journeyman\n 3 - Master\n 4 - Grandmaster\n 5 - Secretmaster\nDefault: "..tes3.getObject(config.mortars[1]).name,
							min=1,
							max=5,
							variable = {
								id = "M",
								class = "TableVariable",
								table = config.potionStats.b
							},
						},
					},
				},
				{
					class="Category",
					label = "Cheap Potion Stats",
					components=
					{
						{
							class="SideBySideBlock",
							components = 
							{
								{
									label = "Alchemy ",
									class="TextField",
									description = "Default value=25",
									variable = {
										id = "A",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.c
									}
								},
								{
									label = "Intelligence ",
									class="TextField",
									description = "Default value=50",
									variable = {
										id = "I",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.c
									}
								},
								{
									label = "Luck ",
									class="TextField",
									description = "Default value=50",
									variable = {
										id = "L",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.c
									}
								},
							},
						},
						{
							class="Slider",
							label="Mortar & Pestle level",
							description="\n1 - Apprentice\n 2 - Journeyman\n 3 - Master\n 4 - Grandmaster\n 5 - Secretmaster\nDefault: "..tes3.getObject(config.mortars[1]).name,
							min=1,
							max=5,
							variable = {
								id = "M",
								class = "TableVariable",
								table = config.potionStats.c
							},
						},
					},
				},
				{
					class="Category",
					label = "Standard Potion Stats",
					components=
					{
						{
							class="SideBySideBlock",
							components = 
							{
								{
									label = "Alchemy ",
									class="TextField",
									description = "Default value=40",
									variable = {
										id = "A",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.s
									}
								},
								{
									label = "Intelligence ",
									class="TextField",
									description = "Default value=50",
									variable = {
										id = "I",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.s
									}
								},
								{
									label = "Luck ",
									class="TextField",
									description = "Default value=50",
									variable = {
										id = "L",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.s
									}
								},
							},
						},
						{
							class="Slider",
							label="Mortar & Pestle level",
							description="\n1 - Apprentice\n 2 - Journeyman\n 3 - Master\n 4 - Grandmaster\n 5 - Secretmaster\nDefault: "..tes3.getObject(config.mortars[2]).name,
							min=1,
							max=5,
							variable = {
								id = "M",
								class = "TableVariable",
								table = config.potionStats.s
							},
						},
					},
				},
				{
					class="Category",
					label = "Quality Potion Stats",
					components=
					{
						{
							class="SideBySideBlock",
							components = 
							{
								{
									label = "Alchemy ",
									class="TextField",
									description = "Default value=65",
									variable = {
										id = "A",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.q
									}
								},
								{
									label = "Intelligence ",
									class="TextField",
									description = "Default value=65",
									variable = {
										id = "I",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.q
									}
								},
								{
									label = "Luck ",
									class="TextField",
									description = "Default value=50",
									variable = {
										id = "L",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.q
									}
								},
							},
						},
						{
							class="Slider",
							label="Mortar & Pestle level",
							description="\n1 - Apprentice\n 2 - Journeyman\n 3 - Master\n 4 - Grandmaster\n 5 - Secretmaster\nDefault: "..tes3.getObject(config.mortars[3]).name,
							min=1,
							max=5,
							variable = {
								id = "M",
								class = "TableVariable",
								table = config.potionStats.q
							},
						},
					},
				},
				{
					class="Category",
					label = "Exclusive Potion Stats",
					components=
					{
						{
							class="SideBySideBlock",
							components = 
							{
								{
									label = "Alchemy ",
									class="TextField",
									description = "Default value=80",
									variable = {
										id = "A",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.e
									}
								},
								{
									label = "Intelligence ",
									class="TextField",
									description = "Default value=80",
									variable = {
										id = "I",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.e
									}
								},
								{
									label = "Luck ",
									class="TextField",
									description = "Default value=70",
									variable = {
										id = "L",
										class = "TableVariable",
										numbersOnly=true,
										table = config.potionStats.e
									}
								},
							},
						},
						{
							class="Slider",
							label="Mortar & Pestle level",
							description="\n1 - Apprentice\n 2 - Journeyman\n 3 - Master\n 4 - Grandmaster\n 5 - Secretmaster\nDefault: "..tes3.getObject(config.mortars[4]).name,
							min=1,
							max=5,
							variable = {
								id = "M",
								class = "TableVariable",
								table = config.potionStats.e
							},
						},
					},
				},
			},

			sidebarComponents = {
				{
					label = "Alchemy Strength",
					class = "Info",
					text = "These settings control the stat level needed to brew potions of the same potency as the premade Bargain, Cheap, Standard, Quality and Exclusive ones. Alchemy strength is calculated as mortarQuality*(1.0 * alchemySkill + 0.1 * intelligence + 0.1 * luck, values configurable). When the brewer's alchemy strength is exactly at these thresholds, they will brew potions identical to premade ones, and for strengths in between the magnitudes, durations and values will scale linearly. For potions stronger than Exclusive the Quality->Exclusive linear scaling is maintained.",
				},
			},
		},
		{
			label = "Ingredient Randomization",
			class = "SideBarPage",
			components = {
				{
					label = "Multiplier distribution scale",
					class="TextField",
					description = "Controls how far effect multipliers will tend to skew from the mean. Scale parameter of the gaussian. Default value=0.1",
					variable = {
						id = "randomizeIngredientsScale",
						numbersOnly=true,
						class = "TableVariable",
						table = config
					}
				},
				{
					label = "Default mean",
					class="TextField",
					description = "Default value=1.0",
					variable = {
						id = "m0",
						numbersOnly=true,
						class = "TableVariable",
						table = config.ingredientValueMeans
					}
				},
				{
					label = "1st value threshold",
					class="TextField",
					description = "Default value=20",
					variable = {
						id = "t1",
						numbersOnly=true,
						class = "TableVariable",
						table = config.ingredientValueThresholds
					}
				},
				{
					label = "1st value mean",
					class="TextField",
					description = "Default value=1.1",
					variable = {
						id = "m1",
						numbersOnly=true,
						class = "TableVariable",
						table = config.ingredientValueMeans
					}
				},
				{
					label = "2nd value threshold",
					class="TextField",
					description = "Default value=50",
					variable = {
						id = "t2",
						numbersOnly=true,
						class = "TableVariable",
						table = config.ingredientValueThresholds
					}
				},
				{
					label = "2nd value mean",
					class="TextField",
					description = "Default value=1.2",
					variable = {
						id = "m2",
						numbersOnly=true,
						class = "TableVariable",
						table = config.ingredientValueMeans
					}
				},
				{
					label = "3rd value threshold",
					class="TextField",
					description = "Default value=100",
					variable = {
						id = "t3",
						numbersOnly=true,
						class = "TableVariable",
						table = config.ingredientValueThresholds
					}
				},
				{
					label = "4th value mean",
					class="TextField",
					description = "Default value=1.3",
					variable = {
						id = "m3",
						numbersOnly=true,
						class = "TableVariable",
						table = config.ingredientValueMeans
					}
				},
				{
					label = "4th value threshold",
					class="TextField",
					description = "Default value=200",
					variable = {
						id = "t4",
						numbersOnly=true,
						class = "TableVariable",
						table = config.ingredientValueThresholds
					}
				},
				{
					label = "5th value mean",
					class="TextField",
					description = "Default value=1.5",
					variable = {
						id = "m5",
						numbersOnly=true,
						class = "TableVariable",
						table = config.ingredientValueMeans
					}
				},
				{
					label = "5th value threshold",
					class="TextField",
					description = "Default value=500",
					variable = {
						id = "t5",
						numbersOnly=true,
						class = "TableVariable",
						table = config.ingredientValueThresholds
					}
				},
				{
					label = "5th value mean",
					class="TextField",
					description = "Default value=1.5",
					variable = {
						id = "m5",
						numbersOnly=true,
						class = "TableVariable",
						table = config.ingredientValueMeans
					}
				},
			},
			sidebarComponents = {
				{
					label = "Alchemy Strength",
					class = "Info",
					text = "If ingredient randomization is turned on, certain ingredients will have random, non-stacking multipliers added to the magnitude and duration of potions made with them - which also affects their value. These multipliers follow a normal distribution, whose mean is higher and higher as the ingredient value reaches certain thresholds."
					},
			},
		},
		{
			label="Other Tools",
			class="SideBarPage",
			components = {
					{
						class="Category",
						label = "Positive modifiers",
						components = 
						{
							{
								label = "rcp_r - Retort",
								class="TextField",
								description = "Default value=2.0",
								variable = {
									id = "rcp_r",
									numbersOnly=true,
									class = "TableVariable",
									table = config.otherTools
								}
							},
							{
								label = "rcp_c - Calcinator",
								class="TextField",
								description = "Default value=1.0",
								variable = {
									id = "rcp_c",
									numbersOnly=true,
									class = "TableVariable",
									table = config.otherTools
								}
							},
							{
								label = "rp_r - Retort",
								class="TextField",
								description = "Default value=2.0",
								variable = {
									id = "rp_r",
									numbersOnly=true,
									class = "TableVariable",
									table = config.otherTools
								}
							},
						}	
					},
					{
						class="Category",
						label = "Negative modifiers",
						components = 
						{
							{
								label = "acn_a - Alembic",
								class="TextField",
								description = "Default value=2.0",
								variable = {
									id = "acn_a",
									numbersOnly=true,
									class = "TableVariable",
									table = config.otherTools
								}
							},
							{
								label = "acn_c - Calcinator",
								class="TextField",
								description = "Default value=3.0",
								variable = {
									id = "acn_c",
									numbersOnly=true,
									class = "TableVariable",
									table = config.otherTools
								}
							},
							{
								label = "an_a - Alembic multiplier",
								class="TextField",
								description = "Default value=1.0",
								variable = {
									id = "an_a",
									numbersOnly=true,
									class = "TableVariable",
									table = config.otherTools
								}
							},
							{
								label = "an_a_scalar - Alembic scalar",
								class="TextField",
								description = "Default value=1.0",
								variable = {
									id = "an_a_scalar",
									numbersOnly=true,
									class = "TableVariable",
									table = config.otherTools
								}
							},
						}	
					},
					{
						label = "only_c - Calcinator",
						class="TextField",
						description = "Default value=2.0",
						variable = {
							id = "only_c",
							numbersOnly=true,
							class = "TableVariable",
							table = config.otherTools
						}
					},
					{
						label = "Calcinator weight reduction?",
						class = "OnOffButton",
						description = "When enabled, using a calcinator reduces potion weight.",
						variable = {
							id = "calcWeightReduce",
							class = "TableVariable",
							table = config,
						},
					},
					{
						label = "c_wmult - Calcinator weight reduction",
						class="TextField",
						description = "Default value=0.5",
						variable = {
							id = "c_wmult",
							numbersOnly=true,
							class = "TableVariable",
							table = config.otherTools
						}
					},
					{
						label = "c_wscalar - Calcinator weight reduction",
						class="TextField",
						description = "Default value=0.75",
						variable = {
							id = "c_wscalar",
							numbersOnly=true,
							class = "TableVariable",
							table = config.otherTools
						}
					},
				},
			sidebarComponents = {
				{
					label = "Alchemy Strength",
					class = "Info",
					text = "Controls the behavior of the alembic, calcinator and retort. Only applies if Potion Scaling is turned on.\n If using a calcinator: \nFor positive effects, duration/magnitude have the appropriate value from (rcp_r*r_quality + rcp_c*c_quality, rp_r*r_quality) added.\n For negative effects and if using an alembic, duration and magnitude are divided by the appropriate value from (acn_a*a_quality+acn_c*c_quality, an*a_quality + an_scalar). \nIf only using a calcinator, add only_c*c_quality to duration/magnitude. Using a calcinator can also reduce the weight of the potion (formula is weight /= c_wmult * c_quality + c_wscalar)."
					},
			},
		},
	},
	onClose = saveConfig,
}

return easyMCMConfig
