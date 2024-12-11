/* 
	File: fn_fireArtillery.sqf
	Author: PiG13BR - https://github.com/PiG13BR
	Date: 2024-09-04
	Last Update: 2024-10-21
	License: MIT License - http://www.opensource.org/licenses/MIT

	Description:
		Fire artillery rounds at a given position.
		References: Antistasi and Lambs_danger

	Parameter(s):
		_targetPos - Fire mission position 											[POSITION, defaults to [0,0,0]]
		_areaSpread - Spread radius, more radius = less accuracy 						[NUMBER, defaults to 125] 
		_ammo - Type of ammunition, can be "HE", "SMOKE", "FLARE", "CLUSTER", "LG"			[STRING, defaults to HE round]
		_rounds - How many rounds it will fire												[NUMBER, defaults to 3]
		_artillery - The artillery that will do this fire mission							[OBJECT, defaults to objNull]
		_targetObject - This argument is for laser creation									[OBJECT, defaults to objNull]

	Returns:
		Array:
			[BOOL - true or false]
			[ARRAY]
				_artillery - Artillery unit the fired [OBJECT]
				_eta - Shell's ETA [NUMBER]
				_ammoClass - What type of ammunition did it fired [STRING]
				_rounds - How many rounds did it fired [NUMBER]
				_gunnerArty - Gunner from the artillery object [OBJECT]
*/

params[
	["_targetPos",[0,0,0],[[]], [2, 3]],
	["_areaSpread", 125, [0]],
	["_ammo", "HE", [""]],
	["_rounds", 3, [0]],
	["_artillery", objNull, [objNull]],
	["_targetObject", objNull, [objNull]]
];

if (_targetPos isEqualTo [0, 0, 0]) exitWith {["No or zero pos given"] call BIS_fnc_error; [false, []]};

// ---------------------------------------------------------- SELECT ARTILLERY

// If no artillery is provided, find one in the pool
if (isNull _artillery) then {
	_artillery_battery = [] call KPLIB_fnc_getReadyArtillery;
	if (_artillery_battery isEqualTo []) exitWith {["No artillery available in the pool", "FIRE MISSION FAILED"] call KPLIB_fnc_log; [false, []]};
	_artillery = selectRandom _artillery_battery;
};

// ---------------------------------------------------------- SET ARTILLERY TO BUSY
_gunnerArty = gunner _artillery;
_gunnerArty setVariable ["KPLIB_isArtilleryBusy", true, true];

// ---------------------------------------------------------- SELECT AMMO
private _ammoClass = "";

switch (_ammo) do {
	case "HE" : {
		_ammoClass = KPLIB_artyHashMap_ammo get "KPLIB_arty_HE_round";
	};
	case "SMOKE" : {
		// If it's night, change the ammo
		if (sunOrMoon == 1) then {
			_ammoClass = KPLIB_artyHashMap_ammo get "KPLIB_arty_SMOKE_round";
		} else {
			_ammoClass = KPLIB_artyHashMap_ammo get "KPLIB_arty_FLARE_round";
			_rounds = 1;
		};
	};
	case "FLARE" : {
		_ammoClass = KPLIB_artyHashMap_ammo get "KPLIB_arty_FLARE_round";
	};
	case "CLUSTER" : {
		_ammoClass = KPLIB_artyHashMap_ammo get "KPLIB_arty_CLUSTER_round";
	};
	case "LG" : {
		_ammoClass = KPLIB_artyHashMap_ammo get "KPLIB_arty_LG_round";
		
		if (_ammoClass != "") then {
			_areaSpread = 0; // Precise strike
			private _eta = _artillery getArtilleryETA [_targetPos, _ammoClass];
			_laserTarget = [_targetPos, KPLIB_side_enemy, _eta, _targetObject] call KPLIB_fnc_createLaserTarget;
			// Don't fire LG rounds if not found any targets to lase
			if (isNull _laserTarget) exitWith {
				_ammoClass = KPLIB_artyHashMap_ammo get "KPLIB_arty_HE_round"; 
				_rounds = 3;
			}
		}
	}
};

// If no ammo found in the preset, get the default ("HE") with minimum rounds
if (_ammoClass == "") then {_ammoClass = KPLIB_artyHashMap_ammo get "KPLIB_arty_HE_round"; _rounds = 3;};
// If it's still getting a empty string, exit the script
if (_ammoClass == "") exitWith {["No ammo class found. Check your preset"] call BIS_fnc_error; 
	_gunnerArty setVariable ["KPLIB_isArtilleryBusy", false, true];
	[false, []]
};

// ---------------------------------------------------------- CHECK RANGE
if !(_targetPos inRangeOfArtillery [[_artillery], _ammoClass]) exitWith {
	["The target is out of artillery range or wrong magazine type provided in presets or artillery is null", "FIRE MISSION FAILED"] call KPLIB_fnc_log;
	_gunnerArty setVariable ["KPLIB_isArtilleryBusy", false, true];
	[false, []]
};

// ---------------------------------------------------------- FIRE MISSION
_artillery doWatch _targetPos;

_weaponTurret = (_artillery weaponsTurret [0]) select 0;
private _reloadTime = getNumber(ConfigFile >> "CfgWeapons" >> _weaponTurret >> "magazineReloadTime");
if (_reloadTime < 1) then {_reloadTime = 1};

private _eta = _artillery getArtilleryETA [_targetPos, _ammoClass];

[_artillery, _targetPos, _areaSpread, _ammoClass, floor(_rounds), _reloadTime, _gunnerArty] spawn {
	params["_artillery", "_targetPos", "_areaSpread", "_ammoClass", "_rounds", "_reloadTime", "_gunnerArty"];
	[format ["The enemy artillery is firing at pos %1 with class ammo %2. Rounds: %3",_targetPos, _ammoClass, _rounds], "FIRE MISSION"] call KPLIB_fnc_log;
	for "_i" from 1 to _rounds do {
		_randomPos = [[[_targetPos, _areaSpread]], []] call BIS_fnc_randomPos;

		// Fire artillery
		if (local _artillery) then {
			_artillery doArtilleryFire [_randomPos, _ammoClass, 1];
		} else {
			[_artillery, [_randomPos, _ammoClass, 1]] remoteExec ["doArtilleryFire", owner _artillery];
		};

		sleep (3 + _reloadTime);
	};
	// ---------------------------------------------------------- SET ARTILLERY TO NOT BUSY
	_gunnerArty setVariable ["KPLIB_isArtilleryBusy", false, true];
};

[true, [_artillery, _eta, _ammoClass, _rounds, _gunnerArty]]
