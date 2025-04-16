/*
	File: fn_artillerySupRequest.sqf
	Author: PiG13BR - https://github.com/PiG13BR
	Date: 2024-09-10
	Last Update: 2025-04-16
	License: MIT License - http://www.opensource.org/licenses/MIT

	Description:
		Request artillery strike at a target object

	Parameter(s):
		_grp - Group of requester [GROUP]
		_grpLeader - Requester [OBJECT - Infantry unit]
		_target - Target object [OBJECT - Infantry unit/vehicle]
		_targetPos - Target Position [POSITION]
	
	Returns:
	-
*/

params["_grp", "_grpLeader", "_target", "_targetPos"];

// Check if the leader can see the target
private _visibility = [objNull, "VIEW"] checkVisibility [eyePos _grpLeader, eyePos _target];
private _knowsAbout = _grpLeader knowsAbout _target;

if ((_visibility > 0.1) && {_knowsAbout > 1.5}) then {

	// Stop looping this
	// Arty support is per group. The original idea is to make per sector, but since we can't add string/marker/position as varspace, I've decided to leave with the group itself instead.
	if ((_grp getVariable ["KPLIB_artySupportCalled", false])) exitWith {};
	_grp setVariable ["KPLIB_artySupportCalled", true];
	
	// AI Disable features
	_grpLeader forceSpeed 0;
	_grpLeader setUnitPos "MIDDLE";
	_grpLeader doTarget _target;
	_grpLeader disableAI "FireWeapon";

	sleep 2;

	// Force AI to use binocular by removing it's weapons
	// Save weapons and magazines for later
	_grpLWeapons = weapons _grpLeader;
	_grpLMagazines = (magazines _grpLeader) + [currentMagazine _grpLeader];
	removeAllWeapons _grpLeader;

	if ((binocular _grpLeader) isEqualTo "") then {
		_grpLeader addWeapon "binocular";
	};

	_grpLeader selectWeapon (binocular _grpLeader);
	
	sleep 10 + (random 10); // The players has a chance to kill the leader before calling the arty strike
	if (!(alive _grpLeader) || {!([_grpLeader] call KPLIB_fnc_ace_isAwake)}) exitWith {};

	// From this point, enemy artillery strike is unavoidable

	// AI enable features back
	_grpLeader forceSpeed -1;
	_grpLeader enableAI "FireWeapon";
	_grpLeader setUnitPos "AUTO";

	// Add magazines back
	{
		_grpLeader addMagazine _x;
	}forEach _grpLMagazines;

	// Add weapons back
	{
		_grpLeader addWeapon _x;
	}forEach _grpLWeapons;

	// If provided position is too far from the real killer position, fire a check round instead
	if ((_targetPos distance2d _target > 100) && (_targetPos distance2d _target < 300)) exitWith {
		[_targetPos, 0, "HE", 1 + (random 1)] call KPLIB_fnc_fireArtillery;

		// Artillery strike cooldown
		[{
			_thisArgs setVariable ["KPLIB_artySupportCalled", nil];
		},_grp ,(20 + (random 20)) / (([] call KPLIB_fnc_getOpforFactor) * KPLIB_param_aggressivity)] call CBA_fnc_waitAndExecute;
	};

	// Infantry Section
	if ((_target isKindOf "Man") && (isNull objectParent _target)) then {
		// Machine-gunner/Sniper killer (if doesn't work, blame shitty mod config)
		if (((primaryweapon _target call BIS_fnc_itemtype) select 1 == "MachineGun") || {(primaryweapon _target call BIS_fnc_itemtype) select 1 == "SniperRifle"}) then {
			
			private _ammoType = [[100, "HE", (3 + (random 7))], [0, "SMOKE", (3 + (random 2))]] selectRandomWeighted [0.5, 0.5];
			_ammoType params ["_spread", "_ammo", "_rounds"];
			[_targetPos, _spread, _ammo, _rounds] call KPLIB_fnc_fireArtillery;
		} else {
			// Ordinary infantry
			
			if (sunOrMoon < 1) then {
				_artyReturns = [_targetPos, 10, "FLARE", 1] call KPLIB_fnc_fireArtillery;
				_artyReturns params ["_fired", "_artyElements"];
				if (_fired) then {
					_eta = _artyElements select 1; // Gets the shell's ETA
					sleep _eta + 5;
					[_targetPos, 100, "HE", (3 + (random 7))] call KPLIB_fnc_fireArtillery;
				}
			} else {
				[_targetPos, 100, "HE", (3 + (random 7))] call KPLIB_fnc_fireArtillery;
			};
		};
	};

	// Vehicles Section
	if ((getNumber(configFile >> "CfgVehicles" >> (typeOf (vehicle _target)) >> "ArtilleryScanner")) == 1) exitWith {}; // Let the counter battery handle artillery fire

	if ((toLower (typeOf (vehicle _target))) in KPLIB_allLandVeh_classes) then {
		if ((((typeOf (vehicle _target)) isKindOf "Tank") || {(typeOf (vehicle _target)) isKindOf "WheeledAPC"} || {(typeOf (vehicle _target)) isKindOf "TrackedAPC"} || {(typeOf (vehicle _target)) isKindOf "Wheeled_APC_F"}) && !((typeOf (vehicle _target)) isKindOf "Air")) then {
			// Heavy vehicle
			private _ammoType = [["CLUSTER", 1 + (random 2)], ["LG", 1 + (random 1)], objNull, _target] selectRandomWeighted [0.5, 0.9];
			_ammoType params 
			[
				"_ammo", 
				"_rounds", 
				["_artillery", objNull], 
				["_laserTarget", objNull]
			];
			
			[_targetPos, 10, _ammo, _rounds, _artillery, _laserTarget] call KPLIB_fnc_fireArtillery;
		} else {
			// Light vehicle
			
			[_targetPos, 10, "HE", (3 + (random 7))] call KPLIB_fnc_fireArtillery;
		}
	};

	// Artillery strike cooldown
	[{
		_thisArgs setVariable ["KPLIB_artySupportCalled", nil];
	},_grp ,(90 + (random 30)) / (([] call KPLIB_fnc_getOpforFactor) * KPLIB_param_aggressivity)] call CBA_fnc_waitAndExecute;
}
//}
