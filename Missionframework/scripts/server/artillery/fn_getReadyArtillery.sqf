/*
    File: fn_getReadyArtillery.sqf
    Author: PiG13B - https://github.com/PiG13BR
    Date: 2024-09-06
    Last Update: 2024-12-11
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Gets available/ready artillery in the pool

    Parameter(s):
        -

    Returns:
        Artillery pool [ARRAY]
*/

if (KPLIB_o_artilleryUnits isEqualTo []) exitWith {};

private _artillery_battery = [];

{	
	private _gunner = objNull;
	_gunner = gunner _x;
	if ((isNull _gunner) || {!alive (gunner _x)} || {!canFire _x}) then {continue};
	if (!(_gunner getVariable ["KPLIB_isArtilleryBusy", false])) then {
		if ((getNumber(configFile >> "CfgVehicles" >> typeOf _x >> "artilleryScanner")) == 1) then {
			if ((gunner _x) isEqualTo objNull) then {continue};
            
            // Add to pool
			_artillery_battery pushBack _x;
		}
	};
}forEach KPLIB_o_artilleryUnits;

_artillery_battery