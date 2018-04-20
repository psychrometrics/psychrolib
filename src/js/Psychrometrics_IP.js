function Psychrometrics() {

// This psychrometrics package is used to demonstrate psychrometric calculations.
// It contains functions to calculate dew point temperature, wet bulb temperature,
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
// Notes about the JavaScript version
// Thanks to Tom Worster for explaining how to quickly translate C 
// to JavaScript
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
// History
//
// 2016-09-28 - Forked from C version
//

// Standard functions
var log = Math.log;
var exp = Math.exp;
var pow = Math.pow;
var min = Math.min;

//*****************************************************************************\
// Macros and utility functions used in this file
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Constants

var RGAS = 1545.349;           // Universal gas constant in ft·lbf /lb mol·R
var MOLMASSAIR = 28.966;       // mean molecular mass of dry air based on C-12 scale
var ZEROF = 459.67;            // Zero ºF expressed in R
var INVALID = -99999;          // Invalid value



///////////////////////////////////////////////////////////////////////////////
// Conversions from Fahrenheit to Rankin
var FTOR = function(T_F) { return T_F+ZEROF; }              /* exact */

//*****************************************************************************
//       Conversions between dew point, wet bulb, and relative humidity
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Wet-bulb temperature given dry-bulb temperature and dew-point temperature
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
this.GetTWetBulbFromTDewPoint = function // (o) Wet bulb temperature [F]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , TDewPoint            // (i) Dew point temperature [F]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  var HumRatio;

  if (!(TDewPoint <= TDryBulb))
    throw "Dew point temperature is above dry bulb temperature";

  HumRatio = this.GetHumRatioFromTDewPoint(TDewPoint, Pressure);
  return this.GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Wet-bulb temperature given dry-bulb temperature and relative humidity
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
this.GetTWetBulbFromRelHum = function    // (o) Wet bulb temperature [F]
  ( TDryBulb             // (i) Dry bulb temperature [F] //
  , RelHum               // (i) Relative humidity [0-1] //
  , Pressure             // (i) Atmospheric pressure [Psi] //
  )
{
  var HumRatio;

  if (!(RelHum >= 0 && RelHum <= 1))
    throw "Relative humidity is outside range [0,1]";

  HumRatio = this.GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure);
  return this.GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Relative Humidity given dry-bulb temperature and dew-point temperature
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
this.GetRelHumFromTDewPoint = function   // (o) Relative humidity [0-1]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , TDewPoint            // (i) Dew point temperature [F]
  )
{
  var VapPres, SatVapPres;

  if (!(TDewPoint <= TDryBulb))
    throw "Dew point temperature is above dry bulb temperature";

  VapPres = this.GetSatVapPres(TDewPoint);     // Eqn. 36
  SatVapPres = this.GetSatVapPres(TDryBulb);
  return VapPres/SatVapPres;              // Eqn. 24
}

///////////////////////////////////////////////////////////////////////////////
// Relative Humidity given dry-bulb temperature and wet bulb temperature
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
this.GetRelHumFromTWetBulb = function    // (o) Relative humidity [0-1]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , TWetBulb             // (i) Wet bulb temperature [F]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  var HumRatio;

  if (!(TWetBulb <= TDryBulb))
    throw "Wet bulb temperature is above dry bulb temperature";

  HumRatio = this.GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
  return this.GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Dew Point Temperature given dry bulb temperature and relative humidity
// ASHRAE Fundamentals (2005) ch. 6 eqn 24
// ASHRAE Fundamentals (2009) ch. 1 eqn 24
//
this.GetTDewPointFromRelHum = function   // (o) Dew Point temperature [F]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , RelHum               // (i) Relative humidity [0-1]
  )
{
  var VapPres;

  if (!(RelHum >= 0 && RelHum <= 1))
    throw "Relative humidity is outside range [0,1]";

  VapPres = this.GetVapPresFromRelHum(TDryBulb, RelHum);
  return this.GetTDewPointFromVapPres(TDryBulb, VapPres);
}

///////////////////////////////////////////////////////////////////////////////
// Dew Point Temperature given dry bulb temperature and wet bulb temperature
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
this.GetTDewPointFromTWetBulb = function // (o) Dew Point temperature [F]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , TWetBulb             // (i) Wet bulb temperature [F]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  var HumRatio;

  if (!(TWetBulb <= TDryBulb))
    throw "Wet bulb temperature is above dry bulb temperature";

  HumRatio = this.GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
  return this.GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);
}

//*****************************************************************************
//  Conversions between dew point, or relative humidity and vapor pressure
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Partial pressure of water vapor as a function of relative humidity and
// temperature in C
// ASHRAE Fundamentals (2005) ch. 6, eqn. 24
// ASHRAE Fundamentals (2009) ch. 1, eqn. 24
//
this.GetVapPresFromRelHum = function     // (o) Partial pressure of water vapor in moist air [Psi]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , RelHum               // (i) Relative humidity [0-1]
  )
{
  if (!(RelHum >= 0 && RelHum <= 1))
    throw "Relative humidity is outside range [0,1]";

  return RelHum*this.GetSatVapPres(TDryBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Relative Humidity given dry bulb temperature and vapor pressure
// ASHRAE Fundamentals (2005) ch. 6, eqn. 24
// ASHRAE Fundamentals (2009) ch. 1, eqn. 24
//
this.GetRelHumFromVapPres = function     // (o) Relative humidity [0-1]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , VapPres              // (i) Partial pressure of water vapor in moist air [Psi]
  )
{
  if (!(VapPres >= 0))
    throw "Partial pressure of water vapor in moist air is negative";

  return VapPres/this.GetSatVapPres(TDryBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Dew point temperature given vapor pressure and dry bulb temperature
// ASHRAE Fundamentals (2005) ch. 6, eqn. 39 and 40
// ASHRAE Fundamentals (2009) ch. 1, eqn. 39 and 40
//
this.GetTDewPointFromVapPres = function  // (o) Dew Point temperature [F]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , VapPres              // (i) Partial pressure of water vapor in moist air [Psi]
  )
{
  var alpha, TDewPoint, VP;

  if (!(VapPres >= 0))
    throw "Partial pressure of water vapor in moist air is negative";

  VP = VapPres;
  alpha = log(VP);
  if (TDryBulb >= 32 && TDryBulb <= 200)
  TDewPoint = 100.45+33.193*alpha+2.319*alpha*alpha+0.17074*pow(alpha,3)
    +1.2063*pow(VP, 0.1984);                            // (39)
  else if (TDryBulb < 32)
  TDewPoint = 90.12+26.142*alpha+0.8927*alpha*alpha;     // (40)
  else
    TDewPoint = INVALID;                                // Invalid value
  return min(TDewPoint, TDryBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure given dew point temperature
// ASHRAE Fundamentals (2005) ch. 6 eqn. 38
// ASHRAE Fundamentals (2009) ch. 1 eqn. 38
//
this.GetVapPresFromTDewPoint = function  // (o) Partial pressure of water vapor in moist air [Psi]
  ( TDewPoint            // (i) Dew point temperature [F]
  )
{
  return this.GetSatVapPres(TDewPoint);
}


//*****************************************************************************
//        Conversions from wet bulb temperature, dew point temperature,
//                or relative humidity to humidity ratio
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Wet bulb temperature given humidity ratio
// ASHRAE Fundamentals (2005) ch. 6 eqn. 35
// ASHRAE Fundamentals (2009) ch. 1 eqn. 35
//
this.GetTWetBulbFromHumRatio = function  // (o) Wet bulb temperature [F]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , HumRatio             // (i) Humidity ratio [H2O/AIR]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  // Declarations
  var Wstar;
  var TDewPoint, TWetBulb, TWetBulbSup, TWetBulbInf;

  if (!(HumRatio >= 0))
    throw "Humidity ratio is negative";

  TDewPoint = this.GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);

  // Initial guesses
  TWetBulbSup = TDryBulb;
  TWetBulbInf = TDewPoint;
  TWetBulb = (TWetBulbInf + TWetBulbSup)/2.;

  // Bisection loop
  while(TWetBulbSup - TWetBulbInf > 0.001)
  {
   // Compute humidity ratio at temperature Tstar
   Wstar = this.GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);

   // Get new bounds
   if (Wstar > HumRatio)
    TWetBulbSup = TWetBulb;
   else
    TWetBulbInf = TWetBulb;

   // New guess of wet bulb temperature
   TWetBulb = (TWetBulbSup+TWetBulbInf)/2.;
  }

  return TWetBulb;
}

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given wet bulb temperature and dry bulb temperature
// ASHRAE Fundamentals (2005) ch. 6 eqn. 35
// ASHRAE Fundamentals (2009) ch. 1 eqn. 35
//
this.GetHumRatioFromTWetBulb = function  // (o) Humidity Ratio [H2O/AIR]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , TWetBulb             // (i) Wet bulb temperature [F]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  var Wsstar;

  if (!(TWetBulb <= TDryBulb))
    throw "Wet bulb temperature is above dry bulb temperature";

  Wsstar = this.GetSatHumRatio(TWetBulb, Pressure);
  return ((1093 - 0.556*TWetBulb)*Wsstar - 0.240*(TDryBulb - TWetBulb))
       / (1093 + 0.444*TDryBulb - TWetBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given relative humidity
// ASHRAE Fundamentals (2005) ch. 6 eqn. 38
// ASHRAE Fundamentals (2009) ch. 1 eqn. 38
//
this.GetHumRatioFromRelHum = function    // (o) Humidity Ratio [H2O/AIR]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , RelHum               // (i) Relative humidity [0-1]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  var VapPres;

  if (!(RelHum >= 0 && RelHum <= 1))
    throw "Relative humidity is outside range [0,1]";

  VapPres = this.GetVapPresFromRelHum(TDryBulb, RelHum);
  return this.GetHumRatioFromVapPres(VapPres, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Relative humidity given humidity ratio
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
this.GetRelHumFromHumRatio = function    // (o) Relative humidity [0-1]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , HumRatio             // (i) Humidity ratio [H2O/AIR]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  var VapPres;

  if (!(HumRatio >= 0))
    throw "Humidity ratio is negative";

  VapPres = this.GetVapPresFromHumRatio(HumRatio, Pressure);
  return this.GetRelHumFromVapPres(TDryBulb, VapPres);
}
///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given dew point temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 22
// ASHRAE Fundamentals (2009) ch. 1 eqn. 22
//
this.GetHumRatioFromTDewPoint = function // (o) Humidity Ratio [H2O/AIR]
  ( TDewPoint            // (i) Dew point temperature [F]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  var VapPres;

  VapPres = this.GetSatVapPres(TDewPoint);
  return this.GetHumRatioFromVapPres(VapPres, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Dew point temperature given dry bulb temperature, humidity ratio, and pressure
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
this.GetTDewPointFromHumRatio = function // (o) Dew Point temperature [F]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , HumRatio             // (i) Humidity ratio [H2O/AIR]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  var VapPres;

  if (!(HumRatio >= 0))
    throw "Humidity ratio is negative";

  VapPres = this.GetVapPresFromHumRatio(HumRatio, Pressure);
  return this.GetTDewPointFromVapPres(TDryBulb, VapPres);
}

//*****************************************************************************
//       Conversions between humidity ratio and vapor pressure
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given water vapor pressure and atmospheric pressure
// ASHRAE Fundamentals (2005) ch. 6 eqn. 22
// ASHRAE Fundamentals (2009) ch. 1 eqn. 22
//
this.GetHumRatioFromVapPres = function   // (o) Humidity Ratio [H2O/AIR]
  ( VapPres              // (i) Partial pressure of water vapor in moist air [Psi]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  if (!(VapPres >= 0))
    throw "Partial pressure of water vapor in moist air is negative";

  return 0.621945*VapPres/(Pressure-VapPres);
}

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure given humidity ratio and pressure
// ASHRAE Fundamentals (2005) ch. 6 eqn. 22
// ASHRAE Fundamentals (2009) ch. 1 eqn. 22
//

this.GetVapPresFromHumRatio = function   // (o) Partial pressure of water vapor in moist air [Psi]
  ( HumRatio             // (i) Humidity ratio [H2O/AIR]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  var VapPres;

  if (!(HumRatio >= 0))
    throw "Humidity ratio is negative";

  VapPres = Pressure*HumRatio/(0.621945 +HumRatio);
  return VapPres;
}

//*****************************************************************************
//                             Dry Air Calculations
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Dry air enthalpy given dry bulb temperature.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 30
// ASHRAE Fundamentals (2009) ch. 1 eqn. 30
//
this.GetDryAirEnthalpy = function        // (o) Dry air enthalpy [Btu/lb]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  )
{
  return 0.240*TDryBulb;
}

///////////////////////////////////////////////////////////////////////////////
// Dry air density given dry bulb temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 28
// ASHRAE Fundamentals (2009) ch. 1 eqn. 28
// **NOTE** pressure is in inHg, not psi
//
this.GetDryAirDensity = function         // (o) Dry air density [lb/ft3]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , Pressure             // (i) Atmospheric pressure [in Hg]
  )
{
  return (Pressure*MOLMASSAIR)/(RGAS*FTOR(TDryBulb));
}

///////////////////////////////////////////////////////////////////////////////
// Dry air volume given dry bulb temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 28
// ASHRAE Fundamentals (2009) ch. 1 eqn. 28
// **NOTE** pressure is in inHg, not psi
//
this.GetDryAirVolume = function          // (o) Dry air volume [ft3/lb]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , Pressure             // (i) Atmospheric pressure [in Hg]
  )
{
  return (RGAS*FTOR(TDryBulb))/(Pressure*MOLMASSAIR);
}

//*****************************************************************************
//                       Saturated Air Calculations
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Saturation vapor pressure as a function of temperature
// ASHRAE Fundamentals (2005) ch. 6 eqn. 5, 6
// ASHRAE Fundamentals (2009) ch. 1 eqn. 5, 6
//
this.GetSatVapPres = function            // (o) Vapor Pressure of saturated air [Psi]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  )
{
  var LnPws, T;

  if (!(TDryBulb >= -148 && TDryBulb <= 392))
    throw "Dry bulb temperature is outside range [-148, 392]"

  T = FTOR(TDryBulb);
  if (TDryBulb >= -148. && TDryBulb <= 32.)
    LnPws = (-1.0214165E+04/T - 4.8932428 - 5.3765794E-03*T + 1.9202377E-07*T*T
        + 3.5575832E-10*pow(T, 3) - 9.0344688E-14*pow(T, 4) + 4.1635019*log(T));
  else if (TDryBulb > 32. && TDryBulb <= 392. )
    LnPws = -1.0440397E+04/T - 1.1294650E+01 - 2.7022355E-02*T + 1.2890360E-05*T*T
      - 2.4780681E-09*pow(T, 3) + 6.5459673*log(T);
  else
    return INVALID;             // TDryBulb is out of range [-148, 392]
  return exp(LnPws);
}

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio of saturated air given dry bulb temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 23
// ASHRAE Fundamentals (2009) ch. 1 eqn. 23
//
this.GetSatHumRatio = function           // (o) Humidity ratio of saturated air [H2O/AIR]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , Pressure             // (i) Atmospheric pressure [Psi]
    )
{
  var SatVaporPres;

  SatVaporPres = this.GetSatVapPres(TDryBulb);
  return 0.621945*SatVaporPres/(Pressure-SatVaporPres);
}

///////////////////////////////////////////////////////////////////////////////
// Saturated air enthalpy given dry bulb temperature and pressure
// ASHRAE Fundamentals (2005) ch. 6 eqn. 32
//
this.GetSatAirEnthalpy = function        // (o) Saturated air enthalpy [Btu/lb]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  return this.GetMoistAirEnthalpy(TDryBulb, this.GetSatHumRatio(TDryBulb, Pressure));
}

//*****************************************************************************
//                       Moist Air Calculations
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure deficit in Pa given humidity ratio, dry bulb temperature, and
// pressure.
// See Oke (1987) eqn. 2.13a
//
this.GetVPD = function                   // (o) Vapor pressure deficit [Psi]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , HumRatio             // (i) Humidity ratio [H2O/AIR]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  var RelHum;

  if (!(HumRatio >= 0))
    throw "Humidity ratio is negative";

  RelHum = this.GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
  return this.GetSatVapPres(TDryBulb)*(1.-RelHum);
}

///////////////////////////////////////////////////////////////////////////////
// ASHRAE Fundamentals (2005) ch. 6 eqn. 12
// ASHRAE Fundamentals (2009) ch. 1 eqn. 12
//
this.GetDegreeOfSaturation = function    // (o) Degree of saturation []
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , HumRatio             // (i) Humidity ratio [H2O/AIR]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  if (!(HumRatio >= 0))
    throw "Humidity ratio is negative";

  return HumRatio/this.GetSatHumRatio(TDryBulb, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Moist air enthalpy given dry bulb temperature and humidity ratio
// ASHRAE Fundamentals (2005) ch. 6 eqn. 32
// ASHRAE Fundamentals (2009) ch. 1 eqn. 32
//
this.GetMoistAirEnthalpy = function      // (o) Moist Air Enthalpy [Btu/lb]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , HumRatio             // (i) Humidity ratio [H2O/AIR]
  )
{
  if (!(HumRatio >= 0))
    throw "Humidity ratio is negative";

  return (0.240*TDryBulb + HumRatio*(1061 + 0.444*TDryBulb));
}

///////////////////////////////////////////////////////////////////////////////
// Moist air volume given dry bulb temperature, humidity ratio, and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 28
// ASHRAE Fundamentals (2009) ch. 1 eqn. 28
//
this.GetMoistAirVolume = function        // (o) Specific Volume [ft3/lb]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , HumRatio             // (i) Humidity ratio [H2O/AIR]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  if (!(HumRatio >= 0))
    throw "Humidity ratio is negative";

  return 0.370486 *(FTOR(TDryBulb))*(1.+1.607858*HumRatio)/(Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Moist air density given humidity ratio, dry bulb temperature, and pressure
// ASHRAE Fundamentals (2005) ch. 6 6.8 eqn. 11
// ASHRAE Fundamentals (2009) ch. 1 1.8 eqn 11
//
this.GetMoistAirDensity = function       // (o) Moist air density [lb/ft3]
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , HumRatio             // (i) Humidity ratio [H2O/AIR]
  , Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  if (!(HumRatio >= 0))
    throw "Humidity ratio is negative";

  return (1.+HumRatio)/this.GetMoistAirVolume(TDryBulb, HumRatio, Pressure);
}

//*****************************************************************************
//                Functions to set all psychrometric values
//*****************************************************************************

this.CalcPsychrometricsFromTWetBulb = function
  /*
  [ TDewPoint           // (o) Dew point temperature [F]
  , RelHum              // (o) Relative humidity [0-1]
  , HumRatio            // (o) Humidity ratio [H2O/AIR]
  , VapPres             // (o) Partial pressure of water vapor in moist air [Psi]
  , MoistAirEnthalpy    // (o) Moist air enthalpy [Btu/lb]
  , MoistAirVolume      // (o) Specific volume [ft3/lb]
  , DegSaturation       // (o) Degree of saturation []
  ]
  */
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , Pressure             // (i) Atmospheric pressure [Psi]
  , TWetBulb             // (i) Wet bulb temperature [F]
  )
{
  var HumRatio = this.GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
  var TDewPoint = this.GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);
  var RelHum = this.GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
  var VapPres = this.GetVapPresFromHumRatio(HumRatio, Pressure);
  var MoistAirEnthalpy = this.GetMoistAirEnthalpy(TDryBulb, HumRatio);
  var MoistAirVolume = this.GetMoistAirVolume(TDryBulb, HumRatio, Pressure);
  var DegSaturation = this.GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure);
  return [TDewPoint, RelHum, HumRatio, VapPres, MoistAirEnthalpy, MoistAirVolume, DegSaturation];
}

this.CalcPsychrometricsFromTDewPoint = function
  /*
  [ TWetBulb            // (o) Wet bulb temperature [F]
  , RelHum              // (o) Relative humidity [0-1]
  , HumRatio            // (o) Humidity ratio [H2O/AIR]
  , VapPres             // (o) Partial pressure of water vapor in moist air [Psi]
  , MoistAirEnthalpy    // (o) Moist air enthalpy [Btu/lb]
  , MoistAirVolume      // (o) Specific volume [ft3/lb]
  , DegSaturation       // (o) Degree of saturation []
  ]
  */
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , Pressure             // (i) Atmospheric pressure [Psi]
  , TDewPoint            // (i) Dew point temperature [F]
  )
{
  var HumRatio = this.GetHumRatioFromTDewPoint(TDewPoint, Pressure);
  var TWetBulb = this.GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
  var RelHum = this.GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
  var VapPres = this.GetVapPresFromHumRatio(HumRatio, Pressure);
  var MoistAirEnthalpy = this.GetMoistAirEnthalpy(TDryBulb, HumRatio);
  var MoistAirVolume = this.GetMoistAirVolume(TDryBulb, HumRatio, Pressure);
  var DegSaturation = this.GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure);
  return [TWetBulb, RelHum, HumRatio, VapPres, MoistAirEnthalpy, MoistAirVolume, DegSaturation];
}

this.CalcPsychrometricsFromRelHum = function
  /*
  [ TWetBulb            // (o) Wet bulb temperature [F]
  , TDewPoint           // (o) Dew point temperature [F]
  , HumRatio            // (o) Humidity ratio [kgH2O/kgAIR]
  , VapPres             // (o) Partial pressure of water vapor in moist air [Psi]
  , MoistAirEnthalpy    // (o) Moist air enthalpy [Btu/lb]
  , MoistAirVolume      // (o) Specific volume [ft3/lb]
  , DegSaturation       // (o) Degree of saturation []
  ]
  */
  ( TDryBulb             // (i) Dry bulb temperature [F]
  , Pressure             // (i) Atmospheric pressure [Psi]
  , RelHum               // (i) Relative humidity [0-1]
  )
{
  var HumRatio = this.GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure);
  var TWetBulb = this.GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
  var TDewPoint = this.GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);
  var VapPres = this.GetVapPresFromHumRatio(HumRatio, Pressure);
  var MoistAirEnthalpy = this.GetMoistAirEnthalpy(TDryBulb, HumRatio);
  var MoistAirVolume = this.GetMoistAirVolume(TDryBulb, HumRatio, Pressure);
  var DegSaturation = this.GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure);
  return [TWetBulb, TDewPoint, HumRatio, VapPres, MoistAirEnthalpy, MoistAirVolume, DegSaturation];
}

//*****************************************************************************
//                          Standard atmosphere
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Standard atmosphere barometric pressure, given the elevation (altitude)
// ASHRAE Fundamentals (2005) ch. 6 eqn. 3
// ASHRAE Fundamentals (2009) ch. 1 eqn. 3
//
this.GetStandardAtmPressure = function   // (o) standard atmosphere barometric pressure [Psi]
  ( Altitude             // (i) altitude [ft]
  )
{
  var Pressure = 14.696*pow(1.-6.8754e-06*Altitude, 5.2559);
  return Pressure;
}

///////////////////////////////////////////////////////////////////////////////
// Standard atmosphere temperature, given the elevation (altitude)
// ASHRAE Fundamentals (2005) ch. 6 eqn. 4
// ASHRAE Fundamentals (2009) ch. 1 eqn. 4
//
this.GetStandardAtmTemperature = function // (o) standard atmosphere dry bulb temperature [F]
  ( Altitude              // (i) altitude [ft]
  )
{
  var Temperature = 59-0.00356620*Altitude;
  return Temperature;
}

///////////////////////////////////////////////////////////////////////////////
// Sea level pressure from observed station pressure
// Note: the standard procedure for the US is to use for TDryBulb the average
// of the current station temperature and the station temperature from 12 hours ago
// Hess SL, Introduction to theoretical meteorology, Holt Rinehart and Winston, NY 1959,
// ch. 6.5; Stull RB, Meteorology for scientists and engineers, 2nd edition,
// Brooks/Cole 2000, ch. 1.
//
this.GetSeaLevelPressure = function   // (o) sea level barometric pressure [Psi]
  ( StnPressure       // (i) observed station pressure [Psi]
  , Altitude          // (i) altitude above sea level [ft]
  , TDryBulb          // (i) dry bulb temperature [°F]
  )
{
  // Calculate average temperature in column of air, assuming a lapse rate
  // of 3.6 °F/1000ft
  var TColumn = TDryBulb + 0.0036*Altitude/2.;

  // Determine the scale height
  var H = 53.351*FTOR(TColumn);

  // Calculate the sea level pressure
  var SeaLevelPressure = StnPressure*exp(Altitude/H);
  return SeaLevelPressure;
}

///////////////////////////////////////////////////////////////////////////////
// Station pressure from sea level pressure
// This is just the previous function, reversed
//
this.GetStationPressure = function    // (o) station pressure [Psi]
  ( SeaLevelPressure  // (i) sea level barometric pressure [Psi]
  , Altitude          // (i) altitude above sea level [ft]
  , TDryBulb          // (i) dry bulb temperature [°F]
  )
{
  return SeaLevelPressure/this.GetSeaLevelPressure(1., Altitude, TDryBulb);
}

}