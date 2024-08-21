
ticks = 0
ANNOUNCE_TO = -1 -- print commands
usedport = 2500
disable_much_core_functionality = false
error_checking_not_relaxed = true

g_savedata.spawning_queue_data = {}
g_savedata.server_spawning_queue_data = {}

g_savedata.fish_withdrawal_tasks = {}

g_savedata.crane_glob_of_info = {
	{tag="id1",  queued=false,  spawned=false,  vehicle_id=-1,  location="SAWYER 9_8"},
	{tag="id2",  queued=false,  spawned=false,  vehicle_id=-1,  location="SAWYER 8_7"},
	{tag="id3",  queued=false,  spawned=false,  vehicle_id=-1,  location="SAWYER 15_2"},
	{tag="id4",  queued=false,  spawned=false,  vehicle_id=-1,  location="SAWYER 2_9"},
	{tag="id5",  queued=false,  spawned=false,  vehicle_id=-1,  location="MILITARY BASE"},
	{tag="id6",  queued=false,  spawned=false,  vehicle_id=-1,  location="HARBOUR BASE"},
	{tag="id7",  queued=false,  spawned=false,  vehicle_id=-1,  location="MULTIPLAYER ISLAND BASE"},
	{tag="id8",  queued=false,  spawned=false,  vehicle_id=-1,  location="MEIER 8_15"},
	{tag="id9",  queued=false,  spawned=false,  vehicle_id=-1,  location="MEIER 5_14"},
	{tag="id10",  queued=false,  spawned=false,  vehicle_id=-1,  location="MEIER 24_3"},
	{tag="id11",  queued=false,  spawned=false,  vehicle_id=-1,  location="MEIER 26_14"},
	{tag="id12",  queued=false,  spawned=false,  vehicle_id=-1,  location="TERMINAL SPYCAKES"},
	{tag="id13",  queued=false,  spawned=false,  vehicle_id=-1,  location="ARCTIC OIL PLATFORM"},
	{tag="id14",  queued=false,  spawned=false,  vehicle_id=-1,  location="ARCTIC ISLAND BASE"},
	{tag="id15",  queued=false,  spawned=false,  vehicle_id=-1,  location="CREATIVE BASE"}
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
	[13] = "Anchovy",
	[14] = "Anglerfish",
	[15] = "Arctic Char",
	[16] = "Ballan Lizardfish",
	[17] = "Ballan Wrasse",
	[18] = "Barreleye Fish",
	[19] = "Black Bream",
	[20] = "Black Dragonfish",
	[21] = "Clownfish",
	[22] = "Cod",
	[23] = "Dolphinfish",
	[24] = "Gulper Eel",
	[25] = "Haddock",
	[26] = "Hake",
	[27] = "Herring",
	[28] = "John Dory",
	[29] = "Labrus",
	[30] = "Lanternfish",
	[31] = "Mackerel",
	[32] = "Midshipman",
	[33] = "Perch",
	[34] = "Pike",
	[35] = "Pinecone Fish",
	[36] = "Pollock",
	[37] = "Red Mullet",
	[38] = "Rockfish",
	[39] = "Sablefish",
	[40] = "Salmon",
	[41] = "Sardine",
	[42] = "Scad",
	[43] = "Sea Bream",
	[44] = "Halibut",
	[45] = "Sea Piranha",
	[46] = "Seabass",
	[47] = "Slimehead",
	[48] = "Snapper",
	[49] = "Gold Snapper",
	[50] = "Snook",
	[51] = "Spadefish",
	[52] = "Trout",
	[53] = "Tubeshoulders fish",
	[54] = "Viperfish",
	[55] = "Yellowfin Tuna"
}