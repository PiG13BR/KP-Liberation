/*
    File: fn_registerSectorObjects.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 2024-11-23
    Last Update: 2024-11-24
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Registers pre-placed objects from a sector into a hashmap and deletes them from the map

    Parameter(s):
        -

    Returns:
        -
*/

if (!isServer) exitWith {};

[{(!isNil "KPLIB_sectors_all") && {!isNil "KPBLIB_sector_ObjectsBlacklist"}}, {
	private _radius = KPLIB_range_sectorCapture * 1.5;
	private _allObjects = [];
	// Get all placed objects near sectors
	{
		_editedObjs = nearestObjects [(markerPos _x), ["Static", "Thing"], _radius];
		_terrainObjs = nearestTerrainObjects [(markerPos _x), [], _radius]; // Get the terrain objects. It will also get simple objects set up from attributes.

		_onlyEditedObjs = (_editedObjs - _terrainObjs) select {!((typeOf _x) in KPLIB_radioTowerClassnames)}; // Exclude terrain objects and radio towers

		_allObjects append _onlyEditedObjs;
	}forEach KPLIB_sectors_all;

	if (isNil "KPBLIB_garrisonsHashMap") then {
		// Creates the hashmap
		KPBLIB_garrisonsHashMap = createHashMap;
	};

	{
		// Ignore object from blacklist (the object will not be deleted in game start and will retain any attributes from editor)
		if (_x in KPBLIB_sector_ObjectsBlacklist) then { continue };
		private _sector = [_radius, getPos _x] call KPLIB_fnc_getNearestSector; // Nearest sector will be the key for the hashmap
		
		if (_sector isEqualTo "") then {[format ["%1 in position %2 is too far away from any sectors. Deleting the object.", (typeOf _x), (getPos _x)], "WARNING"] call KPLIB_fnc_log; deleteVehicle _x; continue};
		
		// Check if the key (sector) is already in the hashmap
		if !(_sector in KPBLIB_garrisonsHashMap) then {
			// Create a new key with a value
			KPBLIB_garrisonsHashMap set [_sector, [[typeOf _x, [getPosATL _x, getDir _x]]]];
		} else {
			// Update key values if key already exists
			private _mapValue = KPBLIB_garrisonsHashMap get _sector;
			private _mapNewValues = _mapValue + [[typeOf _x, [getPosATL _x, getDir _x]]];
			KPBLIB_garrisonsHashMap set [_sector, _mapNewValues];
		};

		// Delete the object to spawn it later when the sector is activated
		deleteVehicle _x;
	}forEach _allObjects;

	KPBLIB_sector_ObjectsBlacklist = nil;

}, []] call CBA_fnc_waitUntilAndExecute;
