#include "script_component.hpp"

// Locality check.
if !(hasInterface) exitWith {false};

params ["_unit", "", "_vehicle"];

// Null parameter check.
if (isNull _unit) exitWith {false};

// Set a flag to determine if the unit should be ejected or not.
private _qualified = true;
private _message = "You are not qualified to use this position. Please take the required role.";

// Groundcrew restrictions.
if (GVAR(restrictGroundCrew) && {!([_unit] call FUNC(getRole) == "groundcrew")}) then {

  // Check the vehicle is a tank or APC.
  if (typeOf _vehicle isKindOf ["Tank_F", configFile >> "CfgVehicles"] || {typeOf _vehicle isKindOf ["Wheeled_APC_F", configFile >> "CfgVehicles"]}) then {

    {
      _x params ["_crewUnit", "_role", "", "_turretPath", "_personTurret"];

      // Only apply to the event handler unit position.
      if (_crewUnit == _unit) then {

        // Disqualify driver and commander positions.
        if (_role in ["driver", "commander"] || {(_role isEqualTo "gunner" && _turretPath isEqualTo [0])}) then {
          _qualified = false;
          _message = "You must take a groundcrew role to operate that vehicle position.";
        } else {
          if (GVAR(restrictTurrets) && {_role isEqualTo "gunner" && {_turretPath isNotEqualTo []}}) then {
            _qualified = false;
            _message = "You must take a groundcrew role to operate that vehicle position.";
          };
        };
      };

    } forEach fullCrew _vehicle;

  };

};

// Aircrew restrictions.
if (GVAR(restrictAirCrew) && {!([_unit] call FUNC(getRole) == "aircrew")}) then {

  // Check the vehicle is an air vehicle
  if (typeOf _vehicle isKindOf ["Air", configFile >> "CfgVehicles"]) then {

    {
      _x params ["_crewUnit", "_role", "", "_turretPath", "_personTurret"];

      // Only apply to the event handler unit position.
      if (_crewUnit == _unit) then {

        // Disqualify driver and commander positions.
        if (_role in ["driver", "commander"] || {(_role isEqualTo "gunner" && _turretPath isEqualTo [0])}) then {
          _qualified = false;
          _message = "You must take a aircrew role to operate that vehicle position.";
        } else {
          if (GVAR(restrictTurrets) && {_role isEqualTo "gunner" && {_turretPath isNotEqualTo []}}) then {
            _qualified = false;
            _message = "You must take a aircrew role to operate that vehicle position.";
          };
        };
      };

    } forEach fullCrew _vehicle;

  };
};

// Eject the unit and display the message if the unit is not qualified.
if !(_qualified) exitWith {
  _unit moveOut _vehicle;
  hint _message;
};

true