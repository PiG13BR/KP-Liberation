/*
    File: fn_artilleryPositionManager.sqf
    Author: PiG13BR - https://github.com/PiG13BR
	Date: 2024-10-06
	Last Update: 2024-10-07
	License: MIT License - http://www.opensource.org/licenses/MIT

	Description:
		Manages the artillery position. Checks if the artillery units are still operational.

	Parameter(s):
		_despawnObjects - Array of objects and groups to be despawned from artillery position [ARRAY, defaults to []]

	Return(s):
		-
*/

params [
	["_despawnObjects", [], [[]] ,[2]]
];

if ((_despawnObjects isEqualTo []) || {count _despawnObjects < 2}) exitWith {};

// Add PFH to update the artillery units variable
[{
	params["_args", "_handler"];
	_args params ["_objects", "_groups"];
	KPLIB_o_artilleryUnits = KPLIB_o_artilleryUnits select {(alive _x) && {canFire _x} && {!(gunner _x isEqualTo objNull)} && {alive (gunner _x)}}; // Check arty status.

	//(_artillery_alive isEqualTo []) || 
	if (KPLIB_o_artilleryUnits isEqualTo []) then {

		// Despawner
		{[_x] call PIG_fnc_despawnObject}forEach _objects;
		{[_x] call PIG_fnc_despawnGroup}forEach _groups;
		// Remove PFH
		[_handler] call CBA_fnc_removePerFrameHandler;
		// Call the artillery spawn script
		[] call KPLIB_fnc_artilleryTimerSpawn;
		// Reset counter artillery chance
		PIG_counterArtyChance = nil;
	};
}, 60, _despawnObjects] call CBA_fnc_addPerFrameHandler;