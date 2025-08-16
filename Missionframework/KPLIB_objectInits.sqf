/*
    Specific object init codes depending on classnames.
*/

addMissionEventHandler ["EntityCreated", {
    params["_entity"];

    if (isPlayer _entity) exitWith {};

    // Set KP logo on white flag
    if (_entity isKindOf "Flag_White_F") then {_this setFlagTexture "res\flag_kp_co.paa";};

    // Add helipads to zeus, as they can't be recycled after built
    if (( _entity isKindOf "Helipad_base_F") || {_entity isKindOf "LAND_uns_Heli_pad"} || {_entity isKindOf "Helipad"} || {_entity isKindOf "LAND_uns_evac_pad"} || {_entity isKindOf "LAND_uns_Heli_H"}) then {{[_x, [[_entity], true]] remoteExecCall ["addCuratorEditableObjects", 2]} forEach allCurators;};
    
    // Add ViV and build action to FOB box/truck
    if (_entity isKindOf KPLIB_b_fobBox || {_entity isKindOf KPLIB_b_fobTruck}) then {
        [_entity] spawn {
            params ["_fobBox"];
            waitUntil {sleep 0.1; time > 0};
            if ((typeOf _fobBox) isEqualTo KPLIB_b_fobBox) then {
                [_fobBox] call KPLIB_fnc_setFobMass;
                [_fobBox] remoteExecCall ["KPLIB_fnc_setLoadableViV", 0, _fobBox];
            };
            [_fobBox] remoteExecCall ["KPLIB_fnc_addActionsFob", 0, _fobBox];
        };
    };

    // Add FOB building damage handler override and repack action
    if (_entity isKindOf KPLIB_b_fobBuilding) then {
        _entity addEventHandler ["HandleDamage", {0}];
        [_entity] spawn {
            params ["_fob"];
            waitUntil {sleep 0.1; time > 0};
            [_fob] remoteExecCall ["KPLIB_fnc_addActionsFob", 0, _fob];
        };
    };

    // Add storage type variable to built storage areas (only for FOB built/loaded ones)
    if ((_entity isKindOf KPLIB_b_smallStorage) || {_entity isKindOf KPLIB_b_largeStorage}) then {_entity setVariable ["KPLIB_storage_type", 0, true];};

    // Add ACE variables to corresponding building types
    if (_entity isKindOf KPLIB_b_logiStation) then {_entity setVariable ["ace_isRepairFacility", 1, true];};
    if ((typeOf _entity) in KPLIB_medical_facilities) then {_entity setVariable ["ace_medical_isMedicalFacility", true, true];};
    if ((typeOf _entity) in KPLIB_medical_vehicles) then {_entity setVariable ["ace_medical_isMedicalVehicle", true, true];};

    // Hide Cover on big GM trucks
    if ((_entity isKindOf "gm_ge_army_kat1_454_cargo") || {_entity isKindOf "gm_ge_army_kat1_454_cargo_win"}) then {entity animateSource ["cover_unhide", 0, true];};

    // Make sure a slingloaded object is local to the helicopter pilot (avoid desync and rope break)
    if (_entity isKindOf "Helicopter") then {
        if (isServer) then {
            [_this] call KPLIB_fnc_addRopeAttachEh;
        } else {
            [_this] remoteExecCall ["KPLIB_fnc_addRopeAttachEh", 2];
        };
    };

    // Add valid vehicles to support module, if system is enabled
    if ((typeOf _entity) in KPLIB_param_supportModule_artyVeh) then if (KPLIB_param_supportModule > 0) then {KPLIB_param_supportModule_arty synchronizeObjectsAdd [_this];};

   // Disable autocombat (if set in parameters) and fleeing
   if (_entity isKindOf "Man") then {
    if (!(KPLIB_param_autodanger) && {(side _entity) isEqualTo KPLIB_side_player}) then {
            _entity disableAI "AUTOCOMBAT";
        };
        _entity allowFleeing 0;
    };
}];