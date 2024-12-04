/*
    Specific object init codes depending on classnames.

    Format:
    [
        Array of classnames as strings <ARRAY>,
        Code to apply <CODE>,
        Allow inheritance <BOOL> (default false)
    ]
    _this is the reference to the object with the classname

    Example:
        KPLIB_objectInits = [
            [
                ["O_soldierU_F"],
                {systemChat "CSAT urban soldier was spawned!"}
            ],
            [
                ["CAManBase"],
                {systemChat format ["Some human named '%1' was spawned!", name _this]},
                true
            ]
        ];
*/

KPLIB_objectInits = [
    // Set KP logo on white flag
    [
        ["Flag_White_F"],
        {_this setFlagTexture "res\flag_kp_co.paa";}
    ],

    // Add helipads to zeus, as they can't be recycled after built
    [
        ["Helipad_base_F", "LAND_uns_Heli_pad", "Helipad", "LAND_uns_evac_pad", "LAND_uns_Heli_H"],
        {{[_x, [[_this], true]] remoteExecCall ["addCuratorEditableObjects", 2]} forEach allCurators;},
        true
    ],

    // Add ViV and build action to FOB box/truck
    [
        [KPLIB_b_fobBox, KPLIB_b_fobTruck],
        {
            [_this] spawn {
                params ["_fobBox"];
                waitUntil {sleep 0.1; time > 0};
                if ((typeOf _fobBox) isEqualTo KPLIB_b_fobBox) then {
                    [_fobBox] call KPLIB_fnc_setFobMass;
                    [_fobBox] remoteExecCall ["KPLIB_fnc_setLoadableViV", 0, _fobBox];
                };
                [_fobBox] remoteExecCall ["KPLIB_fnc_addActionsFob", 0, _fobBox];
            };
        }
    ],

    // Add FOB building damage handler override and repack action
    [
        [KPLIB_b_fobBuilding],
        {
            _this addEventHandler ["HandleDamage", {0}];
            [_this] spawn {
                params ["_fob"];
                waitUntil {sleep 0.1; time > 0};
                [_fob] remoteExecCall ["KPLIB_fnc_addActionsFob", 0, _fob];
            };
        }
    ],

    // Add ViV action to Arsenal crate
    [
        [KPLIB_b_arsenal],
        {
            [_this] spawn {
                params ["_arsenal"];
                waitUntil {sleep 0.1; time > 0};
                [_arsenal] remoteExecCall ["KPLIB_fnc_setLoadableViV", 0, _arsenal];
            };
        }
    ],

    // Add storage type variable to built storage areas (only for FOB built/loaded ones)
    [
        [KPLIB_b_smallStorage, KPLIB_b_largeStorage],
        {_this setVariable ["KPLIB_storage_type", 0, true];}
    ],

    // Add ACE variables to corresponding building types
    [
        [KPLIB_b_logiStation],
        {_this setVariable ["ace_isRepairFacility", 1, true];}
    ],
    [
        KPLIB_medical_facilities,
        {_this setVariable ["ace_medical_isMedicalFacility", true, true];}
    ],
    [
        KPLIB_medical_vehicles,
        {_this setVariable ["ace_medical_isMedicalVehicle", true, true];}
    ],

    // Hide Cover on big GM trucks
    [
        ["gm_ge_army_kat1_454_cargo", "gm_ge_army_kat1_454_cargo_win"],
        {_this animateSource ["cover_unhide", 0, true];}
    ],

    // Make sure a slingloaded object is local to the helicopter pilot (avoid desync and rope break)
    [
        ["Helicopter"],
        {if (isServer) then {[_this] call KPLIB_fnc_addRopeAttachEh;} else {[_this] remoteExecCall ["KPLIB_fnc_addRopeAttachEh", 2];};},
        true
    ],

    // Add valid vehicles to support module, if system is enabled
    [
        KPLIB_param_supportModule_artyVeh,
        {
            if (KPLIB_param_supportModule > 0) then {KPLIB_param_supportModule_arty synchronizeObjectsAdd [_this];};
            // ---------------------------------------------------------- COUNTER-ARTILLERY MANAGEMENT
            _this addEventHandler ["Fired", {
                params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
                
                if (side _gunner == KPLIB_side_player) then {

                    // Check artillery fired ammo
                    if (getNumber(configFile >> "CfgAmmo" >> _ammo >> "artilleryLock") < 1) exitWith {};

                    // Check if the enemy artillery is available
                    if (isNil "KPLIB_o_artilleryUnits") exitWith {};
                    if (KPLIB_o_artilleryUnits isEqualTo []) exitWith {};
                    // Add Deleted EH to the projectile. When explodes, run the counter artillery script
                    [_projectile, "Explode", {
                        params ["_projectile", "_pos", "_velocity"];
                        [_thisArgs, _pos] remoteExec ["KPLIB_fnc_counterArtillery", 2];
                    }, _unit] call CBA_fnc_addBISEventHandler;

                    // Add EH for shells that creates submunitions
                    _unit setVariable ["KPLIB_count_subMunition", 0]; // To avoid calling the counter script multiple times
                    [_projectile, "SubmunitionCreated", {
                        params ["_projectile", "_submunitionProjectile", "_pos", "_velocity"];
                        _countSubMunition = (_thisArgs getVariable "KPLIB_count_subMunition");
                        _countSubMunition = _countSubMunition + 1;

                        if (_countSubMunition > 1) exitWith {};
                        
                        [_thisArgs, _pos] remoteExec ["KPLIB_fnc_counterArtillery", 2];
                    }, _unit] call CBA_fnc_addBISEventHandler;
                };
            }];
        }
    ],

    // Disable autocombat (if set in parameters) and fleeing
    [
        ["Man"],
        {
            if (!(KPLIB_param_autodanger) && {(side _this) isEqualTo KPLIB_side_player}) then {
                _this disableAI "AUTOCOMBAT";
            };
            _this allowFleeing 0;
        },
        true
    ]
];
