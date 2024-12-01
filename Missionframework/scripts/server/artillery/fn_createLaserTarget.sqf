/*
	File: fn_createLaserTarget.sqf
	Author: PiG13BR - https://github.com/PiG13BR
	Date: 2024-09-06
	Last Update: 2024-10-11
	License: MIT License - http://www.opensource.org/licenses/MIT

	Description:
		Creates a target laser in a object
	
	Parameter(s):
		_targetArea - Target position [POSITION - Defaults to [0,0,0]]
		_side - Side used for the creation of the laser object [SIDE - Defaults to KPLIB_side_enemy from KPLIB_config.sqf]
		_eta - Arty shell time travel (Time to delete the laser object) [NUMBER - Defaults to 60]
		_targetObject - The target object if provided [OBJECT - Defaults to objNull]
	
	Returns:
		Target Object if success, objNull if fails - [OBJECT]
*/

params[
	["_targetArea", [0,0,0], [[]], [2,3]],
	["_side", KPLIB_side_enemy, [sideUnknown]], 
	["_eta", 60, [0]],
	["_targetObject", objNull, [objNull]]
];

if (_targetArea isEqualTo [0, 0, 0]) exitWith {["No or zero pos given"] call BIS_fnc_error; _targetObject};

if (_targetObject isEqualTo objNull) then {
	// Find a target to lase

	private _structureTargets = [];
	private _realVehTargets = [];
	private _realStructureTargets = [];
	private _possibleTargets = [];

	// Find valuable vehicles in the area
	/*
		nearEntities only searches for alive objects and on-foot soldiers.
		In-vehicle units, killed units, destroyed vehicles, static objects and buildings will be ignored.
	*/
	_realVehTargets = _targetArea nearEntities [(KPLIB_b_vehHeavy + KPLIB_b_vehAir) apply {_x select 0}, 125];

	// FOB?
	if (_targetArea in KPLIB_sectors_fob) then {
		// Find valuable structures aswell
		_structureTargets = nearestObjects [_targetArea, [KPLIB_b_airControl, KPLIB_b_slotPlane, KPLIB_b_logiStation], KPLIB_range_fob];
		// Filter it
		_realStructureTargets = _structureTargets select {alive _x};
	};

	_possibleTargets = _realVehTargets + _realStructureTargets;
	if (_possibleTargets isEqualTo []) exitWith {["No object found to lase","LASER CREATION FAILED"] call KPLIB_fnc_log;};

	// Select the target
	_targetObject = selectRandom _possibleTargets;
};

if (_targetObject isEqualTo objNull) exitWith {["object for laser is Null","LASER CREATION FAILED"] call KPLIB_fnc_log; _targetObject};

// Create the laser and attach to the target object
_laserObject = objNull;
switch (_side) do {
	case west : {
		_laserObject = "laserTargetW";
	};
	case east : {
		_laserObject = "laserTargetE";
	};
};

_laser = createVehicle [_laserObject, markerPos "ghost_spot", [], 0, "CAN_COLLIDE"]; 
_laser attachTo [_targetObject,[0,0,0.3]];

[{
	deleteVehicle _thisArgs
}, _laser, 30 + _eta] call CBA_fnc_waitAndExecute;

_targetObject