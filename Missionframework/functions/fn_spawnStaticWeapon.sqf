/*
    File: fn_spawnStaticWeapon.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 2024-11-22
    Last Update: 2024-11-22
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
       Handles the spawning of a static weapon

    Parameter(s):
        _relPos - relative position to a object [POSITION, PositionRelative]
		_class - classname of the static weapon to spawn [STRING]
		_relDir - relative direction to a object [NUMBER]

    Returns:
        All static weapons [ARRAY]
*/

params ["_relPos", "_class", "_relDir"];

_weapon = createVehicle [_staticClass, _relPos, [], 0, "CAN_COLLIDE"];
_weapon setDir ((getDir _garrison) + (_relDir));
_weapon setVectorUp surfaceNormal getPosASL _weapon;
_crewGrp = createVehicleCrew _weapon;

{
	_x addMPEventHandler ["MPKilled", {
		params ["_unit", "_killer"];
		["KPLIB_manageKills", [_unit, _killer]] call CBA_fnc_localEvent;
	}];
} forEach (units _crewGrp);

_weapon addMPEventHandler ["MPKilled", {
    params ["_unit", "_killer"];
    ["KPLIB_manageKills", [_unit, _killer]] call CBA_fnc_localEvent;
}];

// Infinite ammo.
_weapon addEventHandler ["Reloaded", {
	params ["_unit", "_weapon", "_muzzle", "_newMagazine", "_oldMagazine"];
	if !(isPlayer (gunner _unit)) then {_unit setVehicleAmmo 1};
}];

[_weapon] call KPLIB_fnc_clearCargo;
[_weapon] call KPLIB_fnc_addObjectInit;

_weapon
