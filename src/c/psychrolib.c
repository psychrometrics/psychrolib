/**
 * PsychroLib (version 2.0.0) (https://github.com/psychrometrics/psychrolib)
 * Copyright (c) 2018 D. Thevenard and D. Meyer for the current library implementation
 * Copyright (c) 2017 ASHRAE Handbook — Fundamentals for ASHRAE equations and coefficients
 * Licensed under the MIT License.
 *
 * Module overview
 *  Contains functions for calculating thermodynamic properties of gas-vapor mixtures
 *  and standard atmosphere suitable for most engineering, physical and meteorological
 *  applications.
 *
 *  Most of the functions are an implementation of the formulae found in the
 *  2017 ASHRAE Handbook - Fundamentals, in both International System (SI),
 *  and Imperial (IP) units. Please refer to the information included in
 *  each function for their respective reference.
 *
 * Example
 *  #include "psychrolib.h"
 *  // Set the unit system, for example to SI (can be either 'SI' or 'IP')
 *  SetUnitSystem(SI);
 *  // Calculate the dew point temperature for a dry bulb temperature of 25 C and a relative humidity of 80%
 *  double TDewPoint = GetTDewPointFromRelHum(25.0, 0.80);
 *  printf("%lg", TDewPoint);
 * 21.3094
 *
 * Copyright
 *  - For the current library implementation
 *     Copyright (c) 2018 D. Thevenard and D. Meyer.
 *  - For equations and coefficients published ASHRAE Handbook — Fundamentals, Chapter 1
 *     Copyright (c) 2017 ASHRAE Handbook — Fundamentals (https://www.ashrae.org)
 *
 * License
 *  MIT (https://github.com/psychrometrics/psychrolib/LICENSE.txt)
 *
 * Note from the Authors
 *  We have made every effort to ensure that the code is adequate, however, we make no
 *  representation with respect to its accuracy. Use at your own risk. Should you notice
 *  an error, or if you have a suggestion, please notify us through GitHub at
 *  https://github.com/psychrometrics/psychrolib/issues.
 */

// Standard C header files
#include <float.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

// Header specific to this file
#include "psychrolib.h"


/******************************************************************************************************
 * Global constants
 *****************************************************************************************************/

#define R_DA_IP 53.350    // Universal gas constant for dry air (IP version) in ft∙lbf/lb_da/R
                          // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
#define R_DA_SI 287.042   // Universal gas constant for dry air (SI version) in J/kg_da/K
                          // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1

#define INVALID -99999    // Invalid value


/******************************************************************************************************
 * Helper functions
 *****************************************************************************************************/

#define ASSERT(condition, msg) \
  if (! (condition)) \
  { \
    Assert(msg, __FILE__, __LINE__); \
  }

// Function called if an assertion fails
// Replace this function with your own function for better error processing
void Assert
    ( char *Msg                 // (i) message to print to screen
    , char *FileName            // (i) name of file in which error occurred
    , int LineNo                // (i) number of line in which error occurred
    )
{
  printf("Assert failed in file %s at line %d:\n", FileName, LineNo);
  printf("%s\n", Msg);
  printf("Aborting program...");
  printf("\a");
  exit(1);
}

// Min and max macros (in case they are not defined)
#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif

#ifndef max
#define max(a,b)            (((a) > (b)) ? (a) : (b))
#endif

// Systems of units (IP or SI)
static enum UnitSystem PSYCHROLIB_UNITS = UNDEFINED;

// Tolerance of temperature calculations
static double PSYCHROLIB_TOLERANCE = 1.;

// Set the system of units to use (SI or IP).
// Note: this function *HAS TO BE CALLED* before the library can be used
void SetUnitSystem
  ( enum UnitSystem Units       // (i) System of units (IP or SI)
  )
{
  PSYCHROLIB_UNITS = Units;

  // Define tolerance on temperature calculations
  // The tolerance is the same in IP and SI
  if (PSYCHROLIB_UNITS == IP)
    PSYCHROLIB_TOLERANCE = 0.001 * 9. / 5.;
  else
    PSYCHROLIB_TOLERANCE = 0.001;
}

// Return system of units in use.
enum UnitSystem GetUnitSystem  // (o) System of units (SI or IP)
  (
  )
{
  return PSYCHROLIB_UNITS;
}

// Check whether the system in use is IP or SI.
// The function exits in error if the system of units is undefined
int isIP                    // (o) 1 if IP, 0 if SI, error otherwise
(
)
{
  if (PSYCHROLIB_UNITS == IP)
    return 1;
  else if (PSYCHROLIB_UNITS == SI)
    return 0;
  else
  {
    printf("The system of units has not been defined");
    exit(1);
  }
}


/******************************************************************************************************
 * Conversion between temperature units
 *****************************************************************************************************/

// Utility function to convert temperature to degree Rankine (°R)
// given temperature in degree Fahrenheit (°F).
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
double GetTRankineFromTFahrenheit(double T_F) { return T_F + 459.67; }         /* exact */

// Utility function to convert temperature to Kelvin (K)
// given temperature in degree Celsius (°C).
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
double GetTKelvinFromTCelsius(double T_C) { return T_C + 273.15; }            /* exact */


/******************************************************************************************************
 * Conversions between dew point, wet bulb, and relative humidity
 *****************************************************************************************************/

// Return wet-bulb temperature given dry-bulb temperature, dew-point temperature, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
double GetTWetBulbFromTDewPoint // (o) Wet bulb temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  double HumRatio;

  ASSERT (TDewPoint <= TDryBulb, "Dew point temperature is above dry bulb temperature")

  HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure);
  return GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
}

// Return wet-bulb temperature given dry-bulb temperature, relative humidity, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
double GetTWetBulbFromRelHum    // (o) Wet bulb temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double RelHum               // (i) Relative humidity [0-1]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  double HumRatio;

  ASSERT (RelHum >= 0 && RelHum <= 1, "Relative humidity is outside range [0,1]")

  HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure);
  return GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
}

// Return relative humidity given dry-bulb temperature and dew-point temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 22
double GetRelHumFromTDewPoint   // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  )
{
  double VapPres, SatVapPres;

  ASSERT (TDewPoint <= TDryBulb, "Dew point temperature is above dry bulb temperature")

  VapPres = GetSatVapPres(TDewPoint);
  SatVapPres = GetSatVapPres(TDryBulb);
  return VapPres/SatVapPres;
}

// Return relative humidity given dry-bulb temperature, wet bulb temperature and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
double GetRelHumFromTWetBulb    // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TWetBulb             // (i) Wet bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  double HumRatio;

  ASSERT (TWetBulb <= TDryBulb, "Wet bulb temperature is above dry bulb temperature")

  HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
  return GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
}

// Return dew-point temperature given dry-bulb temperature and relative humidity.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
double GetTDewPointFromRelHum   // (o) Dew Point temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double RelHum               // (i) Relative humidity [0-1]
  )
{
  double VapPres;

  ASSERT (RelHum >= 0 && RelHum <= 1, "Relative humidity is outside range [0,1]")

  VapPres = GetVapPresFromRelHum(TDryBulb, RelHum);
  return GetTDewPointFromVapPres(TDryBulb, VapPres);
}

// Return dew-point temperature given dry-bulb temperature, wet-bulb temperature, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
double GetTDewPointFromTWetBulb // (o) Dew Point temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TWetBulb             // (i) Wet bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  double HumRatio;

  ASSERT (TWetBulb <= TDryBulb, "Wet bulb temperature is above dry bulb temperature")

  HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
  return GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);
}


/******************************************************************************************************
 * Conversions between dew point, or relative humidity and vapor pressure
 *****************************************************************************************************/

// Return partial pressure of water vapor as a function of relative humidity and temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
double GetVapPresFromRelHum     // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double RelHum               // (i) Relative humidity [0-1]
  )
{
  ASSERT (RelHum >= 0. && RelHum <= 1., "Relative humidity is outside range [0,1]")

  return RelHum*GetSatVapPres(TDryBulb);
}

// Return relative humidity given dry-bulb temperature and vapor pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
double GetRelHumFromVapPres     // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double VapPres              // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  )
{
  ASSERT (VapPres >= 0., "Partial pressure of water vapor in moist air is negative")

  return VapPres/GetSatVapPres(TDryBulb);
}

// Return dew-point temperature given dry-bulb temperature and vapor pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 and 6
// Notes: the dew point temperature is solved by inverting the equation giving water vapor pressure
// at saturation from temperature rather than using the regressions provided
// by ASHRAE (eqn. 37 and 38) which are much less accurate and have a
// narrower range of validity.
// The Newton-Raphson (NR) method is used on the logarithm of water vapour
// pressure as a function of temperature, which is a very smooth function
// Convergence is usually achieved in 3 to 5 iterations.
// TDryBulb is not really needed here, just used for convenience.
double GetTDewPointFromVapPres  // (o) Dew Point temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double VapPres              // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  )
{
  // Bounds and step size as a function of the system of units
  double _BOUNDS[2];              // Domain of validity of the equations
  double _STEPSIZE;               // Temperature step used for the calculation of numerical derivatives
  if (isIP())
  {
    _BOUNDS[0] = -148.;
    _BOUNDS[1] = 392.;
    _STEPSIZE = 0.01 * 9. / 5.;
  }
  else
  {
    _BOUNDS[0] = -100.;
    _BOUNDS[1] = 200.;
    _STEPSIZE = 0.01;
  }

  double TMidPoint = (_BOUNDS[0] + _BOUNDS[1]) / 2.;     // Midpoint of domain of validity

  // Bounds outside which a solution cannot be found
  ASSERT (VapPres >= GetSatVapPres(_BOUNDS[0]) && VapPres <= GetSatVapPres(_BOUNDS[1]), "Partial pressure of water vapor is outside range of validity of equations")

  // First guess
  double Tdp = TDryBulb;      // Calculated value of dew point temperatures, solved for iteratively in °F [IP] or °C [SI]
  double lnVP = log(VapPres); // Natural logarithm of partial pressure of water vapor pressure in moist air

  double Tdp_c;               // Value of Tdp used in NR calculation
  double lnVP_c;              // Value of log of vapor water pressure used in NR calculation
  double d_Tdp;               // Value of temperature step used in NR calculation
  do
  {
    // Current point
    Tdp_c = Tdp;
    lnVP_c = log(GetSatVapPres(Tdp_c));
    // Step - negative in the right part of the curve, positive in the left part
    // to avoid going past the domain of validity of eqn. 5 and 6
    // when Tdp_c is close to its bounds
    if (Tdp_c > TMidPoint)
      d_Tdp = -_STEPSIZE;
    else
      d_Tdp = _STEPSIZE;
    // Derivative of function, calculated numerically
    double d_lnVP = (log(GetSatVapPres(Tdp_c + d_Tdp)) - lnVP_c) / d_Tdp;
    // New estimate, bounded by domain of validity of eqn. 5 and 6
    Tdp = Tdp_c - (lnVP_c - lnVP) / d_lnVP;
    Tdp = max(Tdp, _BOUNDS[0]);
    Tdp = min(Tdp, _BOUNDS[1]);
  }
  while (fabs(Tdp - Tdp_c) > PSYCHROLIB_TOLERANCE);
  return min(Tdp, TDryBulb);
}

// Return vapor pressure given dew point temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 36
double GetVapPresFromTDewPoint  // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  ( double TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  )
{
  return GetSatVapPres(TDewPoint);
}


/******************************************************************************************************
 * Conversions from wet-bulb temperature, dew-point temperature, or relative humidity to humidity ratio
 *****************************************************************************************************/

// Return wet-bulb temperature given dry-bulb temperature, humidity ratio, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35 solved for Tstar
double GetTWetBulbFromHumRatio  // (o) Wet bulb temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  // Declarations
  double Wstar;
  double TDewPoint, TWetBulb, TWetBulbSup, TWetBulbInf;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);

  // Initial guesses
  TWetBulbSup = TDryBulb;
  TWetBulbInf = TDewPoint;
  TWetBulb = (TWetBulbInf + TWetBulbSup) / 2.;

  // Bisection loop
  while(TWetBulbSup - TWetBulbInf > PSYCHROLIB_TOLERANCE)
  {
   // Compute humidity ratio at temperature Tstar
   Wstar = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);

   // Get new bounds
   if (Wstar > HumRatio)
    TWetBulbSup = TWetBulb;
   else
    TWetBulbInf = TWetBulb;

   // New guess of wet bulb temperature
   TWetBulb = (TWetBulbSup+TWetBulbInf) / 2.;
  }

  return TWetBulb;
}

// Return humidity ratio given dry-bulb temperature, wet-bulb temperature, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35
double GetHumRatioFromTWetBulb  // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TWetBulb             // (i) Wet bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  double Wsstar;
  double HumRatio = INVALID;

  ASSERT (TWetBulb <= TDryBulb, "Wet bulb temperature is above dry bulb temperature")

  Wsstar = GetSatHumRatio(TWetBulb, Pressure);

  if (isIP())
  {
    if (TWetBulb >= 32.)
      HumRatio = ((1093. - 0.556 * TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb))
      / (1093. + 0.444 * TDryBulb - TWetBulb);
    else
      HumRatio = ((1220. - 0.04 * TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb))
      / (1220. + 0.444 * TDryBulb - 0.48 * TWetBulb);
  }
  else
  {
    if (TWetBulb >= 0.)
      HumRatio = ((2501. - 2.326 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb))
         / (2501. + 1.86 * TDryBulb - 4.186 * TWetBulb);
    else
      HumRatio = ((2830. - 0.24 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb))
         / (2830. + 1.86 * TDryBulb - 2.1 * TWetBulb);
  }

  return HumRatio;
}

// Return humidity ratio given dry-bulb temperature, relative humidity, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
double GetHumRatioFromRelHum    // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double RelHum               // (i) Relative humidity [0-1]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  double VapPres;

  ASSERT (RelHum >= 0. && RelHum <= 1., "Relative humidity is outside range [0,1]")

  VapPres = GetVapPresFromRelHum(TDryBulb, RelHum);
  return GetHumRatioFromVapPres(VapPres, Pressure);
}

// Return relative humidity given dry-bulb temperature, humidity ratio, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
double GetRelHumFromHumRatio    // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  double VapPres;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure);
  return GetRelHumFromVapPres(TDryBulb, VapPres);
}

// Return humidity ratio given dew-point temperature and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
double GetHumRatioFromTDewPoint // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( double TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  double VapPres;

  VapPres = GetSatVapPres(TDewPoint);
  return GetHumRatioFromVapPres(VapPres, Pressure);
}

// Return dew-point temperature given dry-bulb temperature, humidity ratio, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
double GetTDewPointFromHumRatio // (o) Dew Point temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  double VapPres;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure);
  return GetTDewPointFromVapPres(TDryBulb, VapPres);
}


/******************************************************************************************************
 * Conversions between humidity ratio and vapor pressure
 *****************************************************************************************************/

// Return humidity ratio given water vapor pressure and atmospheric pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20
double GetHumRatioFromVapPres   // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( double VapPres              // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  ASSERT (VapPres >= 0., "Partial pressure of water vapor in moist air is negative")

  return 0.621945 * VapPres / (Pressure - VapPres);
}

// Return vapor pressure given humidity ratio and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20 solved for pw
double GetVapPresFromHumRatio   // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  ( double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  double VapPres;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  VapPres = Pressure * HumRatio/(0.621945 + HumRatio);
  return VapPres;
}


/******************************************************************************************************
 * Conversion between humidity types
 *****************************************************************************************************/

// Return the specific humidity from humidity ratio (aka mixing ratio)
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b
double GetSpecificHumFromHumRatio // (o) Specific humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( double HumRatio               // (i) Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]
  )
{
  ASSERT (HumRatio >= 0., "Humidity ratio is negative")
  return HumRatio / (1.0 + HumRatio);
}

// Return the humidity ratio (aka mixing ratio) from specific humidity
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b (solved for humidity ratio)
double GetHumRatioFromSpecificHum // (o) Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]
  ( double SpecificHum            // (i) Specific humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  )
{
  ASSERT (SpecificHum >= 0.0 && SpecificHum < 1.0, "Specific humidity is outside range [0,1[")
  return SpecificHum / (1.0 - SpecificHum);
}


/******************************************************************************************************
 * Dry Air Calculations
 *****************************************************************************************************/

// Return dry-air enthalpy given dry-bulb temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 28
double GetDryAirEnthalpy        // (o) Dry air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  )
{
  if (isIP())
    return 0.240 * TDryBulb;
  else
    return 1006 * TDryBulb;
}

// Return dry-air density given dry-bulb temperature and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
// Notes: eqn 14 for the perfect gas relationship for dry air.
// Eqn 1 for the universal gas constant.
// The factor 144 in IP is for the conversion of Psi = lb in⁻² to lb ft⁻².
double GetDryAirDensity         // (o) Dry air density in lb ft⁻³ [IP] or kg m⁻³ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  if (isIP())
    return (144. * Pressure) / R_DA_IP / GetTRankineFromTFahrenheit(TDryBulb);
  else
    return Pressure / R_DA_SI / GetTKelvinFromTCelsius(TDryBulb);
}

// Return dry-air volume given dry-bulb temperature and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
// Notes: eqn 14 for the perfect gas relationship for dry air.
// Eqn 1 for the universal gas constant.
// The factor 144 in IP is for the conversion of Psi = lb in⁻² to lb ft⁻².
double GetDryAirVolume          // (o) Dry air volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  if (isIP())
    return R_DA_IP * GetTRankineFromTFahrenheit(TDryBulb) / (144. * Pressure);
  else
    return R_DA_SI * GetTKelvinFromTCelsius(TDryBulb) / Pressure;
}


// Return dry bulb temperature from enthalpy and humidity ratio
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30
// Notes: based on the `GetMoistAirEnthalpy` function, rearranged for humidity ratio
double GetTDryBulbFromMoistAirEnthalpy  // (o) Dry-bulb temperature in °F [IP] or °C [SI]
  ( double MoistAirEnthalpy             // (i) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
  , double HumRatio                     // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  )
{
  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  if (isIP())
    return (MoistAirEnthalpy - 1061.0 * HumRatio) / (0.240 + 0.444 * HumRatio);
  else
    return (MoistAirEnthalpy / 1000.0 - 2501.0 * HumRatio) / (1.006 + 1.86 * HumRatio);
}

/******************************************************************************************************
 * Saturated Air Calculations
 *****************************************************************************************************/

// Return saturation vapor pressure given dry-bulb temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 & 6
double GetSatVapPres            // (o) Vapor Pressure of saturated air in Psi [IP] or Pa [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  )
{
  double LnPws, T;

  if (isIP())
  {
    ASSERT(TDryBulb >= -148. && TDryBulb <= 392., "Dry bulb temperature is outside range [-148, 392]")

    T = GetTRankineFromTFahrenheit(TDryBulb);
    if (TDryBulb >= -148. && TDryBulb <= 32.)
      LnPws = (-1.0214165E+04 / T - 4.8932428 - 5.3765794E-03 * T + 1.9202377E-07 * T * T
        + 3.5575832E-10 * pow(T, 3) - 9.0344688E-14 * pow(T, 4) + 4.1635019 * log(T));
    else if (TDryBulb > 32. && TDryBulb <= 392.)
      LnPws = -1.0440397E+04 / T - 1.1294650E+01 - 2.7022355E-02 * T + 1.2890360E-05 * T * T
      - 2.4780681E-09 * pow(T, 3) + 6.5459673 * log(T);
    else
      return INVALID;             // TDryBulb is out of range [-148, 392]
  }
  else
  {
    ASSERT(TDryBulb >= -100. && TDryBulb <= 200., "Dry bulb temperature is outside range [-100, 200]")

    T = GetTKelvinFromTCelsius(TDryBulb);
    if (TDryBulb >= -100. && TDryBulb <= 0.)
      LnPws = -5.6745359E+03 / T + 6.3925247 - 9.677843E-03 * T + 6.2215701E-07 * T * T
          + 2.0747825E-09 * pow(T, 3) - 9.484024E-13 * pow(T, 4) + 4.1635019 * log(T);
    else if (TDryBulb > 0. && TDryBulb <= 200.)
      LnPws = -5.8002206E+03 / T + 1.3914993 - 4.8640239E-02 * T + 4.1764768E-05 * T * T
        - 1.4452093E-08 * pow(T, 3) + 6.5459673 * log(T);
    else
      return INVALID;             // TDryBulb is out of range [-100, 200]
  }

  return exp(LnPws);
}

// Return humidity ratio of saturated air given dry-bulb temperature and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36, solved for W
double GetSatHumRatio           // (o) Humidity ratio of saturated air in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  double SatVaporPres;

  SatVaporPres = GetSatVapPres(TDryBulb);
  return 0.621945 * SatVaporPres / (Pressure - SatVaporPres);
}

// Return saturated air enthalpy given dry-bulb temperature and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
double GetSatAirEnthalpy        // (o) Saturated air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  return GetMoistAirEnthalpy(TDryBulb, GetSatHumRatio(TDryBulb, Pressure));
}

/******************************************************************************************************
 * Moist Air Calculations
 *****************************************************************************************************/

// Return Vapor pressure deficit given dry-bulb temperature, humidity ratio, and pressure.
// Reference: see Oke (1987) eqn. 2.13a
double GetVaporPressureDeficit  // (o) Vapor pressure deficit in Psi [IP] or Pa [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  double RelHum;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
  return GetSatVapPres(TDryBulb) * (1. - RelHum);
}

// Return the degree of saturation (i.e humidity ratio of the air / humidity ratio of the air at saturation
// at the same temperature and pressure) given dry-bulb temperature, humidity ratio, and atmospheric pressure.
// Reference: ASHRAE Handbook - Fundamentals (2009) ch. 1 eqn. 12
// Notes: the definition is absent from the 2017 Handbook
double GetDegreeOfSaturation    // (o) Degree of saturation []
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  return HumRatio / GetSatHumRatio(TDryBulb, Pressure);
}

// Return moist air enthalpy given dry-bulb temperature and humidity ratio.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 30
double GetMoistAirEnthalpy      // (o) Moist Air Enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  )
{
  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  if (isIP())
    return 0.240 * TDryBulb + HumRatio*(1061. + 0.444 * TDryBulb);
  else
    return (1.006 * TDryBulb + HumRatio*(2501. + 1.86 * TDryBulb)) * 1000.;
}

// Return moist air specific volume given dry-bulb temperature, humidity ratio, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 26
// Notes: in IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26.
// The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².
double GetMoistAirVolume        // (o) Specific Volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  ASSERT(HumRatio >= 0., "Humidity ratio is negative")

  if (isIP())
    return R_DA_IP * GetTRankineFromTFahrenheit(TDryBulb) * (1. + 1.607858*HumRatio) / (144. * Pressure);
  else
    return R_DA_SI * GetTKelvinFromTCelsius(TDryBulb) * (1. + 1.607858*HumRatio) / Pressure;
}

// Return moist air density given humidity ratio, dry bulb temperature, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 11
double GetMoistAirDensity       // (o) Moist air density in lb ft⁻³ [IP] or kg m⁻³ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
{
  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  return (1. + HumRatio) / GetMoistAirVolume(TDryBulb, HumRatio, Pressure);
}


/******************************************************************************************************
 * Standard atmosphere
 *****************************************************************************************************/

// Return standard atmosphere barometric pressure, given the elevation (altitude).
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 3
double GetStandardAtmPressure   // (o) Standard atmosphere barometric pressure in Psi [IP] or Pa [SI]
  ( double Altitude             // (i) Altitude in ft [IP] or m [SI]
  )
{
  double Pressure;
  if (isIP())
    Pressure = 14.696 * pow(1. - 6.8754e-06 * Altitude, 5.2559);
  else
    Pressure = 101325. * pow(1. - 2.25577e-05 * Altitude, 5.2559);
  return Pressure;
}

// Return standard atmosphere temperature, given the elevation (altitude).
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 4
double GetStandardAtmTemperature // (o) Standard atmosphere dry bulb temperature in °F [IP] or °C [SI]
  ( double Altitude              // (i) Altitude in ft [IP] or m [SI]
  )
 {
  double Temperature;
  if (isIP())
    Temperature = 59. - 0.00356620 * Altitude;
  else
    Temperature = 15. - 0.0065 * Altitude;
  return Temperature;
}

// Return sea level pressure given dry-bulb temperature, altitude above sea level and pressure.
// Reference: Hess SL, Introduction to theoretical meteorology, Holt Rinehart and Winston, NY 1959,
// ch. 6.5; Stull RB, Meteorology for scientists and engineers, 2nd edition,
// Brooks/Cole 2000, ch. 1.
// Notes: the standard procedure for the US is to use for TDryBulb the average
// of the current station temperature and the station temperature from 12 hours ago.
double GetSeaLevelPressure   // (o) Sea level barometric pressure in Psi [IP] or Pa [SI]
  ( double StnPressure       // (i) Observed station pressure in Psi [IP] or Pa [SI]
  , double Altitude          // (i) Altitude above sea level in ft [IP] or m [SI]
  , double TDryBulb          // (i) Dry bulb temperature ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  )
{
  double TColumn, H;
  if (isIP())
  {
    // Calculate average temperature in column of air, assuming a lapse rate
    // of 3.6 °F/1000ft
    TColumn = TDryBulb + 0.0036 * Altitude / 2.;

    // Determine the scale height
    H = 53.351 * GetTRankineFromTFahrenheit(TColumn);
  }
  else
  {
    // Calculate average temperature in column of air, assuming a lapse rate
    // of 6.5 °C/km
    TColumn = TDryBulb + 0.0065 * Altitude / 2.;

    // Determine the scale height
    H = 287.055 * GetTKelvinFromTCelsius(TColumn) / 9.807;
  }

  // Calculate the sea level pressure
  double SeaLevelPressure = StnPressure * exp(Altitude / H);
  return SeaLevelPressure;
}

// Return station pressure from sea level pressure
// Reference: see 'GetSeaLevelPressure'
// Notes: this function is just the inverse of 'GetSeaLevelPressure'.
double GetStationPressure    // (o) Station pressure in Psi [IP] or Pa [SI]
  ( double SeaLevelPressure  // (i) Sea level barometric pressure in Psi [IP] or Pa [SI]
  , double Altitude          // (i) Altitude above sea level in ft [IP] or m [SI]
  , double TDryBulb          // (i) Dry bulb temperature in °F [IP] or °C [SI]
  )
{
  return SeaLevelPressure / GetSeaLevelPressure(1., Altitude, TDryBulb);
}


/******************************************************************************************************
 * Functions to set all psychrometric values
 *****************************************************************************************************/

// Utility function to calculate humidity ratio, dew-point temperature, relative humidity,
// vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
// dry-bulb temperature, wet-bulb temperature, and pressure.
void CalcPsychrometricsFromTWetBulb
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TWetBulb             // (i) Wet bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  , double *HumRatio            // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double *TDewPoint           // (o) Dew point temperature in °F [IP] or °C [SI]
  , double *RelHum              // (o) Relative humidity [0-1]
  , double *VapPres             // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  , double *MoistAirVolume      // (o) Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  , double *DegreeOfSaturation  // (o) Degree of saturation [unitless]
)
{
  ASSERT(TWetBulb <= TDryBulb, "Wet bulb temperature is above dry bulb temperature")

  *HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
  *TDewPoint = GetTDewPointFromHumRatio(TDryBulb, *HumRatio, Pressure);
  *RelHum = GetRelHumFromHumRatio(TDryBulb, *HumRatio, Pressure);
  *VapPres = GetVapPresFromHumRatio(*HumRatio, Pressure);
  *MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, *HumRatio);
  *MoistAirVolume = GetMoistAirVolume(TDryBulb, *HumRatio, Pressure);
  *DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, *HumRatio, Pressure);
}

// Utility function to calculate humidity ratio, wet-bulb temperature, relative humidity,
// vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
// dry-bulb temperature, dew-point temperature, and pressure.
void CalcPsychrometricsFromTDewPoint
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  , double *HumRatio            // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double *TWetBulb            // (o) Wet bulb temperature in °F [IP] or °C [SI]
  , double *RelHum              // (o) Relative humidity [0-1]
  , double *VapPres             // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  , double *MoistAirVolume      // (o) Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  , double *DegreeOfSaturation  // (o) Degree of saturation [unitless]
)
{
  ASSERT(TDewPoint <= TDryBulb, "Dew point temperature is above dry bulb temperature")

  *HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure);
  *TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, *HumRatio, Pressure);
  *RelHum = GetRelHumFromHumRatio(TDryBulb, *HumRatio, Pressure);
  *VapPres = GetVapPresFromHumRatio(*HumRatio, Pressure);
  *MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, *HumRatio);
  *MoistAirVolume = GetMoistAirVolume(TDryBulb, *HumRatio, Pressure);
  *DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, *HumRatio, Pressure);
}

// Utility function to calculate humidity ratio, wet-bulb temperature, dew-point temperature,
// vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
// dry-bulb temperature, relative humidity and pressure.
void CalcPsychrometricsFromRelHum
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double RelHum               // (i) Relative humidity [0-1]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  , double *HumRatio            // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double *TWetBulb            // (o) Wet bulb temperature in °F [IP] or °C [SI]
  , double *TDewPoint           // (o) Dew point temperature in °F [IP] or °C [SI]
  , double *VapPres             // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  , double *MoistAirVolume      // (o) Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  , double *DegreeOfSaturation  // (o) Degree of saturation [unitless]
)
{
  ASSERT(RelHum >= 0 && RelHum <= 1, "Relative humidity is outside range [0,1]")

  *HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure);
  *TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, *HumRatio, Pressure);
  *TDewPoint = GetTDewPointFromHumRatio(TDryBulb, *HumRatio, Pressure);
  *VapPres = GetVapPresFromHumRatio(*HumRatio, Pressure);
  *MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, *HumRatio);
  *MoistAirVolume = GetMoistAirVolume(TDryBulb, *HumRatio, Pressure);
  *DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, *HumRatio, Pressure);
}
