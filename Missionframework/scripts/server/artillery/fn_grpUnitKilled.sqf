/*
	File: fn_grpUnitKilled.sqf
	Author: PiG13BR
	Date: 2024-10-11
    Last Update: 2024-10-17
    License: MIT License - http://www.opensource.org/licenses/MIT

	Description:
		Handles the calling of enemy artillery support if group of enemy units is attacked

	Parameter(s):
		_grp - group of the unit that got killed [GROUP]
		_unit - unit that got killed [OBJECT - Infantry unit]
		_killer - killer [OBJECT - Infantry unit]
	
	Returns:
		-
*/

params ["_grp", "_unit", "_killer"];

// Return the nearest sector of the killed unit
_sector = [300, getPos _unit] call KPLIB_fnc_getNearestSector;
// Is this an active sector?
if (!(_sector in KPLIB_sectors_active) || {_sector in KPLIB_sectors_player}) exitWith {};

if ((!(isNull objectParent _unit)) && {vehicle (leader _grp) != (leader _grp)}) exitWith {};

// ---------------------------------------------------------- ENEMY ARTILLERY SUPPORT HANDLING
if (!isNil "KPLIB_o_artilleryUnits") then {

	private _minDist = 100; // This is the minumun distance from the killer that the leader can call the artillery

	// Check distance from killer and artillery availability
	if ((_unit distance2d _killer >= _minDist) || {KPLIB_o_artilleryUnits isNotEqualTo []}) then {
		if ((side _killer) == KPLIB_side_player) then {
			// Only leaders (from preset) can call artillery strike
			private _grpLeader = leader _grp;
			//private _leaderType = typeOf _grpLeader;
			//if ((_leaderType != KPLIB_o_officer) && {(_leaderType != KPLIB_o_squadLeader)} && {(_leaderType != KPLIB_o_teamLeader)} && {!(_leaderType in KPLIB_o_militiaInfantry)}) exitWith {["Exit Leader"] remoteExec ["hint"]};

			// "Returns the Position where object believes the enemy to be".
			_posKiller = _grpLeader getHideFrom _killer;
			[str _posKiller] remoteExec ["systemChat"];
			if (_posKiller isEqualTo [0,0,0]) exitWith {}; // "A returned position of [0,0,0] implies that object does not knowAbout enemy

			// Check if the provided position is not inside a town/capital
			if (((_sector in KPLIB_sectors_capital) || {_sector in KPLIB_sectors_city}) && {_posKiller distance (markerpos _sector) < 250}) exitWith {};
			//private _nearby_bigtown = KPLIB_sectors_capital select {!(_x in KPLIB_sectors_player) && (_posKiller distance (markerpos _x) < 250)};
			//private _nearby_smalltown = KPLIB_sectors_city select {!(_x in KPLIB_sectors_player) && (_posKiller distance (markerpos _x) < 250)};

			//if ((count _nearby_bigtown > 0) || {count _nearby_smalltown > 0}) exitWith {["Exit 1"] remoteExec ["hint"]};
			// Check if possible position is too far from the original position or too near to friendlies
			if ((_posKiller distance2d _killer >= 200) || {count((_posKiller nearEntities [["Man"], 75]) select {side _x == KPLIB_side_enemy}) > 0}) exitWith {["Too far or too near to friendlies"] remoteExec ["hint"]};

			// Check target strength
			_targetsArray = _grpLeader targets [true, (_grpLeader distance2d _killer) + 100, [side _killer]];

			// If killer side strength is higher, call artillery support
			if ((count _targetsArray) > (count units _grp) || {(toLower (typeOf (vehicle _killer))) in KPLIB_allLandVeh_classes}) then {
				[_grp, _grpLeader, _killer, _posKiller] spawn KPLIB_fnc_artillerySupRequest
			};
		};
	};
};

