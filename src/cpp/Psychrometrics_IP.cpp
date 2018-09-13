// This psychrometrics package is used to demonstrate psychrometric calculations.
// It contains C functions to calculate dew point temperature, wet bulb temperature,
// relative humidity, humidity ratio, partial pressure of water vapor, moist air
// enthalpy, moist air volume, specific volume, and degree of saturation, given
// dry bulb temperature and another psychrometric variable. The code also includes
// functions for standard atmosphere calculation.
// The functions implement formulae found in the 2017 ASHRAE Handbook - Fundamentals.
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
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE. See the GNU General Public License for more
// details.
//
//	You should have received a copy of the GNU General Public License
//  along with this code.  If not, see <http://www.gnu.org/licenses/>.
//
//-----------------------------------------------------------------------------
//    March 31, 2011 - IP version of SI library created
//    August 15, 2018 - Update to 2017 edition of ASHRAE Handbook - Fundamentals
//

// Standard C header files
#include <float.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

// Header specific to this file
#include "psychrometricsIP.h"


//*****************************************************************************\
// Macros and utility functions used in this file
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Constants


#define ZEROF 459.67            // Zero ºF expressed in R
#define INVALID -99999          // Invalid value

// Universal gas constant for dry air in ft∙lb_f/lb_da/R
// ASHRAE Handbook - Fundamentals (2017) - ch. 1, eqn 1
#define Rda 53.350


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
// Conversions from Fahrenheit to Rankin
double FTOR(double T_F) { return T_F+ZEROF; }              /* exact */

//*****************************************************************************
//       Conversions between dew point, wet bulb, and relative humidity
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Wet-bulb temperature given dry-bulb temperature and dew-point temperature
// ASHRAE Handbook - Fundamentals (2017) ch. 1
//
double GetTWetBulbFromTDewPoint // (o) Wet bulb temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double TDewPoint            // (i) Dew point temperature [F]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  double HumRatio;

  ASSERT (TDewPoint <= TDryBulb, "Dew point temperature is above dry bulb temperature")

  HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure);
  return GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Wet-bulb temperature given dry-bulb temperature and relative humidity
// ASHRAE Handbook - Fundamentals (2017) ch. 1
//
double GetTWetBulbFromRelHum    // (o) Wet bulb temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F] //
  , double RelHum               // (i) Relative humidity [0-1] //
  , double Pressure             // (i) Atmospheric pressure [Psi] //
  )
{
  double HumRatio;

  ASSERT (RelHum >= 0 && RelHum <= 1, "Relative humidity is outside range [0,1]")

  HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure);
  return GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Relative humidity given dry-bulb temperature and dew-point temperature
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 22
//
double GetRelHumFromTDewPoint   // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double TDewPoint            // (i) Dew point temperature [F]
    )
{
  double VapPres, SatVapPres;

  ASSERT (TDewPoint <= TDryBulb, "Dew point temperature is above dry bulb temperature")

  VapPres = GetSatVapPres(TDewPoint);
  SatVapPres = GetSatVapPres(TDryBulb);
  return VapPres/SatVapPres;
}

///////////////////////////////////////////////////////////////////////////////
// Relative humidity given dry-bulb temperature and wet bulb temperature
// ASHRAE Handbook - Fundamentals (2017) ch. 1
//
double GetRelHumFromTWetBulb    // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double TWetBulb             // (i) Wet bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  double HumRatio;

  ASSERT (TWetBulb <= TDryBulb, "Wet bulb temperature is above dry bulb temperature")

  HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure);
  return GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Dew point temperature given dry bulb temperature and relative humidity
// ASHRAE Handbook - Fundamentals (2017) ch. 1
//
double GetTDewPointFromRelHum   // (o) Dew Point temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
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
// ASHRAE Handbook - Fundamentals (2017) ch. 1
//
double GetTDewPointFromTWetBulb // (o) Dew Point temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double TWetBulb             // (i) Wet bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [Psi]
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
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
//
double GetVapPresFromRelHum     // (o) Partial pressure of water vapor in moist air [Psi]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double RelHum               // (i) Relative humidity [0-1]
  )
{
  ASSERT (RelHum >= 0 && RelHum <= 1, "Relative humidity is outside range [0,1]")

  return RelHum*GetSatVapPres(TDryBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Relative Humidity given dry bulb temperature and vapor pressure
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
//
double GetRelHumFromVapPres     // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double VapPres              // (i) Partial pressure of water vapor in moist air [Psi]
  )
{
  ASSERT (VapPres >= 0, "Partial pressure of water vapor in moist air is negative")

  return VapPres/GetSatVapPres(TDryBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Dew point temperature given vapor pressure and dry bulb temperature
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 37 & 38
//
double GetTDewPointFromVapPres  // (o) Dew Point temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double VapPres              // (i) Partial pressure of water vapor in moist air [Psi]
  )
{
  double alpha, TDewPoint, VP;

  ASSERT (VapPres >= 0, "Partial pressure of water vapor in moist air is negative")

  VP = VapPres;
  alpha = log(VP);
  if (TDryBulb >= 32 && TDryBulb <= 200)
    TDewPoint = 100.45+33.193*alpha+2.319*alpha*alpha+0.17074*pow(alpha,3)
     +1.2063*pow(VP, 0.1984);                           // (37)
  else if (TDryBulb < 32)
    TDewPoint = 90.12+26.142*alpha+0.8927*alpha*alpha;  // (38)
  else
    TDewPoint = INVALID;                                // Invalid value
  return min(TDewPoint, TDryBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure given dew point temperature
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36
//
double GetVapPresFromTDewPoint  // (o) Partial pressure of water vapor in moist air [Psi]
  ( double TDewPoint            // (i) Dew point temperature [F]
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
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35 solved for Tstar
//
double GetTWetBulbFromHumRatio  // (o) Wet bulb temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [Psi]
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
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35
//
double GetHumRatioFromTWetBulb  // (o) Humidity Ratio [H2O/AIR]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double TWetBulb             // (i) Wet bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  double Wsstar;

  ASSERT (TWetBulb <= TDryBulb, "Wet bulb temperature is above dry bulb temperature")

  Wsstar = GetSatHumRatio(TWetBulb, Pressure);

  if (TWetBulb > 32)
    return ((1093 - 0.556*TWetBulb)*Wsstar - 0.240*(TDryBulb - TWetBulb))
          / (1093 + 0.444*TDryBulb - TWetBulb);
  else
    return ((1220 - 0.04*TWetBulb)*Wsstar - 0.240*(TDryBulb - TWetBulb))
          / (1220 + 0.444*TDryBulb - 0.48*TWetBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given relative humidity
// ASHRAE Handbook - Fundamentals (2017) ch. 1
//
double GetHumRatioFromRelHum    // (o) Humidity Ratio [H2O/AIR]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double RelHum               // (i) Relative humidity [0-1]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  double VapPres;

  ASSERT (RelHum >= 0 && RelHum <= 1, "Relative humidity is outside range [0,1]")

  VapPres = GetVapPresFromRelHum(TDryBulb, RelHum);
  return GetHumRatioFromVapPres(VapPres, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Relative humidity given humidity ratio
// ASHRAE Handbook - Fundamentals (2017) ch. 1
//
double GetRelHumFromHumRatio    // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  double VapPres;

  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure);
  return GetRelHumFromVapPres(TDryBulb, VapPres);
}
///////////////////////////////////////////////////////////////////////////////
// Humidity ratio given dew point temperature and pressure.
// ASHRAE Handbook - Fundamentals (2017) ch. 1
//
double GetHumRatioFromTDewPoint // (o) Humidity Ratio [H2O/AIR]
  ( double TDewPoint            // (i) Dew point temperature [F]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  double VapPres;

  VapPres = GetSatVapPres(TDewPoint);
  return GetHumRatioFromVapPres(VapPres, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Dew point temperature given dry bulb temperature, humidity ratio, and pressure
// ASHRAE Handbook - Fundamentals (2017) ch. 1
//
double GetTDewPointFromHumRatio // (o) Dew Point temperature [F]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [Psi]
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
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20
//
double GetHumRatioFromVapPres   // (o) Humidity Ratio [H2O/AIR]
  ( double VapPres              // (i) Partial pressure of water vapor in moist air [Psi]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  ASSERT (VapPres >= 0, "Partial pressure of water vapor in moist air is negative")

  return 0.621945*VapPres/(Pressure-VapPres);
}

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure given humidity ratio and pressure
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20 solved for pw
//

double GetVapPresFromHumRatio   // (o) Partial pressure of water vapor in moist air [Psi]
  ( double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [Psi]
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
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 28
//
double GetDryAirEnthalpy        // (o) Dry air enthalpy [Btu/lb]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  )
{
  return 0.240*TDryBulb;
}

///////////////////////////////////////////////////////////////////////////////
// Dry air density given dry bulb temperature and pressure.
// ASHRAE Handbook - Fundamentals (2017) ch. 1
// eqn 14 for the perfect gas relationship for dry air
// and eqn 1 for the universal gas constant
// The factor 144 is for the conversion of Psi=lb/in2 to lb/ft2
//
double GetDryAirDensity         // (o) Dry air density [lb/ft3]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  return (144.*Pressure)/R_da/FTOR(TDryBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Dry air volume given dry bulb temperature and pressure.
// ASHRAE Handbook - Fundamentals (2017) ch. 1
// eqn 14 for the perfect gas relationship for dry air
// and eqn 1 for the universal gas constant
// The factor 144 is for the conversion of Psi=lb/in2 to lb/ft2
//
double GetDryAirVolume          // (o) Dry air volume [ft3/lb]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  return FTOR(TDryBulb)*R_da/(144.*Pressure);
}

//*****************************************************************************
//                       Saturated Air Calculations
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Saturation vapor pressure as a function of temperature
// ASHRAE Handbook - Fundamentals (2017) ch. 1  eqn 5
//
double GetSatVapPres            // (o) Vapor Pressure of saturated air [Psi]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  )
{
  double LnPws, T;

  ASSERT(TDryBulb >= -148 && TDryBulb <= 392, "Dry bulb temperature is outside range [-148, 392]")

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
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36, solved for W
//
double GetSatHumRatio           // (o) Humidity ratio of saturated air [H2O/AIR]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [Psi]
    )
{
  double SatVaporPres;

  SatVaporPres = GetSatVapPres(TDryBulb);
  return 0.621945*SatVaporPres/(Pressure-SatVaporPres);
}

///////////////////////////////////////////////////////////////////////////////
// Saturated air enthalpy given dry bulb temperature and pressure
// ASHRAE Handbook - Fundamentals (2017) ch. 1
//
double GetSatAirEnthalpy        // (o) Saturated air enthalpy [Btu/lb]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  ){
  return GetMoistAirEnthalpy(TDryBulb, GetSatHumRatio(TDryBulb, Pressure));
}

//*****************************************************************************
//                       Moist Air Calculations
//*****************************************************************************

///////////////////////////////////////////////////////////////////////////////
// Vapor pressure deficit in Pa given humidity ratio, dry bulb temperature, and
// pressure.
// See Oke (1987) eqn 2.13a
//
double GetVPD                   // (o) Vapor pressure deficit [Psi]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  double RelHum;

  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure);
  return GetSatVapPres(TDryBulb)*(1.-RelHum);
}

///////////////////////////////////////////////////////////////////////////////
// ASHRAE Handbook - Fundamentals (2009) ch. 1 eqn 12
// (Note: the definition is absent from the 2017 Handbook)
//
double GetDegreeOfSaturation    // (o) Degree of saturation []
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  return HumRatio/GetSatHumRatio(TDryBulb, Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Moist air enthalpy given dry bulb temperature and humidity ratio
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30
//
double GetMoistAirEnthalpy      // (o) Moist Air Enthalpy [Btu/lb]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  )
{
  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  return 0.240*TDryBulb + HumRatio*(1061 + 0.444*TDryBulb);
}

///////////////////////////////////////////////////////////////////////////////
// Moist air specific volume given dry bulb temperature, humidity ratio, and pressure.
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26
// Rda / 144 is equal to 0.370486. The 144 factor is for the conversion of Psi = lb/in2 to lb/ft2
//
double GetMoistAirVolume        // (o) Specific volume [ft3/lb of dry air]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  return Rda*FTOR(TDryBulb)*(1.+1.607858*HumRatio)/(144.*Pressure);
}

///////////////////////////////////////////////////////////////////////////////
// Moist air density given humidity ratio, dry bulb temperature, and pressure
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 11
//
double GetMoistAirDensity       // (o) Moist air density [lb/ft3]
  ( double TDryBulb             // (i) Dry bulb temperature [F]
  , double HumRatio             // (i) Humidity ratio [H2O/AIR]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  )
{
  ASSERT (HumRatio >= 0, "Humidity ratio is negative")

  return (1.+HumRatio)/GetMoistAirVolume(TDryBulb, HumRatio, Pressure);
}

//*****************************************************************************
//                Functions to set all psychrometric values
//*****************************************************************************

void CalcPsychrometricsFromTWetBulb
  ( double *TDewPoint           // (o) Dew point temperature [F]
  , double *RelHum              // (o) Relative humidity [0-1]
  , double *HumRatio            // (o) Humidity ratio [H2O/AIR]
  , double *VapPres             // (o) Partial pressure of water vapor in moist air [Psi]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy [Btu/lb]
  , double *MoistAirVolume      // (o) Specific volume [ft3/lb]
  , double *DegSaturation       // (o) Degree of saturation []
  , double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  , double TWetBulb             // (i) Wet bulb temperature [F]
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
  ( double *TWetBulb            // (o) Wet bulb temperature [F]
  , double *RelHum              // (o) Relative humidity [0-1]
  , double *HumRatio            // (o) Humidity ratio [H2O/AIR]
  , double *VapPres             // (o) Partial pressure of water vapor in moist air [Psi]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy [Btu/lb]
  , double *MoistAirVolume      // (o) Specific volume [ft3/lb]
  , double *DegSaturation       // (o) Degree of saturation []
  , double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [Psi]
  , double TDewPoint            // (i) Dew point temperature [F]
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
  ( double *TWetBulb            // (o) Wet bulb temperature [F]
  , double *TDewPoint           // (o) Dew point temperature [F]
  , double *HumRatio            // (o) Humidity ratio [kgH2O/kgAIR]
  , double *VapPres             // (o) Partial pressure of water vapor in moist air [Psi]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy [Btu/lb]
  , double *MoistAirVolume      // (o) Specific volume [ft3/lb]
  , double *DegSaturation       // (o) Degree of saturation []
  , double TDryBulb             // (i) Dry bulb temperature [F]
  , double Pressure             // (i) Atmospheric pressure [Psi]
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
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 3
//
double GetStandardAtmPressure   // (o) Standard atmosphere barometric pressure [Psi]
  ( double Altitude             // (i) Altitude [ft]
  )
{
  double Pressure = 14.696*pow(1.-6.8754e-06*Altitude, 5.2559);
  return Pressure;
}

///////////////////////////////////////////////////////////////////////////////
// Standard atmosphere temperature, given the elevation (altitude)
// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 4
//
double GetStandardAtmTemperature // (o) Standard atmosphere dry bulb temperature [F]
  ( double Altitude              // (i) Altitude [ft]
  )
{
  double Temperature = 59-0.00356620*Altitude;
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
double GetSeaLevelPressure      // (o) Sea level barometric pressure [Psi]
  ( double StnPressure          // (i) Observed station pressure [Psi]
  , double Altitude             // (i) Altitude above sea level [ft]
  , double TDryBulb             // (i) Dry bulb temperature [°F]
  )
{
  // Calculate average temperature in column of air, assuming a lapse rate
  // of 3.6 °F/1000ft
  double TColumn = TDryBulb + 0.0036*Altitude/2.;

  // Determine the scale height
  double H = 53.351*FTOR(TColumn);

  // Calculate the sea level pressure
  double SeaLevelPressure = StnPressure*exp(Altitude/H);
  return SeaLevelPressure;
}

///////////////////////////////////////////////////////////////////////////////
// Station pressure from sea level pressure
// This is just the previous function, reversed
//
double GetStationPressure       // (o) Station pressure [Psi]
  ( double SeaLevelPressure     // (i) Sea level barometric pressure [Psi]
  , double Altitude             // (i) Altitude above sea level [ft]
  , double TDryBulb             // (i) Dry bulb temperature [°F]
  )
{
  return SeaLevelPressure/GetSeaLevelPressure(1., Altitude, TDryBulb);
}