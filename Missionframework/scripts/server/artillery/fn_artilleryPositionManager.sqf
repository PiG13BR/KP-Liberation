/*
    File: fn_artilleryPositionManager.sqf
    Author: PiG13BR - https://github.com/PiG13BR
	Date: 2024-10-06
	Last Update: 2024-12-05
	License: MIT License - http://www.opensource.org/licenses/MIT

	Description:
		Manages the artillery position. Checks if the artillery units are still operational.

	Parameter(s):
		-

	Return(s):
		-
*/

if ((_despawnObjects isEqualTo []) || {count _despawnObjects < 2}) exitWith {};

// Add PFH to update the artillery units variable
[{
	params["_args", "_handler"];
	KPLIB_o_artilleryUnits = KPLIB_o_artilleryUnits select {(alive _x) && {canFire _x} && {!(gunner _x isEqualTo objNull)} && {alive (gunner _x)}}; // Check arty status.

	if (KPLIB_o_artilleryUnits isEqualTo []) then {
		// Despawner
		{[_x] call KPLIB_fnc_despawnObject}forEach KPLIB_artilleryPosition_objects;
		{[_x] call KPLIB_fnc_despawnGroup}forEach KPLIB_artilleryPosition_groups;
		// Remove PFH
		[_handler] call CBA_fnc_removePerFrameHandler;
		// Call the artillery spawn script
		[] call KPLIB_fnc_artilleryTimerSpawn;
		// Reset counter artillery chance
		KPLIB_counterArtyChance = nil;
		KPLIB_artyHashMap_ammo = nil;
        KPLIB_artilleryPosition_objects = nil;
		KPLIB_artilleryPosition_groups = nil;
	};
}, 60, []] call CBA_fnc_addPerFrameHandler; 
