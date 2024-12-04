params[
	["_gunner", objNull, [objNull]],
	["_targetPos", [0,0,0], [[]], [2,3]],
	["_eta", 0, [0]]
];

if (isNil {_gunner getVariable "PIG_enemyArtyFiring"}) then {
	_gunner setVariable ["PIG_enemyArtyFiring", true];

	// If is firing on players position
	["lib_artillery_firing", ["", ""]] call BIS_fnc_showNotification;

	//Create a border marker
	_markerBorder = createMarkerLocal ["opfor_targetPlayers_bordermk", _targetPos];
	_markerBorder setMarkerShapeLocal "ELLIPSE";
	_markerBorder setMarkerBrushLocal "Solid";
	_markerBorder setMarkerAlpha 0.5;
	_markerBorder setMarkerSizeLocal [100,100];
	_markerBorder setMarkerColorLocal KPLIB_color_enemyActive;

	// Cooldown
	sleep _eta + 120; 
	deleteMarker _markerBorder;

	_gunner setVariable ["PIG_enemyArtyFiring", nil];
};