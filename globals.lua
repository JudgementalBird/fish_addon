
ticks = 0
ANNOUNCE_TO = -1 -- print commands
usedport = 2500
disable_much_core_functionality = false
error_checking_not_relaxed = true

g_savedata.spawning_queue_data = {}

g_savedata.fish_withdrawal_tasks = {}

g_savedata.crane_glob_of_info = {
	{tag="id1",  loaded=false,  vehicle_id=-1,  location="SAWYER 9_8"},
	{tag="id2",  loaded=false,  vehicle_id=-1,  location="SAWYER 8_7"},
	{tag="id3",  loaded=false,  vehicle_id=-1,  location="SAWYER 15_2"},
	{tag="id4",  loaded=false,  vehicle_id=-1,  location="SAWYER 2_9"},
	{tag="id5",  loaded=false,  vehicle_id=-1,  location="MILITARY BASE"},
	{tag="id6",  loaded=false,  vehicle_id=-1,  location="HARBOUR BASE"},
	{tag="id7",  loaded=false,  vehicle_id=-1,  location="MULTIPLAYER ISLAND BASE"},
	{tag="id8",  loaded=false,  vehicle_id=-1,  location="MEIER 8_15"},
	{tag="id9",  loaded=false,  vehicle_id=-1,  location="MEIER 5_14"},
	{tag="id10",  loaded=false,  vehicle_id=-1,  location="MEIER 24_3"},
	{tag="id11",  loaded=false,  vehicle_id=-1,  location="MEIER 26_14"},
	{tag="id12",  loaded=false,  vehicle_id=-1,  location="TERMINAL SPYCAKES"},
	{tag="id13",  loaded=false,  vehicle_id=-1,  location="ARCTIC OIL PLATFORM"},
	{tag="id14",  loaded=false,  vehicle_id=-1,  location="ARCTIC ISLAND BASE"},
	{tag="id15",  loaded=false,  vehicle_id=-1,  location="CREATIVE BASE"}
}

logging = {
	http_send = true,
	debug = {
		"no debug",
		"highest level debug",
		"involved debug",
		"ALL debug"
	},
	debugstate = 1,
	get_debug = function()
		return logging.debug[logging.debugstate]
	end,
	increment_debug = function()
		logging.debugstate = (logging.debugstate + 1)
		if logging.debugstate > (#logging.debug) then
			logging.debugstate = 1
		end
		return logging.debug[logging.debugstate]
	end
}

hopper_resource_lookup = {
	[0] = "coal",
	[1] = "iron",
	[2] = "aluminium",
	[3] = "gold",
	[4] = "gold_dirt",
	[5] = "uranium",
	[6] = "ingot_iron",
	[7] = "ingot_steel",
	[8] = "ingot_aluminium",
	[9] = "ingot_gold_impure",
	[10] = "ingot_gold",
	[11] = "ingot_uranium",
	[12] = "solid_propellant",
	[13] = "anchovie",
	[14] = "anglerfish",
	[15] = "arctic_char",
	[16] = "ballan_lizardfish",
	[17] = "ballan_wrasse",
	[18] = "barreleye_fish",
	[19] = "black_bream",
	[20] = "black_dragonfish",
	[21] = "clown_fish",
	[22] = "cod",
	[23] = "dolphinfish",
	[24] = "gulper_eel",
	[25] = "haddock",
	[26] = "hake",
	[27] = "herring",
	[28] = "john_dory",
	[29] = "labrus",
	[30] = "lanternfish",
	[31] = "mackerel",
	[32] = "midshipman",
	[33] = "perch",
	[34] = "pike",
	[35] = "pinecone_fish",
	[36] = "pollock",
	[37] = "red_mullet",
	[38] = "rockfish",
	[39] = "sablefish",
	[40] = "salmon",
	[41] = "sardine",
	[42] = "scad",
	[43] = "sea_bream",
	[44] = "sea_halibut",
	[45] = "sea_piranha",
	[46] = "seabass",
	[47] = "slimehead",
	[48] = "snapper",
	[49] = "snapper_gold",
	[50] = "snook",
	[51] = "spadefish",
	[52] = "trout",
	[53] = "tubeshoulders_fish",
	[54] = "viperfish",
	[55] = "yellowfin_tuna",
	[56] = "blue crab",
	[57] = "brown_box_crab",
	[58] = "coconut_crab",
	[59] = "dungeness_crab",
	[60] = "furry_lobster",
	[61] = "homarus_americanus",
	[62] = "homarus_gammarus",
	[63] = "horseshoe_crab",
	[64] = "jasus_edwardsii",
	[65] = "jasus_lalandii",
	[66] = "jonah_crab",
	[67] = "king_crab",
	[68] = "mud_crab",
	[69] = "munida_lobster",
	[70] = "ornate_rock_lobster",
	[71] = "panulirus_interruptus",
	[72] = "red_king_crab",
	[73] = "reef_lobster",
	[74] = "slipper_lobster",
	[75] = "snow_crab",
	[76] = "southern_rock_lobster",
	[77] = "spider_crab",
	[78] = "spiny_lobster",
	[79] = "stone_crab"
}