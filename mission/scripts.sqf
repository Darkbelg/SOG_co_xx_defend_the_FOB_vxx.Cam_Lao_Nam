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
			_waypoint setWaypointSpeed "FULL";
			_waypoint setWaypointType "MOVE";
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
			_x enableStamina false;
			_x disableAI "FSM";
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
		// _possibleFireteams = [
		// 	["vn_o_men_vc_local_07", "vn_o_men_vc_local_11", "vn_o_men_vc_local_10", "vn_o_men_vc_local_08", "vn_o_men_vc_local_29", "vn_o_men_vc_local_01", "vn_o_men_vc_local_02", "vn_o_men_vc_local_06", "vn_o_men_vc_local_04", "vn_o_men_vc_local_03", "vn_o_men_vc_local_05", "vn_o_men_vc_local_13", "vn_o_men_vc_local_09", "vn_o_men_vc_local_30", "vn_o_men_vc_local_12"],0.75,
		// 	["vn_o_men_vc_local_28", "vn_o_men_vc_local_21", "vn_o_men_vc_local_25", "vn_o_men_vc_local_32", "vn_o_men_vc_local_24", "vn_o_men_vc_local_31", "vn_o_men_vc_local_22", "vn_o_men_vc_local_15", "vn_o_men_vc_local_16", "vn_o_men_vc_local_20", "vn_o_men_vc_local_18", "vn_o_men_vc_local_17", "vn_o_men_vc_local_19", "vn_o_men_vc_local_27", "vn_o_men_vc_local_23", "vn_o_men_vc_local_26"],0.75,
		// 	["vn_o_men_vc_regional_07", "vn_o_men_vc_regional_11", "vn_o_men_vc_regional_10", "vn_o_men_vc_regional_08", "vn_o_men_vc_regional_01", "vn_o_men_vc_regional_04", "vn_o_men_vc_regional_03", "vn_o_men_vc_regional_02", "vn_o_men_vc_regional_06", "vn_o_men_vc_regional_05", "vn_o_men_vc_regional_09", "vn_o_men_vc_regional_12"],0.5,
		// 	["vn_o_men_vc_regional_07", "vn_o_men_vc_regional_11", "vn_o_men_vc_regional_10", "vn_o_men_vc_regional_08", "vn_o_men_vc_regional_01", "vn_o_men_vc_regional_04", "vn_o_men_vc_regional_03", "vn_o_men_vc_regional_02", "vn_o_men_vc_regional_06", "vn_o_men_vc_regional_05", "vn_o_men_vc_regional_09", "vn_o_men_vc_regional_12"],0.5,
		// 	["vn_o_men_vc_07", "vn_o_men_vc_10", "vn_o_men_vc_08", "vn_o_men_vc_01", "vn_o_men_vc_04", "vn_o_men_vc_05", "vn_o_men_vc_03", "vn_o_men_vc_02", "vn_o_men_vc_06", "vn_o_men_vc_09"],0.25,
		// 	["vn_o_men_vc_14", "vn_o_men_vc_07", "vn_o_men_vc_01", "vn_o_men_vc_04", "vn_o_men_vc_05", "vn_o_men_vc_03", "vn_o_men_vc_02", "vn_o_men_vc_06", "vn_o_men_vc_13", "vn_o_men_vc_12"],0.25
		// ];

		_possibleFireteams = [
			["vn_o_men_nva_dc_07","vn_o_men_nva_dc_07","vn_o_men_nva_dc_07","vn_o_men_nva_dc_07","vn_o_men_nva_dc_05", "vn_o_men_nva_dc_02", "vn_o_men_nva_dc_04"],0.25,
			["vn_o_men_nva_dc_11","vn_o_men_nva_dc_11","vn_o_men_nva_dc_11","vn_o_men_nva_dc_11","vn_o_men_nva_dc_11","vn_o_men_nva_dc_11","vn_o_men_nva_dc_11","vn_o_men_nva_dc_11"],0.25,
			["vn_o_men_vc_local_06","vn_o_men_vc_local_06","vn_o_men_vc_local_06","vn_o_men_vc_local_06","vn_o_men_vc_local_06","vn_o_men_vc_local_06","vn_o_men_vc_local_06","vn_o_men_vc_local_06","vn_o_men_vc_local_06","vn_o_men_vc_local_06"],0.75,
			["vn_o_men_nva_dc_09", "vn_o_men_nva_dc_06", "vn_o_men_nva_dc_08","vn_o_men_nva_dc_09", "vn_o_men_nva_dc_06", "vn_o_men_nva_dc_08","vn_o_men_nva_dc_09", "vn_o_men_nva_dc_06", "vn_o_men_nva_dc_08","vn_o_men_nva_dc_09", "vn_o_men_nva_dc_06", "vn_o_men_nva_dc_08"],0.75,
			["vn_o_men_nva_dc_05", "vn_o_men_nva_dc_02", "vn_o_men_nva_dc_04", "vn_o_men_nva_dc_01","vn_o_men_nva_dc_05", "vn_o_men_nva_dc_02", "vn_o_men_nva_dc_04", "vn_o_men_nva_dc_01","vn_o_men_nva_dc_05", "vn_o_men_nva_dc_02", "vn_o_men_nva_dc_04", "vn_o_men_nva_dc_01","vn_o_men_nva_dc_05", "vn_o_men_nva_dc_02", "vn_o_men_nva_dc_04", "vn_o_men_nva_dc_01"],0.5,
			["vn_o_men_nva_15", "vn_o_men_nva_20", "vn_o_men_nva_27", "vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23","vn_o_men_nva_23"],0.75
		];

		while {_totalUnits < _maxAmmount} do {
			waitUntil { sleep 20; diag_fpsMin >= 25; };
			systemChat format["SpawnPosition:%1",_spawnPostition];
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

	// Spawning enemies using the BIS_fnc_findSafePos
	// We will get the first position and then the second. We will check if the distance is larger then a km. Otherwise we will try and find another position.
	// This is to prevent all enemies to come from one direction.
	// When the function finds two positions it will move the two excisting markers. So that it will not break current code in the mission.
	// Marker names will be w1_1 and w1_2
	selectEnemySpawnPoints = {
		systemChat "Starting selecting points";
		private _respawnMarker = getMarkerPos "respawn_west";
		private _spawndirection1 = [_respawnMarker, 700, 850, 1, 0, 0.25, 0] call BIS_fnc_findSafePos;
		private _spawnDirection2 = _spawndirection1;

		systemChat format ["Spawn Point 1:%1",_spawndirection1];
		systemChat format ["Spawn Point 2:%1",_spawndirection2];
		systemChat format ["Spawn Points",_spawndirection1 distance _spawnDirection2 <= 1500];

		while {_spawndirection1 distance _spawnDirection2 <= 1000  } do {
			systemChat "Changing spawn direction 2";
			systemChat format ["Spawn Point 2:%1",_spawndirection2];
			_spawnDirection2 = [_respawnMarker, 600, 750, 1, 0, 0.25, 0] call BIS_fnc_findSafePos;		
		};

		systemChat format ["Spawn Point 1:%1",_spawndirection1];
		systemChat format ["Spawn Point 2:%1",_spawndirection2];

		"w1_1" setMarkerPos _spawndirection1;
		"w1_2" setMarkerPos _spawndirection2;
	};

	startGame = {
		[] spawn selectEnemySpawnPoints;

		if (f_param_difficulty == 16) then {
			f_param_difficulty = floor ((count playableUnits + count switchableUnits) * 0.3) + 3;
		};

		waitUntil { sleep 15;f_param_safe_start <= 0; };
		systemChat "Safety off";
		[highCommand,"Alright they will try and soften us up with an artillery barrage."] remoteExecCall ["sideChat"]; 
		[highCommand,"Get inside the bunkers."] remoteExecCall ["sideChat"]; 
		sleep 5;
		[highCommand,"Keep your heads down."] remoteExecCall ["sideChat"]; 
		sleep 5;
		_art_wave_1 = ["a1_2","vn_shell_60mm_m49a2_he_ammo",100,[20,3],3] spawn BIS_fnc_fireSupportCluster;
		waitUntil { scriptDone _art_wave_1};
		/* Wave 1 */
		[highCommand,"Get ready here they come!"] remoteExecCall ["sideChat"]; 
		[f_param_difficulty,["w1_1"],["a1_1","a1_2"],[100,100]] spawn spawnWaves;
		waitUntil { sleep 60; allEnemiesAttacking && enemyWaveDestroyed; };
		["a1_2"] call createMoveToHold;
		enemyWaveDestroyed = false;
		allEnemiesAttacking = false;
		[highCommand,"The enemy is reorganizing."] remoteExecCall ["sideChat"]; 
		sleep 300;
		/* Wave 2 */
		[highCommand,"Get ready! They are coming from a different direction now."] remoteExecCall ["sideChat"]; 
		[f_param_difficulty,["w1_2"],["a1_1","a1_2"],[100,100]] spawn spawnWaves;
		waitUntil { sleep 60;allEnemiesAttacking && enemyWaveDestroyed;};
		["a1_2"] call createMoveToHold;
		enemyWaveDestroyed = false;
		allEnemiesAttacking = false;
		[highCommand,"The enemy is reorganizing."] remoteExecCall ["sideChat"]; 
		sleep 300;
		/* Wave 3 */
		[highCommand,"Get ready! They are coming from both sides now."] remoteExecCall ["sideChat"]; 
		[f_param_difficulty,["w1_2"],["a1_1","a1_2"],[100,100]] spawn spawnWaves;
		waitUntil { sleep 60; allEnemiesAttacking;};
		allEnemiesAttacking = false;
		[f_param_difficulty,["w1_1"],["a1_1","a1_2"],[100,100]] spawn spawnWaves;
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
		if (east countSide allUnits < 6 && allEnemiesAttacking) then {
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
// this addWeapon "vn_m1928_tommy";
// this addPrimaryWeaponItem "vn_m1928_mag";
// this addWeapon "hgun_Pistol_heavy_01_F";
// this addHandgunItem "optic_MRD";
// this addHandgunItem "11Rnd_45ACP_Mag";

// comment "Add containers";
// this forceAddUniform "U_B_CombatUniform_mcam";
// this addVest "V_BandollierB_rgr";

// comment "Add items to containers";
// this addItemToUniform "FirstAidKit";
// this addItemToUniform "Chemlight_green";
// this addItemToUniform "vn_m1928_mag";
// for "_i" from 1 to 2 do {this addItemToVest "11Rnd_45ACP_Mag";};
// this addItemToVest "SmokeShell";
// this addItemToVest "SmokeShellGreen";
// this addItemToVest "Chemlight_green";
// for "_i" from 1 to 2 do {this addItemToVest "vn_m1928_mag";};
// this addHeadgear "H_MilCap_mcamo";
// this addGoggles "G_Aviator";

// comment "Add items";
// this linkItem "ItemMap";
// this linkItem "ItemCompass";
// this linkItem "ItemWatch";
// this linkItem "ItemRadio";
// this linkItem "ItemGPS";

// comment "Set identity";
// [this,"WhiteHead_04","male03eng"] call BIS_fnc_setIdentity;
