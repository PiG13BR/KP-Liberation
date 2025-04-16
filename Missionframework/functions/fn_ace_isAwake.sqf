/*
	File: fn_ace_IsAwake.sqf
	Author: PiG13BR
	Date: 2024-10-11
    Last Update: 2025-04-16
    License: MIT License - http://www.opensource.org/licenses/MIT

	Description:
		Check unit unconscious state (ACE)

	Parameter(s):
		_unit - unit to check its state [OBJECT - Infantry unit]
	
	Returns:
		State of the unit [BOOL]
*/

params ["_unit"];

_isAwake = true;

if (KPLIB_ace && {bis_reviveParam_mode == 0}) exitWith {
	_isAwake = [_unit] call ace_common_fnc_isAwake;
};

_isAwake
