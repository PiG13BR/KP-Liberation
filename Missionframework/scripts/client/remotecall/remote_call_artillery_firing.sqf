params[
	["_gunner", objNull, [objNull]],
	["_targetPos", [0,0,0], [[]], [2,3]],
	["_eta", 0, [0]],
	["_area", 100, [0]]
];

if (_area < 25) then {_area = 100};

// If is firing on players position
["lib_artillery_firing", ["", ""]] call BIS_fnc_showNotification;

//Create marker
_markerIcon = createMarkerLocal ["opfor_targetPlayers_iconmk", _targetPos];
_markerIcon setMarkerTypeLocal "hd_warning";
_markerIcon setMarkerColorLocal KPLIB_color_enemy;

_markerBorder = createMarkerLocal ["opfor_targetPlayers_bordermk", _targetPos];
_markerBorder setMarkerShapeLocal "ELLIPSE";
_markerBorder setMarkerBrushLocal "Solid";
_markerBorder setMarkerAlpha 0.8;
_markerBorder setMarkerSizeLocal [_area/2, _area/2];
_markerBorder setMarkerColorLocal KPLIB_color_enemyActive;

// Cooldown
sleep _eta + 60;
deleteMarker _markerBorder;
deleteMarker _markerIcon;
