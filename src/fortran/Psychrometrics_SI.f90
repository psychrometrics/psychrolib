!+ Contains a number of functions and subroutines for calculating thermodynamic properties
!+ of gas-vapor mixtures for most engineering, physical and meteorological applications
!+ in SI units.
module Psychrometrics_SI
  !+#####Module overview
  !+ Library module for determining common physical and thermodynamic properties
  !+ of gas-vapor mixtures for most engineering, physical and meteorological applications.
  !+ Most of the functions contained in `Psychrometrics_SI` were implemented from the formulae
  !+ taken from the 2005 and 2009 Ashrae Handbook: Fundamentals, SI Edition (ASHRAE (American Society of Heating
  !+ Refrigerating and Air-Conditioning Engineers) 2005, 2009). For details about other function, please
  !+ follow the corresponding reference inside each function.
  !+---
  !+#####References
  !+ - ASHRAE (American Society of Heating Refrigerating and Air-Conditioning Engineers),
  !+2009: 2009 Ashrae Handbook: Fundamentals, SI Edition. 30329, 926.
  !+ - ASHRAE (American Society of Heating Refrigerating and Air-Conditioning Engineers),
  !+2005: 2005 Ashrae Handbook: Fundamentals, SI Edition. 1000.
  !+---
  !+#####Note from the author
  !+ I have made every effort to ensure that the code is adequate,
  !+ however I make no representation with respect to its accuracy. Use at your
  !+ own risk. Should you notice any error, or if you have suggestions on how to
  !+ improve the code, please notify me through GitHub.
  !+---
  !+#####Legal notice
  !+ This file is provided for free.  You can redistribute it and/or
  !+ modify it under the terms of the GNU General Public
  !+ License as published by the Free Software Foundation
  !+ (version 3 or later).
  !+
  !+ This source code is distributed in the hope that it will be useful
  !+ but WITHOUT ANY WARRANTY; without even the implied
  !+ warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  !+ PURPOSE. See the GNU General Public License for more
  !+ details.
  !+
  !+ You should have received a copy of the GNU General Public License
  !+ along with this code.  If not, see <http://www.gnu.org/licenses/>.
  !+---
  !+#####History
  !+ `Psychrometrics_SI` was initially released for C++ and developed by Didier Thevenard, PhD, P.Eng.,
  !+ whilst working on the simulation software for solar energy systems and climatic data processing.
  !+ It has since been moved to GitHub at <https://github.com/psychrometrics/libraries>
  !+ along with its documentation.
  !+
  !+- dmey - 22-05-2017: fork from C++ version and rewrite following Fortran 2008 standards.
  !+- dmey - 22-05-2017: add `GetSatAirTemperatureFromEnthalpy` to compute the saturation temperature from enthalpy and pressure.
  !+- dmey - 22-05-2017: add `GetHumRatioFromEnthalpy` to compute humidity ratio given dry bulb temperature and enthalpy.
  !+- dmey - 22-05-2017: add `GetAirHeatCapacity` to compute heat capacity of air from dry bulb temperature and humidity ratio.
  !+- dmey - 30-05-2017: add `GetTDryBulbFromEnthalpy` to compute dry bulb temperature from enthalpy and humidity ratio.
  !+---

  ! Import fortran 2008 standard to represent double-precision floating-point format
  use, intrinsic :: iso_fortran_env
  implicit none

  private
  public :: GetTWetBulbFromTDewPoint
  public :: GetTWetBulbFromRelHum
  public :: GetRelHumFromTDewPoint
  public :: GetRelHumFromTWetBulb
  public :: GetTDewPointFromRelHum
  public :: GetTDewPointFromTWetBulb
  public :: GetTDryBulbFromEnthalpy
  public :: GetVapPresFromRelHum
  public :: GetRelHumFromVapPres
  public :: GetTDewPointFromVapPres
  public :: GetVapPresFromTDewPoint
  public :: GetTWetBulbFromHumRatio
  public :: GetHumRatioFromTWetBulb
  public :: GetHumRatioFromEnthalpy
  public :: GetHumRatioFromRelHum
  public :: GetRelHumFromHumRatio
  public :: GetHumRatioFromTDewPoint
  public :: GetTDewPointFromHumRatio
  public :: GetHumRatioFromVapPres
  public :: GetVapPresFromHumRatio
  public :: GetDryAirEnthalpy
  public :: GetDryAirDensity
  public :: GetDryAirVolume
  public :: GetSatVapPres
  public :: GetSatHumRatio
  public :: GetSatAirEnthalpy
  public :: GetVPD
  public :: GetDegreeOfSaturation
  public :: GetMoistAirEnthalpy
  public :: GetMoistAirVolume
  public :: GetMoistAirDensity
  public :: GetAirHeatCapacity
  public :: GetSatAirTemperatureFromEnthalpy
  public :: CalcPsychrometricsFromTWetBulb
  public :: CalcPsychrometricsFromTDewPoint
  public :: CalcPsychrometricsFromRelHum
  public :: GetStandardAtmPressure
  public :: GetStandardAtmTemperature
  public :: GetSeaLevelPressure
  public :: GetStationPressure

  integer, parameter :: dp = REAL64
    !+ Fortran 2008 standard to represent double-precision floating-point format (use `iso_fortran_env`)

  ! Global Constants
  real(dp), parameter ::  RGAS        = 8.314472_dp
    !+ Universal gas constant in J mol⁻¹ K⁻¹
  real(dp), parameter ::  MOLMASSAIR  = 28.966d-3
    !+ Mean molar mass of dry air in kg mol⁻¹
  real(dp), parameter ::  KILO        = 1000.0_dp
    !+ Exact
  real(dp), parameter ::  ZEROC       = 273.15_dp
    !+ Zero degree C expressed in K

  contains

  pure function CTOK(T_C) result(T_K)
  !+ Converts degree Celsius to Kelvin
    real(dp), intent(in)  :: T_C
      !+ Temperature in °C
    real(dp)              :: T_K
      !+ Temperature in K

    T_K = T_C+ZEROC
  end function CTOK

  !----------------------------------------------------------------------------------
  ! Functions to convert between dew point, wet bulb, and relative humidity
  !----------------------------------------------------------------------------------

  function GetTWetBulbFromTDewPoint(TDryBulb, TDewPoint, Pressure) result(TWetBulb)
    !+ Wet-bulb temperature given dry-bulb temperature and dew-point temperature.
    !+ References:
    !+ ASHRAE Fundamentals (2005) ch. 6;
    !+ ASHRAE Fundamentals (2009) ch. 1.

    real(dp), intent(in)  :: TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  :: TDewPoint
      !+ Dew point temperature in °C
    real(dp), intent(in)  :: Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              :: TWetBulb
      !+ Wet bulb temperature in °C
    real(dp)              :: HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹

    if (TDewPoint > TDryBulb) then
      error stop "Error: dew point temperature is above dry bulb temperature"
    end if

    HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure)
    TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
  end function GetTWetBulbFromTDewPoint

  function GetTWetBulbFromRelHum(TDryBulb, RelHum, Pressure) result(TWetBulb)
    !+ Wet-bulb temperature given dry-bulb temperature and relative humidity.
    !+ References:
    !+ ASHRAE Fundamentals (2005) ch. 6;
    !+ ASHRAE Fundamentals (2009) ch. 1.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  RelHum
      !+ Relative humidity in range between 0 and 1
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  TWetBulb
      !+ Wet bulb temperature in °C
    real(dp)              ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹

    if (RelHum < 0.0_dp .or. RelHum > 1.0_dp) then
      error stop "Error: relative humidity is outside range [0,1]"
    end if

    HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure)
    TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
  end function GetTWetBulbFromRelHum

  function GetRelHumFromTDewPoint(TDryBulb, TDewPoint) result(RelHum)
    !+ Relative Humidity given dry-bulb temperature and dew-point temperature.
    !+ References:
    !+ ASHRAE Fundamentals (2005) ch. 6;
    !+ ASHRAE Fundamentals (2009) ch. 1.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  TDewPoint
      !+ Dew point temperature in °C
    real(dp)              ::  RelHum
      !+ Relative humidity in range between 0 and 1
    real(dp)              ::  VapPres
      !+ Partial pressure of water vapor in moist air in Pa
    real(dp)              ::  SatVapPres
      !+ Vapor Pressure of saturated air in Pa

    if (TDewPoint > TDryBulb) then
      error stop "Error: dew point temperature is above dry bulb temperature"
    end if

    VapPres     = GetSatVapPres(TDewPoint)                             ! Eqn. 36
    SatVapPres  = GetSatVapPres(TDryBulb)
    RelHum      = VapPres / SatVapPres                                   ! Eqn. 24
  end function GetRelHumFromTDewPoint

  function GetRelHumFromTWetBulb(TDryBulb, TWetBulb, Pressure) result(RelHum)
    !+ Relative Humidity given dry-bulb temperature and wet bulb temperature.
    !+ References:
    !+ ASHRAE Fundamentals (2005) ch. 6;
    !+ ASHRAE Fundamentals (2009) ch. 1.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  TWetBulb
      !+ Wet bulb temperature in °C
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  RelHum
      !+ Relative humidity in range between 0 and 1
    real(dp)              ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹

    if (TWetBulb > TDryBulb) then
      error stop "Error: wet bulb temperature is above dry bulb temperature"
    end if

    HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    RelHum   = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
  end function GetRelHumFromTWetBulb

  function GetTDewPointFromRelHum(TDryBulb, RelHum) result(TDewPoint)
    !+ Dew Point Temperature given dry bulb temperature and relative humidity.
    !+ References:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn 24;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn 24.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  RelHum
      !+ Relative humidity in range between 0 and 1
    real(dp)              ::  TDewPoint
      !+ Dew Point temperature in °C
    real(dp)              ::  VapPres
      !+ Partial pressure of water vapor in moist air in Pa

    if (RelHum < 0.0_dp .or. RelHum > 1.0_dp) then
      error stop "Error: relative humidity is outside range [0,1]"
    end if

    VapPres   = GetVapPresFromRelHum(TDryBulb, RelHum)
    TDewPoint = GetTDewPointFromVapPres(TDryBulb, VapPres)
  end function GetTDewPointFromRelHum

  function GetTDewPointFromTWetBulb(TDryBulb, TWetBulb, Pressure) result(TDewPoint)
    !+ Dew Point Temperature given dry bulb temperature and wet bulb temperature.
    !+ References:
    !+ ASHRAE Fundamentals (2005) ch. 6;
    !+ ASHRAE Fundamentals (2009) ch. 1.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  TWetBulb
      !+ Wet bulb temperature in °C
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  TDewPoint
      !+ Dew Point temperature in °C
    real(dp)              ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹

    if (TWetBulb > TDryBulb) then
      error stop "Error: wet bulb temperature is above dry bulb temperature"
    end if

    HumRatio  = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
  end function GetTDewPointFromTWetBulb

  function GetTDryBulbFromEnthalpy(Enthalpy, HumRatio) result(TDryBulb)
    !+ Dry bulb temperature from Enthalpy and humidity ratio
    !+ Based on the `GetMoistAirEnthalpy` function, rearranged for humidity ratio
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 32;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 32.

    real(dp), intent(in)  ::  Enthalpy
      !+ Enthalpy in J kg⁻¹
    real(dp), intent(in)  ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp)              ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp)              ::  BoundedHumRatio
      !+ Local function humidity ratio bounded to no less than 1.0d-5 kgH₂O kgAIR⁻¹

    if (HumRatio < 0.0_dp) then
      error stop "Error: humidity ratio is negative"
    end if

    ! Bound humidity ratio to no less than 1.0d-5 kgH₂O kgAIR⁻¹
    BoundedHumRatio = max(HumRatio, 1.0d-5)

    TDryBulb  = (Enthalpy - 2.501d6 * BoundedHumRatio) / (1.006d3 + 1.86d3 * BoundedHumRatio)
  end function GetTDryBulbFromEnthalpy

  !----------------------------------------------------------------------------------
  ! Functions to convert between dew point, or relative humidity and vapor pressure
  !----------------------------------------------------------------------------------

  function GetVapPresFromRelHum(TDryBulb, RelHum) result(VapPres)
    !+ Partial pressure of water vapor as a function of relative humidity and
    !+ temperature.
    !+ References:
    !+ ASHRAE Fundamentals (2005) ch. 6, eqn. 24;
    !+ ASHRAE Fundamentals (2009) ch. 1, eqn. 24.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  RelHum
      !+ Relative humidity in range between 0 and 1
    real(dp)              ::  VapPres
      !+ Partial pressure of water vapor in moist air in Pa

    if (RelHum < 0.0_dp .or. RelHum > 1.0_dp) then
      error stop "Error: relative humidity is outside range [0,1]"
    end if

    VapPres = RelHum * GetSatVapPres(TDryBulb)
  end function GetVapPresFromRelHum

  function GetRelHumFromVapPres(TDryBulb, VapPres) result(RelHum)
    !+ Relative Humidity given dry bulb temperature and vapor pressure.
    !+ References:
    !+ ASHRAE Fundamentals (2005) ch. 6, eqn. 24;
    !+ ASHRAE Fundamentals (2009) ch. 1, eqn. 24.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  VapPres
      !+ Partial pressure of water vapor in moist air in Pa
    real(dp)              ::  RelHum
      !+ Relative humidity in range between 0 and 1

    if (VapPres < 0.0_dp) then
      error stop "Error: partial pressure of water vapor in moist air is negative"
    end if

    RelHum = VapPres / GetSatVapPres(TDryBulb)
  end function GetRelHumFromVapPres

  function GetTDewPointFromVapPres(TDryBulb, VapPres) result(TDewPoint)
    !+ Dew point temperature given vapor pressure and dry bulb temperature.
    !+ References:
    !+ ASHRAE Fundamentals (2005) ch. 6, eqn. 39 and 40;
    !+ ASHRAE Fundamentals (2009) ch. 1, eqn. 39 and 40.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  VapPres
      !+ Partial pressure of water vapor in moist air in Pa
    real(dp)              ::  TDewPoint
      !+ Dew Point temperature in °C
    real(dp)              ::  VP
      !+ Partial pressure of water vapor in moist air in kPa
    real(dp)              ::  alpha
      !+ log of VP (dimensionless)

    if (VapPres < 0.0_dp) then
      error stop "Error: partial pressure of water vapor in moist air is negative"
    end if

    VP = VapPres/1000.0_dp
    alpha = log(VP)

    if (TDryBulb >= 0.0_dp .and. TDryBulb <= 93.0_dp) then
      TDewPoint = 6.54_dp + 14.526_dp * alpha + 0.7389_dp * alpha * alpha + 0.09486_dp * alpha**3.0_dp &      ! (39)
                  + 0.4569_dp * VP**0.1984_dp
    else if (TDryBulb < 0.0_dp) then
      TDewPoint = 6.09_dp + 12.608_dp * alpha + 0.4959_dp * alpha * alpha                                     ! (40)
    else
      error stop "Error: the dry bulb temperature is greater than 93 °C"
    end if

    TDewPoint = min(TDewPoint, TDryBulb)
  end function GetTDewPointFromVapPres

  function GetVapPresFromTDewPoint(TDewPoint) result(VapPres)
    !+ Vapor pressure given dew point temperature.
    !+ References:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 38;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 38.

    real(dp), intent(in)  ::  TDewPoint
      !+ Dew point temperature in °C
    real(dp)              ::  VapPres
      !+ Partial pressure of water vapor in moist air in Pa

    VapPres = GetSatVapPres(TDewPoint)
  end function GetVapPresFromTDewPoint

  !----------------------------------------------------------------------------------
  ! Functions to convert from wet bulb temperature, dew point temperature,
  !                or relative humidity to humidity ratio
  !----------------------------------------------------------------------------------

  function GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure) result(TWetBulb)
    !+ Wet bulb temperature given humidity ratio.
    !+ References:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 35;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 35.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  TWetBulb
      !+ Wet bulb temperature in °C
    real(dp)              ::  TDewPoint
      !+ Dew point temperature in °C
    real(dp)              ::  TWetBulbSup
      !+ Upper value of wet bulb temperature in bissection method (initial guess is from dry bulb temperature) in °C
    real(dp)              ::  TWetBulbInf
      !+ Lower value of wet bulb temperature in bissection method (initial guess is from dew point temperature) in °C
    real(dp)              ::  Wstar
      !+ Humidity ratio at temperature Tstar in kgH₂O kgAIR⁻¹

    if (HumRatio < 0.0_dp) then
      error stop "Error: humidity ratio is negative"
    end if

    TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)

    ! Initial guesses
    TWetBulbSup = TDryBulb
    TWetBulbInf = TDewPoint
    TWetBulb = (TWetBulbInf + TWetBulbSup) / 2.0_dp

    ! Bisection loop
    do while(TWetBulbSup - TWetBulbInf > 0.001_dp)

    ! Compute humidity ratio at temperature Tstar
    Wstar = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)

    ! Get new bounds
    if (Wstar > HumRatio) then
      TWetBulbSup = TWetBulb
    else
      TWetBulbInf = TWetBulb
    end if

    ! New guess of wet bulb temperature
    TWetBulb = (TWetBulbSup + TWetBulbInf) / 2.0_dp
    end do
  end function GetTWetBulbFromHumRatio

  function GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure) result(HumRatio)
    !+ Humidity ratio given wet bulb temperature and dry bulb temperature.
    !+ References:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 35;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 35.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  TWetBulb
      !+ Wet bulb temperature in °C
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp)              ::  Wsstar
      !+ Humidity ratio at temperature Tstar in kgH₂O kgAIR⁻¹

    if (TWetBulb > TDryBulb) then
      error stop "Error: wet bulb temperature is above dry bulb temperature"
    end if

    Wsstar = GetSatHumRatio(TWetBulb, Pressure)

    HumRatio  =  ( (2501.0_dp - 2.326_dp * TWetBulb) * Wsstar - 1.006_dp * (TDryBulb - TWetBulb) ) &
                  / (2501.0_dp + 1.86_dp * TDryBulb - 4.186_dp * TWetBulb)
  end function GetHumRatioFromTWetBulb

  function GetHumRatioFromEnthalpy(TDryBulb, Enthalpy) result(HumRatio)
    !+ Humidity ratio given dry bulb temperature and enthalpy.
    !+ Based on the `GetMoistAirEnthalpy` function, rearranged for humidity ratio
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 32;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 32.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  Enthalpy
      !+ Air enthalpy in J kg⁻¹
    real(dp)              ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp)              ::  MixingRatio
      !+ Mixing ratio in kgH₂O kgAIR⁻¹ (dry air)

    HumRatio = ( Enthalpy - 1.006d3 * TDryBulb ) / (2.501d6 + 1.86d3 * TDryBulb)

    ! Check that MixingRatio is not less than 0
    if (HumRatio < 0.0_dp) then
        HumRatio = 1.d-5
    end if

  end function GetHumRatioFromEnthalpy

  function GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure) result(HumRatio)
    !+ Humidity ratio given relative humidity.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 38;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 38.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  RelHum
      !+ Relative humidity in range between 0 and 1
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp)              ::  VapPres
      !+ Partial pressure of water vapor of moist air in Pa

    if (RelHum < 0.0_dp .or. RelHum > 1.0_dp) then
      error stop "Error: relative humidity is outside range [0,1]"
    end if

    VapPres   = GetVapPresFromRelHum(TDryBulb, RelHum)
    HumRatio  = GetHumRatioFromVapPres(VapPres, Pressure)
  end function GetHumRatioFromRelHum

  function GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure) result(RelHum)
  !+ Relative humidity given humidity ratio.
  !+ Reference:
  !+ ASHRAE Fundamentals (2005) ch. 6;
  !+ ASHRAE Fundamentals (2009) ch. 1.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  RelHum
      !+ Relative humidity in range between 0 and 1
    real(dp)              ::  VapPres
      !+ Partial pressure of water vapor of moist air in Pa

    if (HumRatio < 0.0_dp) then
      error stop "Error: humidity ratio is negative"
    end if

    VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
    RelHum  = GetRelHumFromVapPres(TDryBulb, VapPres)
  end function GetRelHumFromHumRatio

  function GetHumRatioFromTDewPoint(TDewPoint, Pressure) result(HumRatio)
    !+ Humidity ratio given dew point temperature and pressure.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 22;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 22.

    real(dp), intent(in)  ::  TDewPoint
      !+ Dew point temperature in °C
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp)              ::  VapPres
      !+ Partial pressure of water vapor of moist air in Pa

    VapPres   = GetSatVapPres(TDewPoint)
    HumRatio  = GetHumRatioFromVapPres(VapPres, Pressure)
  end function GetHumRatioFromTDewPoint

  function GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure) result(TDewPoint)
    !+ Dew point temperature given dry bulb temperature, humidity ratio, and pressure.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6;
    !+ ASHRAE Fundamentals (2009) ch. 1.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  TDewPoint
      !+ Dew point temperature in °C
    real(dp)              ::  VapPres
      !+ Partial pressure of water vapor in moist air in Pa

    if (HumRatio < 0.0_dp) then
      error stop "Error: humidity ratio is negative"
    end if

    VapPres   = GetVapPresFromHumRatio(HumRatio, Pressure)
    TDewPoint = GetTDewPointFromVapPres(TDryBulb, VapPres)
  end function GetTDewPointFromHumRatio

  !----------------------------------------------------------------------------------
  ! Functions to convert between humidity ratio and vapor pressure
  !----------------------------------------------------------------------------------

  function GetHumRatioFromVapPres(VapPres, Pressure) result(HumRatio)
    !+ Humidity ratio given water vapor pressure and atmospheric pressure
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 22;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 22.

    real(dp), intent(in)  ::  VapPres
      !+ Partial pressure of water vapor in moist air in Pa
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹

    if (VapPres < 0.0_dp) then
      error stop "Error: partial pressure of water vapor in moist air is negative"
    end if

    HumRatio = 0.621945_dp * VapPres / (Pressure-VapPres)
  end function GetHumRatioFromVapPres

  function GetVapPresFromHumRatio(HumRatio, Pressure) result(VapPres)
    !+ Vapor pressure given humidity ratio and pressure.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 22;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 22.

    real(dp), intent(in)  ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  VapPres
      !+ Partial pressure of water vapor of moist air in Pa

    if (HumRatio < 0.0_dp) then
      error stop "Error: humidity ratio is negative"
    end if

    VapPres = Pressure * HumRatio / (0.621945_dp + HumRatio)
  end function GetVapPresFromHumRatio

  !----------------------------------------------------------------------------------
  ! Functions for dry air calculations
  !----------------------------------------------------------------------------------

  function GetDryAirEnthalpy(TDryBulb) result(DryAirEnthalpy)
    !+ Dry air enthalpy given dry bulb temperature.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 30;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 30.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp)              ::  DryAirEnthalpy
      !+ Dry air enthalpy in J kg⁻¹

    DryAirEnthalpy = 1.006d3 * TDryBulb
  end function GetDryAirEnthalpy

  function GetDryAirDensity(TDryBulb, Pressure) result(DryAirDensity)
    !+ Dry air density given dry bulb temperature and pressure.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 28;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 28.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  DryAirDensity
      !+ Dry air density in kg m⁻³

    DryAirDensity = Pressure * MOLMASSAIR / (RGAS * CTOK(TDryBulb))
  end function GetDryAirDensity

  function GetDryAirVolume(TDryBulb, Pressure) result(DryAirVolume)
    !+ Dry air volume given dry bulb temperature and pressure.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 28;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 28.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  DryAirVolume
      !+ Dry air volume in m³ kg⁻¹

    DryAirVolume = (RGAS * CTOK(TDryBulb)) / (Pressure * MOLMASSAIR)
  end function GetDryAirVolume

  !----------------------------------------------------------------------------------
  ! Functions for saturated air calculations
  !----------------------------------------------------------------------------------

  function GetSatVapPres(TDryBulb) result(SatVapPres)
    !+ Saturation vapor pressure as a function of temperature.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 5, 6;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 5, 6.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp)              ::  SatVapPres
      !+ Vapor Pressure of saturated air in Pa
    real(dp)              ::  LnPws
      !+ Log of Vapor Pressure of saturated air (dimensionless)
    real(dp)              ::  T
      !+ Dry bulb temperature in K

    if (TDryBulb < -100.0_dp .or. TDryBulb > 200.0_dp) then
      error stop "Error: dry bulb temperature is outside range [-100, 200]"
    end if

    T = CTOK(TDryBulb)

    if (TDryBulb >= -100.0_dp .and. TDryBulb <= 0.0_dp) then
      LnPws = -5.6745359d3/T + 6.3925247_dp - 9.677843d-3*T + 6.2215701d-7*T*T &
              + 2.0747825d-9*T**3.0_dp - 9.484024d-13*T**4.0_dp + 4.1635019_dp*log(T)

    else if (TDryBulb > 0.0_dp .and. TDryBulb <= 200.0_dp) then
      LnPws = -5.8002206d3/T + 1.3914993_dp - 4.8640239d-2*T + 4.1764768d-5*T*T &
              - 1.4452093d-8*T**3.0_dp + 6.5459673_dp*log(T)

    else
      error stop "Error: dry bulb temperature is out of range [-100, 200]"
    end if

    SatVapPres = exp(LnPws)
  end function GetSatVapPres

  function GetSatHumRatio(TDryBulb, Pressure) result(SatHumRatio)
    !+ Humidity ratio of saturated air given dry bulb temperature and pressure.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 23;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 23.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  HumRatio
      !+ Humidity ratio of saturated air in kgH₂O kgAIR⁻¹
    real(dp)              ::  SatVaporPres
      !+ Vapor pressure of saturated air in Pa

    SatVaporPres  = GetSatVapPres(TDryBulb)
    SatHumRatio      = 0.621945_dp * SatVaporPres / (Pressure-SatVaporPres)
  end function GetSatHumRatio

  function GetSatAirEnthalpy(TDryBulb, Pressure) result(SatAirEnthalpy)
    !+ Saturated air enthalpy given dry bulb temperature and pressure.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 32.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  SatAirEnthalpy
      !+ Saturated air enthalpy in J kg⁻¹

    SatAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, GetSatHumRatio(TDryBulb, Pressure))
  end function GetSatAirEnthalpy

  !----------------------------------------------------------------------------------
  ! Functions for moist air calculations
  !----------------------------------------------------------------------------------

  function GetVPD(TDryBulb, HumRatio, Pressure) result(VPD)
    !+ Vapor pressure deficit given humidity ratio, dry bulb temperature, and
    !+ pressure.
    !+ Reference:
    !+ See Oke (1987) eqn. 2.13a.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  VPD
      !+ Vapor pressure deficit in Pa
    real(dp)              ::  RelHum
      !+ Relative humidity in range between 0 and 1

    if (HumRatio < 0.0_dp) then
      error stop "Error: humidity ratio is negative"
    end if

    RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
    VPD = GetSatVapPres(TDryBulb) * (1.0_dp - RelHum)
  end function GetVPD

  function GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure) result(DegreeOfSaturation)
    !+ Degree of saturation given dry bulb temperature, humidity ratio and pressure.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 12;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 12.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  DegreeOfSaturation
      !+ DegreeOfSaturation (dimensionless)

    if (HumRatio < 0.0_dp) then
      error stop "Error: humidity ratio is negative"
    end if

    DegreeOfSaturation = HumRatio/GetSatHumRatio(TDryBulb, Pressure)
  end function GetDegreeOfSaturation

  function GetMoistAirEnthalpy(TDryBulb, HumRatio) result(MoistAirEnthalpy)
    !+ Moist air enthalpy given dry bulb temperature and humidity ratio.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 32;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 32.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp)              ::  MoistAirEnthalpy
      !+ Moist Air Enthalpy in J kg⁻¹

    if (HumRatio < 0.0_dp) then
      error stop "Error: humidity ratio is negative"
    end if

     MoistAirEnthalpy = 1.006d3 * TDryBulb + HumRatio * (2.501d6 + 1.86d3 * TDryBulb)
  end function GetMoistAirEnthalpy

  function GetMoistAirVolume(TDryBulb, HumRatio, Pressure) result(MoistAirVolume)
    !+ Moist air volume given dry bulb temperature, humidity ratio, and pressure.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 28;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 28.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  MoistAirVolume
      !+ Specific Volume in m³ kg⁻¹

    if (HumRatio < 0.0_dp) then
      error stop "Error: humidity ratio is negative"
    end if

    MoistAirVolume = 0.287042_dp * CTOK(TDryBulb) * ( 1.0_dp + 1.607858_dp * HumRatio) / (Pressure / KILO)
  end function GetMoistAirVolume

  function GetMoistAirDensity(TDryBulb, HumRatio, Pressure) result(MoistAirDensity)
    !+ Moist air density given humidity ratio, dry bulb temperature, and pressure.
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 6.8 eqn. 11;
    !+ ASHRAE Fundamentals (2009) ch. 1 1.8 eqn 11.

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp), intent(in)  ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              ::  MoistAirDensity
      !+ Moist air density in kg m⁻³

    if (HumRatio < 0.0_dp) then
      error stop "Error: humidity ratio is negative"
    end if

    MoistAirDensity = (1. + HumRatio)/GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
  end function GetMoistAirDensity

  function GetAirHeatCapacity(TDryBulb, HumRatio) result(AirHeatCapacity)
    !+ Heat capacity of air given dry bulb temperature and humidity ratio.
    !+ Adapted from the `PsyCpAirFnWTdb` function from Energy Plus.
    !+ Source:
    !+ [Energy Plus `PsyCpAirFnWTdb` function](https://github.com/NREL/EnergyPlusRelease/
    !+blob/1ba8474958dbac5a371362731b23310d40e0635d/SourceCode/PsychRoutines.f90#L377-L445).

    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)  ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp)              ::  AirHeatCapacity
      !+ Heat capacity of air in J kg⁻¹ °C⁻¹ == J kg⁻¹ K⁻¹

    ! Local variables
    real(dp) :: AirEnthalpyMin
      !+ GetMoistAirEnthalpy result of input parameters in J kg⁻¹ °C⁻¹
    real(dp) :: AirEnthalpyMax
      !+ GetMoistAirEnthalpy result of input humidity ratio at TDryBulb + deltaT in J kg⁻¹ °C⁻¹
    real(dp) :: BoundedHumRatio
      !+ Bounded humidity ratio in kgH₂O kgAIR⁻¹
    real(dp) :: DeltaT = 0.1_dp
      !+ temperature step size in °C

    if (HumRatio < 0.0_dp) then
      error stop "Error: humidity ratio is negative"
    end if

    BoundedHumRatio = max(HumRatio, 1.0d-5)
    AirEnthalpyMin  = GetMoistAirEnthalpy(TDryBulb, BoundedHumRatio)
    AirEnthalpyMax = GetMoistAirEnthalpy(TDryBulb + deltaT, BoundedHumRatio)
    AirHeatCapacity = (AirEnthalpyMax - AirEnthalpyMin) / deltaT
  end function GetAirHeatCapacity

  function GetSatAirTemperatureFromEnthalpy(Enthalpy, Pressure) result(SatAirTemperature)
    !+ This function provides the saturation temperature from the enthalpy
    !+ and barometric pressure.
    !+ This implementation was adapted from Energy Plus. Function originally written by George Shih
    !+ and modified in July 2003 by LKL -- peg min/max values (outside range of functions).
    !+ Source:
    !+ [Energy Plus `PsyTsatFnHPb` function](https://github.com/NREL/EnergyPlusRelease/
    !+blob/1ba8474958dbac5a371362731b23310d40e0635d/SourceCode/PsychRoutines.f90#L2331-L2542).
    !+ Original reference:
    !+ ASHRAE Handbook of Fundamentals, 1972, p99, eqn. 22

    real(dp), intent(in)  :: Enthalpy
      !+ Enthalpy in J kg⁻¹
    real(dp), intent(in)  :: Pressure
      !+ Atmospheric pressure in Pa
    real(dp)              :: SatAirTemperature
      !+ Saturation temperature in °C

    ! Local variables:
    real(dp) :: T1
      !+ Approximate saturation temperature in °C
    real(dp) :: T2
      !+ Approximate saturation temperature in °C
    real(dp) :: TN
      !+ New assumed saturation temperature in °C
    real(dp) :: H1
      !+ Approximate enthalpy in J kg⁻¹
    real(dp) :: H2
      !+ Approximate enthalpy in J kg⁻¹
    real(dp) :: Y1
      !+ Error in enthalpy in  J kg⁻¹
    real(dp) :: Y2
      !+ Error in enthalpy in  J kg⁻¹
    real(dp) :: HH
      !+ Temporary Enthalpy (calculation) value in  J kg⁻¹
    real(dp) :: Hloc
      !+ Local enthalpy value in  J kg⁻¹
    integer  :: IterCount
      !+ Iteration counter (dimensionless)


    ! Check that enthalpy is in range
    HH = Enthalpy + 1.78637d4

    if (Enthalpy >= 0.0_dp) then
      Hloc = max(0.00001_dp,Enthalpy)
    else if (Enthalpy  < 0.0_dp) then
      Hloc = min(-.00001_dp,Enthalpy)
    end if

    if (HH > 7.5222d4) go to  20
    if (HH > 2.7297d4) go to  60
    if (HH > -6.7012d2) go to 50
    if (HH > -2.2138d4) go to 40
    if (HH < -4.24d4) HH=-4.24d4    ! Peg to minimum
    go to 30
  20 continue
    if (HH < 1.8379d5) go to 70
    if (HH < 4.7577d5) go to 80
    if (HH < 1.5445d6) go to 90
    if (HH < 3.8353d6) go to 100
    if (HH > 4.5866d7) HH=4.5866d7  ! Peg to maximum
    go to 110

  ! If the barometric pressure is equal to 101330 Pa, the saturation temperature is calculated by the
  ! following equations.

  !  Temperature is between -60 and -40 °C
    30 continue
        Satairtemperature=F6(HH,-19.44_dp,8.53675d-4,-5.12637d-9,-9.85546d-14,-1.00102d-18,-4.2705d-24)
        go to 120
  !  Temperature is between -40 and -20 °C
    40 continue
        Satairtemperature=F6(HH,-1.94224d1,8.5892d-4,-4.50709d-9,-6.19492d-14,8.71734d-20,8.73051d-24)
        go to 120
  !  Temperature is between -20 and 0 °C
    50 continue
        Satairtemperature=F6(HH,-1.94224d1,8.59061d-4,-4.4875d-9,-5.76696d-14,7.72217d-19,3.97894d-24)
        go to 120
  !  Temperature is between 0 and 20 °C
    60 continue
        Satairtemperature=F6(HH,-2.01147d1,9.04936d-4,-6.83305d-9,2.3261d-14,7.27237d-20,-6.31939d-25)
        go to 120
  !  Temperature is between 20 and 40 °C
    70 continue
        Satairtemperature=F6(HH,-1.82124d1,8.31683d-4,-6.16461d-9,3.06411d-14,-8.60964d-20,1.03003d-25)
        go to 120
  !  Temperature is between 40 and 60 °C
    80 continue
        Satairtemperature=F6(HH,-1.29419_dp,3.88538d-4,-1.30237d-9,2.78254d-15,-3.27225d-21,1.60969d-27)
        go to 120
  !  Temperature is between 60 and 80 °C
    90 continue
        Satairtemperature=F6(HH,2.39214d1,1.27519d-4,-1.52089d-10,1.1043d-16,-4.33919d-23,7.05296d-30)
        go to 120
  !  Temperature is between 80 and 90 °C
    100 continue
        Satairtemperature=F6(HH,4.88446d1,3.85534d-5,-1.78805d-11,4.87224d-18,-7.15283d-25,4.36246d-32)
        go to 120
  !  Temperature is between 90 and 100 °C
    110 continue
        Satairtemperature=F7(HH,7.60565d11,5.80534d4,-7.36433d-3,5.11531d-10,-1.93619d-17,3.70511d-25, -2.77313d-33)

  ! If the barometric pressure is not equal to equal to 101330 Pa, the saturation temperature is calculated by the
  ! following equations instead of the above ones.

  120 continue

      if (abs(Pressure-1.0133d5)/1.0133d5 <= 0.01_dp) go to 170
      IterCount=0
      T1=Satairtemperature
      H1=GetMoistAirEnthalpy(T1, GetHumRatioFromTWetBulb(T1, T1, Pressure))
      Y1=H1-Hloc
      if (abs(Y1/Hloc) <= 0.1d-4) go to 140
      T2=T1*0.9_dp
  130 IterCount=IterCount+1
      H2=GetMoistAirEnthalpy(T2, GetHumRatioFromTWetBulb(T2, T2, Pressure))
      Y2=H2-Hloc
      if (abs(Y2/Hloc) <= 0.1d-4) go to 150
      if (Y2 == Y1) go to 150
      TN=T2-Y2/(Y2-Y1)*(T2-T1)
      if (IterCount > 30) go to 160
      T1=T2
      T2=TN
      Y1=Y2
      go to 130
  140 continue
      Satairtemperature=T1
      go to 170
  150 continue
      Satairtemperature=T2
      go to 170
  160 continue

  170 continue

  ! The result is the saturation temperature

  return

  contains

      real(dp) function F6(X,A0,A1,A2,A3,A4,A5)
        implicit none
        real(dp) X
        real(dp) A0,A1,A2,A3,A4,A5

        F6=A0+X*(A1+X*(A2+X*(A3+X*(A4+X*A5))))
        return
      end function F6

      real(dp) function F7(X,A0,A1,A2,A3,A4,A5,A6)
        implicit none
        real(dp) X,A6
        real(dp) A0,A1,A2,A3,A4,A5

        F7=(A0+X*(A1+X*(A2+X*(A3+X*(A4+X*(A5+X*A6))))))/1.0D10
        return
      end function F7

  end function GetSatAirTemperatureFromEnthalpy

  !----------------------------------------------------------------------------------
  ! Subroutines for setting all psychrometric values
  !----------------------------------------------------------------------------------

  subroutine CalcPsychrometricsFromTWetBulb(TDryBulb,           &
                                            Pressure,           &
                                            TWetBulb,           &
                                            TDewPoint,          &
                                            RelHum,             &
                                            HumRatio,           &
                                            VapPres,            &
                                            MoistAirEnthalpy,   &
                                            MoistAirVolume,     &
                                            DegSaturation)

  !+ Given dry bulb pressure, atmospheric pressure, and wet bulb temperature,
  !+ `CalcPsychrometricsFromTWetBulb` returns the dew point temperature,
  !+ the relative humidity, the humidity ratio, the partial pressure of water vapour in moist air,
  !+ the moist air enthalpy, the specific volume and the degree of saturation.

    real(dp), intent(in)    ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)    ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp), intent(in)    ::  TWetBulb
      !+ Wet bulb temperature in °C
    real(dp), intent(out)   ::  TDewPoint
      !+ Dew point temperature in °C
    real(dp), intent(out)   ::  RelHum
      !+ Relative humidity in range between 0 and 1
    real(dp), intent(out)   ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp), intent(out)   ::  VapPres
      !+ Partial pressure of water vapour in moist air in Pa
    real(dp), intent(out)   ::  MoistAirEnthalpy
      !+ Moist air enthalpy in J kg⁻¹
    real(dp), intent(out)   ::  MoistAirVolume
      !+ Specific volume in m³ kg⁻¹
    real(dp), intent(out)   ::  DegSaturation
      !+ Degree of saturation (dimensionless)

    HumRatio          = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    TDewPoint         = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
    RelHum            = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
    VapPres           = GetVapPresFromHumRatio(HumRatio, Pressure)
    MoistAirEnthalpy  = GetMoistAirEnthalpy(TDryBulb, HumRatio)
    MoistAirVolume    = GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
    DegSaturation     = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)
  end subroutine CalcPsychrometricsFromTWetBulb

  subroutine CalcPsychrometricsFromTDewPoint(TDryBulb,           &
                                             Pressure,           &
                                             TDewPoint,          &
                                             TWetBulb,           &
                                             RelHum,             &
                                             HumRatio,           &
                                             VapPres,            &
                                             MoistAirEnthalpy,   &
                                             MoistAirVolume,     &
                                             DegSaturation)

  !+ Given dry bulb pressure, atmospheric pressure, and dew point temperature 
  !+ `CalcPsychrometricsFromTDewPoint` returns the wet bulb temperature, the relative humidity, 
  !+ the humidity ratio, the partial pressure of water vapour in moist air, the moist air enthalpy,
  !+ the specific volume and the degree of saturation.

    real(dp), intent(in)    ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)    ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp), intent(in)    ::  TDewPoint
      !+ Dew point temperature in °C
    real(dp), intent(out)   ::  TWetBulb
      !+ Wet bulb temperature in °C
    real(dp), intent(out)   ::  RelHum
      !+ Relative humidity in range between 0 and 1
    real(dp), intent(out)   ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp), intent(out)   ::  VapPres
      !+ Partial pressure of water vapour in moist air in Pa
    real(dp), intent(out)   ::  MoistAirEnthalpy
      !+ Moist air enthalpy in J kg⁻¹
    real(dp), intent(out)   ::  MoistAirVolume
      !+ Specific volume in m³ kg⁻¹
    real(dp), intent(out)   ::  DegSaturation
      !+ Degree of saturation (dimensionless)

    HumRatio          = GetHumRatioFromTDewPoint(TDewPoint, Pressure)
    TWetBulb          = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
    RelHum            = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
    VapPres           = GetVapPresFromHumRatio(HumRatio, Pressure)
    MoistAirEnthalpy  = GetMoistAirEnthalpy(TDryBulb, HumRatio)
    MoistAirVolume    = GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
    DegSaturation     = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)
  end subroutine CalcPsychrometricsFromTDewPoint

  subroutine CalcPsychrometricsFromRelHum(TDryBulb,           &
                                          Pressure,           &
                                          RelHum,             &
                                          TWetBulb,           &
                                          TDewPoint,          &
                                          HumRatio,           &
                                          VapPres,            &
                                          MoistAirEnthalpy,   &
                                          MoistAirVolume,     &
                                          DegSaturation)

  !+ Given dry bulb pressure, atmospheric pressure, and relative humidity,
  !+ `CalcPsychrometricsFromRelHum` returns the wet bulb temperature, the dew point temperature, 
  !+ the humidity ratio, the partial pressure of water vapour in moist air, the moist air enthalpy,
  !+ the specific volume and the degree of saturation.

    real(dp), intent(in)    ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp), intent(in)    ::  Pressure
      !+ Atmospheric pressure in Pa
    real(dp), intent(in)   ::   RelHum
      !+ Relative humidity in range between 0 and 1
    real(dp), intent(out)   ::  TWetBulb
      !+ Wet bulb temperature in °C
    real(dp), intent(out)   ::  TDewPoint
      !+ Dew point temperature in °C
    real(dp), intent(out)   ::  HumRatio
      !+ Humidity ratio in kgH₂O kgAIR⁻¹
    real(dp), intent(out)   ::  VapPres
      !+ Partial pressure of water vapour in moist air in Pa
    real(dp), intent(out)   ::  MoistAirEnthalpy
      !+ Moist air enthalpy in J kg⁻¹
    real(dp), intent(out)   ::  MoistAirVolume
      !+ Specific volume in m³ kg⁻¹
    real(dp), intent(out)   ::  DegSaturation
      !+ Degree of saturation (dimensionless)

    HumRatio          = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure)
    TWetBulb          = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
    TDewPoint         = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
    VapPres           = GetVapPresFromHumRatio(HumRatio, Pressure)
    MoistAirEnthalpy  = GetMoistAirEnthalpy(TDryBulb, HumRatio)
    MoistAirVolume    = GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
    DegSaturation     = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)
  end subroutine CalcPsychrometricsFromRelHum

  !----------------------------------------------------------------------------------
  ! General functions for the standard atmosphere
  !----------------------------------------------------------------------------------

  pure function GetStandardAtmPressure(Altitude) result(StandardAtmPressure)
    !+ Standard-atmosphere barometric pressure, given the elevation (altitude).
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 3;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 1.

    real(dp), intent(in)  ::  Altitude
      !+ Altitude in m
    real(dp)              ::  StandardAtmPressure
      !+ Standard-atmosphere barometric pressure in Pa

    StandardAtmPressure = 101325.*(1.-2.25577d-5*Altitude)**5.2559
  end function GetStandardAtmPressure

  pure function GetStandardAtmTemperature(Altitude) result(StandardAtmTemperature)
    !+ Standard-atmosphere temperature, given the elevation (altitude).
    !+ Reference:
    !+ ASHRAE Fundamentals (2005) ch. 6 eqn. 4;
    !+ ASHRAE Fundamentals (2009) ch. 1 eqn. 4.

    real(dp), intent(in)  ::  Altitude
      !+ Altitude in m
    real(dp)              ::  StandardAtmTemperature
      !+ Standard-atmosphere dry bulb temperature in °C

    StandardAtmTemperature = 15.0_dp - 0.0065_dp * Altitude
  end function GetStandardAtmTemperature

  pure function GetSeaLevelPressure(StnPressure, Altitude, TDryBulb) result(SeaLevelPressure)
    !+ Sea level pressure from observed station pressure.
    !+ ***Note***: the standard procedure in the US is to use for TDryBulb the average
    !+ of the current station temperature and the station temperature from the previous 12 hours.
    !+ Reference:
    !+ Hess SL, Introduction to theoretical meteorology, Holt Rinehart and Winston, NY 1959,
    !+ ch. 6.5; Stull RB, Meteorology for scientists and engineers, 2nd edition,
    !+ Brooks/Cole 2000, ch. 1.

    real(dp), intent(in)  ::  StnPressure
      !+ Observed station pressure in Pa
    real(dp), intent(in)  ::  Altitude
      !+ Altitude in m
    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp)              ::  SeaLevelPressure
      !+ Sea level barometric pressure in Pa
    real(dp)              ::  TColumn
      !+ Average temperature in column of air in K
    real(dp)              ::  H
      !+ scale height (dimensionless)

    ! Calculate average temperature in column of air, assuming a lapse rate
    ! of 6.5 °C km⁻¹
    TColumn = TDryBulb + 0.0065_dp * Altitude / 2.0_dp

    ! Determine the scale height
    H = 287.055_dp * CTOK(TColumn) / 9.807_dp

    ! Calculate sea level pressure
    SeaLevelPressure = StnPressure*exp(Altitude/H)
  end function GetSeaLevelPressure

  pure function GetStationPressure(SeaLevelPressure, Altitude, TDryBulb) result(StationPressure)
    !+ Station pressure from sea level pressure.
    !+ This is just `GetSeaLevelPressure`, reversed.

    real(dp), intent(in)  ::  SeaLevelPressure
      !+ Sea level barometric pressure in Pa
    real(dp), intent(in)  ::  Altitude
      !+ Altitude above sea level in m
    real(dp), intent(in)  ::  TDryBulb
      !+ Dry bulb temperature in °C
    real(dp)              ::  StationPressure
      !+ Station pressure in Pa

    StationPressure = SeaLevelPressure/GetSeaLevelPressure(1.0_dp, Altitude, TDryBulb)
  end function GetStationPressure

end module Psychrometrics_SI