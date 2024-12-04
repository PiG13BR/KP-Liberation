/*
    File: fn_counterArtillery.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 2024-09-01
    Last Update: 2024-12-03
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Handles the counter artillery fire.
		It's executed when a artillery shell explodes via EH

    Parameter(s):
    	_unit - The artillery piece that fired [OBJECT] 
		_shellPos - Position where the shell exploded [POSITION]

    Returns:
        -
*/

params["_unit", "_shellPos"];

if (isNil "KPLIB_o_artilleryUnits") exitWith {};
if (KPLIB_o_artilleryUnits isEqualTo []) exitWith {};
if (count (((ASLToAGL _shellPos) nearEntities [["Man", "landVehicle"], 200]) select {(alive _x) && (side _x == KPLIB_side_enemy)}) < 1) exitWith {};

// Each time that blufor fires an artillery and targets enemy units by shell exploding near them, it will raise the chance of the counter artillery
// Get the original value from KPLIB_config.sqf into a new variable to modifity it without modifying the original value itself
if (isNil "PIG_counterArtyChance") then {
	// Resets value if nil
	PIG_counterArtyChance = 25;
	publicVariableServer "PIG_counterArtyChance"
};

PIG_counterArtyChance = PIG_counterArtyChance + 5;
publicVariableServer "PIG_counterArtyChance";

if (PIG_counterArtyChance >= 100) then {PIG_counterArtyChance = 100; publicVariableServer "PIG_counterArtyChance";};

if (side _unit == KPLIB_side_player) then {

	private _chanceOfFiring = 0;

	// Find if the shell landed near the enemy artillery position by getting the nearest artillery piece
	private _nearestArtillery = [_shellPos, 200] call KPLIB_fnc_getNearestArtillery;

	if (!isNil "_nearestArtillery") then {
			_chanceOfFiring = 100; // Always react
		} else {
			_chanceOfFiring = PIG_counterArtyChance // Has a chance to react
		};
	if ((random 100) <= _chanceOfFiring) then {

		if (_unit getVariable ["PIG_CounterArtyReaction", false]) exitWith {}; // Exit loop
		_unit setVariable ["PIG_CounterArtyReaction", true];

		// Enemy artillery reaction time
		sleep ((10 + (random 20)) / (([] call KPLIB_fnc_getOpforFactor) * KPLIB_param_aggressivity));

		if ((_unit isKindOf "StaticMortar") || {_unit isKindOf "StaticWeapon"}) then {
			// Static target artillery
			private _ammoType = [["HE", (3 + (random 7))], ["CLUSTER", (1 + (random 1))]] selectRandomWeighted [0.8, 0.2];
			[getPos _unit, 20, (_ammoType select 0), (_ammoType select 1)] call KPLIB_fnc_fireArtillery;
		} else {
			// Heavy/Mobile target artillery
			private _ammoType = [["HE", (3 + (random 7))], ["LG", 1]] selectRandomWeighted [0.2, 0.8]; // Heavy punishment for the use of heavy artillery
			if (_ammoType select 0 == "LG") then {
				[getPos _unit, 20, (_ammoType select 0), (_ammoType select 1), objNull, _unit] call KPLIB_fnc_fireArtillery;
			} else {
				[getPos _unit, 20, (_ammoType select 0), (_ammoType select 1)] call KPLIB_fnc_fireArtillery;
			};
		};

		// Delay
		sleep ((10 + (random 20)) / (([] call KPLIB_fnc_getOpforFactor) * KPLIB_param_aggressivity));
		_unit setVariable ["PIG_CounterArtyReaction", nil];
	}
};