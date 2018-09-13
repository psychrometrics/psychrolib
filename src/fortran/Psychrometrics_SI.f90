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
  public :: GetVapPresFromRelHum
  public :: GetRelHumFromVapPres
  public :: GetTDewPointFromVapPres
  public :: GetVapPresFromTDewPoint
  public :: GetTWetBulbFromHumRatio
  public :: GetHumRatioFromTWetBulb
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