/*
 * PsychroLib (version 2.5.0) (https://github.com/psychrometrics/psychrolib).
 * Copyright (c) 2018-2020 The PsychroLib Contributors for the current library implementation.
 * Copyright (c) 2017 ASHRAE Handbook — Fundamentals for ASHRAE equations and coefficients.
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
 *     Copyright (c) 2018-2020 The PsychroLib Contributors.
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

package psychrolib

import "math"

const (
      UNDEFINED = iota
      IP = iota
      SI = iota
      )


/******************************************************************************************************
 * Global constants
 *****************************************************************************************************/

const ZERO_FAHRENHEIT_AS_RANKINE float64 = 459.67  // Zero degree Fahrenheit (°F) expressed as degree Rankine (°R).
                                                   // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 39.

const ZERO_CELSIUS_AS_KELVIN float64 = 273.15      // Zero degree Celsius (°C) expressed as Kelvin (K).
                                                   // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 39.

const R_DA_IP float64 = 53.350                  // Universal gas constant for dry air (IP version) in ft∙lbf/lb_da/R.
                                                // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1.

const R_DA_SI float64 = 287.042                 // Universal gas constant for dry air (SI version) in J/kg_da/K.
                                                // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1.

const INVALID float64 = -99999                  // Invalid value.

const MAX_ITER_COUNT int = 100              // Maximum number of iterations before exiting while loops.

const MIN_HUM_RATIO float64 = 1e-7              // Minimum acceptable humidity ratio used/returned by any functions.
                                                // Any value above 0 or below the MIN_HUM_RATIO will be reset to this value.

const FREEZING_POINT_WATER_IP float64 = 32.0    // Freezing point of water in Fahrenheit.

const FREEZING_POINT_WATER_SI float64 = 0.0     // Freezing point of water in Celsius.

const TRIPLE_POINT_WATER_IP float64 = 32.018    // Triple point of water in Fahrenheit.

const TRIPLE_POINT_WATER_SI float64 = 0.01      // Triple point of water in Celsius.

/******************************************************************************************************
 * Helper functions
 *****************************************************************************************************/

func ASSERT (test bool, error string) {
  if (!test) {
    panic(error)
  }
}


var PSYCHROLIB_UNITS int = UNDEFINED
var PSYCHROLIB_TOLERANCE float64 = 1.

func SetUnitSystem(Units int) {
  PSYCHROLIB_UNITS = Units
  if (PSYCHROLIB_UNITS == IP) {
    PSYCHROLIB_TOLERANCE = 0.001 * 9. / 5.
  } else {
    PSYCHROLIB_TOLERANCE = 0.001
  }
}

func GetUnitSystem() int {
  return PSYCHROLIB_UNITS  
}

func isIP() bool {
  if (PSYCHROLIB_UNITS == IP) {
    return true
  } else if (PSYCHROLIB_UNITS == SI) {
    return false
  } else {
    panic("The system of units has not been defined");
  }
}


/******************************************************************************************************
 * Conversion between temperature units
 *****************************************************************************************************/

// Utility function to convert temperature to degree Rankine (°R)
// given temperature in degree Fahrenheit (°F).
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
func GetTRankineFromTFahrenheit(T_F float64) float64 {return T_F + ZERO_FAHRENHEIT_AS_RANKINE }         /* exact */

// Utility function to convert temperature to degree Fahrenheit (°F)
// given temperature in degree Rankine (°R).
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
func GetTFahrenheitFromTRankine(T_R float64) float64 { return T_R - ZERO_FAHRENHEIT_AS_RANKINE; }        /* exact */

// Utility function to convert temperature to Kelvin (K)
// given temperature in degree Celsius (°C).
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
func GetTKelvinFromTCelsius(T_C float64) float64 { return T_C + ZERO_CELSIUS_AS_KELVIN; }                /* exact */

// Utility function to convert temperature to degree Celsius (°C)
// given temperature in Kelvin (K).
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
func GetTCelsiusFromTKelvin(T_K float64) float64 { return T_K - ZERO_CELSIUS_AS_KELVIN; }                /* exact */


/******************************************************************************************************
 * Conversions between dew point, wet bulb, and relative humidity
 *****************************************************************************************************/
/*
// Return wet-bulb temperature given dry-bulb temperature, dew-point temperature, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
float64 GetTWetBulbFromTDewPoint // (o) Wet bulb temperature in °F [IP] or °C [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetTWetBulbFromTDewPoint( TDryBulb float64, TDewPoint float64, Pressure float64) float64 {
  var HumRatio float64

  ASSERT (TDewPoint <= TDryBulb, "Dew point temperature is above dry bulb temperature")

  HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure);
  return GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
}

// Return wet-bulb temperature given dry-bulb temperature, relative humidity, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
/*
float64 GetTWetBulbFromRelHum    // (o) Wet bulb temperature in °F [IP] or °C [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 RelHum               // (i) Relative humidity [0-1]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetTWetBulbFromRelHum( TDryBulb float64, RelHum float64, Pressure float64) float64 {
  var HumRatio float64

  ASSERT (RelHum >= 0 && RelHum <= 1, "Relative humidity is outside range [0,1]")

  HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure);
  return GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
}

// Return relative humidity given dry-bulb temperature and dew-point temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 22
/*
float64 GetRelHumFromTDewPoint   // (o) Relative humidity [0-1]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  )
*/
func GetRelHumFromTDewPoint( TDryBulb float64, TDewPoint float64) float64 {
  var VapPres, SatVapPres float64;

  ASSERT (TDewPoint <= TDryBulb, "Dew point temperature is above dry bulb temperature")

  VapPres = GetSatVapPres(TDewPoint);
  SatVapPres = GetSatVapPres(TDryBulb);
  return VapPres/SatVapPres;
}

// Return relative humidity given dry-bulb temperature, wet bulb temperature and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
/*
float64 GetRelHumFromTWetBulb    // (o) Relative humidity [0-1]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 TWetBulb             // (i) Wet bulb temperature in °F [IP] or °C [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetRelHumFromTWetBulb(TDryBulb float64, TWetBulb float64, Pressure float64) float64 {
  var HumRatio float64

  ASSERT (TWetBulb <= TDryBulb, "Wet bulb temperature is above dry bulb temperature")

  HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
  return GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
}

// Return dew-point temperature given dry-bulb temperature and relative humidity.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
/*
float64 GetTDewPointFromRelHum   // (o) Dew Point temperature in °F [IP] or °C [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 RelHum               // (i) Relative humidity [0-1]
  )
*/
func GetTDewPointFromRelHum( TDryBulb float64, RelHum float64) float64 {
  var VapPres float64;

  ASSERT (RelHum >= 0 && RelHum <= 1, "Relative humidity is outside range [0,1]")

  VapPres = GetVapPresFromRelHum(TDryBulb, RelHum);
  return GetTDewPointFromVapPres(TDryBulb, VapPres);
}

// Return dew-point temperature given dry-bulb temperature, wet-bulb temperature, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
/*
float64 GetTDewPointFromTWetBulb // (o) Dew Point temperature in °F [IP] or °C [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 TWetBulb             // (i) Wet bulb temperature in °F [IP] or °C [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetTDewPointFromTWetBulb(TDryBulb float64, TWetBulb float64, Pressure float64) float64 {
  var HumRatio float64;

  ASSERT (TWetBulb <= TDryBulb, "Wet bulb temperature is above dry bulb temperature")

  HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
  return GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);
}


/******************************************************************************************************
 * Conversions between dew point, or relative humidity and vapor pressure
 *****************************************************************************************************/

// Return partial pressure of water vapor as a function of relative humidity and temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
/*
float64 GetVapPresFromRelHum     // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 RelHum               // (i) Relative humidity [0-1]
  )
*/
func GetVapPresFromRelHum( TDryBulb float64, RelHum float64) float64 {
  ASSERT (RelHum >= 0. && RelHum <= 1., "Relative humidity is outside range [0,1]")

  return RelHum*GetSatVapPres(TDryBulb);
}

// Return relative humidity given dry-bulb temperature and vapor pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
/*
float64 GetRelHumFromVapPres     // (o) Relative humidity [0-1]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 VapPres              // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  )
*/
func GetRelHumFromVapPres( TDryBulb float64, VapPres float64) float64 {
  ASSERT (VapPres >= 0., "Partial pressure of water vapor in moist air is negative")

  return VapPres/GetSatVapPres(TDryBulb);
}

// Helper function returning the derivative of the natural log of the saturation vapor pressure
// as a function of dry-bulb temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 & 6
func dLnPws_(TDryBulb float64) float64 {
  var dLnPws, T float64;

  if (isIP()) {
    T = GetTRankineFromTFahrenheit(TDryBulb);

    if (TDryBulb <= TRIPLE_POINT_WATER_IP) {
      dLnPws = 1.0214165E+04 / math.Pow(T, 2) - 5.3765794E-03 + 2 * 1.9202377E-07 * T + 3 * 3.5575832E-10 * math.Pow(T, 2) - 4 * 9.0344688E-14 * math.Pow(T, 3) + 4.1635019 / T;
    } else {
      dLnPws = 1.0440397E+04 / math.Pow(T, 2) - 2.7022355E-02 + 2 * 1.2890360E-05 * T - 3 * 2.4780681E-09 * math.Pow(T, 2) + 6.5459673 / T;
    }
  } else {
    T = GetTKelvinFromTCelsius(TDryBulb);

    if (TDryBulb <= TRIPLE_POINT_WATER_SI) {
      dLnPws = 5.6745359E+03 / math.Pow(T, 2) - 9.677843E-03 + 2 * 6.2215701E-07 * T + 3 * 2.0747825E-09 * math.Pow(T, 2) - 4 * 9.484024E-13 * math.Pow(T, 3) + 4.1635019 / T;
    } else {
      dLnPws = 5.8002206E+03 / math.Pow(T, 2) - 4.8640239E-02 + 2 * 4.1764768E-05 * T - 3 * 1.4452093E-08 * math.Pow(T, 2) + 6.5459673 / T;
    }
  }

  return dLnPws;
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
/*
float64 GetTDewPointFromVapPres  // (o) Dew Point temperature in °F [IP] or °C [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 VapPres              // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  )
*/
func GetTDewPointFromVapPres( TDryBulb float64, VapPres float64) float64 {
  // Bounds function of the system of units
  var BOUNDS[2] float64;              // Domain of validity of the equations

  if (isIP()) {
    BOUNDS[0] = -148.;
    BOUNDS[1] = 392.;
  } else {
    BOUNDS[0] = -100.;
    BOUNDS[1] = 200.;
  }

  // Bounds outside which a solution cannot be found
  ASSERT ((VapPres >= GetSatVapPres(BOUNDS[0]) && VapPres <= GetSatVapPres(BOUNDS[1])), "Partial pressure of water vapor is outside range of validity of equations")

  // We use NR to approximate the solution.
  // First guess
  TDewPoint := TDryBulb;      // Calculated value of dew point temperatures, solved for iteratively in °F [IP] or °C [SI]
  lnVP := math.Log(VapPres);       // Natural logarithm of partial pressure of water vapor pressure in moist air

  var TDewPoint_iter float64;            // Value of TDewPoint used in NR calculation
  var lnVP_iter float64;                 // Value of log of vapor water pressure used in NR calculation
  var index int = 1;

  for (true) {
    TDewPoint_iter = TDewPoint; // TDewPoint used in NR calculation
    lnVP_iter = math.Log(GetSatVapPres(TDewPoint_iter));

    // Derivative of function, calculated analytically
    d_lnVP := dLnPws_(TDewPoint_iter);

    // New estimate, bounded by domain of validity of eqn. 5 and 6
    TDewPoint = TDewPoint_iter - (lnVP_iter - lnVP) / d_lnVP;
    TDewPoint = max(TDewPoint, BOUNDS[0]);
    TDewPoint = min(TDewPoint, BOUNDS[1]);

    ASSERT (index <= MAX_ITER_COUNT, "Convergence not reached in GetTDewPointFromVapPres. Stopping.")

    index++;
    if !(math.Abs(TDewPoint - TDewPoint_iter) > PSYCHROLIB_TOLERANCE) {
      break
    }
  }
  return min(TDewPoint, TDryBulb);
}

// Return vapor pressure given dew point temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 36
/*
float64 GetVapPresFromTDewPoint  // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  ( float64 TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  )
*/
func GetVapPresFromTDewPoint(TDewPoint float64) float64 {
  return GetSatVapPres(TDewPoint);
}


/******************************************************************************************************
 * Conversions from wet-bulb temperature, dew-point temperature, or relative humidity to humidity ratio
 *****************************************************************************************************/

// Return wet-bulb temperature given dry-bulb temperature, humidity ratio, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35 solved for Tstar
/*
float64 GetTWetBulbFromHumRatio  // (o) Wet bulb temperature in °F [IP] or °C [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetTWetBulbFromHumRatio(TDryBulb float64, HumRatio float64, Pressure float64) float64 {
  // Declarations
  var Wstar float64;
  var TDewPoint, TWetBulb, TWetBulbSup, TWetBulbInf, BoundedHumRatio float64;
  var index int = 1;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

  TDewPoint = GetTDewPointFromHumRatio(TDryBulb, BoundedHumRatio, Pressure);

  // Initial guesses
  TWetBulbSup = TDryBulb;
  TWetBulbInf = TDewPoint;
  TWetBulb = (TWetBulbInf + TWetBulbSup) / 2.;

  // Bisection loop
  for (true) {
   // Compute humidity ratio at temperature Tstar
   Wstar = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);

   // Get new bounds
   if (Wstar > BoundedHumRatio) {
    TWetBulbSup = TWetBulb;
   } else {
    TWetBulbInf = TWetBulb;
   }

   // New guess of wet bulb temperature
   TWetBulb = (TWetBulbSup+TWetBulbInf) / 2.;

   ASSERT (index <= MAX_ITER_COUNT, "Convergence not reached in GetTWetBulbFromHumRatio. Stopping.")

   index++;
   if !((TWetBulbSup - TWetBulbInf) > PSYCHROLIB_TOLERANCE) {
     break;
   }
  }

  return TWetBulb;
}

// Return humidity ratio given dry-bulb temperature, wet-bulb temperature, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35
/*
float64 GetHumRatioFromTWetBulb  // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 TWetBulb             // (i) Wet bulb temperature in °F [IP] or °C [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetHumRatioFromTWetBulb(TDryBulb float64, TWetBulb float64, Pressure float64) float64 {
  var Wsstar float64;
  var HumRatio float64 = INVALID;

  ASSERT (TWetBulb <= TDryBulb, "Wet bulb temperature is above dry bulb temperature")

  Wsstar = GetSatHumRatio(TWetBulb, Pressure);

  if (isIP()) {
    if (TWetBulb >= FREEZING_POINT_WATER_IP) {
      HumRatio = ((1093. - 0.556 * TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb)) / (1093. + 0.444 * TDryBulb - TWetBulb);
    } else {
      HumRatio = ((1220. - 0.04 * TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb)) / (1220. + 0.444 * TDryBulb - 0.48 * TWetBulb);
    }
  } else {
    if (TWetBulb >= FREEZING_POINT_WATER_SI) {
      HumRatio = ((2501. - 2.326 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb)) / (2501. + 1.86 * TDryBulb - 4.186 * TWetBulb);
    } else {
      HumRatio = ((2830. - 0.24 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb)) / (2830. + 1.86 * TDryBulb - 2.1 * TWetBulb);
    }
  }
  // Validity check.
  return max(HumRatio, MIN_HUM_RATIO);
}

// Return humidity ratio given dry-bulb temperature, relative humidity, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
/*
float64 GetHumRatioFromRelHum    // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 RelHum               // (i) Relative humidity [0-1]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetHumRatioFromRelHum( TDryBulb float64, RelHum float64, Pressure float64) float64 {
  var VapPres float64;

  ASSERT (RelHum >= 0. && RelHum <= 1., "Relative humidity is outside range [0,1]")

  VapPres = GetVapPresFromRelHum(TDryBulb, RelHum);
  return GetHumRatioFromVapPres(VapPres, Pressure);
}

// Return relative humidity given dry-bulb temperature, humidity ratio, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
/*
float64 GetRelHumFromHumRatio    // (o) Relative humidity [0-1]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetRelHumFromHumRatio(TDryBulb float64, HumRatio float64, Pressure float64) float64 {
  var VapPres float64;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure);
  return GetRelHumFromVapPres(TDryBulb, VapPres);
}

// Return humidity ratio given dew-point temperature and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
/*
float64 GetHumRatioFromTDewPoint // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( float64 TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetHumRatioFromTDewPoint(TDewPoint float64, Pressure float64) float64 {
  var VapPres float64;

  VapPres = GetSatVapPres(TDewPoint);
  return GetHumRatioFromVapPres(VapPres, Pressure);
}

// Return dew-point temperature given dry-bulb temperature, humidity ratio, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
/*
float64 GetTDewPointFromHumRatio // (o) Dew Point temperature in °F [IP] or °C [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetTDewPointFromHumRatio( TDryBulb float64, HumRatio float64, Pressure float64) float64 {
  var VapPres float64;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure);
  return GetTDewPointFromVapPres(TDryBulb, VapPres);
}


/******************************************************************************************************
 * Conversions between humidity ratio and vapor pressure
 *****************************************************************************************************/

// Return humidity ratio given water vapor pressure and atmospheric pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20
/*
float64 GetHumRatioFromVapPres   // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( float64 VapPres              // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetHumRatioFromVapPres(VapPres float64, Pressure float64) float64{
  var HumRatio float64;

  ASSERT (VapPres >= 0., "Partial pressure of water vapor in moist air is negative")

  HumRatio = 0.621945 * VapPres / (Pressure - VapPres);

  // Validity check.
  return max(HumRatio, MIN_HUM_RATIO);
}

// Return vapor pressure given humidity ratio and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20 solved for pw
/*
float64 GetVapPresFromHumRatio   // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  ( float64 HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetVapPresFromHumRatio(HumRatio float64, Pressure float64) float64 {
  var VapPres, BoundedHumRatio float64;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

  VapPres = Pressure * BoundedHumRatio / (0.621945 + BoundedHumRatio);
  return VapPres;
}


/******************************************************************************************************
 * Conversions between humidity ratio and specific humidity
 *****************************************************************************************************/

// Return the specific humidity from humidity ratio (aka mixing ratio)
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b
/*
float64 GetSpecificHumFromHumRatio // (o) Specific humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( float64 HumRatio               // (i) Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]
  )
*/
func GetSpecificHumFromHumRatio(HumRatio float64) float64 {
  var BoundedHumRatio float64;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

  return BoundedHumRatio / (1.0 + BoundedHumRatio);
}

// Return the humidity ratio (aka mixing ratio) from specific humidity
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b (solved for humidity ratio)
/*
float64 GetHumRatioFromSpecificHum // (o) Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]
  ( float64 SpecificHum            // (i) Specific humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  )
*/
func GetHumRatioFromSpecificHum(SpecificHum float64) float64 {
  var HumRatio float64;

  ASSERT (SpecificHum >= 0.0 && SpecificHum < 1.0, "Specific humidity is outside range [0, 1)")

  HumRatio = SpecificHum / (1.0 - SpecificHum);

  // Validity check
  return max(HumRatio, MIN_HUM_RATIO);
}


/******************************************************************************************************
 * Dry Air Calculations
 *****************************************************************************************************/

// Return dry-air enthalpy given dry-bulb temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 28
/*
float64 GetDryAirEnthalpy        // (o) Dry air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  )
*/
func GetDryAirEnthalpy(TDryBulb float64) float64 {
  if (isIP()) {
    return 0.240 * TDryBulb;
  } else {
    return 1006 * TDryBulb;
  }
}

// Return dry-air density given dry-bulb temperature and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
// Notes: eqn 14 for the perfect gas relationship for dry air.
// Eqn 1 for the universal gas constant.
// The factor 144 in IP is for the conversion of Psi = lb in⁻² to lb ft⁻².
/*
float64 GetDryAirDensity         // (o) Dry air density in lb ft⁻³ [IP] or kg m⁻³ [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetDryAirDensity(TDryBulb float64, Pressure float64) float64 {
  if (isIP()) {
    return (144. * Pressure) / R_DA_IP / GetTRankineFromTFahrenheit(TDryBulb);
  } else {
    return Pressure / R_DA_SI / GetTKelvinFromTCelsius(TDryBulb);
  }
}

// Return dry-air volume given dry-bulb temperature and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
// Notes: eqn 14 for the perfect gas relationship for dry air.
// Eqn 1 for the universal gas constant.
// The factor 144 in IP is for the conversion of Psi = lb in⁻² to lb ft⁻².
/*
float64 GetDryAirVolume          // (o) Dry air volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetDryAirVolume( TDryBulb float64, Pressure float64) float64 {
  if (isIP()) {
    return R_DA_IP * GetTRankineFromTFahrenheit(TDryBulb) / (144. * Pressure);
  } else {
    return R_DA_SI * GetTKelvinFromTCelsius(TDryBulb) / Pressure;
  }
}

// Return dry bulb temperature from enthalpy and humidity ratio.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30.
// Notes: based on the `GetMoistAirEnthalpy` function, rearranged for temperature.
/*
float64 GetTDryBulbFromEnthalpyAndHumRatio  // (o) Dry-bulb temperature in °F [IP] or °C [SI]
  ( float64 MoistAirEnthalpy                // (i) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
  , float64 HumRatio                        // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  )
*/
func GetTDryBulbFromEnthalpyAndHumRatio(MoistAirEnthalpy float64, HumRatio float64) float64 {
  var BoundedHumRatio float64;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

  if (isIP()) {
    return (MoistAirEnthalpy - 1061.0 * BoundedHumRatio) / (0.240 + 0.444 * BoundedHumRatio);
  } else {
    return (MoistAirEnthalpy / 1000.0 - 2501.0 * BoundedHumRatio) / (1.006 + 1.86 * BoundedHumRatio);
  }
}

// Return humidity ratio from enthalpy and dry-bulb temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30.
// Notes: based on the `GetMoistAirEnthalpy` function, rearranged for humidity ratio.
/*
float64 GetHumRatioFromEnthalpyAndTDryBulb  // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( float64 MoistAirEnthalpy                // (i) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
  , float64 TDryBulb                        // (i) Dry-bulb temperature in °F [IP] or °C [SI]
  )
*/
func GetHumRatioFromEnthalpyAndTDryBulb(MoistAirEnthalpy float64, TDryBulb float64) float64 {
  var HumRatio float64;
  if (isIP()) {
    HumRatio = (MoistAirEnthalpy - 0.240 * TDryBulb) / (1061.0 + 0.444 * TDryBulb);
  } else {
    HumRatio = (MoistAirEnthalpy / 1000.0 - 1.006 * TDryBulb) / (2501.0 + 1.86 * TDryBulb);
  }
  // Validity check.
  return max(HumRatio, MIN_HUM_RATIO);
}


/******************************************************************************************************
 * Saturated Air Calculations
 *****************************************************************************************************/

// Return saturation vapor pressure given dry-bulb temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 & 6
// Important note: the ASHRAE formulae are defined above and below the freezing point but have
// a discontinuity at the freezing point. This is a small inaccuracy on ASHRAE's part: the formulae
// should be defined above and below the triple point of water (not the feezing point) in which case
// the discontinuity vanishes. It is essential to use the triple point of water otherwise function
// GetTDewPointFromVapPres, which inverts the present function, does not converge properly around
// the freezing point.
/*
float64 GetSatVapPres            // (o) Vapor Pressure of saturated air in Psi [IP] or Pa [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  )
*/
func GetSatVapPres(TDryBulb float64) float64 {
  var LnPws, T float64;

  if (isIP()) {
    ASSERT (TDryBulb >= -148. && TDryBulb <= 392., "Dry bulb temperature is outside range [-148, 392]")

    T = GetTRankineFromTFahrenheit(TDryBulb);

    if (TDryBulb <= TRIPLE_POINT_WATER_IP) {
      LnPws = (-1.0214165E+04 / T - 4.8932428 - 5.3765794E-03 * T + 1.9202377E-07 * T * T + 3.5575832E-10 * math.Pow(T, 3) - 9.0344688E-14 * math.Pow(T, 4) + 4.1635019 * math.Log(T));
    } else {
      LnPws = -1.0440397E+04 / T - 1.1294650E+01 - 2.7022355E-02 * T + 1.2890360E-05 * T * T - 2.4780681E-09 * math.Pow(T, 3) + 6.5459673 * math.Log(T);
    }
  } else {
    ASSERT (TDryBulb >= -100. && TDryBulb <= 200., "Dry bulb temperature is outside range [-100, 200]")

    T = GetTKelvinFromTCelsius(TDryBulb);

    if (TDryBulb <= TRIPLE_POINT_WATER_SI) {
      LnPws = -5.6745359E+03 / T + 6.3925247 - 9.677843E-03 * T + 6.2215701E-07 * T * T + 2.0747825E-09 * math.Pow(T, 3) - 9.484024E-13 * math.Pow(T, 4) + 4.1635019 * math.Log(T);
    } else {
      LnPws = -5.8002206E+03 / T + 1.3914993 - 4.8640239E-02 * T + 4.1764768E-05 * T * T - 1.4452093E-08 * math.Pow(T, 3) + 6.5459673 * math.Log(T);
    }
  }

  return math.Exp(LnPws);
}

// Return humidity ratio of saturated air given dry-bulb temperature and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36, solved for W
/*
float64 GetSatHumRatio           // (o) Humidity ratio of saturated air in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetSatHumRatio( TDryBulb float64, Pressure float64) float64 {
  var SatVaporPres, SatHumRatio float64;

  SatVaporPres = GetSatVapPres(TDryBulb);
  SatHumRatio = 0.621945 * SatVaporPres / (Pressure - SatVaporPres);

  // Validity check.
  return max(SatHumRatio, MIN_HUM_RATIO);
}

// Return saturated air enthalpy given dry-bulb temperature and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
/*
float64 GetSatAirEnthalpy        // (o) Saturated air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetSatAirEnthalpy(TDryBulb float64, Pressure float64) float64 {
  return GetMoistAirEnthalpy(TDryBulb, GetSatHumRatio(TDryBulb, Pressure));
}

/******************************************************************************************************
 * Moist Air Calculations
 *****************************************************************************************************/

// Return Vapor pressure deficit given dry-bulb temperature, humidity ratio, and pressure.
// Reference: see Oke (1987) eqn. 2.13a
/*
float64 GetVaporPressureDeficit  // (o) Vapor pressure deficit in Psi [IP] or Pa [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetVaporPressureDeficit(TDryBulb float64, HumRatio float64, Pressure float64) float64 {
  var RelHum float64;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")

  RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
  return GetSatVapPres(TDryBulb) * (1. - RelHum);
}

// Return the degree of saturation (i.e humidity ratio of the air / humidity ratio of the air at saturation
// at the same temperature and pressure) given dry-bulb temperature, humidity ratio, and atmospheric pressure.
// Reference: ASHRAE Handbook - Fundamentals (2009) ch. 1 eqn. 12
// Notes: the definition is absent from the 2017 Handbook
/*
float64 GetDegreeOfSaturation    // (o) Degree of saturation []
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetDegreeOfSaturation(TDryBulb float64, HumRatio float64, Pressure float64) float64 {
  var BoundedHumRatio float64;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

  return BoundedHumRatio / GetSatHumRatio(TDryBulb, Pressure);
}

// Return moist air enthalpy given dry-bulb temperature and humidity ratio.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 30
/*
float64 GetMoistAirEnthalpy      // (o) Moist Air Enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  )
*/
func GetMoistAirEnthalpy(TDryBulb float64, HumRatio float64) float64 {
  var BoundedHumRatio float64;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

  if (isIP()) {
    return 0.240 * TDryBulb + BoundedHumRatio*(1061. + 0.444 * TDryBulb);
  } else {
    return (1.006 * TDryBulb + BoundedHumRatio*(2501. + 1.86 * TDryBulb)) * 1000.;
  }
}

// Return moist air specific volume given dry-bulb temperature, humidity ratio, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 26
// Notes: in IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26.
// The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².
/*
float64 GetMoistAirVolume        // (o) Specific Volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetMoistAirVolume(TDryBulb float64, HumRatio float64, Pressure float64) float64 {
  var BoundedHumRatio float64;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

  if (isIP()) {
    return R_DA_IP * GetTRankineFromTFahrenheit(TDryBulb) * (1. + 1.607858 * BoundedHumRatio) / (144. * Pressure);
  } else {
    return R_DA_SI * GetTKelvinFromTCelsius(TDryBulb) * (1. + 1.607858 * BoundedHumRatio) / Pressure;
  }
}

// Return dry-bulb temperature given moist air specific volume, humidity ratio, and pressure.
// Reference:
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26
// Notes:
// In IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26
// The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².
// Based on the `GetMoistAirVolume` function, rearranged for dry-bulb temperature.
/*
float64 GetTDryBulbFromMoistAirVolumeAndHumRatio   // (o) Dry-bulb temperature in °F [IP] or °C [SI]
  ( float64 MoistAirVolume                         // (i) Specific volume of moist air in ft³ lb⁻¹ of dry air [IP] or in m³ kg⁻¹ of dry air [SI]
  , float64 HumRatio                               // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , float64 Pressure                               // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetTDryBulbFromMoistAirVolumeAndHumRatio(MoistAirVolume float64, HumRatio float64, Pressure float64) float64 {
  var BoundedHumRatio float64;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

  if (isIP()) {
    return GetTFahrenheitFromTRankine(MoistAirVolume * (144 * Pressure) / (R_DA_IP * (1 + 1.607858 * BoundedHumRatio)));
  } else {
    return  GetTCelsiusFromTKelvin(MoistAirVolume * Pressure / (R_DA_SI * (1 + 1.607858 * BoundedHumRatio)));
  }
}

// Return moist air density given humidity ratio, dry bulb temperature, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 11
/*
float64 GetMoistAirDensity       // (o) Moist air density in lb ft⁻³ [IP] or kg m⁻³ [SI]
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  )
*/
func GetMoistAirDensity(TDryBulb float64, HumRatio float64, Pressure float64) float64 {
  var BoundedHumRatio float64;

  ASSERT (HumRatio >= 0., "Humidity ratio is negative")
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

  return (1. + BoundedHumRatio) / GetMoistAirVolume(TDryBulb, BoundedHumRatio, Pressure);
}


/******************************************************************************************************
 * Standard atmosphere
 *****************************************************************************************************/


// Return standard atmosphere barometric pressure, given the elevation (altitude).
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 3
/*
float64 GetStandardAtmPressure   // (o) Standard atmosphere barometric pressure in Psi [IP] or Pa [SI]
  ( float64 Altitude             // (i) Altitude in ft [IP] or m [SI]
  )
*/
func GetStandardAtmPressure( Altitude float64) float64 {
  var Pressure float64;
  if (isIP()) {
    Pressure = 14.696 * math.Pow(1. - 6.8754e-06 * Altitude, 5.2559);
  } else {
    Pressure = 101325. * math.Pow(1. - 2.25577e-05 * Altitude, 5.2559);
  }
  return Pressure;
}

// Return standard atmosphere temperature, given the elevation (altitude).
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 4
/*
float64 GetStandardAtmTemperature // (o) Standard atmosphere dry bulb temperature in °F [IP] or °C [SI]
  ( float64 Altitude              // (i) Altitude in ft [IP] or m [SI]
  )
*/
func GetStandardAtmTemperature(Altitude float64) float64 {
  var Temperature float64;
  if (isIP()) {
    Temperature = 59. - 0.00356620 * Altitude;
  } else {
    Temperature = 15. - 0.0065 * Altitude;
  }
  return Temperature;
}

// Return sea level pressure given dry-bulb temperature, altitude above sea level and pressure.
// Reference: Hess SL, Introduction to theoretical meteorology, Holt Rinehart and Winston, NY 1959,
// ch. 6.5; Stull RB, Meteorology for scientists and engineers, 2nd edition,
// Brooks/Cole 2000, ch. 1.
// Notes: the standard procedure for the US is to use for TDryBulb the average
// of the current station temperature and the station temperature from 12 hours ago.
/*
float64 GetSeaLevelPressure   // (o) Sea level barometric pressure in Psi [IP] or Pa [SI]
  ( float64 StnPressure       // (i) Observed station pressure in Psi [IP] or Pa [SI]
  , float64 Altitude          // (i) Altitude above sea level in ft [IP] or m [SI]
  , float64 TDryBulb          // (i) Dry bulb temperature ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  )
*/
func GetSeaLevelPressure( StnPressure float64, Altitude float64, TDryBulb float64) float64 {
  var TColumn, H float64;
  if (isIP()) {
    // Calculate average temperature in column of air, assuming a lapse rate
    // of 3.6 °F/1000ft
    TColumn = TDryBulb + 0.0036 * Altitude / 2.;

    // Determine the scale height
    H = 53.351 * GetTRankineFromTFahrenheit(TColumn);
  } else {
    // Calculate average temperature in column of air, assuming a lapse rate
    // of 6.5 °C/km
    TColumn = TDryBulb + 0.0065 * Altitude / 2.;

    // Determine the scale height
    H = 287.055 * GetTKelvinFromTCelsius(TColumn) / 9.807;
  }

  // Calculate the sea level pressure
  SeaLevelPressure := StnPressure * math.Exp(Altitude / H);
  return SeaLevelPressure;
}

// Return station pressure from sea level pressure
// Reference: see 'GetSeaLevelPressure'
// Notes: this function is just the inverse of 'GetSeaLevelPressure'.
/*
float64 GetStationPressure    // (o) Station pressure in Psi [IP] or Pa [SI]
  ( float64 SeaLevelPressure  // (i) Sea level barometric pressure in Psi [IP] or Pa [SI]
  , float64 Altitude          // (i) Altitude above sea level in ft [IP] or m [SI]
  , float64 TDryBulb          // (i) Dry bulb temperature in °F [IP] or °C [SI]
  )
*/
func GetStationPressure( SeaLevelPressure float64, Altitude float64, TDryBulb float64) float64 {
  return SeaLevelPressure / GetSeaLevelPressure(1., Altitude, TDryBulb);
}


/******************************************************************************************************
 * Functions to set all psychrometric values
 *****************************************************************************************************/

// Utility function to calculate humidity ratio, dew-point temperature, relative humidity,
// vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
// dry-bulb temperature, wet-bulb temperature, and pressure.
/*
void CalcPsychrometricsFromTWetBulb
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 TWetBulb             // (i) Wet bulb temperature in °F [IP] or °C [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  , float64 *HumRatio            // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , float64 *TDewPoint           // (o) Dew point temperature in °F [IP] or °C [SI]
  , float64 *RelHum              // (o) Relative humidity [0-1]
  , float64 *VapPres             // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  , float64 *MoistAirEnthalpy    // (o) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  , float64 *MoistAirVolume      // (o) Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  , float64 *DegreeOfSaturation  // (o) Degree of saturation [unitless]
)
*/
func CalcPsychrometricsFromTWetBulb(TDryBulb, TWetBulb, Pressure float64) (HumRatio, TDewPoint, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation float64) {
  ASSERT (TWetBulb <= TDryBulb, "Wet bulb temperature is above dry bulb temperature")

  HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
  TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);
  RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure);
  MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio);
  MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure);
  DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure);
  return
}

// Utility function to calculate humidity ratio, wet-bulb temperature, relative humidity,
// vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
// dry-bulb temperature, dew-point temperature, and pressure.
/*
void CalcPsychrometricsFromTDewPoint
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  , float64 *HumRatio            // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , float64 *TWetBulb            // (o) Wet bulb temperature in °F [IP] or °C [SI]
  , float64 *RelHum              // (o) Relative humidity [0-1]
  , float64 *VapPres             // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  , float64 *MoistAirEnthalpy    // (o) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  , float64 *MoistAirVolume      // (o) Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  , float64 *DegreeOfSaturation  // (o) Degree of saturation [unitless]
)
*/
func CalcPsychrometricsFromTDewPoint(TDryBulb, TDewPoint, Pressure float64) (HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation float64) {
  ASSERT (TDewPoint <= TDryBulb, "Dew point temperature is above dry bulb temperature")
  
  HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure);
  TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
  RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure);
  MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio);
  MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure);
  DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure);
  return
}

// Utility function to calculate humidity ratio, wet-bulb temperature, dew-point temperature,
// vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
// dry-bulb temperature, relative humidity and pressure.
/*
void CalcPsychrometricsFromRelHum
  ( float64 TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , float64 RelHum               // (i) Relative humidity [0-1]
  , float64 Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  , float64 *HumRatio            // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , float64 *TWetBulb            // (o) Wet bulb temperature in °F [IP] or °C [SI]
  , float64 *TDewPoint           // (o) Dew point temperature in °F [IP] or °C [SI]
  , float64 *VapPres             // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  , float64 *MoistAirEnthalpy    // (o) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  , float64 *MoistAirVolume      // (o) Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  , float64 *DegreeOfSaturation  // (o) Degree of saturation [unitless]
)
*/
func CalcPsychrometricsFromRelHum(TDryBulb, RelHum, Pressure float64) (HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation float64) {
  ASSERT (RelHum >= 0 && RelHum <= 1, "Relative humidity is outside range [0,1]")

  HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure);
  TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
  TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);
  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure);
  MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio);
  MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure);
  DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure);
  return
}
