/*
    File: fn_despawnObject.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 24-09-18
    Last Update: 24-10-06
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Handles despawn of an object using CBA's PFH. it will wait until any player side units are far enough to delete the object.

    Parameter(s):
        _veh - Object to despawn [OBJECT, defaults to objNull]

    Returns:
        -
*/

params[
	["_veh", objNull, [objNull]]
];

if (_veh isEqualTo objNull) exitWith {};

[{
	params["_veh", "_handler"];

	if (!isNil {_veh getVariable "inDespawner"}) exitWith {[_handler] call CBA_fnc_removePerFrameHandler;};
	_veh setVariable ["inDespawner", true];

	private _near_units = false;
	{		
		if ((_x distance _veh) < 1500) exitWith { _near_units = true };
	} forEach (allUnits select {(alive _x) && (side _x == KPLIB_side_player)});

	private _despawn = call {
		if ({ alive _x } count crew _veh > 0) exitWith {false};
		if (_near_units) exitWith {false};
		true;
	};

	if ((!alive _veh) && {_despawn}) exitWith {deleteVehicle _veh; [_handler] call CBA_fnc_removePerFrameHandler;};
	if (_despawn) exitWith {deleteVehicle _veh; [_handler] call CBA_fnc_removePerFrameHandler; _veh setVariable ["inDespawner", nil];};
	
}, 60, _veh] call CBA_fnc_addPerFrameHandler;