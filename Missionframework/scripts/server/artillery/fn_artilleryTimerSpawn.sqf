/*
    File: fn_artilleryTimerSpawn.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 2024-09-22
    Last Update: 2024-09-25
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Sets a delay to spawns the enemy artillery position in the map (About 15-30 min)

    Parameter(s):
        -  

    Returns:
        -
*/

PIG_o_artilleryUnits = [];

_sleeptime =  (900 + (random 900)) / (([] call KPLIB_fnc_getOpforFactor) * KPLIB_param_aggressivity);

if (KPLIB_enemyReadiness >= 40) then {_sleeptime = _sleeptime * 0.75;};
if (KPLIB_enemyReadiness >= 60) then {_sleeptime = _sleeptime * 0.75;};
if (KPLIB_enemyReadiness >= 80) then {_sleeptime = _sleeptime * 0.75;};

[{
    params["_sleeptime"];
    [{
        params ["_args", "_handler"];
        if ((!isNil "KPLIB_sectors_fob") && {KPLIB_sectors_fob isNotEqualTo []}) then {
            // Spawns the artillery position
            if ((PIG_o_artilleryUnits isEqualTo []) && {KPLIB_enemyReadiness >= 15}) then {
                if ((count (allPlayers - entities "HeadlessClient_F") >= (1 / KPLIB_param_aggressivity))) then {
                    private _artySpawned = [""] call KPLIB_fnc_artillerySpawnPosition;
                    if (_artySpawned) then {
                        [_handler] call CBA_fnc_removePerFrameHandler;
                    }
                }
            }
        }
    }, _sleeptime, []] call CBA_fnc_addPerFrameHandler;
}, _sleeptime, _sleeptime] call CBA_fnc_waitAndExecute;
