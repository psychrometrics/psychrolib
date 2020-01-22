# PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
# Copyright (c) 2018-2020 The PsychroLib Contributors for the current library implementation.
# Copyright (c) 2017 ASHRAE Handbook — Fundamentals for ASHRAE equations and coefficients.
# Licensed under the MIT License.

""" psychrolib.py

Contains functions for calculating thermodynamic properties of gas-vapor mixtures
and standard atmosphere suitable for most engineering, physical and meteorological
applications.

Most of the functions are an implementation of the formulae found in the
2017 ASHRAE Handbook - Fundamentals, in both International System (SI),
and Imperial (IP) units. Please refer to the information included in
each function for their respective reference.

Example
    >>> import psychrolib
    >>> # Set the unit system, for example to SI (can be either psychrolib.SI or psychrolib.IP)
    >>> psychrolib.SetUnitSystem(psychrolib.SI)
    >>> # Calculate the dew point temperature for a dry bulb temperature of 25 C and a relative humidity of 80%
    >>> TDewPoint = psychrolib.GetTDewPointFromRelHum(25.0, 0.80)
    >>> print(TDewPoint)
    21.309397163661785

Copyright
    - For the current library implementation
        Copyright (c) 2018-2020 The PsychroLib Contributors.
    - For equations and coefficients published ASHRAE Handbook — Fundamentals, Chapter 1
        Copyright (c) 2017 ASHRAE Handbook — Fundamentals (https://www.ashrae.org)

License
    MIT (https://github.com/psychrometrics/psychrolib/LICENSE.txt)

Note from the Authors
    We have made every effort to ensure that the code is adequate, however, we make no
    representation with respect to its accuracy. Use at your own risk. Should you notice
    an error, or if you have a suggestion, please notify us through GitHub at
    https://github.com/psychrometrics/psychrolib/issues.


"""


import math
from enum import Enum, auto
from typing import Optional


#######################################################################################################
# Global constants
#######################################################################################################

ZERO_FAHRENHEIT_AS_RANKINE = 459.67
"""float: Zero degree Fahrenheit (°F) expressed as degree Rankine (°R)

    Units:
        °R

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 39

"""

ZERO_CELSIUS_AS_KELVIN = 273.15
"""float: Zero degree Celsius (°C) expressed as Kelvin (K)

    Units:
        K

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 39

"""

R_DA_IP = 53.350
"""float: Universal gas constant for dry air (IP version)

    Units:
        ft lb_Force lb_DryAir⁻¹ R⁻¹

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

"""

R_DA_SI = 287.042
"""float: Universal gas constant for dry air (SI version)

    Units:
        J kg_DryAir⁻¹ K⁻¹

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

"""

MAX_ITER_COUNT = 100
"""int: Maximum number of iterations before exiting while loops.

"""

MIN_HUM_RATIO = 1e-7
"""float: Minimum acceptable humidity ratio used/returned by any functions.
          Any value above 0 or below the MIN_HUM_RATIO will be reset to this value.

"""

FREEZING_POINT_WATER_IP = 32.0
"""float: Freezing point of water in Fahrenheit.

"""

FREEZING_POINT_WATER_SI = 0.0
"""float: Freezing point of water in Celsius.

"""

TRIPLE_POINT_WATER_IP = 32.018
"""float: Triple point of water in Fahrenheit.

"""

TRIPLE_POINT_WATER_SI = 0.01
"""float: Triple point of water in Celsius.

"""

#######################################################################################################
# Helper functions
#######################################################################################################

# Unit system to use.
class UnitSystem(Enum):
    """
    Private class not exposed used to set automatic enumeration values.
    """
    IP = auto()
    SI = auto()

IP = UnitSystem.IP
SI = UnitSystem.SI

PSYCHROLIB_UNITS = None

PSYCHROLIB_TOLERANCE = 1.0
# Tolerance of temperature calculations

def SetUnitSystem(Units: UnitSystem) -> None:
    """
    Set the system of units to use (SI or IP).

    Args:
        Units: string indicating the system of units chosen (SI or IP)

    Notes:
        This function *HAS TO BE CALLED* before the library can be used

    """
    global PSYCHROLIB_UNITS
    global PSYCHROLIB_TOLERANCE

    if not isinstance(Units, UnitSystem):
        raise ValueError("The system of units has to be either SI or IP.")

    PSYCHROLIB_UNITS = Units

    # Define tolerance on temperature calculations
    # The tolerance is the same in IP and SI
    if Units == IP:
        PSYCHROLIB_TOLERANCE = 0.001 * 9. / 5.
    else:
        PSYCHROLIB_TOLERANCE = 0.001

def GetUnitSystem() -> Optional[UnitSystem]:
    """
    Return system of units in use.

    """
    return PSYCHROLIB_UNITS

def isIP() -> bool:
    """
    Check whether the system in use is IP or SI.

    """
    if PSYCHROLIB_UNITS == IP:
        return True
    elif PSYCHROLIB_UNITS == SI:
        return False
    else:
        raise ValueError('The system of units has not been defined.')


#######################################################################################################
# Conversion between temperature units
#######################################################################################################

def GetTRankineFromTFahrenheit(TFahrenheit: float) -> float:
    """
    Utility function to convert temperature to degree Rankine (°R)
    given temperature in degree Fahrenheit (°F).

    Args:
        TRankine: Temperature in degree Fahrenheit (°F)

    Returns:
        Temperature in degree Rankine (°R)

    Reference:
        Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3

    Notes:
        Exact conversion.

    """
    TRankine = TFahrenheit + ZERO_FAHRENHEIT_AS_RANKINE
    return TRankine

def GetTFahrenheitFromTRankine(TRankine: float) -> float:
    """
    Utility function to convert temperature to degree Fahrenheit (°F)
    given temperature in degree Rankine (°R).

    Args:
        TRankine: Temperature in degree Rankine (°R)

    Returns:
        Temperature in degree Fahrenheit (°F)

    Reference:
        Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3

    Notes:
        Exact conversion.

    """
    return TRankine - ZERO_FAHRENHEIT_AS_RANKINE

def GetTKelvinFromTCelsius(TCelsius: float) -> float:
    """
    Utility function to convert temperature to Kelvin (K)
    given temperature in degree Celsius (°C).

    Args:
        TCelsius: Temperature in degree Celsius (°C)

    Returns:
        Temperature in Kelvin (K)

    Reference:
        Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3

    Notes:
        Exact conversion.

    """
    TKelvin = TCelsius + ZERO_CELSIUS_AS_KELVIN
    return TKelvin

def GetTCelsiusFromTKelvin(TKelvin: float) -> float:
    """
    Utility function to convert temperature to degree Celsius (°C)
    given temperature in Kelvin (K).

    Args:
        TKelvin: Temperature in Kelvin (K)

    Returns:
        Temperature in degree Celsius (°C)

    Reference:
        Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3

    Notes:
        Exact conversion.

    """
    return TKelvin - ZERO_CELSIUS_AS_KELVIN


#######################################################################################################
# Conversions between dew point, wet bulb, and relative humidity
#######################################################################################################

def GetTWetBulbFromTDewPoint(TDryBulb: float, TDewPoint: float, Pressure: float) -> float:
    """
    Return wet-bulb temperature given dry-bulb temperature, dew-point temperature, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Wet-bulb temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    if TDewPoint > TDryBulb:
        raise ValueError("Dew point temperature is above dry bulb temperature")

    HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure)
    TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
    return TWetBulb

def GetTWetBulbFromRelHum(TDryBulb: float, RelHum: float, Pressure: float) -> float:
    """
    Return wet-bulb temperature given dry-bulb temperature, relative humidity, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        RelHum : Relative humidity in range [0, 1]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Wet-bulb temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    if RelHum < 0 or RelHum > 1:
        raise ValueError("Relative humidity is outside range [0, 1]")

    HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure)
    TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
    return TWetBulb

def GetRelHumFromTDewPoint(TDryBulb: float, TDewPoint: float) -> float:
    """
    Return relative humidity given dry-bulb temperature and dew-point temperature.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]

    Returns:
        Relative humidity in range [0, 1]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 22

    """
    if TDewPoint > TDryBulb:
        raise ValueError("Dew point temperature is above dry bulb temperature")

    VapPres = GetSatVapPres(TDewPoint)
    SatVapPres = GetSatVapPres(TDryBulb)
    RelHum = VapPres / SatVapPres
    return RelHum

def GetRelHumFromTWetBulb(TDryBulb: float, TWetBulb: float, Pressure: float) -> float:
    """
    Return relative humidity given dry-bulb temperature, wet bulb temperature and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        TWetBulb : Wet-bulb temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Relative humidity in range [0, 1]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    if TWetBulb > TDryBulb:
        raise ValueError("Wet bulb temperature is above dry bulb temperature")

    HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    RelHum =  GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
    return RelHum

def GetTDewPointFromRelHum(TDryBulb: float, RelHum: float) -> float:
    """
    Return dew-point temperature given dry-bulb temperature and relative humidity.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        RelHum: Relative humidity in range [0, 1]

    Returns:
        Dew-point temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    if RelHum < 0 or RelHum > 1:
        raise ValueError("Relative humidity is outside range [0, 1]")

    VapPres = GetVapPresFromRelHum(TDryBulb, RelHum)
    TDewPoint = GetTDewPointFromVapPres(TDryBulb, VapPres)
    return TDewPoint

def GetTDewPointFromTWetBulb(TDryBulb: float, TWetBulb: float, Pressure: float) -> float:
    """
    Return dew-point temperature given dry-bulb temperature, wet-bulb temperature, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        TWetBulb : Wet-bulb temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Dew-point temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    if TWetBulb > TDryBulb:
        raise ValueError("Wet bulb temperature is above dry bulb temperature")

    HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
    return TDewPoint


#######################################################################################################
# Conversions between dew point, or relative humidity and vapor pressure
#######################################################################################################

def GetVapPresFromRelHum(TDryBulb: float, RelHum: float) -> float:
    """
    Return partial pressure of water vapor as a function of relative humidity and temperature.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        RelHum : Relative humidity in range [0, 1]

    Returns:
        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22

    """
    if RelHum < 0 or RelHum > 1:
        raise ValueError("Relative humidity is outside range [0, 1]")

    VapPres = RelHum * GetSatVapPres(TDryBulb)
    return VapPres

def GetRelHumFromVapPres(TDryBulb: float, VapPres: float) -> float:
    """
    Return relative humidity given dry-bulb temperature and vapor pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        VapPres: Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]

    Returns:
        Relative humidity in range [0, 1]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22

    """
    if VapPres < 0:
        raise ValueError("Partial pressure of water vapor in moist air cannot be negative")

    RelHum = VapPres / GetSatVapPres(TDryBulb)
    return RelHum

def dLnPws_(TDryBulb: float) -> float:
    """
    Helper function returning the derivative of the natural log of the saturation vapor pressure 
    as a function of dry-bulb temperature.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Returns:
        Derivative of natural log of vapor pressure of saturated air in Psi [IP] or Pa [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1  eqn 5 & 6

    """
    if isIP():
        T = GetTRankineFromTFahrenheit(TDryBulb)
        if TDryBulb <= TRIPLE_POINT_WATER_IP:
            dLnPws = 1.0214165E+04 / math.pow(T, 2) - 5.3765794E-03 + 2 * 1.9202377E-07 * T \
                  + 3 * 3.5575832E-10 * math.pow(T, 2) - 4 * 9.0344688E-14 * math.pow(T, 3) + 4.1635019 / T
        else:
            dLnPws = 1.0440397E+04 / math.pow(T, 2) - 2.7022355E-02 + 2 * 1.2890360E-05 * T \
                  - 3 * 2.4780681E-09 * math.pow(T, 2) + 6.5459673 / T
    else:
        T = GetTKelvinFromTCelsius(TDryBulb)
        if TDryBulb <= TRIPLE_POINT_WATER_SI:
            dLnPws = 5.6745359E+03 / math.pow(T, 2) - 9.677843E-03 + 2 * 6.2215701E-07 * T \
                  + 3 * 2.0747825E-09 * math.pow(T, 2) - 4 * 9.484024E-13 * math.pow(T, 3) + 4.1635019 / T
        else:
            dLnPws = 5.8002206E+03 / math.pow(T, 2) - 4.8640239E-02 + 2 * 4.1764768E-05 * T \
                  - 3 * 1.4452093E-08 * math.pow(T, 2) + 6.5459673 / T

    return dLnPws

def GetTDewPointFromVapPres(TDryBulb: float, VapPres: float) -> float:
    """
    Return dew-point temperature given dry-bulb temperature and vapor pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        VapPres: Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]

    Returns:
        Dew-point temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 and 6

    Notes:
        The dew point temperature is solved by inverting the equation giving water vapor pressure
        at saturation from temperature rather than using the regressions provided
        by ASHRAE (eqn. 37 and 38) which are much less accurate and have a
        narrower range of validity.
        The Newton-Raphson (NR) method is used on the logarithm of water vapour
        pressure as a function of temperature, which is a very smooth function
        Convergence is usually achieved in 3 to 5 iterations. 
        TDryBulb is not really needed here, just used for convenience.

    """
    if isIP():
        BOUNDS = [-148, 392]
    else:
        BOUNDS = [-100, 200]

    # Validity check -- bounds outside which a solution cannot be found
    if VapPres < GetSatVapPres(BOUNDS[0]) or VapPres > GetSatVapPres(BOUNDS[1]):
        raise ValueError("Partial pressure of water vapor is outside range of validity of equations")

    # We use NR to approximate the solution.
    # First guess
    TDewPoint = TDryBulb        # Calculated value of dew point temperatures, solved for iteratively
    lnVP = math.log(VapPres)    # Partial pressure of water vapor in moist air

    index = 1

    while True:
        TDewPoint_iter = TDewPoint   # TDewPoint used in NR calculation
        lnVP_iter = math.log(GetSatVapPres(TDewPoint_iter))

        # Derivative of function, calculated analytically
        d_lnVP = dLnPws_(TDewPoint_iter)

        # New estimate, bounded by the search domain defined above
        TDewPoint = TDewPoint_iter - (lnVP_iter - lnVP) / d_lnVP
        TDewPoint = max(TDewPoint, BOUNDS[0])
        TDewPoint = min(TDewPoint, BOUNDS[1])

        if ((math.fabs(TDewPoint - TDewPoint_iter) <= PSYCHROLIB_TOLERANCE)):
            break

        if (index > MAX_ITER_COUNT):
            raise ValueError("Convergence not reached in GetTDewPointFromVapPres. Stopping.")

        index = index + 1

    TDewPoint = min(TDewPoint, TDryBulb)
    return TDewPoint

def GetVapPresFromTDewPoint(TDewPoint: float) -> float:
    """
    Return vapor pressure given dew point temperature.

    Args:
        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]

    Returns:
        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36

    """
    VapPres = GetSatVapPres(TDewPoint)
    return VapPres


#######################################################################################################
# Conversions from wet-bulb temperature, dew-point temperature, or relative humidity to humidity ratio
#######################################################################################################

def GetTWetBulbFromHumRatio(TDryBulb: float, HumRatio: float, Pressure: float) -> float:
    """
    Return wet-bulb temperature given dry-bulb temperature, humidity ratio, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Wet-bulb temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35 solved for Tstar

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio cannot be negative")
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    TDewPoint = GetTDewPointFromHumRatio(TDryBulb, BoundedHumRatio, Pressure)

    # Initial guesses
    TWetBulbSup = TDryBulb
    TWetBulbInf = TDewPoint
    TWetBulb = (TWetBulbInf + TWetBulbSup) / 2

    index = 1
    # Bisection loop
    while ((TWetBulbSup - TWetBulbInf) > PSYCHROLIB_TOLERANCE):

        # Compute humidity ratio at temperature Tstar
        Wstar = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)

        # Get new bounds
        if Wstar > BoundedHumRatio:
            TWetBulbSup = TWetBulb
        else:
            TWetBulbInf = TWetBulb

        # New guess of wet bulb temperature
        TWetBulb = (TWetBulbSup + TWetBulbInf) / 2

        if (index >= MAX_ITER_COUNT):
            raise ValueError("Convergence not reached in GetTWetBulbFromHumRatio. Stopping.")

        index = index + 1
    return TWetBulb

def GetHumRatioFromTWetBulb(TDryBulb: float, TWetBulb: float, Pressure: float) -> float:
    """
    Return humidity ratio given dry-bulb temperature, wet-bulb temperature, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        TWetBulb : Wet-bulb temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35

    """
    if TWetBulb > TDryBulb:
        raise ValueError("Wet bulb temperature is above dry bulb temperature")

    Wsstar = GetSatHumRatio(TWetBulb, Pressure)

    if isIP():
       if TWetBulb >= FREEZING_POINT_WATER_IP:
           HumRatio = ((1093 - 0.556 * TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb)) \
                    / (1093 + 0.444 * TDryBulb - TWetBulb)
       else:
           HumRatio = ((1220 - 0.04 * TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb)) \
                    / (1220 + 0.444 * TDryBulb - 0.48*TWetBulb)
    else:
       if TWetBulb >= FREEZING_POINT_WATER_SI:
           HumRatio = ((2501. - 2.326 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb)) \
                    / (2501. + 1.86 * TDryBulb - 4.186 * TWetBulb)
       else:
           HumRatio = ((2830. - 0.24 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb)) \
                    / (2830. + 1.86 * TDryBulb - 2.1 * TWetBulb)
    # Validity check.
    return max(HumRatio, MIN_HUM_RATIO)

def GetHumRatioFromRelHum(TDryBulb: float, RelHum: float, Pressure: float) -> float:
    """
    Return humidity ratio given dry-bulb temperature, relative humidity, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        RelHum : Relative humidity in range [0, 1]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    if RelHum < 0 or RelHum > 1:
        raise ValueError("Relative humidity is outside range [0, 1]")

    VapPres = GetVapPresFromRelHum(TDryBulb, RelHum)
    HumRatio = GetHumRatioFromVapPres(VapPres, Pressure)
    return HumRatio

def GetRelHumFromHumRatio(TDryBulb: float, HumRatio: float, Pressure: float) -> float:
    """
    Return relative humidity given dry-bulb temperature, humidity ratio, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Relative humidity in range [0, 1]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio cannot be negative")

    VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
    RelHum = GetRelHumFromVapPres(TDryBulb, VapPres)
    return RelHum

def GetHumRatioFromTDewPoint(TDewPoint: float, Pressure: float) -> float:
    """
    Return humidity ratio given dew-point temperature and pressure.

    Args:
        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 13

    """
    VapPres = GetSatVapPres(TDewPoint)
    HumRatio = GetHumRatioFromVapPres(VapPres, Pressure)
    return HumRatio

def GetTDewPointFromHumRatio(TDryBulb: float, HumRatio: float, Pressure: float) -> float:
    """
    Return dew-point temperature given dry-bulb temperature, humidity ratio, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Dew-point temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio cannot be negative")

    VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
    TDewPoint = GetTDewPointFromVapPres(TDryBulb, VapPres)
    return TDewPoint


#######################################################################################################
# Conversions between humidity ratio and vapor pressure
#######################################################################################################

def GetHumRatioFromVapPres(VapPres: float, Pressure: float) -> float:
    """
    Return humidity ratio given water vapor pressure and atmospheric pressure.

    Args:
        VapPres : Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20

    """
    if VapPres < 0:
        raise ValueError("Partial pressure of water vapor in moist air cannot be negative")

    HumRatio = 0.621945 * VapPres / (Pressure - VapPres)

    # Validity check.
    return max(HumRatio, MIN_HUM_RATIO)

def GetVapPresFromHumRatio(HumRatio: float, Pressure: float) -> float:
    """
    Return vapor pressure given humidity ratio and pressure.

    Args:
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20 solved for pw

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio is negative")
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    VapPres = Pressure * BoundedHumRatio / (0.621945 + BoundedHumRatio)
    return VapPres


#######################################################################################################
# Conversions between humidity ratio and specific humidity
#######################################################################################################

def GetSpecificHumFromHumRatio(HumRatio: float) -> float:
    """
    Return the specific humidity from humidity ratio (aka mixing ratio).

    Args:
        HumRatio : Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]

    Returns:
        Specific humidity in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio cannot be negative")
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    SpecificHum = BoundedHumRatio / (1.0 + BoundedHumRatio)
    return SpecificHum

def GetHumRatioFromSpecificHum(SpecificHum: float) -> float:
    """
    Return the humidity ratio (aka mixing ratio) from specific humidity.

    Args:
        SpecificHum : Specific humidity in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b (solved for humidity ratio)

    """
    if SpecificHum < 0.0 or SpecificHum >= 1.0:
        raise ValueError("Specific humidity is outside range [0, 1[")

    HumRatio = SpecificHum / (1.0 - SpecificHum)

    # Validity check.
    return max(HumRatio, MIN_HUM_RATIO)


#######################################################################################################
# Dry Air Calculations
#######################################################################################################

def GetDryAirEnthalpy(TDryBulb: float) -> float:
    """
    Return dry-air enthalpy given dry-bulb temperature.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Returns:
        Dry air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 28

    """
    if isIP():
        DryAirEnthalpy = 0.240 * TDryBulb
    else:
        DryAirEnthalpy = 1006 * TDryBulb
    return DryAirEnthalpy

def GetDryAirDensity(TDryBulb: float, Pressure: float) -> float:
    """
    Return dry-air density given dry-bulb temperature and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Dry air density in lb ft⁻³ [IP] or kg m⁻³ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    Notes:
        Eqn 14 for the perfect gas relationship for dry air.
        Eqn 1 for the universal gas constant.
        The factor 144 in IP is for the conversion of Psi = lb in⁻² to lb ft⁻².

    """
    if isIP():
        DryAirDensity = (144 * Pressure) / R_DA_IP / GetTRankineFromTFahrenheit(TDryBulb)
    else:
        DryAirDensity = Pressure / R_DA_SI / GetTKelvinFromTCelsius(TDryBulb)
    return DryAirDensity

def GetDryAirVolume(TDryBulb: float, Pressure: float) -> float:
    """
    Return dry-air volume given dry-bulb temperature and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Dry air volume in ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    Notes:
        Eqn 14 for the perfect gas relationship for dry air.
        Eqn 1 for the universal gas constant.
        The factor 144 in IP is for the conversion of Psi = lb in⁻² to lb ft⁻².

    """
    if isIP():
        DryAirVolume = R_DA_IP * GetTRankineFromTFahrenheit(TDryBulb) / (144 * Pressure)
    else:
        DryAirVolume = R_DA_SI * GetTKelvinFromTCelsius(TDryBulb) / Pressure
    return DryAirVolume


def GetTDryBulbFromEnthalpyAndHumRatio(MoistAirEnthalpy: float, HumRatio: float) -> float:
    """
    Return dry bulb temperature from enthalpy and humidity ratio.


    Args:
        MoistAirEnthalpy : Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Returns:
        Dry-bulb temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30

    Notes:
        Based on the `GetMoistAirEnthalpy` function, rearranged for temperature.

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio is negative")
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    if isIP():
        TDryBulb  = (MoistAirEnthalpy - 1061.0 * BoundedHumRatio) / (0.240 + 0.444 * BoundedHumRatio)
    else:
        TDryBulb  = (MoistAirEnthalpy / 1000.0 - 2501.0 * BoundedHumRatio) / (1.006 + 1.86 * BoundedHumRatio)
    return TDryBulb

def GetHumRatioFromEnthalpyAndTDryBulb(MoistAirEnthalpy: float, TDryBulb: float) -> float:
    """
    Return humidity ratio from enthalpy and dry-bulb temperature.


    Args:
        MoistAirEnthalpy : Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30.

    Notes:
        Based on the `GetMoistAirEnthalpy` function, rearranged for humidity ratio.

    """
    if isIP():
        HumRatio  = (MoistAirEnthalpy - 0.240 * TDryBulb) / (1061.0 + 0.444 * TDryBulb)
    else:
        HumRatio  = (MoistAirEnthalpy / 1000.0 - 1.006 * TDryBulb) / (2501.0 + 1.86 * TDryBulb)

    # Validity check.
    return max(HumRatio, MIN_HUM_RATIO)


#######################################################################################################
# Saturated Air Calculations
#######################################################################################################

def GetSatVapPres(TDryBulb: float) -> float:
    """
    Return saturation vapor pressure given dry-bulb temperature.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Returns:
        Vapor pressure of saturated air in Psi [IP] or Pa [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1  eqn 5 & 6
        Important note: the ASHRAE formulae are defined above and below the freezing point but have
        a discontinuity at the freezing point. This is a small inaccuracy on ASHRAE's part: the formulae
        should be defined above and below the triple point of water (not the feezing point) in which case
        the discontinuity vanishes. It is essential to use the triple point of water otherwise function
        GetTDewPointFromVapPres, which inverts the present function, does not converge properly around
        the freezing point.

    """
    if isIP():
        if (TDryBulb < -148 or TDryBulb > 392):
            raise ValueError("Dry bulb temperature must be in range [-148, 392]°F")

        T = GetTRankineFromTFahrenheit(TDryBulb)

        if (TDryBulb <= TRIPLE_POINT_WATER_IP):
            LnPws = (-1.0214165E+04 / T - 4.8932428 - 5.3765794E-03 * T + 1.9202377E-07 * T**2 \
                  + 3.5575832E-10 * math.pow(T, 3) - 9.0344688E-14 * math.pow(T, 4) + 4.1635019 * math.log(T))
        else:
            LnPws = -1.0440397E+04 / T - 1.1294650E+01 - 2.7022355E-02* T + 1.2890360E-05 * T**2 \
                  - 2.4780681E-09 * math.pow(T, 3) + 6.5459673 * math.log(T)
    else:
        if (TDryBulb < -100 or TDryBulb > 200):
            raise ValueError("Dry bulb temperature must be in range [-100, 200]°C")

        T = GetTKelvinFromTCelsius(TDryBulb)

        if (TDryBulb <= TRIPLE_POINT_WATER_SI):
            LnPws = -5.6745359E+03 / T + 6.3925247 - 9.677843E-03 * T + 6.2215701E-07 * T**2 \
                  + 2.0747825E-09 * math.pow(T, 3) - 9.484024E-13 * math.pow(T, 4) + 4.1635019 * math.log(T)
        else:
            LnPws = -5.8002206E+03 / T + 1.3914993 - 4.8640239E-02 * T + 4.1764768E-05 * T**2 \
                  - 1.4452093E-08 * math.pow(T, 3) + 6.5459673 * math.log(T)

    SatVapPres = math.exp(LnPws)
    return SatVapPres

def GetSatHumRatio(TDryBulb: float, Pressure: float) -> float:
    """
    Return humidity ratio of saturated air given dry-bulb temperature and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Humidity ratio of saturated air in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36, solved for W

    """
    SatVaporPres = GetSatVapPres(TDryBulb)
    SatHumRatio = 0.621945 * SatVaporPres / (Pressure - SatVaporPres)

    # Validity check.
    return max(SatHumRatio, MIN_HUM_RATIO)

def GetSatAirEnthalpy(TDryBulb: float, Pressure: float) -> float:
    """
    Return saturated air enthalpy given dry-bulb temperature and pressure.

    Args:
        TDryBulb: Dry-bulb temperature in °F [IP] or °C [SI]
        Pressure: Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Saturated air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    SatHumRatio = GetSatHumRatio(TDryBulb, Pressure)
    SatAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, SatHumRatio)
    return SatAirEnthalpy


#######################################################################################################
# Moist Air Calculations
#######################################################################################################

def GetVaporPressureDeficit(TDryBulb: float, HumRatio: float, Pressure: float) -> float:
    """
    Return Vapor pressure deficit given dry-bulb temperature, humidity ratio, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Vapor pressure deficit in Psi [IP] or Pa [SI]

    Reference:
        Oke (1987) eqn 2.13a

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio is negative")

    RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
    VaporPressureDeficit = GetSatVapPres(TDryBulb) * (1 - RelHum)
    return VaporPressureDeficit

def GetDegreeOfSaturation(TDryBulb: float, HumRatio: float, Pressure: float) -> float:
    """
    Return the degree of saturation (i.e humidity ratio of the air / humidity ratio of the air at saturation
    at the same temperature and pressure) given dry-bulb temperature, humidity ratio, and atmospheric pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Degree of saturation in arbitrary unit

    Reference:
        ASHRAE Handbook - Fundamentals (2009) ch. 1 eqn 12

    Notes:
        This definition is absent from the 2017 Handbook. Using 2009 version instead.

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio is negative")
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    SatHumRatio = GetSatHumRatio(TDryBulb, Pressure)
    DegreeOfSaturation = BoundedHumRatio / SatHumRatio
    return DegreeOfSaturation

def GetMoistAirEnthalpy(TDryBulb: float, HumRatio: float) -> float:
    """
    Return moist air enthalpy given dry-bulb temperature and humidity ratio.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]

    Returns:
        Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio is negative")
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    if isIP():
        MoistAirEnthalpy = 0.240 * TDryBulb + BoundedHumRatio * (1061 + 0.444 * TDryBulb)
    else:
        MoistAirEnthalpy = (1.006 * TDryBulb + BoundedHumRatio * (2501. + 1.86 * TDryBulb)) * 1000
    return MoistAirEnthalpy

def GetMoistAirVolume(TDryBulb: float, HumRatio: float, Pressure: float) -> float:
    """
    Return moist air specific volume given dry-bulb temperature, humidity ratio, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Specific volume of moist air in ft³ lb⁻¹ of dry air [IP] or in m³ kg⁻¹ of dry air [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26

    Notes:
        In IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26
        The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio is negative")
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    if isIP():
        MoistAirVolume = R_DA_IP * GetTRankineFromTFahrenheit(TDryBulb) * (1 + 1.607858 * BoundedHumRatio) / (144 * Pressure)
    else:
        MoistAirVolume = R_DA_SI * GetTKelvinFromTCelsius(TDryBulb) * (1 + 1.607858 * BoundedHumRatio) / Pressure
    return MoistAirVolume

def GetTDryBulbFromMoistAirVolumeAndHumRatio(MoistAirVolume: float, HumRatio: float, Pressure: float) -> float:
    """
    Return dry-bulb temperature given moist air specific volume, humidity ratio, and pressure.

    Args:
        MoistAirVolume: Specific volume of moist air in ft³ lb⁻¹ of dry air [IP] or in m³ kg⁻¹ of dry air [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26

    Notes:
        In IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26
        The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².
        Based on the `GetMoistAirVolume` function, rearranged for dry-bulb temperature.

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio is negative")
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    if isIP():
        TDryBulb = GetTFahrenheitFromTRankine(MoistAirVolume * (144 * Pressure)
                        / (R_DA_IP * (1 + 1.607858 * BoundedHumRatio)))
    else:
        TDryBulb = GetTCelsiusFromTKelvin(MoistAirVolume * Pressure
                        / (R_DA_SI * (1 + 1.607858 * BoundedHumRatio)))
    return TDryBulb

def GetMoistAirDensity(TDryBulb: float, HumRatio: float, Pressure:float) -> float:
    """
    Return moist air density given humidity ratio, dry bulb temperature, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        MoistAirDensity: Moist air density in lb ft⁻³ [IP] or kg m⁻³ [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 11

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio is negative")
    BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

    MoistAirVolume = GetMoistAirVolume(TDryBulb, BoundedHumRatio, Pressure)
    MoistAirDensity = (1 + BoundedHumRatio) / MoistAirVolume
    return MoistAirDensity


#######################################################################################################
# Standard atmosphere
#######################################################################################################

def GetStandardAtmPressure(Altitude: float) -> float:
    """
    Return standard atmosphere barometric pressure, given the elevation (altitude).

    Args:
        Altitude: Altitude in ft [IP] or m [SI]

    Returns:
        Standard atmosphere barometric pressure in Psi [IP] or Pa [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 3

    """

    if isIP():
        StandardAtmPressure = 14.696 * math.pow(1 - 6.8754e-06 * Altitude, 5.2559)
    else:
        StandardAtmPressure = 101325 * math.pow(1 - 2.25577e-05 * Altitude, 5.2559)
    return StandardAtmPressure

def GetStandardAtmTemperature(Altitude: float) -> float:
    """
    Return standard atmosphere temperature, given the elevation (altitude).

    Args:
        Altitude: Altitude in ft [IP] or m [SI]

    Returns:
        Standard atmosphere dry-bulb temperature in °F [IP] or °C [SI]

    Reference:
        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 4

    """
    if isIP():
        StandardAtmTemperature = 59 - 0.00356620 * Altitude
    else:
        StandardAtmTemperature = 15 - 0.0065 * Altitude
    return StandardAtmTemperature

def GetSeaLevelPressure(StationPressure: float, Altitude: float, TDryBulb: float) -> float:

    """
    Return sea level pressure given dry-bulb temperature, altitude above sea level and pressure.

    Args:
        StationPressure : Observed station pressure in Psi [IP] or Pa [SI]
        Altitude: Altitude in ft [IP] or m [SI]
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Returns:
        Sea level barometric pressure in Psi [IP] or Pa [SI]

    Reference:
        Hess SL, Introduction to theoretical meteorology, Holt Rinehart and Winston, NY 1959,
        ch. 6.5; Stull RB, Meteorology for scientists and engineers, 2nd edition,
        Brooks/Cole 2000, ch. 1.

    Notes:
        The standard procedure for the US is to use for TDryBulb the average
        of the current station temperature and the station temperature from 12 hours ago.

    """
    if isIP():
        # Calculate average temperature in column of air, assuming a lapse rate
        # of 3.6 °F/1000ft
        TColumn = TDryBulb + 0.0036 * Altitude / 2

        # Determine the scale height
        H = 53.351 * GetTRankineFromTFahrenheit(TColumn)
    else:
        # Calculate average temperature in column of air, assuming a lapse rate
        # of 6.5 °C/km
        TColumn = TDryBulb + 0.0065 * Altitude / 2

        # Determine the scale height
        H = 287.055 * GetTKelvinFromTCelsius(TColumn) / 9.807

    # Calculate the sea level pressure
    SeaLevelPressure = StationPressure * math.exp(Altitude / H)
    return SeaLevelPressure

def GetStationPressure(SeaLevelPressure: float, Altitude: float, TDryBulb: float) -> float:
    """
    Return station pressure from sea level pressure.

    Args:
        SeaLevelPressure : Sea level barometric pressure in Psi [IP] or Pa [SI]
        Altitude: Altitude in ft [IP] or m [SI]
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]

    Returns:
        Station pressure in Psi [IP] or Pa [SI]

    Reference:
        See 'GetSeaLevelPressure'

    Notes:
        This function is just the inverse of 'GetSeaLevelPressure'.

    """
    StationPressure = SeaLevelPressure / GetSeaLevelPressure(1, Altitude, TDryBulb)
    return StationPressure


######################################################################################################
# Functions to set all psychrometric values
#######################################################################################################

def CalcPsychrometricsFromTWetBulb(TDryBulb: float, TWetBulb: float, Pressure: float) -> tuple:
    """
    Utility function to calculate humidity ratio, dew-point temperature, relative humidity,
    vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
    dry-bulb temperature, wet-bulb temperature, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        TWetBulb : Wet-bulb temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Dew-point temperature in °F [IP] or °C [SI]
        Relative humidity in range [0, 1]
        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
        Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
        Specific volume of moist air in ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
        Degree of saturation [unitless]

    """
    HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
    RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
    VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
    MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio)
    MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
    DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)
    return HumRatio, TDewPoint, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation

def CalcPsychrometricsFromTDewPoint(TDryBulb: float, TDewPoint: float, Pressure: float) -> tuple:
    """
    Utility function to calculate humidity ratio, wet-bulb temperature, relative humidity,
    vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
    dry-bulb temperature, dew-point temperature, and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Wet-bulb temperature in °F [IP] or °C [SI]
        Relative humidity in range [0, 1]
        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
        Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
        Specific volume of moist air in ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
        Degree of saturation [unitless]

    """
    HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure)
    TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
    RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
    VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
    MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio)
    MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
    DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)
    return HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation

def CalcPsychrometricsFromRelHum(TDryBulb: float, RelHum: float, Pressure: float) -> tuple:
    """
    Utility function to calculate humidity ratio, wet-bulb temperature, dew-point temperature,
    vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
    dry-bulb temperature, relative humidity and pressure.

    Args:
        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
        RelHum : Relative humidity in range [0, 1]
        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]

    Returns:
        Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        Wet-bulb temperature in °F [IP] or °C [SI]
        Dew-point temperature in °F [IP] or °C [SI].
        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
        Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
        Specific volume of moist air in ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
        Degree of saturation [unitless]

    """
    HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure)
    TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
    TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
    VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
    MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio)
    MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
    DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)
    return HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation
