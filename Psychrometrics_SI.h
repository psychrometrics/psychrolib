// This psychrometrics package is used to demonstrate psychrometric calculations.
// It contains C functions to calculate dew point temperature, wet bulb temperature,
// relative humidity, humidity ratio, partial pressure of water vapor, moist air
// enthalpy, moist air volume, specific volume, and degree of saturation, given
// dry bulb temperature and another psychrometric variable. The code also includes
// functions for standard atmosphere calculation.
// The functions implement formulae found in the 2005 ASHRAE Handbook of Fundamentals.
// This version of the library works in SI units.
//
// This library was originally developed by Didier Thevenard, PhD, P.Eng., while 
// working of simulation software for solar energy systems and climatic data processing.
// It has since been moved to GitHub at https://github.com/psychrometrics/libraries
// along with its documentation.
//
// Note from the author: I have made every effort to ensure that the code is adequate,
// however I make no representation with respect to its accuracy. Use at your
// own risk. Should you notice any error, or if you have suggestions on how to
// improve the code, please notify me through GitHub.
//
//-----------------------------------------------------------------------------
//
// Legal notice
//
// This file is provided for free.  You can redistribute it and/or
// modify it under the terms of the GNU General Public
// License as published by the Free Software Foundation
// (version 3 or later).
//
// This source code is distributed in the hope that it will be useful
// but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE. See the GNU General Public License for more
// details.
//
//	You should have received a copy of the GNU General Public License
//  along with this code.  If not, see <http://www.gnu.org/licenses/>.
//
//-----------------------------------------------------------------------------
//

#ifndef PSYCHROMETRICS_H
#define PSYCHROMETRICS_H



//*****************************************************************************
//       Conversions between dew point, wet bulb, and relative humidity
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Wet-bulb temperature given dry-bulb temperature and dew-point temperature
// ASHRAE Fundamentals (2005) ch. 6
//
double GetTWetBulbFromTDewPoint // (o) Wet bulb temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double TDewPoint            // (i) Dew point temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Wet-bulb temperature given dry-bulb temperature and relative humidity
// ASHRAE Fundamentals (2005) ch. 6
//
double GetTWetBulbFromRelHum    // (o) Wet bulb temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C] //
  , double RelHum               // (i) Relative humidity [0-1] //
  , double Pressure             // (i) Atmospheric pressure [Pa] //
  );

///////////////////////////////////////////////////////////////////////////////
// Relative Humidity given dry-bulb temperature and dew-point temperature
// ASHRAE Fundamentals (2005) ch. 6
//
double GetRelHumFromTDewPoint   // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double TDewPoint            // (i) Dew point temperature [C]
    );

///////////////////////////////////////////////////////////////////////////////
// Relative Humidity given dry-bulb temperature and wet bulb temperature
// ASHRAE Fundamentals (2005) ch. 6
//
double GetRelHumFromTWetBulb    // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double TWetBulb             // (i) Wet bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Dew Point Temperature given dry bulb temperature and relative humidity
// ASHRAE Fundamentals (2005) ch. 6 eqn 24
//
double GetTDewPointFromRelHum   // (o) Dew Point temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double RelHum               // (i) Relative humidity [0-1]
  );

///////////////////////////////////////////////////////////////////////////////
// Dew Point Temperature given dry bulb temperature and wet bulb temperature
// ASHRAE Fundamentals (2005) ch. 6
//
double GetTDewPointFromTWetBulb // (o) Dew Point temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double TWetBulb             // (i) Wet bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

//*****************************************************************************
//  Conversions between dew point, or relative humidity and vapor pressure
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Partial pressure of water vapor as a function of relative humidity and
// temperature in C
// ASHRAE Fundamentals (2005) ch. 6, eqn. 24
//
double GetVapPresFromRelHum     // (o) Partial pressure of water vapor in moist air [Pa]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double RelHum               // (i) Relative humidity [0-1]
  );

///////////////////////////////////////////////////////////////////////////////
// Relative Humidity given dry bulb temperature and vapor pressure
// ASHRAE Fundamentals (2005) ch. 6, eqn. 24
//
double GetRelHumFromVapPres     // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double VapPres              // (i) Partial pressure of water vapor in moist air [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Dew point temperature given vapor pressure and dry bulb temperature
// ASHRAE Fundamentals (2005) ch. 6, eqn. 37 and 38
//
double GetTDewPointFromVapPres  // (o) Dew Point temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double VapPres              // (i) Partial pressure of water vapor in moist air [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure given dew point temperature
// ASHRAE Fundamentals (2005) ch. 6 eqn. 36
//
double GetVapPresFromTDewPoint  // (o) Partial pressure of water vapor in moist air [Pa]
  ( double TDewPoint            // (i) Dew point temperature [C]
  );


//*******************************************************************************
//        Conversions from wet bulb temperature, dew point temperature,
//                or relative humidity to humidity ratio
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Wet bulb temperature given humidity ratio
// ASHRAE Fundamentals (2005) ch. 6 eqn. 35
//
double GetTWetBulbFromHumRatio  // (o) Wet bulb temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given wet bulb temperature and dry bulb temperature
// ASHRAE Fundamentals (2005) ch. 6 eqn. 35
//
double GetHumRatioFromTWetBulb  // (o) Humidity Ratio [kgH2O/kgAIR]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double TWetBulb             // (i) Wet bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given relative humidity
// ASHRAE Fundamentals (2005) ch. 6 eqn. 38
//
double GetHumRatioFromRelHum    // (o) Humidity Ratio [kgH2O/kgAIR]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double RelHum               // (i) Relative humidity [0-1]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Relative humidity given humidity ratio
// ASHRAE Fundamentals (2005) ch. 6
//
double GetRelHumFromHumRatio    // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given dew point temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 22
//
double GetHumRatioFromTDewPoint // (o) Humidity Ratio [kgH2O/kgAIR]
  ( double TDewPoint            // (i) Dew point temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Dew point temperature given dry bulb temperature, humidity ratio, and pressure
// ASHRAE Fundamentals (2005) ch. 6
//
double GetTDewPointFromHumRatio // (o) Dew Point temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

//*****************************************************************************
//       Conversions between humidity ratio and vapor pressure
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given water vapor pressure and atmospheric pressure
// ASHRAE Fundamentals (2005) ch. 6 eqn. 22
//
double GetHumRatioFromVapPres   // (o) Humidity Ratio [kgH2O/kgAIR]
  ( double VapPres              // (i) Partial pressure of water vapor in moist air [Pa]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure given humidity ratio and pressure
// ASHRAE Fundamentals (2005) ch. 6 eqn. 22
//

double GetVapPresFromHumRatio   // (o) Partial pressure of water vapor in moist air [Pa]
  ( double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

//*****************************************************************************
//                             Dry Air Calculations
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Dry air enthalpy given dry bulb temperature.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 30
//
double GetDryAirEnthalpy        // (o) Dry air enthalpy [J/kg]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  );

///////////////////////////////////////////////////////////////////////////////
// Dry air density given dry bulb temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 28
//
double GetDryAirDensity         // (o) Dry air density [kg/m3]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Dry air volume given dry bulb temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 28
//
double GetDryAirVolume          // (o) Dry air volume [m3/kg]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

//*****************************************************************************
//                       Saturated Air Calculations
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Saturation vapor pressure as a function of temperature
// ASHRAE Fundamentals (2005) ch. 6 eqn. 5, 6
//
double GetSatVapPres            // (o) Vapor Pressure of saturated air [Pa]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  );

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio of saturated air given dry bulb temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 23
//
double GetSatHumRatio           // (o) Humidity ratio of saturated air [kgH2O/kgAIR]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Saturated air enthalpy given dry bulb temperature.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 32
//
double GetSatAirEnthalpy        // (o) Saturated air enthalpy [J/kg]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

//*****************************************************************************
//                       Moist Air Calculations
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure deficit in Pa given humidity ratio, dry bulb temperature, and
// pressure.
// See Oke (1987) eqn. 2.13a
//
double GetVPD                   // (o) Vapor pressure deficit [Pa]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// ASHRAE Fundamentals (2005) ch. 6 eqn. 12
//
double GetDegreeOfSaturation    // (o) Degree of saturation []
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Moist air enthalpy given dry bulb temperature and humidity ratio
// ASHRAE Fundamentals (2005) ch. 6 eqn. 32
//
double GetMoistAirEnthalpy      // (o) Moist Air Enthalpy [J/kg]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  );

///////////////////////////////////////////////////////////////////////////////
// Moist air volume given dry bulb temperature, humidity ratio, and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 28
//
double GetMoistAirVolume        // (o) Specific Volume [m3/kg]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

///////////////////////////////////////////////////////////////////////////////
// Moist air density given humidity ratio, dry bulb temperature, and pressure
// ASHRAE Fundamentals (2005) ch. 6 6.8 eqn. 11
//
double GetMoistAirDensity       // (o) Moist air density [kg/m3]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  );

//*****************************************************************************
//                Functions to set all psychrometric values
//*****************************************************************************

void CalcPsychrometricsFromTWetBulb
  ( double *TDewPoint           // (o) Dew point temperature [C]
  , double *RelHum              // (o) Relative humidity [0-1]
  , double *HumRatio            // (o) Humidity ratio [kgH2O/kgAIR]
  , double *VapPres             // (o) Partial pressure of water vapor in moist air [Pa]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy [J/kg]
  , double *MoistAirVolume      // (o) Specific volume [m3/kg]
  , double *DegSaturation       // (o) Degree of saturation []
  , double TDryBulb             // (i) Dry bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  , double TWetBulb             // (i) Wet bulb temperature [C]
  );

void CalcPsychrometricsFromTDewPoint
  ( double *TWetBulb            // (o) Wet bulb temperature [C]
  , double *RelHum              // (o) Relative humidity [0-1]
  , double *HumRatio            // (o) Humidity ratio [kgH2O/kgAIR]
  , double *VapPres             // (o) Partial pressure of water vapor in moist air [Pa]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy [J/kg]
  , double *MoistAirVolume      // (o) Specific volume [m3/kg]
  , double *DegSaturation       // (o) Degree of saturation []
  , double TDryBulb             // (i) Dry bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  , double TDewPoint            // (i) Dew point temperature [C]
  );

void CalcPsychrometricsFromRelHum
  ( double *TWetBulb            // (o) Wet bulb temperature [C]
  , double *TDewPoint           // (o) Dew point temperature [C]
  , double *HumRatio            // (o) Humidity ratio [kgH2O/kgAIR]
  , double *VapPres             // (o) Partial pressure of water vapor in moist air [Pa]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy [J/kg]
  , double *MoistAirVolume      // (o) Specific volume [m3/kg]
  , double *DegSaturation       // (o) Degree of saturation []
  , double TDryBulb             // (i) Dry bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  , double RelHum               // (i) Relative humidity [0-1]
  );

//*****************************************************************************
//                          Standard atmosphere
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Standard atmosphere barometric pressure, given the elevation (altitude)
// ASHRAE Fundamentals (2005) ch. 6 eqn. 3
//
double GetStandardAtmPressure   // (o) standard atmosphere barometric pressure [Pa]
  ( double Altitude             // (i) altitude [m]
  );

///////////////////////////////////////////////////////////////////////////////
// Standard atmosphere temperature, given the elevation (altitude)
// ASHRAE Fundamentals (2005) ch. 6 eqn. 4
//
double GetStandardAtmTemperature // (o) standard atmosphere dry bulb temperature [C]
  ( double Altitude             // (i) altitude [m]
  );

///////////////////////////////////////////////////////////////////////////////
// Sea level pressure from observed station pressure
// Note: the standard procedure for the US is to use for TDryBulb the average
// of the current station temperature and the station temperature from 12 hours ago
// Hess SL, Introduction to theoretical meteorology, Holt Rinehart and Winston, NY 1959,
// ch. 6.5; Stull RB, Meteorology for scientists and engineers, 2nd edition,
// Brooks/Cole 2000, ch. 1.
//
double GetSeaLevelPressure   // (o) sea level barometric pressure [Pa]
  ( double StnPressure       // (i) observed station pressure [Pa]
  , double Altitude          // (i) altitude above sea level [m]
  , double TDryBulb          // (i) dry bulb temperature [°C]
  );

///////////////////////////////////////////////////////////////////////////////
// Station pressure from sea level pressure
// This is just the previous function, reversed
//
double GetStationPressure    // (o) station pressure [Pa]
  ( double SeaLevelPressure  // (i) sea level barometric pressure [Pa]
  , double Altitude          // (i) altitude above sea level [m]
  , double TDryBulb          // (i) dry bulb temperature [°C]
  );


#endif