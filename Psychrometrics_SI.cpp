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
// 2011 - Corrected GetHumRatioFromRelHum call in GetTWetBulbFromRelHum function
//      - Replaced RGAS (8314.41 J/kmol/K) with 8.31441 J/mol/K
//      - Defined constant MOLMASSAIR as 28.966 g/mol; the mean molar mass of
//          dry air. Replaced instances of mean molar mass of dry air = 28.966
//          with MOLMASSAIR.
//      - Updated with 2009 coefficients (eqns 28, 22, 28)
//

// Standard C header files
#include <float.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

// Header specific to this file
#include "psychrometrics.h"


//*****************************************************************************\
// Macros and utility functions used in this file
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Constants


#define RGAS  8.314472          // Universal gas constant in J/mol/K
#define MOLMASSAIR 0.028966     // mean molar mass of dry air in kg/mol
#define KILO 1.e+03             // exact
#define ZEROC 273.15            // Zero ºC expressed in K
#define INVALID -99999          // Invalid value


///////////////////////////////////////////////////////////////////////////////
// ASSERT macro

#define ASSERT(condition, msg) \
  if (! (condition)) \
  { \
    Assert(msg, __FILE__, __LINE__); \
  }

///////////////////////////////////////////////////////////////////////////////
// Function called if an assertion fails
// Replace this function with your own function for better error processing
//
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

///////////////////////////////////////////////////////////////////////////////
// Min macro (in case it's not defined)

#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif


///////////////////////////////////////////////////////////////////////////////
// Conversions from Celsius to Kelvin
double CTOK(double T_C) { return T_C+ZEROC; }              /* exact */

//*****************************************************************************
//       Conversions between dew point, wet bulb, and relative humidity
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Wet-bulb temperature given dry-bulb temperature and dew-point temperature
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
double GetTWetBulbFromTDewPoint // (o) Wet bulb temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double TDewPoint            // (i) Dew point temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  double HumRatio;

  ASSERT (TDewPoint <= TDryBulb, "Dew point temperature is above dry bulb temperature")

  HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure);
  return GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Wet-bulb temperature given dry-bulb temperature and relative humidity
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
double GetTWetBulbFromRelHum    // (o) Wet bulb temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C] //
  , double RelHum               // (i) Relative humidity [0-1] //
  , double Pressure             // (i) Atmospheric pressure [Pa] //
  )
{
  double HumRatio;

  ASSERT (RelHum >= 0 && RelHum <= 1, "Relative humidity is outside range [0,1]")

  HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure);
  return GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Relative Humidity given dry-bulb temperature and dew-point temperature
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
double GetRelHumFromTDewPoint   // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double TDewPoint            // (i) Dew point temperature [C]
    )
{
  double VapPres, SatVapPres;

  ASSERT (TDewPoint <= TDryBulb, "Dew point temperature is above dry bulb temperature")

  VapPres = GetSatVapPres(TDewPoint);     // Eqn. 36
  SatVapPres = GetSatVapPres(TDryBulb);
  return VapPres/SatVapPres;              // Eqn. 24
}

///////////////////////////////////////////////////////////////////////////////
// Relative Humidity given dry-bulb temperature and wet bulb temperature
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
double GetRelHumFromTWetBulb    // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double TWetBulb             // (i) Wet bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  double HumRatio;

  ASSERT (TWetBulb <= TDryBulb, "Wet bulb temperature is above dry bulb temperature")

  HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
  return GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Dew Point Temperature given dry bulb temperature and relative humidity
// ASHRAE Fundamentals (2005) ch. 6 eqn 24
// ASHRAE Fundamentals (2009) ch. 1 eqn 24
//
double GetTDewPointFromRelHum   // (o) Dew Point temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double RelHum               // (i) Relative humidity [0-1]
  )
{
  double VapPres;

  ASSERT (RelHum >= 0 && RelHum <= 1, "Relative humidity is outside range [0,1]")

  VapPres = GetVapPresFromRelHum(TDryBulb, RelHum);
  return GetTDewPointFromVapPres(TDryBulb, VapPres);
}

///////////////////////////////////////////////////////////////////////////////
// Dew Point Temperature given dry bulb temperature and wet bulb temperature
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
double GetTDewPointFromTWetBulb // (o) Dew Point temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double TWetBulb             // (i) Wet bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  double HumRatio;

  ASSERT (TWetBulb <= TDryBulb, "Wet bulb temperature is above dry bulb temperature")

  HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
  return GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);
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
double GetVapPresFromRelHum     // (o) Partial pressure of water vapor in moist air [Pa]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double RelHum               // (i) Relative humidity [0-1]
  )
{
  ASSERT (RelHum >= 0 && RelHum <= 1, "Relative humidity is outside range [0,1]")

  return RelHum*GetSatVapPres(TDryBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Relative Humidity given dry bulb temperature and vapor pressure
// ASHRAE Fundamentals (2005) ch. 6, eqn. 24
// ASHRAE Fundamentals (2009) ch. 1, eqn. 24
//
double GetRelHumFromVapPres     // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double VapPres              // (i) Partial pressure of water vapor in moist air [Pa]
  )
{
  ASSERT (VapPres >= 0, "Partial pressure of water vapor in moist air is negative")

  return VapPres/GetSatVapPres(TDryBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Dew point temperature given vapor pressure and dry bulb temperature
// ASHRAE Fundamentals (2005) ch. 6, eqn. 39 and 40
// ASHRAE Fundamentals (2009) ch. 1, eqn. 39 and 40
//
double GetTDewPointFromVapPres  // (o) Dew Point temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double VapPres              // (i) Partial pressure of water vapor in moist air [Pa]
  )
{
  double alpha, TDewPoint, VP;

  ASSERT (VapPres >= 0, "Partial pressure of water vapor in moist air is negative")

  VP = VapPres/1000;
  alpha = log(VP);
  if (TDryBulb >= 0 && TDryBulb <= 93)
  TDewPoint = 6.54+14.526*alpha+0.7389*alpha*alpha+0.09486*pow(alpha,3)
    +0.4569*pow(VP, 0.1984);                            // (39)
  else if (TDryBulb < 0)
  TDewPoint = 6.09+12.608*alpha+0.4959*alpha*alpha;     // (40)
  else
    TDewPoint = INVALID;                                // Invalid value
  return min(TDewPoint, TDryBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure given dew point temperature
// ASHRAE Fundamentals (2005) ch. 6 eqn. 38
// ASHRAE Fundamentals (2009) ch. 1 eqn. 38
//
double GetVapPresFromTDewPoint  // (o) Partial pressure of water vapor in moist air [Pa]
  ( double TDewPoint            // (i) Dew point temperature [C]
  )
{
  return GetSatVapPres(TDewPoint);
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
double GetTWetBulbFromHumRatio  // (o) Wet bulb temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  // Declarations
  double Wstar;
  double TDewPoint, TWetBulb, TWetBulbSup, TWetBulbInf;

  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure);

  // Initial guesses
  TWetBulbSup = TDryBulb;
  TWetBulbInf = TDewPoint;
  TWetBulb = (TWetBulbInf + TWetBulbSup)/2.;

  // Bisection loop
  while(TWetBulbSup - TWetBulbInf > 0.001)
  {
   // Compute humidity ratio at temperature Tstar
   Wstar = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);

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
double GetHumRatioFromTWetBulb  // (o) Humidity Ratio [kgH2O/kgAIR]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double TWetBulb             // (i) Wet bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  double Wsstar;

  ASSERT (TWetBulb <= TDryBulb, "Wet bulb temperature is above dry bulb temperature")

  Wsstar = GetSatHumRatio(TWetBulb, Pressure);
  return ((2501. - 2.326*TWetBulb)*Wsstar - 1.006*(TDryBulb - TWetBulb))
       / (2501. + 1.86*TDryBulb -4.186*TWetBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given relative humidity
// ASHRAE Fundamentals (2005) ch. 6 eqn. 38
// ASHRAE Fundamentals (2009) ch. 1 eqn. 38
//
double GetHumRatioFromRelHum    // (o) Humidity Ratio [kgH2O/kgAIR]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double RelHum               // (i) Relative humidity [0-1]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  double VapPres;

  ASSERT (RelHum >= 0 && RelHum <= 1, "Relative humidity is outside range [0,1]")

  VapPres = GetVapPresFromRelHum(TDryBulb, RelHum);
  return GetHumRatioFromVapPres(VapPres, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Relative humidity given humidity ratio
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
double GetRelHumFromHumRatio    // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  double VapPres;

  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure);
  return GetRelHumFromVapPres(TDryBulb, VapPres);
}
///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given dew point temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 22
// ASHRAE Fundamentals (2009) ch. 1 eqn. 22
//
double GetHumRatioFromTDewPoint // (o) Humidity Ratio [kgH2O/kgAIR]
  ( double TDewPoint            // (i) Dew point temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  double VapPres;

  VapPres = GetSatVapPres(TDewPoint);
  return GetHumRatioFromVapPres(VapPres, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Dew point temperature given dry bulb temperature, humidity ratio, and pressure
// ASHRAE Fundamentals (2005) ch. 6
// ASHRAE Fundamentals (2009) ch. 1
//
double GetTDewPointFromHumRatio // (o) Dew Point temperature [C]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  double VapPres;

  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure);
  return GetTDewPointFromVapPres(TDryBulb, VapPres);
}

//*****************************************************************************
//       Conversions between humidity ratio and vapor pressure
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given water vapor pressure and atmospheric pressure
// ASHRAE Fundamentals (2005) ch. 6 eqn. 22
// ASHRAE Fundamentals (2009) ch. 1 eqn. 22
//
double GetHumRatioFromVapPres   // (o) Humidity Ratio [kgH2O/kgAIR]
  ( double VapPres              // (i) Partial pressure of water vapor in moist air [Pa]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  ASSERT (VapPres >= 0, "Partial pressure of water vapor in moist air is negative")

  return 0.621945*VapPres/(Pressure-VapPres);
}

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure given humidity ratio and pressure
// ASHRAE Fundamentals (2005) ch. 6 eqn. 22
// ASHRAE Fundamentals (2009) ch. 1 eqn. 22
//

double GetVapPresFromHumRatio   // (o) Partial pressure of water vapor in moist air [Pa]
  ( double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  double VapPres;

  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

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
double GetDryAirEnthalpy        // (o) Dry air enthalpy [J/kg]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  )
{
  return 1.006*TDryBulb*KILO;
}

///////////////////////////////////////////////////////////////////////////////
// Dry air density given dry bulb temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 28
// ASHRAE Fundamentals (2009) ch. 1 eqn. 28
//
double GetDryAirDensity         // (o) Dry air density [kg/m3]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  return (Pressure/KILO)*MOLMASSAIR/(RGAS*CTOK(TDryBulb));
}

///////////////////////////////////////////////////////////////////////////////
// Dry air volume given dry bulb temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 28
// ASHRAE Fundamentals (2009) ch. 1 eqn. 28
//
double GetDryAirVolume          // (o) Dry air volume [m3/kg]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  return (RGAS*CTOK(TDryBulb))/((Pressure/KILO)*MOLMASSAIR);
}

//*****************************************************************************
//                       Saturated Air Calculations
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Saturation vapor pressure as a function of temperature
// ASHRAE Fundamentals (2005) ch. 6 eqn. 5, 6
// ASHRAE Fundamentals (2009) ch. 1 eqn. 5, 6
//
double GetSatVapPres            // (o) Vapor Pressure of saturated air [Pa]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  )
{
  double LnPws, T;

  ASSERT(TDryBulb >= -100. && TDryBulb <= 200., "Dry bulb temperature is outside range [-100, 200]")

  T = CTOK(TDryBulb);
  if (TDryBulb >= -100. && TDryBulb <= 0.)
    LnPws = (-5.6745359E+03/T + 6.3925247 - 9.677843E-03*T + 6.2215701E-07*T*T
        + 2.0747825E-09*pow(T, 3) - 9.484024E-13*pow(T, 4) + 4.1635019*log(T));
  else if (TDryBulb > 0. && TDryBulb <= 200.)
    LnPws = -5.8002206E+03/T + 1.3914993 - 4.8640239E-02*T + 4.1764768E-05*T*T
      - 1.4452093E-08*pow(T, 3) + 6.5459673*log(T);
  else
    return INVALID;             // TDryBulb is out of range [-100, 200]
  return exp(LnPws);
}

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio of saturated air given dry bulb temperature and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 23
// ASHRAE Fundamentals (2009) ch. 1 eqn. 23
//
double GetSatHumRatio           // (o) Humidity ratio of saturated air [kgH2O/kgAIR]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
    )
{
  double SatVaporPres;

  SatVaporPres = GetSatVapPres(TDryBulb);
  return 0.621945*SatVaporPres/(Pressure-SatVaporPres);
}

///////////////////////////////////////////////////////////////////////////////
// Saturated air enthalpy given dry bulb temperature and pressure
// ASHRAE Fundamentals (2005) ch. 6 eqn. 32
//
double GetSatAirEnthalpy        // (o) Saturated air enthalpy [J/kg]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  return GetMoistAirEnthalpy(TDryBulb, GetSatHumRatio(TDryBulb, Pressure));
}

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
  )
{
  double RelHum;

  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
  return GetSatVapPres(TDryBulb)*(1.-RelHum);
}

///////////////////////////////////////////////////////////////////////////////
// ASHRAE Fundamentals (2005) ch. 6 eqn. 12
// ASHRAE Fundamentals (2009) ch. 1 eqn. 12
//
double GetDegreeOfSaturation    // (o) Degree of saturation []
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  return HumRatio/GetSatHumRatio(TDryBulb, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Moist air enthalpy given dry bulb temperature and humidity ratio
// ASHRAE Fundamentals (2005) ch. 6 eqn. 32
// ASHRAE Fundamentals (2009) ch. 1 eqn. 32
//
double GetMoistAirEnthalpy      // (o) Moist Air Enthalpy [J/kg]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  )
{
  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  return (1.006*TDryBulb + HumRatio*(2501. + 1.86*TDryBulb))*KILO;
}

///////////////////////////////////////////////////////////////////////////////
// Moist air volume given dry bulb temperature, humidity ratio, and pressure.
// ASHRAE Fundamentals (2005) ch. 6 eqn. 28
// ASHRAE Fundamentals (2009) ch. 1 eqn. 28
//
double GetMoistAirVolume        // (o) Specific Volume [m3/kg]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  return 0.287042 *(CTOK(TDryBulb))*(1.+1.607858*HumRatio)/(Pressure/KILO);
}

///////////////////////////////////////////////////////////////////////////////
// Moist air density given humidity ratio, dry bulb temperature, and pressure
// ASHRAE Fundamentals (2005) ch. 6 6.8 eqn. 11
// ASHRAE Fundamentals (2009) ch. 1 1.8 eqn 11
//
double GetMoistAirDensity       // (o) Moist air density [kg/m3]
  ( double TDryBulb             // (i) Dry bulb temperature [C]
  , double HumRatio             // (i) Humidity ratio [kgH2O/kgAIR]
  , double Pressure             // (i) Atmospheric pressure [Pa]
  )
{
  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  return (1.+HumRatio)/GetMoistAirVolume(TDryBulb, HumRatio, Pressure);
}

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
  )
{
  *HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
  *TDewPoint = GetTDewPointFromHumRatio(TDryBulb, *HumRatio, Pressure);
  *RelHum = GetRelHumFromHumRatio(TDryBulb, *HumRatio, Pressure);
  *VapPres = GetVapPresFromHumRatio(*HumRatio, Pressure);
  *MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, *HumRatio);
  *MoistAirVolume = GetMoistAirVolume(TDryBulb, *HumRatio, Pressure);
  *DegSaturation = GetDegreeOfSaturation(TDryBulb, *HumRatio, Pressure);
}

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
  )
{
  *HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure);
  *TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, *HumRatio, Pressure);
  *RelHum = GetRelHumFromHumRatio(TDryBulb, *HumRatio, Pressure);
  *VapPres = GetVapPresFromHumRatio(*HumRatio, Pressure);
  *MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, *HumRatio);
  *MoistAirVolume = GetMoistAirVolume(TDryBulb, *HumRatio, Pressure);
  *DegSaturation = GetDegreeOfSaturation(TDryBulb, *HumRatio, Pressure);
}

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
  )
{
  *HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure);
  *TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, *HumRatio, Pressure);
  *TDewPoint = GetTDewPointFromHumRatio(TDryBulb, *HumRatio, Pressure);
  *VapPres = GetVapPresFromHumRatio(*HumRatio, Pressure);
  *MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, *HumRatio);
  *MoistAirVolume = GetMoistAirVolume(TDryBulb, *HumRatio, Pressure);
  *DegSaturation = GetDegreeOfSaturation(TDryBulb, *HumRatio, Pressure);
}

//*****************************************************************************
//                          Standard atmosphere
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Standard atmosphere barometric pressure, given the elevation (altitude)
// ASHRAE Fundamentals (2005) ch. 6 eqn. 3
// ASHRAE Fundamentals (2009) ch. 1 eqn. 1
//
double GetStandardAtmPressure   // (o) standard atmosphere barometric pressure [Pa]
  ( double Altitude             // (i) altitude [m]
  )
{
  double Pressure = 101325.*pow(1.-2.25577e-05*Altitude, 5.2559);
  return Pressure;
}

///////////////////////////////////////////////////////////////////////////////
// Standard atmosphere temperature, given the elevation (altitude)
// ASHRAE Fundamentals (2005) ch. 6 eqn. 4
// ASHRAE Fundamentals (2009) ch. 1 eqn. 4
//
double GetStandardAtmTemperature // (o) standard atmosphere dry bulb temperature [C]
  ( double Altitude              // (i) altitude [m]
  )
{
  double Temperature = 15-0.0065*Altitude;
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
double GetSeaLevelPressure   // (o) sea level barometric pressure [Pa]
  ( double StnPressure       // (i) observed station pressure [Pa]
  , double Altitude          // (i) altitude above sea level [m]
  , double TDryBulb          // (i) dry bulb temperature [°C]
  )
{
  // Calculate average temperature in column of air, assuming a lapse rate
  // of 6.5 °C/km
  double TColumn = TDryBulb + 0.0065*Altitude/2.;

  // Determine the scale height
  double H = 287.055*CTOK(TColumn)/9.807;

  // Calculate the sea level pressure
  double SeaLevelPressure = StnPressure*exp(Altitude/H);
  return SeaLevelPressure;
}

///////////////////////////////////////////////////////////////////////////////
// Station pressure from sea level pressure
// This is just the previous function, reversed
//
double GetStationPressure    // (o) station pressure [Pa]
  ( double SeaLevelPressure  // (i) sea level barometric pressure [Pa]
  , double Altitude          // (i) altitude above sea level [m]
  , double TDryBulb          // (i) dry bulb temperature [°C]
  )
{
  return SeaLevelPressure/GetSeaLevelPressure(1., Altitude, TDryBulb);
}

