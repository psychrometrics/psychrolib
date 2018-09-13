
"""
psychro_ip.py
====================================
Module to calculate psychrometric libraries in Imperial units (IP)
"""

import math


# Global Constant
# Universal gas constant for dry air in ft∙lb_f/lb_da/R
# Reference: ASHRAE Handbook - Fundamentals (2017) - ch. 1, eqn 1
R_DA = 53.350


def GetRankineFromFahrenheit(TFahrenheit: float) -> float:
    """
    Utility function to convert temperature to degree Rankine (°R)
    given temperature in from degree Fahrenheit (°F).

    Parameters
    ----------
    TRankine: Temperature in degree Fahrenheit (°F)

    Returns
    -------
    TRankine : Temperature in degree Rankine (°R)

    Notes
    -----
    Exact conversion.

    """
    # Zero degree Fahrenheit (°F) expressed as degree Rankine (°R)
    ZERO_FAHRENHEIT_AS_RANKINE = 459.67

    TRankine = TFahrenheit + ZERO_FAHRENHEIT_AS_RANKINE
    return TRankine


def GetTWetBulbFromTDewPoint(TDryBulb: float, TDewPoint: float, Pressure: float) -> float:
    """
    Return wet-bulb temperature given dry-bulb temperature, dew-point temperature, and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    TDewPoint : Dew-point temperature in °F
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    TWetBulb: Wet-bulb temperature in °F

    References
    ----------
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

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    RelHum : Relative humidity in range [0, 1]
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    TWetBulb : Wet-bulb temperature in °F

    References
    ----------
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

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    TDewPoint : Dew-point temperature in °F

    Returns
    -------
    RelHum : Relative humidity in range [0, 1]

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 22

    """
    if TDewPoint > TDryBulb:
        raise ValueError("Dew point temperature is above dry bulb temperature")

    VapPres = GetSatVapPres(TDewPoint)
    SatVapPres = GetSatVapPres(TDryBulb)
    RelHum = VapPres/SatVapPres
    return RelHum


def GetRelHumFromTWetBulb(TDryBulb: float, TWetBulb: float, Pressure: float) -> float:
    """
    Return relative humidity given dry-bulb temperature, wet bulb temperature and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    TWetBulb : Wet-bulb temperature in °F
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    RelHum : Relative humidity in range [0, 1]

    References
    ----------
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

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    RelHum: Relative humidity in range [0, 1]

    Returns
    -------
    TDewPoint : Dew-point temperature in °F

    References
    ----------
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

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    TWetBulb : Wet-bulb temperature in °F
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    TDewPoint : Dew-point temperature in °F

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    if TWetBulb > TDryBulb:
        raise ValueError("Wet bulb temperature is above dry bulb temperature")

    HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
    return TDewPoint

#  Conversions between dew point, or relative humidity and vapor pressure


def GetVapPresFromRelHum(TDryBulb: float, RelHum: float) -> float:
    """
    Retrun partial pressure of water vapor as a function of relative humidity and temperature.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    RelHum : Relative humidity in range [0, 1]

    Returns
    -------
    VapPres: Partial pressure of water vapor in moist air in Psi

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22

    """
    if RelHum < 0 or RelHum > 1:
        raise ValueError("Relative humidity is outside range [0, 1]")

    VapPres = RelHum * GetSatVapPres(TDryBulb)
    return VapPres


def GetRelHumFromVapPres(TDryBulb: float, VapPres: float) -> float:
    """
    Return relative humidity given dry-bulb temperature and vapor pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    VapPres: Partial pressure of water vapor in moist air in Psi

    Returns
    -------
    RelHum : Relative humidity in range [0, 1]

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22

    """
    if VapPres < 0:
        raise ValueError("Partial pressure of water vapor in moist air cannot be negative")

    RelHum = VapPres / GetSatVapPres(TDryBulb)
    return RelHum


def GetTDewPointFromVapPres(TDryBulb: float, VapPres: float) -> float:
    """
    Return dew-point temperature given dry-bulb temperature and vapor pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    VapPres: Partial pressure of water vapor in moist air in Psi

    Returns
    -------
    TDewPoint : Dew-point temperature in °F

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 37 & 38

    """
    if VapPres < 0:
        raise ValueError("Partial pressure of water vapor in moist air cannot be negative")

    alpha = math.log(VapPres)

    if TDryBulb >= 32 and TDryBulb <= 200:
        TDewPoint = 100.45 + 33.193 * alpha + 2.319 * alpha**2 + 0.17074 * math.pow(alpha, 3) \
                    + 1.2063 * math.pow(VapPres, 0.1984)      # Eqn 37
    if TDryBulb < 32:
        TDewPoint = 90.12+26.142 * alpha + 0.8927 * alpha**2  # Eqn 38
    else:
        raise ValueError("Invalid dry-bulb temperature")

    TDewPoint = min(TDewPoint, TDryBulb)
    return TDewPoint


def GetVapPresFromTDewPoint(TDewPoint: float) -> float:
    """
    Return vapor pressure given dew point temperature.

    Parameters
    ----------
    TDewPoint : Dew-point temperature in °F

    Returns
    -------
    VapPres : Partial pressure of water vapor in moist air in Psi

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36

    """
    VapPres = GetSatVapPres(TDewPoint)
    return VapPres


# Conversions from wet-bulb temperature, dew-point temperature,
# or relative humidity to humidity ratio.


def GetTWetBulbFromHumRatio(TDryBulb: float, HumRatio: float, Pressure: float) -> float:
    """
    Return wet-bulb temperature given dry-bulb temperature, humidity ratio, and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    HumRatio : Humidity ratio in H₂O Air⁻¹
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    TWetBulb : Wet-bulb temperature in °F

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35 solved for Tstar

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio cannot be negative")

    TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)

    # Initial guesses
    TWetBulbSup = TDryBulb
    TWetBulbInf = TDewPoint
    TWetBulb = (TWetBulbInf + TWetBulbSup) / 2

    # Bisection loop
    while (TWetBulbSup - TWetBulbInf > 0.001):

        # Compute humidity ratio at temperature Tstar
        Wstar = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)

        # Get new bounds
        if Wstar > HumRatio:
            TWetBulbSup = TWetBulb
        else:
            TWetBulbInf = TWetBulb

        # New guess of wet bulb temperature
        TWetBulb = (TWetBulbSup + TWetBulbInf) / 2

    return TWetBulb


def GetHumRatioFromTWetBulb(TDryBulb: float, TWetBulb: float, Pressure: float) -> float:
    """
    Return humidity ratio given dry-bulb temperature, wet-bulb temperature, and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    TWetBulb : Wet-bulb temperature in °F
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    HumRatio : Humidity ratio in H₂O Air⁻¹

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35

    """
    if TWetBulb > TDryBulb:
        raise ValueError("Wet bulb temperature is above dry bulb temperature")

    Wsstar = GetSatHumRatio(TWetBulb, Pressure)

    if TWetBulb > 32:
        HumRatio =  ((1093 - 0.556 * TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb)) \
                    / (1093 + 0.444 * TDryBulb - TWetBulb)
    else:
        HumRatio =  ((1220 - 0.04*TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb)) \
                    / (1220 + 0.444 * TDryBulb - 0.48 * TWetBulb)

    return HumRatio


def GetHumRatioFromRelHum(TDryBulb: float, RelHum: float, Pressure: float) -> float:
    """
    Return humidity ratio given dry-bulb temperature, relative humidity, and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    RelHum : Relative humidity in range [0, 1]
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    HumRatio : Humidity ratio in H₂O Air⁻¹

    References
    ----------
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

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    HumRatio : Humidity ratio in H₂O Air⁻¹
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    RelHum : Relative humidity in range [0, 1]

    References
    ----------
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

    Parameters
    ----------
    TDewPoint : Dew-point temperature in °F
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    HumRatio : Humidity ratio in H₂O Air⁻¹

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    VapPres = GetSatVapPres(TDewPoint)
    HumRatio = GetHumRatioFromVapPres(VapPres, Pressure)
    return HumRatio


def GetTDewPointFromHumRatio(TDryBulb: float, HumRatio: float, Pressure: float) -> float:
    """
    Return dew-point temperature given dry-bulb temperature, humidity ratio, and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    HumRatio : Humidity ratio in H₂O Air⁻¹
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    TDewPoint : Dew-point temperature in °F

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio cannot be negative")

    VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
    TDewPoint = GetTDewPointFromVapPres(TDryBulb, VapPres)
    return TDewPoint


# Conversions between humidity ratio and vapor pressure


def GetHumRatioFromVapPres(VapPres: float, Pressure: float) -> float:
    """
    Return humidity ratio given water vapor pressure and atmospheric pressure.

    Parameters
    ----------
    VapPres : Partial pressure of water vapor in moist air in Psi
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    HumRatio : Humidity ratio in H₂O Air⁻¹

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20

    """
    if VapPres < 0:
        raise ValueError("Partial pressure of water vapor in moist air cannot be negative")

    HumRatio = 0.621945 * VapPres / (Pressure - VapPres)
    return HumRatio


def GetVapPresFromHumRatio(HumRatio: float, Pressure: float) -> float:
    """
    Return vapor pressure given humidity ratio and pressure.

    Parameters
    ----------
    HumRatio : Humidity ratio in H₂O Air⁻¹
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    VapPres : Partial pressure of water vapor in moist air in Psi

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20 solved for pw

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio is negative")

    VapPres = Pressure*HumRatio / (0.621945 + HumRatio)
    return VapPres


# Dry Air Calculations

def GetDryAirEnthalpy(TDryBulb: float) -> float:
    """
    Return dry-air enthalpy given dry-bulb temperature.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F

    Returns
    -------
    DryAirEnthalpy: Dry air enthalpy in Btu lb⁻¹


    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 28

    """
    DryAirEnthalpy = 0.240 * TDryBulb
    return DryAirEnthalpy


def GetDryAirDensity(TDryBulb: float, Pressure: float) -> float:
    """
    Return dry-air density given dry-bulb temperature and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    DryAirDensity : Dry air density in lb ft⁻³

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1

    Notes
    -----
    Eqn 14 for the perfect gas relationship for dry air.
    Eqn 1 for the universal gas constant.
    The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².

    """
    DryAirDensity = (144 * Pressure) / R_DA / GetRankineFromFahrenheit(TDryBulb)
    return DryAirDensity


def GetDryAirVolume(TDryBulb: float, Pressure: float) -> float:
    """
    Return dry-air volume given dry-bulb temperature and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    DryAirVolume: Dry air volume in ft³ lb⁻¹

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1

    Notes
    -----
    Eqn 14 for the perfect gas relationship for dry air.
    Eqn 1 for the universal gas constant.
    The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².

    """
    DryAirVolume = GetRankineFromFahrenheit(TDryBulb) * R_DA / (144 * Pressure)
    return DryAirVolume


# Saturated Air Calculations


def GetSatVapPres(TDryBulb: float) -> float:
    """
    Return saturation vapor pressure given dry-bulb temperature.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F

    Returns
    -------
    SatVapPres: Vapor pressure of saturated air in Psi

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1  eqn 5

    """
    if TDryBulb < -148 or TDryBulb > 392:
        raise ValueError("Dry bulb temperature must be in range [-148, 392]")

    T = GetRankineFromFahrenheit(TDryBulb)

    if TDryBulb <= 32:
        LnPws = -1.0214165E+04 / T - 4.8932428 - 5.3765794E-03 * T + 1.9202377E-07 * T**2 \
                + 3.5575832E-10 * math.pow(T, 3) - 9.0344688E-14 * math.pow(T, 4) + 4.1635019 * math.log(T)
    if TDryBulb > 32:
        LnPws = -1.0440397E+04 / T - 1.1294650E+01 - 2.7022355E-02 * T + 1.2890360E-05 * T**2 \
                - 2.4780681E-09 * math.pow(T, 3) + 6.5459673 * math.log(T)
    else:
        raise ValueError("Invalid dry-bulb temperature")

    SatVapPres = math.exp(LnPws)
    return SatVapPres


def GetSatHumRatio(TDryBulb: float, Pressure: float) -> float:
    """
    Return humidity ratio of saturated air given dry-bulb temperature and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    SatHumRatio: Humidity ratio of saturated air in H₂O Air⁻¹

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36, solved for W

    """
    SatVaporPres = GetSatVapPres(TDryBulb)
    SatHumRatio = 0.621945 * SatVaporPres / (Pressure - SatVaporPres)
    return SatHumRatio


def GetSatAirEnthalpy(TDryBulb: float, Pressure: float) -> float:
    """
    Return saturated air enthalpy given dry-bulb temperature and pressure.

    Parameters
    ----------
    TDryBulb: Dry-bulb temperature in °F
    Pressure: Atmospheric pressure in Psi

    Returns
    -------
    SatAirEnthalpy: Saturated air enthalpy in Btu lb⁻¹

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1

    """
    SatHumRatio = GetSatHumRatio(TDryBulb, Pressure)
    SatAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, SatHumRatio)
    return SatAirEnthalpy


# Moist Air Calculations


# TODO: check if this func is valid for IP
def GetVaporPressureDeficit(TDryBulb: float, HumRatio: float, Pressure: float) -> float:
    """
    Return Vapor pressure deficit given dry-bulb temperature, humidity ratio, and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    HumRatio : Humidity ratio in H₂O Air⁻¹
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    VaporPressureDeficit: Vapor pressure deficit in Psi

    References
    ----------
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

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    HumRatio : Humidity ratio in H₂O Air⁻¹
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    DegreeOfSaturation : Degree of saturation in arbitrary unit

    References
    ----------
    ASHRAE Handbook - Fundamentals (2009) ch. 1 eqn 12

    Notes
    -----
    This definition is absent from the 2017 Handbook. Using 2009 version instead.

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio is negative")

    SatHumRatio = GetSatHumRatio(TDryBulb, Pressure)
    DegreeOfSaturation = HumRatio / SatHumRatio
    return DegreeOfSaturation


def GetMoistAirEnthalpy(TDryBulb: float, HumRatio: float) -> float:
    """
    Return moist air enthalpy given dry-bulb temperature and humidity ratio.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    HumRatio : Humidity ratio in H₂O Air⁻¹

    Returns
    -------
    MoistAirEnthalpy: Moist air enthalpy in Btu lb⁻¹

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio is negative")

    MoistAirEnthalpy = 0.240 * TDryBulb + HumRatio * (1061 + 0.444 * TDryBulb)
    return MoistAirEnthalpy


def GetMoistAirVolume(TDryBulb: float, HumRatio: float, Pressure: float) -> float:
    """
    Return moist air specific volume given dry-bulb temperature, humidity ratio, and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    HumRatio : Humidity ratio in H₂O Air⁻¹
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    MoistAirVolume: Specific volume of moist air in ft³ lb⁻¹
    FIXME: The original comment was: Specific volume [ft3/lb of dry air]

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26

    Notes
    -----
    R_DA / 144 equals 0.370486. FIXME: check why is this here?
    The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio is negative")

    MoistAirVolume = R_DA * GetRankineFromFahrenheit(TDryBulb) * (1 + 1.607858 * HumRatio) / (144 * Pressure)
    return MoistAirVolume


def GetMoistAirDensity(TDryBulb: float, HumRatio: float, Pressure:float) -> float:
    """
    Return moist air density given humidity ratio, dry bulb temperature, and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    HumRatio : Humidity ratio in H₂O Air⁻¹
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    MoistAirDensity: Moist air density in lb ft⁻³

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 11

    """
    if HumRatio < 0:
        raise ValueError("Humidity ratio is negative")

    MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
    MoistAirDensity = (1 + HumRatio) / MoistAirVolume
    return MoistAirDensity


# Functions to set all psychrometric values

def CalcPsychrometricsFromTWetBulb(TDryBulb: float, TWetBulb: float, Pressure: float):
    """
    Utility function to calculate humidity ratio, dew-point temperature, relative humidity,
    vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
    dry-bulb temperature, wet-bulb temperature, and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    TWetBulb : Wet-bulb temperature in °F
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    HumRatio : Humidity ratio in H₂O Air⁻¹
    TDewPoint : Dew-point temperature in °F
    RelHum : Relative humidity in range [0, 1]
    VapPres : Partial pressure of water vapor in moist air in Psi
    MoistAirEnthalpy: Moist air enthalpy in Btu lb⁻¹
    MoistAirVolume: Specific volume of moist air in ft³ lb⁻¹
    DegreeOfSaturation : Degree of saturation in arbitrary unit

    """
    HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
    RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
    VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
    MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio)
    MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
    DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)
    return HumRatio, TDewPoint, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation

def CalcPsychrometricsFromTDewPoint(TDryBulb: float, TDewPoint: float, Pressure: float):
    """
    Utility function to calculate humidity ratio, wet-bulb temperature, relative humidity,
    vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
    dry-bulb temperature, dew-point temperature, and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    TDewPoint : Dew-point temperature in °F
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    HumRatio : Humidity ratio in H₂O Air⁻¹
    TWetBulb : Wet-bulb temperature in °F
    RelHum : Relative humidity in range [0, 1]
    VapPres : Partial pressure of water vapor in moist air in Psi
    MoistAirEnthalpy: Moist air enthalpy in Btu lb⁻¹
    MoistAirVolume: Specific volume of moist air in ft³ lb⁻¹
    DegreeOfSaturation : Degree of saturation in arbitrary unit

    """
    HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure)
    TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
    RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
    VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
    MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio)
    MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
    DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)
    return HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation

def CalcPsychrometricsFromRelHum(TDryBulb: float, RelHum: float, Pressure: float):
    """
    Utility function to calculate humidity ratio, wet-bulb temperature, dew-point temperature,
    vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
    dry-bulb temperature, relative humidity and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    RelHum : Relative humidity in range [0, 1]
    Pressure : Atmospheric pressure in Psi

    Returns
    -------
    HumRatio : Humidity ratio in H₂O Air⁻¹
    TWetBulb : Wet-bulb temperature in °F
    TDewPoint : Dew-point temperature in °F
    VapPres : Partial pressure of water vapor in moist air in Psi
    MoistAirEnthalpy: Moist air enthalpy in Btu lb⁻¹
    MoistAirVolume: Specific volume of moist air in ft³ lb⁻¹
    DegreeOfSaturation : Degree of saturation in arbitrary unit

    """
    HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure)
    TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
    TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
    VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
    MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio)
    MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
    DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)
    return HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation


# Standard atmosphere


def GetStandardAtmPressure(Altitude: float) -> float:
    """
    Return standard atmosphere barometric pressure, given the elevation (altitude).
    Parameters
    ----------
    Altitude: Altitude in ft

    Returns
    -------
    StandardAtmPressure: Standard atmosphere barometric pressure in Psi

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 3

    """
    StandardAtmPressure = 14.696 * math.pow(1 - 6.8754e-06 * Altitude, 5.2559)
    return StandardAtmPressure

#######################################/
# Standard atmosphere temperature, given the elevation (altitude)
# ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 4
#
def GetStandardAtmTemperature(Altitude: float) -> float:
    """
    Return standard atmosphere temperature, given the elevation (altitude).

    Parameters
    ----------
    Altitude: Altitude in ft

    Returns
    -------
    StandardAtmTemperature: Standard atmosphere dry-bulb temperature in °F

    References
    ----------
    ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 4

    """
    StandardAtmTemperature = 59 - 0.00356620 * Altitude
    return StandardAtmTemperature


# FIXME: note that the args order has been changed from original -- need to changed the other funcs too.
def GetSeaLevelPressure(TDryBulb: float, Altitude: float, StationPressure: float) -> float:

    """
    Return sea level pressure given dry-bulb temperature, altitude above sea level and pressure.

    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    Altitude: Altitude in ft
    StationPressure : Observed station pressure in Psi

    Returns
    -------
    SeaLevelPressure : Sea level barometric pressure in Psi

    References
    ----------
    Hess SL, Introduction to theoretical meteorology, Holt Rinehart and Winston, NY 1959,
    ch. 6.5; Stull RB, Meteorology for scientists and engineers, 2nd edition,
    Brooks/Cole 2000, ch. 1.

    Notes
    -----
    The standard procedure for the US is to use for TDryBulb the average
    of the current station temperature and the station temperature from 12 hours ago.

    """
    # Calculate average temperature in column of air, assuming a lapse rate
    # of 3.6 °F/1000ft
    TColumn = TDryBulb + 0.0036 * Altitude / 2

    # Determine the scale height
    H = 53.351 * GetRankineFromFahrenheit(TColumn)

    # Calculate the sea level pressure
    SeaLevelPressure = StationPressure * math.exp(Altitude / H)
    return SeaLevelPressure


# FIXME: check that this function is correct
def GetStationPressure(TDryBulb, Altitude, SeaLevelPressure):
    """
    Parameters
    ----------
    TDryBulb : Dry-bulb temperature in °F
    Altitude: Altitude in ft
    SeaLevelPressure : Sea level barometric pressure in Psi

    Returns
    -------
    StationPressure: Station pressure in Psi

    References
    ----------
    See 'GetSeaLevelPressure'

    Notes
    -----
    This function is just the inverse of 'GetSeaLevelPressure'.

    """
    StationPressure = SeaLevelPressure / GetSeaLevelPressure(1, Altitude, TDryBulb)
    return StationPressure