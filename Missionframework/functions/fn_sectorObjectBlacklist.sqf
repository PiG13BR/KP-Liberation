/*
    File: fn_sectorObjectBlacklist.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 2024-11-23
    Last Update: 2024-12-16
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        This is where the object have the option to remain in the map and not be spawned/despawned in designated sector.
        Adds the object in a blacklist. The object in the blacklist will not be deleted in the game start and will retain any attributes from editor. If the object is a simple object, it will be automatic ignored in the fn_registerSectorObjects.sqf file.
        Also, if the object classname is in KPLIB_staticsConfigs, the spawning of static weapons for this building object can be disabled (NOT THE ENTIRE CLASS) and it will be managed in a different blacklist.
        To add an object in the blacklist, put this code in its init field. Follow the examples below:
            [this] call KPLIB_fnc_sectorObjectBlacklist - object blacklisted, static weapons can spawn in garrison buildings as default
            [this, false, false] call KPLIB_fnc_sectorObjectBlacklist - object not blacklisted and static weapon spawn disabled
            [this, true, false] call KPLIB_fnc_sectorObjectBlacklist - object blacklisted and static weapon spawn disabled
            [this, false, true] call KPLIB_fnc_sectorObjectBlacklist - Normal behaviour without calling this function
        This function must be put in the init field of the objects to run before any liberation script (https://community.bistudio.com/wiki/Initialisation_Order)

        If some of those buildings already exists in the map (as terrain) and you want to disable the spawning of static weapons, for example, place a logic near the object and in its init field:
            {[_x, true, false] call KPLIB_fnc_sectorObjectBlacklist}forEach (nearestObjects [getPos this, ["classname_object"], 25, false])
        Find the correct classname of the object and change the radius of search if needed. Those terrain objects can't be deleted, so leave the second parameter of the function as TRUE.

    Parameter(s):
        _object - structure that will be registered [OBJECT]
        _blacklisted - true for blacklisting the object [BOOL, defaults as true]
        _canGarrison - if the object is a garrison building (KPLIB_staticsConfigs.sqf), false for disabling any static weapon spawning on it [BOOL, defaults as true]

    Returns:
        -
*/
if (!isServer) exitWith {};

params[
    ["_object", objNull, [objNull]],
    ["_blacklisted", true, [FALSE]],
    ["_canGarrison", true, [FALSE]] // To work, the structure classname must be under KPLIB_staticsConfigs. This will not enable a structure to accept static weapons spawn by magic.
];

if (isNull _object) exitWith {};

// General blacklist variable
if (isNil "KPLIB_sector_ObjectsBlacklist") then {
    KPLIB_sector_ObjectsBlacklist = [];
};

// Add object to the general blacklist
if (_blacklisted) then {
    KPLIB_sector_ObjectsBlacklist pushBack _object;
};

// This is for the buildings/structures that the spawning of static weapons is disabled.
if (isNil "KPLIB_GarrisonsBlacklist_HashMap") then {
    // Creates the hashmap
    KPLIB_GarrisonsBlacklist_HashMap = createHashMap;
};

private _radius = KPLIB_range_sectorCapture;

if (!_canGarrison) then {
    [{!isNil "KPLIB_sectors_all"}, {
        _this params ["_object", "_canGarrison"];
        // Because a deleted object will give a <NULL-OBJECT> in the garrison array, save the position of the object instead to find a match later.
        private _objectPos = [round parseNumber (((getPosATL _object) # 0) toFixed 2), round parseNumber (((getPosATL _object) # 1) toFixed 2), round parseNumber (((getPosATL _object) # 2) toFixed 2)];
        private _sector = [_radius, getPos _object] call KPLIB_fnc_getNearestSector;
        //private _objectPos = _object worldToModel (markerPos _sector);
        
        if !(_sector in KPLIB_GarrisonsBlacklist_HashMap) then {
        // Create a new key with a value
            KPLIB_GarrisonsBlacklist_HashMap set [_sector, [_objectPos]];
        } else {
            // Update key values if key already exists
            private _mapValue = KPLIB_GarrisonsBlacklist_HashMap get _sector;
            private _mapNewValues = _mapValue + [_objectPos];
            KPLIB_GarrisonsBlacklist_HashMap set [_sector, _mapNewValues];
        };

    }, [_object, _canGarrison]] call CBA_fnc_waitUntilAndExecute;
};
