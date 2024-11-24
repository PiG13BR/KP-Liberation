/*
    File: fn_createSectorObjects.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 2024-11-22
    Last Update: 2024-11-24
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
       Creates the garrison buildings, provided if they were registered

    Parameter(s):
        _sector - sector where the objects will be created [STRING]

    Returns:
        All objects created in this sector [ARRAY]
*/

if (!isServer) exitWith {};

params ["_sector"];

private _allGarrisons = [];

private _structures = KPLIB_garrisonsHashMap get _sector;
if ((isNil "_structures") || {count _structures < 1}) exitWith {_allGarrisons};

{   
    _class = _x # 0;
    _pos = ((_x # 1) # 0);
    _dir = ((_x # 1) # 1);

    _object = createVehicle [_class, _pos, [], 0, "CAN_COLLIDE"];
    _object setDir _dir;

    _allGarrisons pushBack _object;
}forEach _structures;

_allGarrisons
