params ["_liberated_sector"];

private _KPLIB_enemyReadiness_increase = 0;
switch (true) do {
    case (_liberated_sector in KPLIB_sectors_capital):    {_KPLIB_enemyReadiness_increase = floor (random 10) * KPLIB_param_difficulty;};
    case (_liberated_sector in KPLIB_sectors_city):    {_KPLIB_enemyReadiness_increase = floor (random 6) * KPLIB_param_difficulty;};
    case (_liberated_sector in KPLIB_sectors_military):   {_KPLIB_enemyReadiness_increase = 5 + (floor (random 11)) * KPLIB_param_difficulty;};
    case (_liberated_sector in KPLIB_sectors_factory):    {_KPLIB_enemyReadiness_increase = 3 + (floor (random 7)) * KPLIB_param_difficulty;};
    case (_liberated_sector in KPLIB_sectors_tower):      {_KPLIB_enemyReadiness_increase = floor (random 4);};
};

KPLIB_enemyReadiness = KPLIB_enemyReadiness + _KPLIB_enemyReadiness_increase;
if (KPLIB_enemyReadiness > 100.0 && KPLIB_param_difficulty <= 2.0) then {KPLIB_enemyReadiness = 100.0};
stats_readiness_earned = stats_readiness_earned + _KPLIB_enemyReadiness_increase;

[_liberated_sector, 0] remoteExecCall ["remote_call_sector"];
KPLIB_sectors_player pushback _liberated_sector; publicVariable "KPLIB_sectors_player";
stats_sectors_liberated = stats_sectors_liberated + 1;

["KPLIB_ResetBattleGroups"] call CBA_fnc_serverEvent;

if (_liberated_sector in KPLIB_sectors_factory) then {
    {
        if (_liberated_sector in _x) exitWith {KPLIB_production = KPLIB_production - [_x];};
    } forEach KPLIB_production;

    private _sectorFacilities = (KPLIB_production_markers select {_liberated_sector == (_x select 0)}) select 0;
    KPLIB_production pushBack [
        markerText _liberated_sector,
        _liberated_sector,
        1,
        [],
        _sectorFacilities select 1,
        _sectorFacilities select 2,
        _sectorFacilities select 3,
        3,
        KPLIB_production_interval,
        0,
        0,
        0
    ];
};

[_liberated_sector] spawn F_cr_liberatedSector;

if ((random 100) <= KPLIB_cr_wounded_chance || (count KPLIB_sectors_player) == 1) then {
    [_liberated_sector] spawn civrep_wounded_civs;
};

asymm_blocked_sectors pushBack [_liberated_sector, time];
publicVariable "asymm_blocked_sectors";

[] spawn check_victory_conditions;

sleep 1;

[] spawn KPLIB_fnc_doSave;

sleep 45;

if (KPLIB_endgame == 0) then {
    if (
        !(_liberated_sector in KPLIB_sectors_tower)
        && {
            (random (150 / (KPLIB_param_difficulty * KPLIB_param_aggressivity))) < (KPLIB_enemyReadiness - 15)
            || _liberated_sector in KPLIB_sectors_capital
        }
        && {[] call KPLIB_fnc_getOpforCap < KPLIB_cap_battlegroup}
    ) then {
        [_liberated_sector, (random 100) < 45] spawn spawn_battlegroup;
    };
};

    // Call artillery if players captured military sector
    if ((_liberated_sector in KPLIB_sectors_military) && {!(KPLIB_o_artilleryUnits isEqualTo [])}) then {
        sleep (60 + (random 30)) / (([] call KPLIB_fnc_getOpforFactor) * KPLIB_param_aggressivity);

        // ---------------------------------------------------------- FIRE MISSION
        if ((random 100) <= 45) then {
            _targetPos = getMarkerPos _liberated_sector;
            _ammoType = [["HE", (3 + (random 7))], ["CLUSTER", (2 + (random 1))]] selectRandomWeighted [0.7, 0.3];
            _ammoType params ["_shell", "_rounds"];

            if (sunOrMoon > 0) then {
                _artyReturns = [_targetPos, 10, "FLARE", 1] call KPLIB_fnc_fireArtillery;
				_artyReturns params ["_fired", "_artyElements"];
				if (_fired) then {
					_eta = _artyElements select 1; // Gets the shell's ETA
					sleep _eta + 5;
					[_targetPos, KPLIB_range_sectorCapture, _shell, _rounds] call KPLIB_fnc_fireArtillery;
                } else {
                    [_targetFob, KPLIB_range_sectorCapture, _shell, _rounds] call KPLIB_fnc_fireArtillery;
                }		
            }
        }
    }
