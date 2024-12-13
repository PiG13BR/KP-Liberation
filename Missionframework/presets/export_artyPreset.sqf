/*
	--- INTRODUCTION ---

	This script returns an array with classname of the artillery and it's availables magazines, in the same order as the presets.
	This script is not perfect and it's a litle messy, but should work with all modded artillery aswell (it's just a theory).
	It's ideal for MORTAR and SPAs, but it can return information about ROCKET BASED ARTILLERY aswell.
	
	--- USAGE ---

	Place this file in the Eden mission folder where you want to get the information from the artillery.
	Place the artillery piece in your editor and preview the mission.
	Look/aim at one of the artillery pieces and access the DEBUG Menu by pressing ESC. 

	In the main box paste this code:
	[cursorObject] execVM export_artyPreset.sqf

	Press LOCAL EXEC. This will copy the returned array.
	Now if all goes right, you'll have an array with the artillery classnames followed by another array with it's availables magazines classname.
	Open the desired preset file and paste it the content over.

	--- RECOMMENDATIONS ---

	If you are using ACE with "Use ammunition handling" activated from the artillery options, MORTAR magazines will return as an EMPTY ARRAY.
	The correct magazines classes for this kind of artillery are found in the ace3 wiki (https://ace3.acemod.org/wiki/class-names#mk6-mortar)
    Put the ACE ammo class in presets ONLY if you are using ammunition handling, if not, get the classes that this scripts gives it.

	For now, it works fine for SPA.

	If you still can't find magazines (magazines array returning empty), you can use magazinesAmmo or magazinesAllTurrets commands and put them manually
*/

params["_artillery"];

private _ammoAvailable = ["", "", "", "", ""];
private _allMags = [];

_allMags = getArtilleryAmmo [_artillery];

// Get HE shells
private _ammoHE = "";
private _HEAmmoArray = [];
_HEAmmoArray = _allMags select {
	private _ammo = getText(configFile >> "CfgMagazines" >> _x >> "ammo");
	if (_ammo != "") then {
		_subConfig = getText(configFile >> "CfgAmmo" >> _ammo >> "warheadName");
		_subConfig isEqualTo "HE"
	} else {
		false
	};
};
_ammoHE = _HEAmmoArray select 0;
if !(isNil "_ammoHE") then {
	missionNamespace setVariable ["arty_HE_shell", _ammoHE, true];
	_allMags = _allMags - _HEAmmoArray;

	//_ammoAvailable pushBack _ammoHE;
	_ammoAvailable set [0, _ammoHE];
} else {
	missionNamespace setVariable ["arty_HE_shell", nil, true];
};

// Get Smoke magazines
// Get the submunitionAmmo and then get the simulation of the submunitionAmmo
// Thank you NikkoJT from ArmA discord and chatGPT for the tips
private _ammoSmoke = "";
private _smokeAmmoArray = [];
_smokeAmmoArray = _allMags select {
	private _ammo = getText(configFile >> "CfgMagazines" >> _x >> "ammo");
	if (_ammo != "") then {
		_subMunition = getText(configFile >> "cfgAmmo" >> _ammo >> "submunitionAmmo");
		if (_subMunition != "") then { 
			getText(configFile >> "cfgAmmo" >> _subMunition >> "simulation") == "shotSmoke" // If the submunitionammo is related to a smoke shell, it should NORMALLY return this string always
		} else {
			false
		};
	} else {
		false
	};
};
_ammoSmoke = _smokeAmmoArray select 0;
if !(isNil "_ammoSmoke") then {
	missionNamespace setVariable ["arty_SMOKE_shell", _ammoSmoke, true];
	_allMags = _allMags - _smokeAmmoArray;
	
	//_ammoAvailable pushBack _ammoSmoke;
	_ammoAvailable set [1, _ammoSmoke];
} else {
	missionNamespace setVariable ["arty_SMOKE_shell", nil, true];
};

// Get flare
// Look for parent class "FlareCore" (not all modded flares has this parent class)
// Look for empty submunitionammo or non-existent submunitionammo parameter
// Also, no subMunitionConeAngle
// brightness = 2 (vanilla rounds);
private _ammoFlare = "";
private _flareAmmoArray = [];
_flareAmmoArray = _allMags select {
	private _ammo = getText(configFile >> "CfgMagazines" >> _x >> "ammo");
	if (_ammo != "") then {
		_subConfig = getNumber(configFile >> "CfgAmmo" >> _ammo >> "subMunitionConeAngle");
		//_subConfig = getNumber(configFile >> "CfgAmmo" >> _ammo >> "brightness");
		_subMunition = getText(configFile >> "cfgAmmo" >> _ammo >> "submunitionAmmo");

		(_subMunition isEqualTo "") && {_subConfig == 0} // more chance
		//_subConfig > 0 // less chance
	} else {
		false
	};
};
_ammoFlare = _flareAmmoArray select 0;
if !(isNil "_ammoFlare") then {
	missionNamespace setVariable ["arty_CLUSTER_shell", _ammoFlare, true];
	_allMags = _allMags - _flareAmmoArray;

	//_ammoAvailable pushBack _ammoFlare;
	_ammoAvailable set [2, _ammoFlare];
} else {
	missionNamespace setVariable ["arty_CLUSTER_shell", nil, true];
};

// Get LG magazines
private _ammoLg = "";
private _lgAmmoArray = [];
_lgAmmoArray = _allMags select {
	private _ammo = getText(configFile >> "CfgMagazines" >> _x >> "ammo");
	if (_ammo != "") then {
		getNumber(configfile >> "CfgAmmo" >> _ammo >> "laserLock") > 0
	} else {
		false
	}
};
_ammoLg = _lgAmmoArray select 0;
if !(isNil "_ammoLg") then {
	missionNamespace setVariable ["arty_LG_shell", _ammoLg, true];
	_allMags = _allMags - _lgAmmoArray;

	//_ammoAvailable pushBack _ammoLg;
	_ammoAvailable set [3, _ammoLg];
} else {
	missionNamespace setVariable ["arty_LG_shell", nil, true];
};

// Get Cluster shell
private _ammoCluster = "";
private _clusterAmmoArray = [];
_clusterAmmoArray = _allMags select {
	private _ammo = getText(configFile >> "CfgMagazines" >> _x >> "ammo");
	if (_ammo != "") then {
		_subConfig = getNumber(configFile >> "CfgAmmo" >> _ammo >> "subMunitionConeAngle");
		_subMunition = getText(configFile >> "CfgAmmo" >> _ammo >> "submunitionAmmo");

		!((_subMunition == "Mo_ATMineRange") || {_subMunition == "Mo_ClassicMineRange"}) && {_subConfig > 0}
	} else {
		false
	};
};
_ammoCluster = _clusterAmmoArray select 0;
if !(isNil "_ammoCluster") then {
	missionNamespace setVariable ["arty_CLUSTER_shell", _ammoCluster, true];

	//_ammoAvailable pushBack _ammoCluster;
	_ammoAvailable set [4, _ammoCluster];
} else {
	missionNamespace setVariable ["arty_CLUSTER_shell", nil, true];
};

// Export array
_exportArray = [];
_exportArray pushBack (typeOf _artillery);
_exportArray pushBack _ammoAvailable;
hint str _exportArray;
copyToClipboard str _exportArray; // and CTRL+V anywhere
_exportArray;
/*
	SOME MAGAZINES ARRAY CHECKS:

	CUP 
	["8Rnd_82mm_Mo_LG","8Rnd_82mm_Mo_Smoke_white","8Rnd_82mm_Mo_shells","8Rnd_82mm_Mo_Flare_white"] // Ok
	["CUP_30Rnd_122mmLASER_D30_M","CUP_30Rnd_122mmSMOKE_D30_M","CUP_30Rnd_122mmHE_D30_M","CUP_30Rnd_122mmILLUM_D30_M"] // Ok
	["CUP_6Rnd_120mm_Smoke_M929","CUP_32Rnd_120mm_HE_M934"] // Stryker mortar // Ok
	["CUP_30Rnd_105mmLASER_M119_M","CUP_30Rnd_105mmSMOKE_M119_M","CUP_30Rnd_105mmHE_M119_M","CUP_30Rnd_105mmILLUM_M119_M"] // Ok

	RHS
	["rhs_mag_3of69m","rhs_mag_d462","rhs_mag_of462","rhs_mag_s463"] // Ok
	["rhs_mag_d832du_10","rhs_mag_3vo18_10","rhs_mag_3vs25m_10"] // Ok
	["rhs_mag_3of69m","rhs_mag_d462","rhs_mag_of462"] // Ok
	["8Rnd_82mm_Mo_LG","8Rnd_82mm_Mo_Smoke_white","rhs_1Rnd_m821_HE","8Rnd_82mm_Mo_Flare_white"] // Ok
	["rhs_mag_m60a2_smoke_4","RHS_mag_m1_he_12","rhs_mag_m314_ilum_4"] // Ok
	["rhs_mag_155mm_m712_2","rhs_mag_155mm_m825a1_2","rhs_mag_155mm_m795_28","rhs_mag_155mm_m864_3","rhs_mag_155mm_485_2"] // Ok

	// IFA 3
	["LIB_Shell_105L28_Gr38_HE"] // Ok
	["LIB_21x_SprGr_KwK36_HE"] // 88 arty // Ok
	// Fail to get any rocket from Nebelwerfer (normal) 
	["IFA3_Shell_m30_HE"] // Ok
	["IFA3_UOF353","IFA3_UBR353"] // Ok
	["LIB_60mm_M2_SmokeShell","LIB_8Rnd_60mmHE_M2"] // 50mm mortar // Ok
	["LIB_82mm_BM37_SmokeShell","LIB_8Rnd_82mmHE_BM37"] // Ok

	// 3AS
	["3AS_8Rnd_82mm_Mo_LG","3AS_8Rnd_82mm_Mo_Smoke_white","3AS_8Rnd_82mm_Mo_shells","3AS_8Rnd_82mm_Mo_Flare_white"] // Mortar // OK
	["3AS_4Rnd_300mm_Mo_LG","3AS_12Rnd_300mm_Mo_smoke","3AS_32Rnd_300mm_Mo_shells","3AS_4Rnd_300mm_Mo_Cluster"] // The floating artillery thing // OK
	["3AS_4Rnd_300mm_Mo_LG","3AS_12Rnd_300mm_Mo_smoke","3AS_32Rnd_300mm_Mo_shells","3AS_4Rnd_300mm_Mo_Cluster"] // The floating artillery thing // OK

	// Imperial Conquest W40K
	["2Rnd_155mm_Mo_LG","6Rnd_155mm_Mo_smoke","32Rnd_155mm_Mo_shells","2Rnd_155mm_Mo_Cluster"] // OK
	["IC_20Rnd_300mm_Mo_shells"] // OK

	// TIOW
	// -- For the mortar uses the default mortar_82mm cfgWeapon
	// -- Gets LG magazine but in the game doesn't have a selection for it (bad mod config, not the script fault)
	["8Rnd_82mm_Mo_LG","8Rnd_82mm_Mo_Smoke_white","8Rnd_82mm_Mo_shells","8Rnd_82mm_Mo_Flare_white"] // Mortar 
	["8Rnd_82mm_Mo_LG","8Rnd_82mm_Mo_Smoke_white","8Rnd_82mm_Mo_shells","8Rnd_82mm_Mo_Flare_white"]	// Mortar
	["8Rnd_82mm_Mo_LG","8Rnd_82mm_Mo_Smoke_white","8Rnd_82mm_Mo_shells","8Rnd_82mm_Mo_Flare_white"]	// Mortar
	["8Rnd_82mm_Mo_LG","8Rnd_82mm_Mo_Smoke_white","8Rnd_82mm_Mo_shells","8Rnd_82mm_Mo_Flare_white"] // Mortar

*/
