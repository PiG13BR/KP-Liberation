/*
    File: fn_getNearestArtillery.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 2024-09-04
    Last Update: 2024-09-04
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Gets

    Parameter(s):
        _pos - Position to check for nearest artillery piece [POSITION, defaults to [0, 0, 0]]
		_radius - Search radius from the position provided [NUMBER, defaults to 1000]

    Returns:
        Nearest artillery piece [OBJECT]
*/


params [
    ["_pos", [0, 0, 0], [[]], [2, 3]],
	["_radius", 1000, [0]]
];

if (KPLIB_o_artilleryUnits isEqualTo []) exitWith {[]};

private _artillery = KPLIB_o_artilleryUnits select {alive _x && {(_x distance2d _pos) < _radius}};

_artillery select 0;