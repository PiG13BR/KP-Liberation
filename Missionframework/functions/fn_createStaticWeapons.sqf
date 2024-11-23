/*
    File: fn_createStaticWeapons.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 2024-11-22
    Last Update: 2024-11-22
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
       Creates static weapons in the structures spawned in the sector

    Parameter(s):
        _structure - structure that will be registered    [OBJECT]

    Returns:
        All static weapons [ARRAY]
*/


if (!isServer) exitWith {};

params[
	["_sectorpos", (getPos player), [[]], [2,3]], 
	["_radius", 500, [0]]
];

private _allStaticWeapons = [];
private _classes = PIG_staticsConfigs apply { _x select 0 }; // Get only the classes

// Find garrisons objects for static weapons in the activated sector
private _allStaticGarrisons = (nearestObjects [_sectorpos, _classes, (_radius * 1.5)]) select {alive _x};
// Create a group for the static weapons for the sector
private _staticGroup = createGroup KPLIB_side_enemy;

if (count _allStaticGarrisons > 0) then {
	// Loop the garrison objects found
	{
		private _garrison = _x;
		// Loop statics configuration provided in KPLIB_staticsConfigs.sqf
		{
			// Check if the object type matches one of the configuration
			if (_x # 0 == typeOf _garrison) then {
				// Count how many positions are available for static weapons by counting the second element of the main array
				private _positions = count (_x # 1);
				if (_positions > 0) then {
					for "_index" from 0 to (_positions - 1) do {
						// The provided _index number in this loop will select each array that contains the necessary values to spawn correctly the static weapon for each relative position provided in the configuration
						private _type = (((_x # 1) # _index) # 0); // Get the types
						private _relPos = (((_x # 1) # _index) # 1); // Get the relativePosition
						private _relDir = (((_x # 1) # _index) # 2); // Get the rotation

						diag_log "---------------------------------------------------";
						diag_log format ["%1, %2, %3", _type, _relPos, _relDir];

						private _typeSel = "";
						// It will select randomly the type if more than one is provided.
						if (count _type > 1) then {
							_typeSel = selectRandom _type;
						} else {
							_typeSel = _type # 0;
						};

						// For the selected type, it will check the static weapons presets
						private _staticClass = "";
						switch _typeSel do {
							case "HMG" : {
								_staticClass = selectRandom KPLIB_o_turrets_HMG;
							};
							case "AT" : {
								_staticClass = selectRandom KPLIB_o_turrets_AT;
							};
							case "AA" : {
								_staticClass = selectRandom KPLIB_o_turrets_AA;
							}
						};
						// Create the static weapon and it's crew
						_weapon = [(_garrison modelToWorld _relPos), _staticClass, _relDir] call PIG_fnc_spawnStaticWeapon;
						// Group the static weapons to share information easily.
						(crew _weapon) joinSilent _staticGroup;
						_allStaticWeapons pushBack _weapon;
					};
				};
			}
		}forEach PIG_staticsConfigs;
	}forEach _allStaticGarrisons;
};

_allStaticWeapons