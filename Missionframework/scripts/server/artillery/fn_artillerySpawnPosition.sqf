/*
    File: fn_artillerySpawnPositon.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 2024-08-26
    Last Update: 2024-12-11
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Spawns the enemy artillery position

    Parameter(s):
        _spawn_marker - Marker where the artillery will spawn [STRING, defaults to ""]  

    Returns:
        Successful\failed spawn [BOOL]
*/

params [
    ["_spawn_marker", "", [""]]
];

if (KPLIB_endgame == 1) exitWith {false};

// ---------------------------------------------------------- GET ARTILLERY CLASSNAME
// Choose artillery QUALITY by the player's progress

private _artillery_pool = [];
private _sectorsCaptured = 0.5 - (0.1 * KPLIB_param_difficulty);
if ((count KPLIB_sectors_player) >= (count KPLIB_sectors_all) * _sectorsCaptured) then {_artillery_pool = KPLIB_o_artilleryHeavy} else {_artillery_pool = KPLIB_o_artilleryLight};
//if (KPLIB_enemyReadiness <= (80 - (5 * KPLIB_param_aggressivity))) then {_artillery_pool = KPLIB_o_artilleryLight} else {_artillery_pool = KPLIB_o_artilleryHeavy}; // placeholder

private _artyClass = "";

_selected_opfor_artillery = selectRandom _artillery_pool;

// Get arty class
_artyClass = _selected_opfor_artillery select 0;

// ---------------------------------------------------------- GET ARTILLERY AMMO POOL
private _artyAmmoArray = _selected_opfor_artillery select 1;

KPLIB_artyHashMap_ammo = [
	"KPLIB_arty_HE_round", 
	"KPLIB_arty_SMOKE_round", 
	"KPLIB_arty_FLARE_round", 
	"KPLIB_arty_CLUSTER_round", 
	"KPLIB_arty_LG_round"
] createHashMapFromArray _artyAmmoArray;

// ---------------------------------------------------------- GET ARTILLERY MIN-MAX RANGES
_minMaxRanges = [_artyClass, KPLIB_artyHashMap_ammo get "KPLIB_arty_HE_round"] call KPLIB_fnc_getArtilleryRanges;
_minMaxRanges params ["_min", "_max"];

// ---------------------------------------------------------- GET POSITION
if (_spawn_marker isEqualTo "") then {
	_spawn_marker = [_min, _max] call KPLIB_fnc_getArtySpawnPoint;
	if (_spawn_marker isEqualTo "") exitWith {["No opfor spawn point found for artillery position", "WARNING"] call KPLIB_fnc_log; false};
};

KPLIB_artilleryPosition_objects = [];
KPLIB_artilleryPosition_groups = [];

if !(_spawn_marker isEqualTo "") then {
	
	if (worldName in KPLIB_battlegroup_clearance) then {
		[markerPos _spawn_marker, 15] call KPLIB_fnc_createClearance;
	};

	// ---------------------------------------------------------- SPAWN ARTILLERY

	// Choose artillery QUANTITY by enemy readiness
	_repeatSpawn = 1; // Minimum/Default value

	if (KPLIB_enemyReadiness >= 50) then {_repeatSpawn = 2};
	if (KPLIB_enemyReadiness >= 80) then {_repeatSpawn = 3};

	for "_i" from 1 to _repeatSpawn do {

		// Spawn artillery vehicle
		_artillery = [markerpos _spawn_marker, _artyClass] call KPLIB_fnc_spawnArtillery;

		// Add the new artillery to the pool
		KPLIB_o_artilleryUnits pushBack _artillery;
		KPLIB_artilleryPosition_objects pushBack _artillery;
		KPLIB_artilleryPosition_groups pushBack (group _artillery);

	};

	// Check variable
	if (KPLIB_o_artilleryUnits isEqualTo []) exitWith {["No artillery spawned", "WARNING"] call KPLIB_fnc_log; false};

	// Mortar: Fix for ACE "Use ammunition handling"
	if (KPLIB_ace && {_artyClass isKindOf "StaticMortar"}) then {
		{
			[_x] call KPLIB_fnc_addMagazinesMortar;
		}forEach (KPLIB_o_artilleryUnits select {magazinesAmmo _x isEqualTo []});
	};

	// ---------------------------------------------------------- ARTILLERY MISSIONS
	// Situations that the artillery might fire.

	[] call KPLIB_fnc_artilleryFobTargeting; // Targeting a FOB is a special event
	
	// ---------------------------------------------------------- DEFENSES
	// Barriers
	{
		_x allowDamage false;
		_x enableSimulation false;

		_artyPos = getPos _x;
		if (_x isKindOf "staticMortar") then {
			{
				// Sandbags for mortars
				// Idea taken from Antistasi fn_DES_Artillery.sqf script
				private _relPos = _artyPos getPos [3, _x]; 
				private _barrier = createVehicle ["Land_BagFence_Round_F", _relPos, [], 0, "CAN_COLLIDE"];
				_barrier setDir (_barrier getDir _artyPos); 
				
				KPLIB_artilleryPosition_objects pushBack _barrier;
			} forEach [0, 90, 180, 270];
		} else {
			// For heavy artillery
			for "_count" from 1 to 3 do {
				private _barrier = createVehicle ["Land_HBarrier_Big_F", markerPos "ghost_spot" , [], 0, "CAN_COLLIDE"];
				switch (_count) do {
					// Front barrier
					case 1 : {
						_barrier setPosATL (_x modelToWorld [0,9,0]);
						_barrier setDir (_barrier getRelDir _artyPos);
					};
					case 2 : {
						// Side barrier
						_barrier setPosATL (_x modelToWorld [5,0,0]);
						_barrier setDir (_barrier getRelDir _artyPos); // Rotate in the same direction of the artillery
						// Set a little bit backward
						_barrier setPosATL (_x modelToWorld [5,-2,0]);
					};
					case 3 : {
						// Side barrier
						_barrier setPosATL (_x modelToWorld [-5,0,0]);
						_barrier setDir (_barrier getRelDir _artyPos); // Rotate in the same direction of the artillery
						// Set a little bit backward
						_barrier setPosATL (_x modelToWorld [-5,-2,0]);
					};
				};
				// Fix for floating objects
				_barrier setPosATL [getPos _barrier select 0, getPos _barrier select 1, 0];
				// Rotation vector fix
				_barrier setVectorUp surfaceNormal position _barrier;

				KPLIB_artilleryPosition_objects pushBack _barrier;
			}
		}
	}forEach KPLIB_o_artilleryUnits;

	// Patrols
	// AA Infantry Patrol
	private _grppatrol1 = [_spawn_marker, KPLIB_o_squadAir] call KPLIB_fnc_spawnRegularSquad;
	[_grppatrol1, markerpos _spawn_marker] spawn add_defense_waypoints;

	KPLIB_artilleryPosition_groups pushBack _grppatrol1;

	// Standard Infantry Patrol
	if (KPLIB_enemyReadiness >= (50 - (5 * KPLIB_param_difficulty))) then {
		_patrol2 = ([] call KPLIB_fnc_getSquadComp);
		private _grppatrol2 = [_spawn_marker, _patrol2] call KPLIB_fnc_spawnRegularSquad;
		[_grppatrol2, markerpos _spawn_marker] spawn add_defense_waypoints;

		KPLIB_artilleryPosition_groups pushBack _grppatrol2;
	};

	// Spawn trucks
	{
		private _spawnPos = [(getMarkerpos _spawn_marker), 10, 100, 10, 0, 0.3, 0] call BIS_fnc_findSafePos;
		_truck = _x createVehicle _spawnPos;
		_truck setDir random 360;
		KPLIB_artilleryPosition_objects pushBack _truck;
	}forEach [KPLIB_o_transportTruckAmmo, KPLIB_o_transportTruck];

	// Spawn AA vehicle
	[_spawn_marker] spawn {
		params ["_spawn_marker"];
		if (KPLIB_enemyReadiness >= (65 - (5 * KPLIB_param_difficulty))) then {
			private _vehicle_pool = [];
			// Try to get an AA vehicle from the preset
			_vehicle_pool = KPLIB_o_battleGrpVehicles select {
				!(_x isKindOf "Air") && (count (_x call BIS_fnc_allTurrets) > 0) && ((getNumber(configfile >> "CfgVehicles" >> _x >> "radarType")) == 2) // Still can spawn other vehicles that might have radar (e.g T-14K Armata)
			};
			// If not found any AA vehicles, get any vehicle
			if (_vehicle_pool isEqualTo []) then {
				_vehicle_pool = KPLIB_o_battleGrpVehicles;
			};
			private _vehtospawn = selectRandom _vehicle_pool;
			private _aaVeh = [(getMarkerpos _spawn_marker) getPos [30 + (random 30), random 360], _vehtospawn, true] call KPLIB_fnc_spawnVehicle;
			KPLIB_artilleryPosition_objects pushBack _aaVeh;
			KPLIB_artilleryPosition_groups pushBack (group _aaVeh);
		};
	};

	// ---------------------------------------------------------- SPAWN RESOURCES
	// Spawn ammunition crate
	private _amount = (ceil (random 2)) * KPLIB_param_resourcesMulti;
	for "_i" from 1 to _amount do {
		_spawnPos = ((getMarkerpos _spawn_marker) getPos [random 50, random 50]) findEmptyPosition [10, 40, KPLIB_b_crateAmmo];
		_crate = [KPLIB_b_crateAmmo, 100, _spawnPos] call KPLIB_fnc_createCrate;
	};

	// Create marker and notification
	[_spawn_marker] remoteExec ["remote_call_artillery"];
};

// ---------------------------------------------------------- FINAL SETUP

{
	_x allowDamage true;
	_x enableSimulation true;
}forEach KPLIB_o_artilleryUnits; 

// Artillery position manager
[] call KPLIB_fnc_artilleryPositionManager;

true
