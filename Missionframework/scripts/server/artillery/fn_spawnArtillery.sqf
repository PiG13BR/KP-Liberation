/* 
	File: fn_spawnArtillery.sqf
	Author: PiG13BR - https://github.com/PiG13BR
	Date: 2024-09-04
	Last Update: 2024-12-01
	License: MIT License - http://www.opensource.org/licenses/MIT

	Description:
		Manage the artillery spawn
	
	Parameter(s):
		- Spawn position - position where the artillery will spawn [POSITION, defaults to [0,0,0]]
		- Classname - classname of the artillery [STRING, defaults to ""]

	Return(s):
		- The artillery spawned [OBJECT]
*/

params [
    ["_pos", [0, 0, 0], [[]], [2, 3]],
    ["_className", "", [""]]
];

if (_pos isEqualTo [0, 0, 0]) exitWith {["No or zero pos given"] call BIS_fnc_error; objNull};
if (_classname isEqualTo "") exitWith {["Empty string given"] call BIS_fnc_error; objNull};

private _newartillery = objNull;
private _spawnPos = [];

// ---------------------------------------------------------- FIND A POSITION 
private _spawnPos = [[[(getMarkerpos _spawn_marker), 100]], ["water"], {
	(count (_this nearRoads 30) == 0) &&
	//{!isOnRoad _this} && 
	{count(_this nearEntities 20) < 1} && 
	{!((_this isFlatEmpty [-1, -1, 0.15, 20, 0, false]) isEqualTo [])}
}] call BIS_fnc_randomPos;

if (_spawnPos isEqualTo [0,0]) exitWith {
    ["No suitable spawn position found."] call BIS_fnc_error;
    [format ["Couldn't find spawn position for %1 around position %2", _classname, _pos], "WARNING"] call KPLIB_fnc_log;
    objNull
};

{  
	[_x, true] remoteExec ["hideObject", 0];
} forEach nearestTerrainObjects [_spawnPos, [], 10, false, true];

// ---------------------------------------------------------- SPAWN THE ARTILLERY
_newartillery = _classname createVehicle _spawnPos;
_newartillery allowDamage false;

[_newartillery] call KPLIB_fnc_allowCrewInImmobile;

// Reset position and vector
_newartillery setPos _spawnPos;
_newartillery setVectorUp surfaceNormal position _newartillery;

// Hide terrain objects near the artillery
{  
	[_x, true] remoteExec ["hideObject", 0];
} forEach nearestTerrainObjects [_newartillery, [], 30, false, true];

// Set direction of the artillery (relative to the nearest player's fob)
private _fob = [_spawnPos] call KPLIB_fnc_getNearestFob;
_newartillery setDir (getDir _newartillery + (_newartillery getRelDir _fob));

// Clear cargo, if enabled
[_newartillery] call KPLIB_fnc_clearCargo;

// Process KP object init
[_newartillery] call KPLIB_fnc_addObjectInit;

// Spawn crew of vehicle
private _crewGrp = createVehicleCrew _newartillery;

// Lock vehicle 
[_newartillery, "LOCKEDPLAYER"] remoteExec ["setVehicleLock"];
_newartillery lockDriver true;

// Delete driver if is a mobile artillery unit
if !(_newartillery isKindOf "StaticWeapon") then {
	// If it's mobile, remove the possibility of moving
	_newartillery deleteVehicleCrew (driver _newartillery);
};

// ---------------------------------------------------------- EVENT HANDLERS
// Manage kills
_newartillery addMPEventHandler ["MPKilled", {
    params ["_unit", "_killer"];
    ["KPLIB_manageKills", [_unit, _killer]] call CBA_fnc_localEvent;
}];

/*
	// Eject any player that tries to enter the artillery.
	_newartillery addEventHandler ["GetIn", {
		params ["_veh", "_pos", "_unit"];
		if (side _unit != KPLIB_side_enemy) then {
			_unit action ["eject", _veh];
		};
	}];
*/

// Infinite ammo
_newartillery addEventHandler ["Fired",{
	params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
	[_unit,	_magazine] call CBA_fnc_addMagazine;
}];

// Handle dammage 
_newartillery addEventHandler ["HandleDamage", {
	params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit", "_context"];
	// Eject crew if damaged
	if (!canFire _unit) then {
		if ({alive _x} count (crew _unit) > 0) then {
			{
				_x action ["eject", _unit];
			}forEach (crew _unit);
		}
	}
}];

if (_newartillery isKindOf "StaticWeapon") then {
	{
		// Eject crew if hit
		_x addEventHandler ["Hit", {
		params ["_unit", "_source", "_damage", "_instigator"];
			private _grp = group _unit;
			private _veh = vehicle _unit;
			{
				_unit action ["eject", _veh];
			}forEach units _grp;
		}];

		// Force eject crew if dead 
		_x addMPEventHandler ["MPKilled", {
			params ["_unit", "_killer"];
			moveOut _unit;
		}];
	}forEach units _crewGrp;
};

// ---------------------------------------------------------- FINAL SETUP AND RETURN
// Set this variable to check if the artillery is busy (Default: false)
_gunner = gunner _newartillery;
_gunner setVariable ["KPLIB_isArtilleryBusy", false, true];

_newartillery allowDamage true;
_newartillery setDamage 0;

_newartillery
