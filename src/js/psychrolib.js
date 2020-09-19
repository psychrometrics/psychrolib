/*
 * PsychroLib (version 2.5.0) (https://github.com/psychrometrics/psychrolib).
 * Copyright (c) 2018-2020 The PsychroLib Contributors for the current library implementation.
 * Copyright (c) 2017 ASHRAE Handbook — Fundamentals for ASHRAE equations and coefficients.
 * Licensed under the MIT License.
 */

function Psychrometrics() {
  /**
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
   * Example (e.g. Node.JS)
   *  // Import the PsychroLib
   *  var psychrolib = require('./psychrolib.js')
   *  // Set unit system
   *  psychrolib.SetUnitSystem(psychrolib.SI)
   *  // Calculate the dew point temperature for a dry bulb temperature of 25 C and a relative humidity of 80%
   *  var TDewPoint = psychrolib.GetTDewPointFromRelHum(25.0, 0.80);
   *  console.log('TDewPoint: %d', TDewPoint);
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


  // Standard functions
  var log = Math.log;
  var exp = Math.exp;
  var pow = Math.pow;
  var min = Math.min;
  var max = Math.max;
  var abs = Math.abs;


  /******************************************************************************************************
   * Global constants
   *****************************************************************************************************/

  var ZERO_FAHRENHEIT_AS_RANKINE = 459.67;  // Zero degree Fahrenheit (°F) expressed as degree Rankine (°R).
                                            // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 39.

  var ZERO_CELSIUS_AS_KELVIN = 273.15;      // Zero degree Celsius (°C) expressed as Kelvin (K).
                                            // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 39.

  var R_DA_IP = 53.350;               // Universal gas constant for dry air (IP version) in ft lb_Force lb_DryAir⁻¹ R⁻¹.
                                      // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1.

  var R_DA_SI = 287.042;              // Universal gas constant for dry air (SI version) in J kg_DryAir⁻¹ K⁻¹.
                                      // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1.

  var INVALID = -99999;               // Invalid value (dimensionless).

  var MAX_ITER_COUNT = 100            // Maximum number of iterations before exiting while loops.

  var MIN_HUM_RATIO = 1e-7            // Minimum acceptable humidity ratio used/returned by any functions.
                                      // Any value above 0 or below the MIN_HUM_RATIO will be reset to this value.

  var FREEZING_POINT_WATER_IP = 32.0  // Freezing point of water in Fahrenheit.

  var FREEZING_POINT_WATER_SI = 0.0   // Freezing point of water in Celsius.

  var TRIPLE_POINT_WATER_IP = 32.018  // Triple point of water in Fahrenheit.

  var TRIPLE_POINT_WATER_SI = 0.01    // Triple point of water in Celsius.



  /******************************************************************************************************
   * Helper functions
   *****************************************************************************************************/

  // Systems of units (IP or SI)
  var PSYCHROLIB_UNITS = undefined;

  this.IP = 1;
  this.SI = 2;

  // Function to set the system of units
  // Note: this function *HAS TO BE CALLED* before the library can be used
  this.SetUnitSystem = function(UnitSystem) {
    if (UnitSystem != this.IP && UnitSystem != this.SI) {
      throw new Error('UnitSystem must be IP or SI');
    }
    PSYCHROLIB_UNITS = UnitSystem;
    // Define tolerance of temperature calculations
    // The tolerance is the same in IP and SI
    if (PSYCHROLIB_UNITS == this.IP)
      PSYCHROLIB_TOLERANCE = 0.001 * 9. / 5.;
    else
      PSYCHROLIB_TOLERANCE = 0.001;
  }

  // Return system of units in use.
  this.GetUnitSystem = function() {
    return PSYCHROLIB_UNITS;
  }

  // Function to check if the current system of units is SI or IP
  // The function exits in error if the system of units is undefined
  this.isIP = function() {
    if (PSYCHROLIB_UNITS == this.IP)
      return true;
    else if (PSYCHROLIB_UNITS == this.SI)
      return false;
    else
      throw new Error("Unit system is not defined");
  }


  /******************************************************************************************************
   * Conversion between temperature units
   *****************************************************************************************************/

  // Utility function to convert temperature to degree Rankine (°R)
  // given temperature in degree Fahrenheit (°F).
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
  this.GetTRankineFromTFahrenheit = function (T_F) { return T_F + ZERO_FAHRENHEIT_AS_RANKINE; }       /* exact */

  // Utility function to convert temperature to degree Fahrenheit (°F)
  // given temperature in degree Rankine (°R).
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
  this.GetTFahrenheitFromTRankine = function (T_R) { return T_R - ZERO_FAHRENHEIT_AS_RANKINE; }       /* exact */

  // Utility function to convert temperature to Kelvin (K)
  // given temperature in degree Celsius (°C).
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
  this.GetTKelvinFromTCelsius = function (T_C) { return T_C + ZERO_CELSIUS_AS_KELVIN; }               /* exact */

  // Utility function to convert temperature to degree Celsius (°C)
  // given temperature in Kelvin (K).
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
  this.GetTCelsiusFromTKelvin = function (T_K) { return T_K - ZERO_CELSIUS_AS_KELVIN; }                /* exact */

  /******************************************************************************************************
   * Conversions between dew point, wet bulb, and relative humidity
   *****************************************************************************************************/

  // Return wet-bulb temperature given dry-bulb temperature, dew-point temperature, and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
  this.GetTWetBulbFromTDewPoint = function  // (o) Wet bulb temperature in °F [IP] or °C [SI]
    ( TDryBulb                              // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , TDewPoint                             // (i) Dew point temperature in °F [IP] or °C [SI]
    , Pressure                              // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var HumRatio;

    if (!(TDewPoint <= TDryBulb))
      throw new Error("Dew point temperature is above dry bulb temperature");

    HumRatio = this.GetHumRatioFromTDewPoint(TDewPoint, Pressure);
    return this.GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
  }

  // Return wet-bulb temperature given dry-bulb temperature, relative humidity, and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
  this.GetTWetBulbFromRelHum = function // (o) Wet bulb temperature in °F [IP] or °C [SI]
    ( TDryBulb                          // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , RelHum                            // (i) Relative humidity [0-1]
    , Pressure                          // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var HumRatio;

    if (!(RelHum >= 0. && RelHum <= 1.))
      throw new Error("Relative humidity is outside range [0,1]");

    HumRatio = this.GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure);
    return this.GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
  }

  // Return relative humidity given dry-bulb temperature and dew-point temperature.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 22
  this.GetRelHumFromTDewPoint = function  // (o) Relative humidity [0-1]
    ( TDryBulb                            // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , TDewPoint                           // (i) Dew point temperature in °F [IP] or °C [SI]
    ) {
    var VapPres, SatVapPres;

    if (!(TDewPoint <= TDryBulb))
      throw new Error("Dew point temperature is above dry bulb temperature");

    VapPres = this.GetSatVapPres(TDewPoint);
    SatVapPres = this.GetSatVapPres(TDryBulb);
    return VapPres / SatVapPres;
  }

  // Return relative humidity given dry-bulb temperature, wet bulb temperature and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
  this.GetRelHumFromTWetBulb = function // (o) Relative humidity [0-1]
    ( TDryBulb                          // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , TWetBulb                          // (i) Wet bulb temperature in °F [IP] or °C [SI]
    , Pressure                          // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var HumRatio;

    if (!(TWetBulb <= TDryBulb))
      throw new Error("Wet bulb temperature is above dry bulb temperature");

    HumRatio = this.GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
    return this.GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
  }

  // Return dew-point temperature given dry-bulb temperature and relative humidity.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
  this.GetTDewPointFromRelHum = function  // (o) Dew Point temperature in °F [IP] or °C [SI]
    ( TDryBulb                            // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , RelHum                              // (i) Relative humidity [0-1]
    ) {
    var VapPres;

    if (!(RelHum >= 0. && RelHum <= 1.))
      throw new Error("Relative humidity is outside range [0,1]");

    VapPres = this.GetVapPresFromRelHum(TDryBulb, RelHum);
    return this.GetTDewPointFromVapPres(TDryBulb, VapPres);
  }

  // Return dew-point temperature given dry-bulb temperature, wet-bulb temperature, and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
  this.GetTDewPointFromTWetBulb = function  // (o) Dew Point temperature in °F [IP] or °C [SI]
    ( TDryBulb                              // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , TWetBulb                              // (i) Wet bulb temperature in °F [IP] or °C [SI]
    , Pressure                              // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var HumRatio;

    if (!(TWetBulb <= TDryBulb))
      throw new Error("Wet bulb temperature is above dry bulb temperature");

    HumRatio = this.GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
    return this.GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);
  }


  /******************************************************************************************************
   * Conversions between dew point, or relative humidity and vapor pressure
   *****************************************************************************************************/

  // Return partial pressure of water vapor as a function of relative humidity and temperature.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
  this.GetVapPresFromRelHum = function  // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
    ( TDryBulb                          // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , RelHum                            // (i) Relative humidity [0-1]
    ) {

    if (!(RelHum >= 0. && RelHum <= 1.))
      throw new Error("Relative humidity is outside range [0,1]");

    return RelHum * this.GetSatVapPres(TDryBulb);
  }

  // Return relative humidity given dry-bulb temperature and vapor pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
  this.GetRelHumFromVapPres = function  // (o) Relative humidity [0-1]
    ( TDryBulb                          // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , VapPres                           // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
    ) {

    if (!(VapPres >= 0.))
      throw new Error("Partial pressure of water vapor in moist air is negative");

    return VapPres / this.GetSatVapPres(TDryBulb);
  }

  // Helper function returning the derivative of the natural log of the saturation vapor pressure
  // as a function of dry-bulb temperature.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 & 6
  this.dLnPws_ = function       // (o)  Derivative of natural log of vapor pressure of saturated air in Psi [IP] or Pa [SI]
    ( TDryBulb                  // (i) Dry bulb temperature in °F [IP] or °C [SI]
    ) {
    var dLnPws, T;

    if (this.isIP())
    {
      T = this.GetTRankineFromTFahrenheit(TDryBulb);

      if (TDryBulb <= TRIPLE_POINT_WATER_IP)
        dLnPws = 1.0214165E+04 / pow(T, 2) - 5.3765794E-03 + 2 * 1.9202377E-07 * T
                 + 3 * 3.5575832E-10 * pow(T, 2) - 4 * 9.0344688E-14 * pow(T, 3) + 4.1635019 / T;
      else
        dLnPws = 1.0440397E+04 / pow(T, 2) - 2.7022355E-02 + 2 * 1.2890360E-05 * T
                 - 3 * 2.4780681E-09 * pow(T, 2) + 6.5459673 / T;
    }
    else
    {
      T = this.GetTKelvinFromTCelsius(TDryBulb);

      if (TDryBulb <= TRIPLE_POINT_WATER_SI)
        dLnPws = 5.6745359E+03 / pow(T, 2) - 9.677843E-03 + 2 * 6.2215701E-07 * T
                 + 3 * 2.0747825E-09 * pow(T, 2) - 4 * 9.484024E-13 * pow(T, 3) + 4.1635019 / T;
      else
        dLnPws = 5.8002206E+03 / pow(T, 2) - 4.8640239E-02 + 2 * 4.1764768E-05 * T
                 - 3 * 1.4452093E-08 * pow(T, 2) + 6.5459673 / T;
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
  this.GetTDewPointFromVapPres = function // (o) Dew Point temperature in °F [IP] or °C [SI]
    ( TDryBulb                            // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , VapPres                             // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
    ) {
   // Bounds function of the system of units
  var BOUNDS              // Domain of validity of the equations

  if (this.isIP())
  {
    BOUNDS = [-148., 392.];   // Domain of validity of the equations
  }
  else
  {
    BOUNDS = [-100., 200.];   // Domain of validity of the equations
  }

  // Bounds outside which a solution cannot be found
  if (VapPres < this.GetSatVapPres(BOUNDS[0]) || VapPres > this.GetSatVapPres(BOUNDS[1]))
    throw new Error("Partial pressure of water vapor is outside range of validity of equations");

  // We use NR to approximate the solution.
  // First guess
  var TDewPoint = TDryBulb;      // Calculated value of dew point temperatures, solved for iteratively in °F [IP] or °C [SI]
  var lnVP = log(VapPres);       // Natural logarithm of partial pressure of water vapor pressure in moist air

  var TDewPoint_iter;            // Value of TDewPoint used in NR calculation
  var lnVP_iter;                 // Value of log of vapor water pressure used in NR calculation
  var index = 1;
  do
  {
    // Current point
    TDewPoint_iter = TDewPoint;
    lnVP_iter = log(this.GetSatVapPres(TDewPoint_iter));

    // Derivative of function, calculated analytically
    var d_lnVP = this.dLnPws_(TDewPoint_iter);

    // New estimate, bounded by domain of validity of eqn. 5 and 6
    TDewPoint = TDewPoint_iter - (lnVP_iter - lnVP) / d_lnVP;
    TDewPoint = max(TDewPoint, BOUNDS[0]);
    TDewPoint = min(TDewPoint, BOUNDS[1]);

    if (index > MAX_ITER_COUNT)
      throw new Error("Convergence not reached in GetTDewPointFromVapPres. Stopping.");

    index++;
  }
  while (abs(TDewPoint - TDewPoint_iter) > PSYCHROLIB_TOLERANCE);
  return min(TDewPoint, TDryBulb);
  }

  // Return vapor pressure given dew point temperature.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 36
  this.GetVapPresFromTDewPoint = function // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
    ( TDewPoint                           // (i) Dew point temperature in °F [IP] or °C [SI]
    ) {
    return this.GetSatVapPres(TDewPoint);
  }


  /******************************************************************************************************
   * Conversions from wet-bulb temperature, dew-point temperature, or relative humidity to humidity ratio
   *****************************************************************************************************/

  // Return wet-bulb temperature given dry-bulb temperature, humidity ratio, and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35 solved for Tstar
  this.GetTWetBulbFromHumRatio = function // (o) Wet bulb temperature in °F [IP] or °C [SI]
    ( TDryBulb                            // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , HumRatio                            // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    , Pressure                            // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    // Declarations
    var Wstar;
    var TDewPoint, TWetBulb, TWetBulbSup, TWetBulbInf, BoundedHumRatio;
    var index = 1;

    if (!(HumRatio >= 0.))
      throw new Error("Humidity ratio is negative");
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

    TDewPoint = this.GetTDewPointFromHumRatio(TDryBulb, BoundedHumRatio, Pressure);

    // Initial guesses
    TWetBulbSup = TDryBulb;
    TWetBulbInf = TDewPoint;
    TWetBulb = (TWetBulbInf + TWetBulbSup) / 2.;

    // Bisection loop
    while ((TWetBulbSup - TWetBulbInf) > PSYCHROLIB_TOLERANCE) {
      // Compute humidity ratio at temperature Tstar
      Wstar = this.GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);

      // Get new bounds
      if (Wstar > BoundedHumRatio)
        TWetBulbSup = TWetBulb;
      else
        TWetBulbInf = TWetBulb;

      // New guess of wet bulb temperature
      TWetBulb = (TWetBulbSup + TWetBulbInf) / 2.;

      if (index > MAX_ITER_COUNT)
        throw new Error("Convergence not reached in GetTWetBulbFromHumRatio. Stopping.");

      index++;
    }

    return TWetBulb;
  }

  // Return humidity ratio given dry-bulb temperature, wet-bulb temperature, and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35
  this.GetHumRatioFromTWetBulb = function // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    ( TDryBulb                            // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , TWetBulb                            // (i) Wet bulb temperature in °F [IP] or °C [SI]
    , Pressure                            // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var Wsstar;
    HumRatio = INVALID

    if (!(TWetBulb <= TDryBulb))
      throw new Error("Wet bulb temperature is above dry bulb temperature");

      Wsstar = this.GetSatHumRatio(TWetBulb, Pressure);

      if (this.isIP())
      {
        if (TWetBulb >= FREEZING_POINT_WATER_IP)
          HumRatio = ((1093. - 0.556 * TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb))
          / (1093. + 0.444 * TDryBulb - TWetBulb);
        else
          HumRatio = ((1220. - 0.04 * TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb))
          / (1220. + 0.444 * TDryBulb - 0.48 * TWetBulb);
      }
      else
      {
        if (TWetBulb >= FREEZING_POINT_WATER_SI)
          HumRatio = ((2501. - 2.326 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb))
             / (2501. + 1.86 * TDryBulb - 4.186 * TWetBulb);
        else
          HumRatio = ((2830. - 0.24 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb))
             / (2830. + 1.86 * TDryBulb - 2.1 * TWetBulb);
      }
      // Validity check.
      return max(HumRatio, MIN_HUM_RATIO);
    }

  // Return humidity ratio given dry-bulb temperature, relative humidity, and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
  this.GetHumRatioFromRelHum = function // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    ( TDryBulb                          // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , RelHum                            // (i) Relative humidity [0-1]
    , Pressure                          // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var VapPres;

    if (!(RelHum >= 0. && RelHum <= 1.))
      throw new Error("Relative humidity is outside range [0,1]");

    VapPres = this.GetVapPresFromRelHum(TDryBulb, RelHum);
    return this.GetHumRatioFromVapPres(VapPres, Pressure);
  }

  // Return relative humidity given dry-bulb temperature, humidity ratio, and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
  this.GetRelHumFromHumRatio = function // (o) Relative humidity [0-1]
    ( TDryBulb                          // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , HumRatio                          // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    , Pressure                          // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var VapPres;

    if (!(HumRatio >= 0.))
      throw new Error("Humidity ratio is negative");

    VapPres = this.GetVapPresFromHumRatio(HumRatio, Pressure);
    return this.GetRelHumFromVapPres(TDryBulb, VapPres);
  }

  // Return humidity ratio given dew-point temperature and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
  this.GetHumRatioFromTDewPoint = function  // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    ( TDewPoint                             // (i) Dew point temperature in °F [IP] or °C [SI]
    , Pressure                              // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var VapPres;

    VapPres = this.GetSatVapPres(TDewPoint);
    return this.GetHumRatioFromVapPres(VapPres, Pressure);
  }

  // Return dew-point temperature given dry-bulb temperature, humidity ratio, and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
  this.GetTDewPointFromHumRatio = function  // (o) Dew Point temperature in °F [IP] or °C [SI]
    ( TDryBulb                              // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , HumRatio                              // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    , Pressure                              // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var VapPres;

    if (!(HumRatio >= 0.))
      throw new Error("Humidity ratio is negative");

    VapPres = this.GetVapPresFromHumRatio(HumRatio, Pressure);
    return this.GetTDewPointFromVapPres(TDryBulb, VapPres);
  }


  /******************************************************************************************************
   * Conversions between humidity ratio and vapor pressure
   *****************************************************************************************************/

  // Return humidity ratio given water vapor pressure and atmospheric pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20
  this.GetHumRatioFromVapPres = function  // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    ( VapPres                             // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
    , Pressure                            // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var HumRatio;

    if (!(VapPres >= 0.))
      throw new Error("Partial pressure of water vapor in moist air is negative");

    HumRatio = 0.621945 * VapPres / (Pressure - VapPres);

    // Validity check.
    return max(HumRatio, MIN_HUM_RATIO);
  }

  // Return vapor pressure given humidity ratio and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20 solved for pw
  this.GetVapPresFromHumRatio = function  // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
    ( HumRatio                            // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    , Pressure                            // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var VapPres, BoundedHumRatio;

    if (!(HumRatio >= 0.))
      throw new Error("Humidity ratio is negative");
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

    VapPres = Pressure * BoundedHumRatio / (0.621945 + BoundedHumRatio);
    return VapPres;
  }


  /******************************************************************************************************
   * Conversions between humidity ratio and specific humidity
   *****************************************************************************************************/

  // Return the specific humidity from humidity ratio (aka mixing ratio)
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b
  this.GetSpecificHumFromHumRatio = function  // (o) Specific humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    ( HumRatio                                // (i) Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]
    ) {
    var BoundedHumRatio;
    if (!(HumRatio >= 0.))
      throw new Error("Humidity ratio is negative");
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

    return BoundedHumRatio / (1.0 + BoundedHumRatio);
  }

  // Return the humidity ratio (aka mixing ratio) from specific humidity
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b (solved for humidity ratio)
  this.GetHumRatioFromSpecificHum = function  // (o) Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]
    ( SpecificHum                             // (i) Specific humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    ) {
    var HumRatio;

    if (!(SpecificHum >= 0.0 && SpecificHum < 1.0))
      throw new Error("Specific humidity is outside range [0, 1)");

    HumRatio = SpecificHum / (1.0 - SpecificHum);

    // Validity check
    return max(HumRatio, MIN_HUM_RATIO);
  }


  /******************************************************************************************************
   * Dry Air Calculations
   *****************************************************************************************************/

  // Return dry-air enthalpy given dry-bulb temperature.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 28
  this.GetDryAirEnthalpy = function // (o) Dry air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
    ( TDryBulb                      // (i) Dry bulb temperature in °F [IP] or °C [SI]
    ) {
    if (this.isIP())
      return 0.240 * TDryBulb;
    else
      return 1006. * TDryBulb;
  }

  // Return dry-air density given dry-bulb temperature and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
  // Notes: eqn 14 for the perfect gas relationship for dry air.
  // Eqn 1 for the universal gas constant.
  // The factor 144 in IP is for the conversion of Psi = lb in⁻² to lb ft⁻².
  this.GetDryAirDensity = function  // (o) Dry air density in lb ft⁻³ [IP] or kg m⁻³ [SI]
    ( TDryBulb                      // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , Pressure                      // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    if (this.isIP())
      return (144. * Pressure) / R_DA_IP / this.GetTRankineFromTFahrenheit(TDryBulb);
    else
      return Pressure / R_DA_SI / this.GetTKelvinFromTCelsius(TDryBulb);
  }

  // Return dry-air volume given dry-bulb temperature and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1.
  // Notes: eqn 14 for the perfect gas relationship for dry air.
  // Eqn 1 for the universal gas constant.
  // The factor 144 in IP is for the conversion of Psi = lb in⁻² to lb ft⁻².
  this.GetDryAirVolume = function // (o) Dry air volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
    ( TDryBulb                    // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , Pressure                    // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    if (this.isIP())
      return R_DA_IP * this.GetTRankineFromTFahrenheit(TDryBulb) / (144. * Pressure);
    else
      return R_DA_SI * this.GetTKelvinFromTCelsius(TDryBulb) / Pressure;
  }

  // Return dry bulb temperature from enthalpy and humidity ratio.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30.
  // Notes: based on the `GetMoistAirEnthalpy` function, rearranged for temperature.
  this.GetTDryBulbFromEnthalpyAndHumRatio = function   // (o) Dry-bulb temperature in °F [IP] or °C [SI]
    ( MoistAirEnthalpy                                 // (i) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
    , HumRatio                                         // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    ) {
    var BoundedHumRatio;
    if (!(HumRatio >= 0.))
      throw new Error("Humidity ratio is negative");
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

    if (this.isIP())
      return (MoistAirEnthalpy - 1061.0 * BoundedHumRatio) / (0.240 + 0.444 * BoundedHumRatio);
    else
      return (MoistAirEnthalpy / 1000.0 - 2501.0 * BoundedHumRatio) / (1.006 + 1.86 * BoundedHumRatio);
    }

  // Return humidity ratio from enthalpy and dry-bulb temperature.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30.
  // Notes: based on the `GetMoistAirEnthalpy` function, rearranged for humidity ratio.
  this.GetHumRatioFromEnthalpyAndTDryBulb = function   // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻
    ( MoistAirEnthalpy                                 // (i) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
    , TDryBulb                                         // (i) Dry-bulb temperature in °F [IP] or °C [SI]
    ) {
    var HumRatio;
    if (this.isIP())
      HumRatio = (MoistAirEnthalpy - 0.240 * TDryBulb) / (1061.0 + 0.444 * TDryBulb);
    else
      HumRatio = (MoistAirEnthalpy / 1000.0 - 1.006 * TDryBulb) / (2501.0 + 1.86 * TDryBulb);

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
  this.GetSatVapPres = function // (o) Vapor Pressure of saturated air in Psi [IP] or Pa [SI]
    ( TDryBulb                  // (i) Dry bulb temperature in °F [IP] or °C [SI]
    ) {
    var LnPws, T;

    if (this.isIP())
    {
      if (!(TDryBulb >= -148. && TDryBulb <= 392.))
        throw new Error("Dry bulb temperature is outside range [-148, 392]");

      T = this.GetTRankineFromTFahrenheit(TDryBulb);
      if (TDryBulb <= TRIPLE_POINT_WATER_IP)
        LnPws = (-1.0214165E+04 / T - 4.8932428 - 5.3765794E-03 * T + 1.9202377E-07 * T * T
                + 3.5575832E-10 * pow(T, 3) - 9.0344688E-14 * pow(T, 4) + 4.1635019 * log(T));
      else
        LnPws = -1.0440397E+04 / T - 1.1294650E+01 - 2.7022355E-02 * T + 1.2890360E-05 * T * T
                - 2.4780681E-09 * pow(T, 3) + 6.5459673 * log(T);
    }
    else
    {
      if (!(TDryBulb >= -100. && TDryBulb <= 200.))
        throw new Error("Dry bulb temperature is outside range [-100, 200]");

      T = this.GetTKelvinFromTCelsius(TDryBulb);
      if (TDryBulb <= TRIPLE_POINT_WATER_SI)
        LnPws = -5.6745359E+03 / T + 6.3925247 - 9.677843E-03 * T + 6.2215701E-07 * T * T
                + 2.0747825E-09 * pow(T, 3) - 9.484024E-13 * pow(T, 4) + 4.1635019 * log(T);
      else
        LnPws = -5.8002206E+03 / T + 1.3914993 - 4.8640239E-02 * T + 4.1764768E-05 * T * T
                - 1.4452093E-08 * pow(T, 3) + 6.5459673 * log(T);
    }

    return exp(LnPws);
  }

  // Return humidity ratio of saturated air given dry-bulb temperature and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36, solved for W
  this.GetSatHumRatio = function  // (o) Humidity ratio of saturated air in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    ( TDryBulb                    // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , Pressure                    // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var SatVaporPres, SatHumRatio;

    SatVaporPres = this.GetSatVapPres(TDryBulb);
    SatHumRatio = 0.621945 * SatVaporPres / (Pressure - SatVaporPres);

    // Validity check.
    return max(SatHumRatio, MIN_HUM_RATIO);
  }

  // Return saturated air enthalpy given dry-bulb temperature and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
  this.GetSatAirEnthalpy = function // (o) Saturated air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
    ( TDryBulb                      // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , Pressure                      // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    return this.GetMoistAirEnthalpy(TDryBulb, this.GetSatHumRatio(TDryBulb, Pressure));
  }


  /******************************************************************************************************
   * Moist Air Calculations
   *****************************************************************************************************/

  // Return Vapor pressure deficit given dry-bulb temperature, humidity ratio, and pressure.
  // Reference: see Oke (1987) eqn. 2.13a
  this.GetVaporPressureDeficit = function  // (o) Vapor pressure deficit in Psi [IP] or Pa [SI]
    ( TDryBulb            // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , HumRatio            // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    , Pressure            // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var RelHum;

    if (!(HumRatio >= 0.))
      throw new Error("Humidity ratio is negative");

    RelHum = this.GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
    return this.GetSatVapPres(TDryBulb) * (1. - RelHum);
  }

  // Return the degree of saturation (i.e humidity ratio of the air / humidity ratio of the air at saturation
  // at the same temperature and pressure) given dry-bulb temperature, humidity ratio, and atmospheric pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2009) ch. 1 eqn. 12
  // Notes: the definition is absent from the 2017 Handbook
  this.GetDegreeOfSaturation = function // (o) Degree of saturation (unitless)
    ( TDryBulb                          // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , HumRatio                          // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    , Pressure                          // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var BoundedHumRatio;

    if (!(HumRatio >= 0.))
      throw new Error("Humidity ratio is negative");
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

    return BoundedHumRatio / this.GetSatHumRatio(TDryBulb, Pressure);
  }

  // Return moist air enthalpy given dry-bulb temperature and humidity ratio.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 30
  this.GetMoistAirEnthalpy = function // (o) Moist Air Enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
    ( TDryBulb                        // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , HumRatio                        // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    ) {
    var BoundedHumRatio;

    if (!(HumRatio >= 0.))
      throw new Error("Humidity ratio is negative");
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

    if (this.isIP())
      return 0.240 * TDryBulb + BoundedHumRatio * (1061. + 0.444 * TDryBulb);
    else
      return (1.006 * TDryBulb + BoundedHumRatio * (2501. + 1.86 * TDryBulb)) * 1000.;
  }

  // Return moist air specific volume given dry-bulb temperature, humidity ratio, and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 26
  // Notes: in IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26.
  // The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².
  this.GetMoistAirVolume = function // (o) Specific Volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
    ( TDryBulb                      // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , HumRatio                      // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    , Pressure                      // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var BoundedHumRatio;

    if (!(HumRatio >= 0.))
      throw new Error("Humidity ratio is negative");
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

    if (this.isIP())
      return R_DA_IP * this.GetTRankineFromTFahrenheit(TDryBulb) * (1. + 1.607858 * BoundedHumRatio) / (144. * Pressure);
    else
      return R_DA_SI * this.GetTKelvinFromTCelsius(TDryBulb) * (1. + 1.607858 * BoundedHumRatio) / Pressure;
  }

  // Return dry-bulb temperature given moist air specific volume, humidity ratio, and pressure.
  // Reference:
  // ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26
  // Notes:
  // In IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26
  // The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².
  // Based on the `GetMoistAirVolume` function, rearranged for dry-bulb temperature.
  this.GetTDryBulbFromMoistAirVolumeAndHumRatio = function  // (o) Dry-bulb temperature in °F [IP] or °C [SI]
    ( MoistAirVolume                                        // (i) Specific volume of moist air in ft³ lb⁻¹ of dry air [IP] or in m³ kg⁻¹ of dry air [SI]
    , HumRatio                                              // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    , Pressure                                              // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var BoundedHumRatio;

    if (!(HumRatio >= 0.))
      throw new Error("Humidity ratio is negative");
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

    if (this.isIP())
      return this.GetTFahrenheitFromTRankine(MoistAirVolume * (144 * Pressure) / (R_DA_IP * (1 + 1.607858 * BoundedHumRatio)));
    else
      return  this.GetTCelsiusFromTKelvin(MoistAirVolume * Pressure / (R_DA_SI * (1 + 1.607858 * BoundedHumRatio)));
  }

  // Return moist air density given humidity ratio, dry bulb temperature, and pressure.
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 11
  this.GetMoistAirDensity = function  // (o) Moist air density in lb ft⁻³ [IP] or kg m⁻³ [SI]
    ( TDryBulb                        // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , HumRatio                        // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
    , Pressure                        // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var BoundedHumRatio;

    if (!(HumRatio >= 0.))
      throw new Error("Humidity ratio is negative");
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO);

    return (1. + BoundedHumRatio) / this.GetMoistAirVolume(TDryBulb, BoundedHumRatio, Pressure);
  }


  /******************************************************************************************************
   * Standard atmosphere
   *****************************************************************************************************/

  // Return standard atmosphere barometric pressure, given the elevation (altitude).
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 3
  this.GetStandardAtmPressure = function  // (o) Standard atmosphere barometric pressure in Psi [IP] or Pa [SI]
    ( Altitude                            // (i) Altitude in ft [IP] or m [SI]
    ) {
    var Pressure;

    if (this.isIP())
      Pressure = 14.696 * pow(1. - 6.8754e-06 * Altitude, 5.2559);
    else
      Pressure = 101325.* pow(1. - 2.25577e-05 * Altitude, 5.2559);
    return Pressure;
  }

  // Return standard atmosphere temperature, given the elevation (altitude).
  // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 4
  this.GetStandardAtmTemperature = function // (o) Standard atmosphere dry bulb temperature in °F [IP] or °C [SI]
    ( Altitude                              // (i) Altitude in ft [IP] or m [SI]
    ) {
    var Temperature;
    if (this.isIP())
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
  this.GetSeaLevelPressure = function // (o) Sea level barometric pressure in Psi [IP] or Pa [SI]
    ( StnPressure                     // (i) Observed station pressure in Psi [IP] or Pa [SI]
    , Altitude                        // (i) Altitude above sea level in ft [IP] or m [SI]
    , TDryBulb                        // (i) Dry bulb temperature ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
    ) {
      var TColumn, H;
      if (this.isIP())
      {
        // Calculate average temperature in column of air, assuming a lapse rate
        // of 3.6 °F/1000ft
        TColumn = TDryBulb + 0.0036 * Altitude / 2.;

        // Determine the scale height
        H = 53.351 * this.GetTRankineFromTFahrenheit(TColumn);
      }
      else
      {
        // Calculate average temperature in column of air, assuming a lapse rate
        // of 6.5 °C/km
        TColumn = TDryBulb + 0.0065 * Altitude / 2.;

        // Determine the scale height
        H = 287.055 * this.GetTKelvinFromTCelsius(TColumn) / 9.807;
      }

      // Calculate the sea level pressure
      var SeaLevelPressure = StnPressure * exp(Altitude / H);
      return SeaLevelPressure;
  }

  // Return station pressure from sea level pressure
  // Reference: see 'GetSeaLevelPressure'
  // Notes: this function is just the inverse of 'GetSeaLevelPressure'.
  this.GetStationPressure = function  // (o) Station pressure in Psi [IP] or Pa [SI]
    ( SeaLevelPressure                // (i) Sea level barometric pressure in Psi [IP] or Pa [SI]
    , Altitude                        // (i) Altitude above sea level in ft [IP] or m [SI]
    , TDryBulb                        // (i) Dry bulb temperature in °F [IP] or °C [SI]
    ) {
    return SeaLevelPressure / this.GetSeaLevelPressure(1., Altitude, TDryBulb);
  }


  /******************************************************************************************************
   * Functions to set all psychrometric values
   *****************************************************************************************************/

  // Utility function to calculate humidity ratio, dew-point temperature, relative humidity,
  // vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
  // dry-bulb temperature, wet-bulb temperature, and pressure.
  this.CalcPsychrometricsFromTWetBulb = function
    /**
     * HumRatio            // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
     * TDewPoint           // (o) Dew point temperature in °F [IP] or °C [SI]
     * RelHum              // (o) Relative humidity [0-1]
     * VapPres             // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
     * MoistAirEnthalpy    // (o) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
     * MoistAirVolume      // (o) Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
     * DegreeOfSaturation  // (o) Degree of saturation [unitless]
     */
    ( TDryBulb            // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , TWetBulb            // (i) Wet bulb temperature in °F [IP] or °C [SI]
    , Pressure            // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var HumRatio = this.GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
    var TDewPoint = this.GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);
    var RelHum = this.GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
    var VapPres = this.GetVapPresFromHumRatio(HumRatio, Pressure);
    var MoistAirEnthalpy = this.GetMoistAirEnthalpy(TDryBulb, HumRatio);
    var MoistAirVolume = this.GetMoistAirVolume(TDryBulb, HumRatio, Pressure);
    var DegreeOfSaturation = this.GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure);
    return [HumRatio, TDewPoint, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation];
  }

  // Utility function to calculate humidity ratio, wet-bulb temperature, relative humidity,
  // vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
  // dry-bulb temperature, dew-point temperature, and pressure.
  this.CalcPsychrometricsFromTDewPoint = function
    /**
     * HumRatio            // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
     * TWetBulb            // (o) Wet bulb temperature in °F [IP] or °C [SI]
     * RelHum              // (o) Relative humidity [0-1]
     * VapPres             // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
     * MoistAirEnthalpy    // (o) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
     * MoistAirVolume      // (o) Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
     * DegreeOfSaturation  // (o) Degree of saturation [unitless]
     */
    ( TDryBulb            // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , TDewPoint           // (i) Dew point temperature in °F [IP] or °C [SI]
    , Pressure            // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var HumRatio = this.GetHumRatioFromTDewPoint(TDewPoint, Pressure);
    var TWetBulb = this.GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
    var RelHum = this.GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
    var VapPres = this.GetVapPresFromHumRatio(HumRatio, Pressure);
    var MoistAirEnthalpy = this.GetMoistAirEnthalpy(TDryBulb, HumRatio);
    var MoistAirVolume = this.GetMoistAirVolume(TDryBulb, HumRatio, Pressure);
    var DegreeOfSaturation = this.GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure);
    return [HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation];
  }

  // Utility function to calculate humidity ratio, wet-bulb temperature, dew-point temperature,
  // vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
  // dry-bulb temperature, relative humidity and pressure.
  this.CalcPsychrometricsFromRelHum = function
    /**
     * HumRatio            // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
     * TWetBulb            // (o) Wet bulb temperature in °F [IP] or °C [SI]
     * TDewPoint           // (o) Dew point temperature in °F [IP] or °C [SI]
     * VapPres             // (o) Partial pressure of water vapor in moist air [Psi]
     * MoistAirEnthalpy    // (o) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
     * MoistAirVolume      // (o) Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
     * DegreeOfSaturation  // (o) Degree of saturation [unitless]
    */
    ( TDryBulb            // (i) Dry bulb temperature in °F [IP] or °C [SI]
    , RelHum              // (i) Relative humidity [0-1]
    , Pressure            // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
    ) {
    var HumRatio = this.GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure);
    var TWetBulb = this.GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
    var TDewPoint = this.GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);
    var VapPres = this.GetVapPresFromHumRatio(HumRatio, Pressure);
    var MoistAirEnthalpy = this.GetMoistAirEnthalpy(TDryBulb, HumRatio);
    var MoistAirVolume = this.GetMoistAirVolume(TDryBulb, HumRatio, Pressure);
    var DegreeOfSaturation = this.GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure);
    return [HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation];
  }
}

// https://github.com/umdjs/umd
(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
      // AMD. Register as an anonymous module.
      define([], factory);
  } else if (typeof module === 'object' && module.exports) {
      // Node. Does not work with strict CommonJS, but
      // only CommonJS-like environments that support module.exports,
      // like Node.
      module.exports = factory();
  } else {
      // Browser globals (root is window)
      root.psychrolib = factory();
}
}(typeof self !== 'undefined' ? self : this, function () {
  return new Psychrometrics();
}));
