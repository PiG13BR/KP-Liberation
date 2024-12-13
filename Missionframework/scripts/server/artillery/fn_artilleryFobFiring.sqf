/* 
	File: fn_artilleryFobTargeting.sqf
	Author: PiG13BR - https://github.com/PiG13BR
	Date: 2024-10-06
	Last Update: 2024-12-13
	License: MIT License - http://www.opensource.org/licenses/MIT

	Description:
		Find a FOB with players inside of it (meaning for the enemy "an active FOB") to do a fire mission (try each 5-10 min + chance)
	
	Parameter(s):
		_targetFob - target FOB position [ARRAY]

	Return(s):
		-
*/

params ["_targetFob"];

// ---------------------------------------------------------- FIRE MISSION
// Can be: HE (70%), Cluster (20%) or LG (10%)

_ammoType = [["HE", (3 + (random 7))], ["CLUSTER", (1 + (random 1))], ["LG", (1 + (random 1))]] selectRandomWeighted [0.7, 0.2, 0.1];
_ammoType params ["_shell", "_rounds"];

[_targetFob, KPLIB_range_fob, _shell, _rounds] call KPLIB_fnc_fireArtillery;

[] call KPLIB_fnc_artilleryFobTargeting;
