// MISSION VARAIBLES
player addRating 100000;
[player, "NoVoice"] remoteExec ["setSpeaker", -2, format["NoVoice_%1", netId player]]; // No player voice
showSubtitles false; // No radio calls
"Group" setDynamicSimulationDistance 1200;
"Vehicle" setDynamicSimulationDistance 2500;
enableEngineArtillery false; 	// Disable Artillery Computer
f_var_AuthorUID = '76561198016469048'; // Allows GUID to access Admin/Zeus features in MP.
[nil, 2] execVM "f\casualtiesCap\f_CasualtiesCapCheck.sqf";
f_param_safe_start = 5;

destroyFences = {
	_center = getMarkerPos "a1_2";
	{
		_x setDamage 1;		
	} forEach (nearestTerrainObjects [_center, ["FENCE"], 1500]);
};

[] spawn destroyFences;


if (isServer) then {
	enemyWaveDestroyed = false;
	allEnemiesAttacking = false;
	// _null = [25,["w1_1"],["a1_2"],[0,500]] spawn spawnWaves;
	// _null = [25,["w1_2"],["a1_2"],[500,0]] spawn spawnWaves;
	// _null = [12,["w1_2"],["a1_2"],[500,0]] spawn spawnWaves;
	// _null = [12,["w1_1"],["a1_2"],[0,500]] spawn spawnWaves;

	spawnWaves = {
		params ["_maxAmmount", "_waveOneMarkers","_waveAttackOneMarkers","_spread"];
		// _waveOneMarkers = ["w1_1"];
		// _waveAttackOneMarkers = ["a1_2"];
		_wave = [_waveOneMarkers,_waveAttackOneMarkers,_maxAmmount,_spread] spawn spawnWave;
	};

	spawnWave = {
		params ["_wave","_waveAttackPoints","_maxAmmount","_spread"];
		{
			_markerPosition = getMarkerPos _x;
			[_markerPosition,_waveAttackPoints,_maxAmmount,_spread] spawn spawnWaveUnits;
		} forEach _wave;
	};

	setWaypointBasics = {
		params ["_unit","_attackPoints"];
		_movementSpeeds = ["NORMAL","NORMAL","NORMAL","FULL"];
		{
			_waypoint = _unit addWaypoint [getMarkerPos _x,5];
			_waypoint setWaypointCombatMode "RED";
			_waypoint setWaypointBehaviour "AWARE";
			_waypoint setWaypointFormation "LINE";
			_waypoint setWaypointSpeed (selectRandom _movementSpeeds);
			_waypoint setWaypointType "SAD";
			//_waypoint setWaypointTimeout [0, 5, 10];
			
		} forEach _attackPoints;
	};

	setAiBasic = {
		params ["_unit"];
		{
			_x allowFleeing 0; // Optional
			// _x disableAI "AIMINGERROR";
			_x disableAI "AUTOCOMBAT";
			_x enableAttack false;
			//_x enableStamina false;
		} forEach units _unit;
	};

	addKilledEvent = {
		params["_unit"];
		{
			_x addMPEventHandler  ["MPKilled", {
				[] call countEnemies;
			}];
		} forEach units _unit;

	};

	spawnWaveUnits = {
		params ["_spawnPostition","_waveAttackPoints","_maxAmmount","_spread"];		
		_totalUnits = 0;
		_possibleFireteams = [
			["vn_o_men_vc_local_07", "vn_o_men_vc_local_11", "vn_o_men_vc_local_10", "vn_o_men_vc_local_08", "vn_o_men_vc_local_29", "vn_o_men_vc_local_01", "vn_o_men_vc_local_02", "vn_o_men_vc_local_06", "vn_o_men_vc_local_04", "vn_o_men_vc_local_03", "vn_o_men_vc_local_05", "vn_o_men_vc_local_13", "vn_o_men_vc_local_09", "vn_o_men_vc_local_30", "vn_o_men_vc_local_12"],0.75,
			["vn_o_men_vc_local_28", "vn_o_men_vc_local_21", "vn_o_men_vc_local_25", "vn_o_men_vc_local_32", "vn_o_men_vc_local_24", "vn_o_men_vc_local_31", "vn_o_men_vc_local_22", "vn_o_men_vc_local_15", "vn_o_men_vc_local_16", "vn_o_men_vc_local_20", "vn_o_men_vc_local_18", "vn_o_men_vc_local_17", "vn_o_men_vc_local_19", "vn_o_men_vc_local_27", "vn_o_men_vc_local_23", "vn_o_men_vc_local_26"],0.75,
			["vn_o_men_vc_regional_07", "vn_o_men_vc_regional_11", "vn_o_men_vc_regional_10", "vn_o_men_vc_regional_08", "vn_o_men_vc_regional_01", "vn_o_men_vc_regional_04", "vn_o_men_vc_regional_03", "vn_o_men_vc_regional_02", "vn_o_men_vc_regional_06", "vn_o_men_vc_regional_05", "vn_o_men_vc_regional_09", "vn_o_men_vc_regional_12"],0.5,
			["vn_o_men_vc_regional_07", "vn_o_men_vc_regional_11", "vn_o_men_vc_regional_10", "vn_o_men_vc_regional_08", "vn_o_men_vc_regional_01", "vn_o_men_vc_regional_04", "vn_o_men_vc_regional_03", "vn_o_men_vc_regional_02", "vn_o_men_vc_regional_06", "vn_o_men_vc_regional_05", "vn_o_men_vc_regional_09", "vn_o_men_vc_regional_12"],0.5,
			["vn_o_men_vc_07", "vn_o_men_vc_10", "vn_o_men_vc_08", "vn_o_men_vc_01", "vn_o_men_vc_04", "vn_o_men_vc_05", "vn_o_men_vc_03", "vn_o_men_vc_02", "vn_o_men_vc_06", "vn_o_men_vc_09"],0.25,
			["vn_o_men_vc_14", "vn_o_men_vc_07", "vn_o_men_vc_01", "vn_o_men_vc_04", "vn_o_men_vc_05", "vn_o_men_vc_03", "vn_o_men_vc_02", "vn_o_men_vc_06", "vn_o_men_vc_13", "vn_o_men_vc_12"],0.25
		];

		while {_totalUnits <= _maxAmmount} do {
			waitUntil { sleep 10; diag_fpsMin >= 30; };
			_unit = [[(_spawnPostition select 0) + random (_spread select 0),(_spawnPostition select 1) + random (_spread select 1), _spawnPostition select 2],east,selectRandomWeighted _possibleFireteams] call BIS_fnc_spawnGroup;
			waitUntil{!(isNil "_unit")};
			_unit deleteGroupWhenEmpty true;
			[_unit] spawn setAiBasic;
			[_unit,_waveAttackPoints] spawn setWaypointBasics;
			[_unit] spawn addKilledEvent;
			_totalUnits = _totalUnits +1;
		};
		allEnemiesAttacking = true;
	};

	createMoveToHold = {
		{
			params ["_attackMarker"];
			if (side _x == east) then {
				deleteWaypoint [_x,1];
				_waypoint = _x addWaypoint [getMarkerPos _attackMarker,5];
				_waypoint setWaypointSpeed "FAST";
				_waypoint setWaypointType "HOLD";
			};
		} forEach allGroups;
	};

	startGame = {
		waitUntil { sleep 15;f_param_safe_start <= 0; };
		systemChat "Safety off";
		[highCommand,"Alright they will try and soften us up with an artillery barrage."] remoteExecCall ["sideChat"]; 
		[highCommand,"Get inside the bunkers."] remoteExecCall ["sideChat"]; 
		sleep 5;
		[highCommand,"Keep your heads down."] remoteExecCall ["sideChat"]; 
		sleep 5;
		_art_wave_1 = ["a1_2","vn_shell_60mm_m49a2_he_ammo",100,[20,3],3] spawn BIS_fnc_fireSupportCluster;
		waitUntil { scriptDone _art_wave_1};
		[highCommand,"Get ready here they come!"] remoteExecCall ["sideChat"]; 
		[f_param_difficulty,["w1_1"],["a1_2"],[100,0]] spawn spawnWaves;
		waitUntil { sleep 60; allEnemiesAttacking && enemyWaveDestroyed; };
		["a1_2"] call createMoveToHold;
		enemyWaveDestroyed = false;
		allEnemiesAttacking = false;
		[highCommand,"The enemy is reorganizing."] remoteExecCall ["sideChat"]; 
		sleep 300;
		[highCommand,"Get ready! They are coming from a different direction now."] remoteExecCall ["sideChat"]; 
		[f_param_difficulty,["w1_2"],["a1_2"],[200,0]] spawn spawnWaves;
		waitUntil { sleep 60;allEnemiesAttacking && enemyWaveDestroyed;};
		["a1_2"] call createMoveToHold;
		enemyWaveDestroyed = false;
		allEnemiesAttacking = false;
		[highCommand,"The enemy is reorganizing."] remoteExecCall ["sideChat"]; 
		sleep 300;
		[highCommand,"Get ready! They are coming from both sides now."] remoteExecCall ["sideChat"]; 
		[f_param_difficulty,["w1_2"],["a1_2"],[200,0]] spawn spawnWaves;
		waitUntil { sleep 60; allEnemiesAttacking;};
		allEnemiesAttacking = false;
		[f_param_difficulty,["w1_1"],["a1_2"],[100,0]] spawn spawnWaves;
		waitUntil { sleep 60; allEnemiesAttacking;};
		enemyWaveDestroyed = false;
		waitUntil { sleep 60;allEnemiesAttacking && enemyWaveDestroyed;};
		["a1_2"] call createMoveToHold;
		[highCommand,"Great job you have repelled the enemy attack."] remoteExecCall ["sideChat"]; 
		sleep 60;
		"End1" call BIS_fnc_endMissionServer;
	};

	fireFlare = {			
		while {true} do {
			[[(getMarkerPos "a1_2") select 0,(getMarkerPos "a1_2") select 1,150],2] call VN_MS_fnc_createFlare;
			[[(getMarkerPos "smoke_1") select 0,(getMarkerPos "smoke_1") select 1,150],2] call VN_MS_fnc_createFlare;
			sleep 15;
			[[(getMarkerPos "a1_2") select 0,(getMarkerPos "a1_2") select 1,150],2] call VN_MS_fnc_createFlare;
			[[(getMarkerPos "smoke_2") select 0,(getMarkerPos "smoke_2") select 1,150],2] call VN_MS_fnc_createFlare;
			sleep 15;
			[[(getMarkerPos "a1_2") select 0,(getMarkerPos "a1_2") select 1,150],2] call VN_MS_fnc_createFlare;
			[[(getMarkerPos "smoke_3") select 0,(getMarkerPos "smoke_3") select 1,150],2] call VN_MS_fnc_createFlare;
			sleep 30;		
		};
	};

	countEnemies = {
		if (east countSide allUnits < 10 && allEnemiesAttacking) then {
			enemyWaveDestroyed = true;
		};
	};

	checkReinforcments = {
		waitUntil { sleep 3600; true; };
		[highCommand,"We have given them a run for their money!"] remoteExecCall ["sideChat"];
		"End1" call BIS_fnc_endMissionServer;
	};

	[] spawn fireFlare;
	[] spawn startGame;
	[] spawn checkReinforcments;
};


// comment "Exported from Arsenal by Darkbelg";

// comment "[!] UNIT MUST BE LOCAL [!]";
// if (!local this) exitWith {};

// comment "Remove existing items";
// removeAllWeapons this;
// removeAllItems this;
// removeAllAssignedItems this;
// removeUniform this;
// removeVest this;
// removeBackpack this;
// removeHeadgear this;
// removeGoggles this;

// comment "Add weapons";
// this addWeapon "vn_m1897";
// this addPrimaryWeaponItem "vn_m1897_buck_mag";
// this addWeapon "vn_mx991_m1911";
// this addHandgunItem "vn_s_m1911";
// this addHandgunItem "vn_m1911_mag";

// comment "Add containers";
// this forceAddUniform "vn_b_uniform_macv_02_01";
// this addVest "vn_b_vest_usarmy_04";
// this addBackpack "vn_b_pack_lw_03_m1897_pl";

// comment "Add binoculars";
// this addWeapon "vn_m19_binocs_grn";

// comment "Add items to containers";
// this addItemToUniform "vn_b_item_firstaidkit";
// for "_i" from 1 to 2 do {this addItemToUniform "vn_m61_grenade_mag";};
// this addItemToUniform "vn_m34_grenade_mag";
// for "_i" from 1 to 2 do {this addItemToUniform "vn_m1897_buck_mag";};
// this addItemToVest "vn_m1897_buck_mag";
// for "_i" from 1 to 3 do {this addItemToVest "vn_m1911_mag";};
// for "_i" from 1 to 2 do {this addItemToBackpack "vn_b_item_firstaidkit";};
// for "_i" from 1 to 6 do {this addItemToBackpack "vn_m1911_mag";};
// for "_i" from 1 to 8 do {this addItemToBackpack "vn_m1897_buck_mag";};
// for "_i" from 1 to 8 do {this addItemToBackpack "vn_m1897_fl_mag";};
// for "_i" from 1 to 4 do {this addItemToBackpack "vn_m61_grenade_mag";};
// for "_i" from 1 to 2 do {this addItemToBackpack "vn_m18_yellow_mag";};
// this addItemToBackpack "vn_m34_grenade_mag";
// for "_i" from 1 to 6 do {this addItemToBackpack "vn_mine_m14_mag";};
// this addHeadgear "vn_b_bandana_01";
// this addGoggles "vn_b_scarf_01_03";

// comment "Add items";
// this linkItem "vn_b_item_map";
// this linkItem "vn_b_item_compass";
// this linkItem "vn_b_item_watch";
// this linkItem "vn_b_item_radio_urc10";

// comment "Set identity";
// [this,"WhiteHead_10","male08eng"] call BIS_fnc_setIdentity;
