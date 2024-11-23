/*
    File: fn_registerGarrison.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 2024-11-22
    Last Update: 2024-11-22
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Registers the garrison buildings into a hashmap and deletes them in the map
		To register a building, you must place in the editor, near a sector, and put this in it's init field: [this] call PIG_fnc_registerGarrison
		Also, the building class must be in the KPLIB_staticsConfigs.sqf to work

    Parameter(s):
        _structure - structure that will be registered    [OBJECT]

    Returns:
        -
*/

if (!isServer) exitWith {};

params ["_structure"];

[{!isNil "KPLIB_sectors_all"}, {
	// Check if building is under KPLIB_staticsConfigs.sqf file
	_classesCheck = PIG_staticsConfigs apply {_x # 0};
	if !((typeOf _this) in _classesCheck) exitWith {[format ["%1 not found in KPLIB_staticsConfigs.sqf", (typeOf _this)], "WARNING"] call KPLIB_fnc_log; deleteVehicle _this;};

	// Get sector
    private _sector = [1000, getPos _this] call KPLIB_fnc_getNearestSector; // Nearest sector will be the key for the hashmap

	if (isNil "PIG_garrisonsHashMap") then {
		// Creates the hashmap
		PIG_garrisonsHashMap = createHashMap;
	};

	// Check if the key (sector) is already in the hashmap
	if !(_sector in PIG_garrisonsHashMap) then {
		// Create a new key with a value
		PIG_garrisonsHashMap set [_sector, [[typeOf _this, [getPosATL _this, getDir _this]]]];
	} else {
		// Update key values if key already exists
		private _mapValue = PIG_garrisonsHashMap get _sector;
		private _mapNewValues = _mapValue + [[typeOf _this, [getPosATL _this, getDir _this]]];
		PIG_garrisonsHashMap set [_sector, _mapNewValues];
	};

	// Delete the structure from the map to spawn it later when sector is activated
	deleteVehicle _this;
}, _structure, 1] call CBA_fnc_waitUntilAndExecute;