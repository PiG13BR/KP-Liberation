/*
    File: fn_despawnObject.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 24-09-18
    Last Update: 24-10-06
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Handles despawn of a group using CBA's PFH. it will wait until any player side units are far enough to delete the group.

    Parameter(s):
        _group - Object to despawn [GROUP, defaults to grpNull]

    Returns:
        -
*/

params[
	["_group", grpNull, [grpNull]]
];

if (_grp isEqualTo grpNull) exitWith {};

[{
	params["_group", "_handler"];

	if (!isNil {_group getVariable "inDespawner"}) exitWith {[_handler] call CBA_fnc_removePerFrameHandler;};
	_group setVariable ["inDespawner", true];

	_leader = leader _group;

	if (isNull _leader) exitWith {[_handler] call CBA_fnc_removePerFrameHandler;}; // No existent leader = no alive members for this group

	private _near_units = false;
	{	
		private _blufor_unit = _x;
		{
			if ((_blufor_unit distance _x) < 1200) exitWith { _near_units = true };
		}forEach units _group;
		
	} forEach (allUnits select {(alive _x) && (side _x == KPLIB_side_player)});

	private _despawn = call {
		if (_near_units) exitWith {false};
		true;
	};

	if (_despawn) exitWith { 
		{
			if (vehicle _x != _x) then {deleteVehicle (vehicle _x); continue};
			if (!alive _x) then {deleteVehicle _x; continue};
			deleteVehicle _x;
		}forEach units _group;
		_group setVariable ["inDespawner", nil];
		[_handler] call CBA_fnc_removePerFrameHandler;
	};
}, 60, _group] call CBA_fnc_addPerFrameHandler;