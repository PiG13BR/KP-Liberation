if (isDedicated) exitWith {};

params ["_artillery_position"];

"opfor_arty_marker" setMarkerPosLocal (markerPos _artillery_position);
["lib_artillery", [markerText ([10000, markerPos _artillery_position] call KPLIB_fnc_getNearestSector)]] call BIS_fnc_showNotification;

sleep 600;

"opfor_arty_marker" setMarkerPosLocal markers_reset;
