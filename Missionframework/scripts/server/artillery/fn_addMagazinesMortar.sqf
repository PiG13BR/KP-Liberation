/*
    File: fn_addMagazinesMortar.sqf
    Author: PiG13BR - https://github.com/PiG13BR
    Date: 2024-08-26
    Last Update: 2024-12-01
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        The option "Use ammunition handling" from ACE artillery might screw with the mortar magazines/ammo, even if it's an AI manning it.
		When enabled, the artillery can't fire it. Why? Because the mortar has no ammo on it.
		To solve this problem, we should add the magazines to the mortar

    Parameter(s):
        _mortar - the mortar object [OBJECT] 

    Returns:
        -
*/

params["_mortar"];

{
	[_mortar, _y] call CBA_fnc_addMagazine;
}forEach KPLIB_artyHashMap_ammo;