/*
    File: fn_createGarrison.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 2024-11-22
    Last Update: 2024-11-22
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
       Creates the garrison buildings, provided if they were registered and in the configuration file

    Parameter(s):
        _structure - structure that will be registered    [OBJECT]

    Returns:
        All garrison objects for this sector [ARRAY]
*/

if (!isServer) exitWith {};

params ["_sector"];

private _allGarrisons = [];

private _structures = PIG_garrisonsHashMap get _sector;
if ((isNil "_structures") || {count _structures < 1}) exitWith {_allGarrisons};

{   
    private _class = _x # 0;
    private _pos = ((_x # 1) # 0);
    private _dir = ((_x # 1) # 1);
    private _object = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];
    _object setDir _dir;

    _allGarrisons pushBack _object;
}forEach _structures;

_allGarrisons
