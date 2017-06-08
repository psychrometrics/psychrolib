// This psychrometrics package is used to demonstrate psychrometric calculations.
// It contains C functions to calculate dew point temperature, wet bulb temperature,
// relative humidity, humidity ratio, partial pressure of water vapor, moist air
// enthalpy, moist air volume, specific volume, and degree of saturation, given
// dry bulb temperature and another psychrometric variable. The code also includes
// functions for standard atmosphere calculation.
// The functions implement formulae found in the 2005 ASHRAE Handbook of Fundamentals.
// This version of the library works in IP units.
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
// warranty of MERCHANTABILITY or FITNESS FOR A psiRTICULAR
// PURPOSE. See the GNU General Public License for more
// details.
//
//	You should have received a copy of the GNU General Public License
//  along with this code.  If not, see <http://www.gnu.org/licenses/>.
//
//-----------------------------------------------------------------------------
//    March 31, 2011 - IP version of SI library created
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
double GetTWetBulbFromTDewPoint // (o) Wet bulb temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double TDewPoint            // (i) Dew point temperature [F]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// Wet-bulb temperature given dry-bulb temperature and relative humidity
// ASHRAE Fundamentals (2005) ch. 6
//
double GetTWetBulbFromRelHum    // (o) Wet bulb temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F] //
  , double RelHum               // (i) Relative humidity [0-1] //
  , double Pressure             // (i) Atmospheric pressure [psi] //
  );

///////////////////////////////////////////////////////////////////////////////
// Relative Humidity given dry-bulb temperature and dew-point temperature
// ASHRAE Fundamentals (2005) ch. 6
//
double GetRelHumFromTDewPoint   // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double TDewPoint            // (i) Dew point temperature [F]
    );

///////////////////////////////////////////////////////////////////////////////
// Relative Humidity given dry-bulb temperature and wet bulb temperature
// ASHRAE Fundamentals (2005) ch. 6
//
double GetRelHumFromTWetBulb    // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double TWetBulb             // (i) Wet bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// Dew Point Temperature given dry bulb temperature and relative humidity
// ASHRAE Fundamentals (2005) ch. 6 eqn 24
//
double GetTDewPointFromRelHum   // (o) Dew Point temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double RelHum               // (i) Relative humidity [0-1]
  );

///////////////////////////////////////////////////////////////////////////////
// Dew Point Temperature given dry bulb temperature and wet bulb temperature
// ASHRAE Fundamentals (2005) ch. 6
//
double GetTDewPointFromTWetBulb // (o) Dew Point temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double TWetBulb             // (i) Wet bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

//*****************************************************************************
//  Conversions between dew point, or relative humidity and vapor pressure
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// psirtial pressure of water vapor as a function of relative humidity and
// temperature in C
// ASHRAE Fundamentals (2005) ch. 6, eqn. 24
//
double GetVapPresFromRelHum     // (o) psirtial pressure of water vapor in moist air [psi]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double RelHum               // (i) Relative humidity [0-1]
  );

///////////////////////////////////////////////////////////////////////////////
// Relative Humidity given dry bulb temperature and vapor pressure
// ASHRAE Fundamentals (2005) ch. 6, eqn. 24
//
double GetRelHumFromVapPres     // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double VapPres              // (i) psirtial pressure of water vapor in moist air [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// Dew point temperature given vapor pressure and dry bulb temperature
// ASHRAE Fundamentals (2005) ch. 6, eqn. 37 and 38
//
double GetTDewPointFromVapPres  // (o) Dew Point temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double VapPres              // (i) psirtial pressure of water vapor in moist air [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure given dew point temperature
// ASHRAE Fundamentals (2005) ch. 6 eqn. 36
//
double GetVapPresFromTDewPoint  // (o) psirtial pressure of water vapor in moist air [psi]
  ( double TDewPoint            // (i) Dew point temperature [F]
  );


//*******************************************************************************
//        Conversions from wet bulb temperature, dew point temperature,
//                or relative humidity to humidity ratio
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Wet bulb temperature given humidity ratio
// ASHRAE Fundamentals (2005) ch. 6 eqn. 35
//
double GetTWetBulbFromHumRatio  // (o) Wet bulb temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given wet bulb temperature and dry bulb temperature
// ASHRAE Fundamentals (2005) ch. 6 eqn. 35
//
double GetHumRatioFromTWetBulb  // (o) Humidity Ratio [H2O/AIR]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double TWetBulb             // (i) Wet bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given relative humidity
// ASHRAE Fundamentals (2005) ch. 6 eqn. 38
//
double GetHumRatioFromRelHum    // (o) Humidity Ratio [H2O/AIR]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double RelHum               // (i) Relative humidity [0-1]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// Relative humidity given humidity ratio
// ASHRAE Fundamentals (2005) ch. 6
//
double GetRelHumFromHumRatio    // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given dew point temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 22
//
double GetHumRatioFromTDewPoint // (o) Humidity Ratio [H2O/AIR]
  ( double TDewPoint            // (i) Dew point temperature [F]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// Dew point temperature given dry bulb temperature, humidity ratio, and pressure
// ASHRAE Fundamentals (2005) ch. 6
//
double GetTDewPointFromHumRatio // (o) Dew Point temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

//*****************************************************************************
//       Conversions between humidity ratio and vapor pressure
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given water vapor pressure and atmospheric pressure
// ASHRAE Fundamentals (2005) ch. 6 eqn. 22
//
double GetHumRatioFromVapPres   // (o) Humidity Ratio [H2O/AIR]
  ( double VapPres              // (i) psirtial pressure of water vapor in moist air [psi]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure given humidity ratio and pressure
// ASHRAE Fundamentals (2005) ch. 6 eqn. 22
//

double GetVapPresFromHumRatio   // (o) psirtial pressure of water vapor in moist air [psi]
  ( double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

//*****************************************************************************
//                             Dry Air Calculations
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Dry air enthalpy given dry bulb temperature.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 30
//
double GetDryAirEnthalpy        // (o) Dry air enthalpy [Btu/lb]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  );

///////////////////////////////////////////////////////////////////////////////
// Dry air density given dry bulb temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 28
//
double GetDryAirDensity         // (o) Dry air density [lb/ft3]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [in Hg]
  );

///////////////////////////////////////////////////////////////////////////////
// Dry air volume given dry bulb temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 28
//
double GetDryAirVolume          // (o) Dry air volume [ft3/lb]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [in Hg]
  );

//*****************************************************************************
//                       Saturated Air Calculations
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Saturation vapor pressure as a function of temperature
// ASHRAE Fundamentals (2005) ch. 6 eqn. 5, 6
//
double GetSatVapPres            // (o) Vapor Pressure of saturated air [psi]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  );

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio of saturated air given dry bulb temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 23
//
double GetSatHumRatio           // (o) Humidity ratio of saturated air [H2O/AIR]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// Saturated air enthalpy given dry bulb temperature.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 32
//
double GetSatAirEnthalpy        // (o) Saturated air enthalpy [Btu/lb]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

//*****************************************************************************
//                       Moist Air Calculations
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure deficit in psi given humidity ratio, dry bulb temperature, and
// pressure.
// See Oke (1987) eqn. 2.13a
//
double GetVPD                   // (o) Vapor pressure deficit [psi]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// ASHRAE Fundamentals (2005) ch. 6 eqn. 12
//
double GetDegreeOfSaturation    // (o) Degree of saturation []
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// Moist air enthalpy given dry bulb temperature and humidity ratio
// ASHRAE Fundamentals (2005) ch. 6 eqn. 32
//
double GetMoistAirEnthalpy      // (o) Moist Air Enthalpy [Btu/lb]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  );

///////////////////////////////////////////////////////////////////////////////
// Moist air volume given dry bulb temperature, humidity ratio, and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 28
//
double GetMoistAirVolume        // (o) Specific Volume [ft3/lb]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

///////////////////////////////////////////////////////////////////////////////
// Moist air density given humidity ratio, dry bulb temperature, and pressure
// ASHRAE Fundamentals (2005) ch. 6 6.8 eqn. 11
//
double GetMoistAirDensity       // (o) Moist air density [lb/ft3]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [psi]
  );

//*****************************************************************************
//                Functions to set all psychrometric values
//*****************************************************************************

void CalcPsychrometricsFromTWetBulb
  ( double *TDewPoint           // (o) Dew point temperature [F]
  , double *RelHum              // (o) Relative humidity [0-1]
  , double *HumRatio            // (o) Humidity ratio [H2O/AIR]
  , double *VapPres             // (o) psirtial pressure of water vapor in moist air [psi]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy [Btu/lb]
  , double *MoistAirVolume      // (o) Specific volume [ft3/lb]
  , double *DegSaturation       // (o) Degree of saturation []
  , double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [psi]
  , double TWetBulb             // (i) Wet bulb temperature [F]
  );

void CalcPsychrometricsFromTDewPoint
  ( double *TWetBulb            // (o) Wet bulb temperature [F]
  , double *RelHum              // (o) Relative humidity [0-1]
  , double *HumRatio            // (o) Humidity ratio [H2O/AIR]
  , double *VapPres             // (o) psirtial pressure of water vapor in moist air [psi]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy [Btu/lb]
  , double *MoistAirVolume      // (o) Specific volume [ft3/lb]
  , double *DegSaturation       // (o) Degree of saturation []
  , double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [psi]
  , double TDewPoint            // (i) Dew point temperature [F]
  );

void CalcPsychrometricsFromRelHum
  ( double *TWetBulb            // (o) Wet bulb temperature [F]
  , double *TDewPoint           // (o) Dew point temperature [F]
  , double *HumRatio            // (o) Humidity ratio [H2O/AIR]
  , double *VapPres             // (o) psirtial pressure of water vapor in moist air [psi]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy [Btu/lb]
  , double *MoistAirVolume      // (o) Specific volume [ft3/lb]
  , double *DegSaturation       // (o) Degree of saturation []
  , double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [psi]
  , double RelHum               // (i) Relative humidity [0-1]
  );

//*****************************************************************************
//                          Standard atmosphere
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Standard atmosphere barometric pressure, given the elevation (altitude)
// ASHRAE Fundamentals (2005) ch. 6 eqn. 3
//
double GetStandardAtmPressure   // (o) standard atmosphere barometric pressure [psi]
  ( double Altitude             // (i) altitude [m]
  );

///////////////////////////////////////////////////////////////////////////////
// Standard atmosphere temperature, given the elevation (altitude)
// ASHRAE Fundamentals (2005) ch. 6 eqn. 4
//
double GetStandardAtmTemperature // (o) standard atmosphere dry bulb temperature [F]
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
double GetSeaLevelPressure   // (o) sea level barometric pressure [psi]
  ( double StnPressure       // (i) observed station pressure [psi]
  , double Altitude          // (i) altitude above sea level [m]
  , double TDryBulb          // (i) dry bulb temperature [°F]
  );

///////////////////////////////////////////////////////////////////////////////
// Station pressure from sea level pressure
// This is just the previous function, reversed
//
double GetStationPressure    // (o) station pressure [psi]
  ( double SeaLevelPressure  // (i) sea level barometric pressure [psi]
  , double Altitude          // (i) altitude above sea level [m]
  , double TDryBulb          // (i) dry bulb temperature [°F]
  );


#endif