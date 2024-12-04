/* 
    File: fn_getArtySpawnPoint.sqf 
    Author: 
        Base file (fn_getOpforSpawnPoint.sqf) - KP Liberation Dev Team - https://github.com/KillahPotatoes; 
        New Edit PIG13BR - https://github.com/PiG13BR
    Date: 2024-12-04 
    Last Update: 2024-12-04 
    License: MIT License - http://www.opensource.org/licenses/MIT 
 
    Description: 
        Gets a random opfor spawn point marker name respecting following conditions: 
        * Wasn't used already in the current session (server restart to server restart) 
        * Blufor FOB as center, opfor artillery position will always be in range of the selected FOB if it stays in the same position during the game
        * It will try to get the closest FOB to the front, considering that they might be the most active ones
        * Distance to blufor FOBs and sectors is more than given min distance 
        * Distance to blufor FOBs and sectors is less than given max distance 
        * Distance to an opfor sector is less than 2000m (to avoid strange spawn in blufor territory) 
 
    Parameter(s): 
        _min        - Minimum range of the artillery                            [NUMBER, defaults to 1000] 
        _max        - Maximum range of the artillery                            [NUMBER, defaults to 6000] 
 
    Returns: 
        Opfor artillery spawn point [STRING] 
*/ 
 
params [ 
    ["_min", 1000, [0]], 
    ["_max", 6000, [0]]
]; 
 
// Only check for opfor spawn points which aren't used already in the current session 
private _spawnsToCheck = KPLIB_sectors_spawn; 
if (!isNil "used_positions") then { 
    _spawnsToCheck = KPLIB_sectors_spawn - used_positions; 
}; 
 
// Get a FOB to be the center position 
if (isNil "KPLIB_sectors_fob" || {KPLIB_sectors_fob isEqualTo []}) exitWith { ["No FOB found", "WARNING"] call KPLIB_fnc_log; ""}; 
 
// Get FOBS near the front by getting the nearest opfor sector 
private _enemy_sectors = KPLIB_sectors_all - KPLIB_sectors_player; 

private _possibleFobs = [];

_possibleFobs = KPLIB_sectors_fob select { 
    _pos = _x; 
    { 
        if !(_pos distance2d markerPos _x > _max ) exitWith { true }; 
    }forEach _enemy_sectors; 
}; 

if (_possibleFobs isEqualTo []) exitWith {["No FOB in range to spawn opfor artillery", "WARNING"] call KPLIB_fnc_log; ""};

// Select a random FOB to be the center position
private _fobCenter = selectRandom _possibleFobs; 

private _possibleSpawns = [];
{ 
    _current = _x; 
 
    // Shouldn't be too close to the current/last position of a secondary mission 
    if (!isNil "secondary_objective_position") then { 
        if !(secondary_objective_position isEqualTo []) then { 
            if !(((markerPos _current) distance2d secondary_objective_position) < 500) then { continue }; 
        }; 
    }; 
 
    // Check marker distances from the FOB 
    if (((markerPos _current) distance2d _fobCenter > _max) || {(markerPos _current) distance2d _fobCenter < _min}) then { continue }; 
     
    // Check marker distances from player's sectors 
    private _check = true; 
    { 
        if (((markerPos _current) distance2d (markerPos _x) < _min) || {(markerPos _current) distance2d (markerPos _x) > _max}) then { 
            _check = false; 
        } 
    }forEach KPLIB_sectors_player; 
 
    if (!_check) then { continue }; 
 
    // Make sure that there is an opfor sector in sensible range to spawn 
    if ((_enemy_sectors) findIf {((markerPos _current) distance2D (markerPos _x)) < 2000} < 0) then { continue }; 
 
    // Make sure that there is no blufor unit inside min dist to spawn 
    if (([markerpos _current, _min, KPLIB_side_player] call KPLIB_fnc_getUnitsCount) > 0) then { continue };
     
    _possibleSpawns pushBack _current; 
 
}forEach _spawnsToCheck; 
 
// Return empty string, if no possible spawn point was found 
if (_possibleSpawns isEqualTo []) exitWith {["No opfor artillery spawn point found", "WARNING"] call KPLIB_fnc_log; ""}; 
 
// Return random spawn point 
(selectRandom _possibleSpawns);