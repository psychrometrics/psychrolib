# PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
# Copyright (c) 2018-2020 The PsychroLib Contributors for the current library implementation.
# Copyright (c) 2017 ASHRAE Handbook — Fundamentals for ASHRAE equations and coefficients.
# Licensed under the MIT License.

#######################################################################################################
# Conversion between temperature units
#######################################################################################################

#' Utility function to convert temperature to degree Rankine (degreeR)
#' given temperature in degree Fahrenheit (degreeF).
#'
#' @param TFahrenheit A numeric vector of temperature in degree Fahrenheit (degreeF)
#'
#' @return A numeric vector of temperature in degree Rankine (degreeR)
#'
#' @section Notes:
#' Exact conversion.
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
#'
#' @examples
#' GetTRankineFromTFahrenheit(1:100)
#'
#' @export
GetTRankineFromTFahrenheit <- function (TFahrenheit) {
    TFahrenheit + ZERO_FAHRENHEIT_AS_RANKINE
}

#' Utility function to convert temperature to degree Fahrenheit (degreeF)
#' given temperature in degree Rankine (degreeR).
#'
#' @param TRankine A numeric vector of temperature in degree Rankine (degreeR)
#'
#' @return A numeric vector of temperature in degree Fahrenheit (degreeF)
#'
#' @section Notes:
#' Exact conversion.
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
#'
#' @examples
#' GetTFahrenheitFromTRankine(500:600)
#'
#' @export
GetTFahrenheitFromTRankine <- function (TRankine) {
    TRankine - ZERO_FAHRENHEIT_AS_RANKINE
}

#' Utility function to convert temperature to Kelvin (K)
#' given temperature in degree Celsius (degreeC).
#'
#' @param TCelsius A numeric vector of temperature in degree Celsius (degreeC)
#'
#' @return A numeric vector of temperature in Kelvin (K)
#'
#' @section Notes:
#' Exact conversion.
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
#'
#' @examples
#' GetTKelvinFromTCelsius(20:30)
#'
#' @export
GetTKelvinFromTCelsius <- function (TCelsius) {
    TCelsius + ZERO_CELSIUS_AS_KELVIN
}

#' Utility function to convert temperature to degree Celsius (degreeC)
#' given temperature in Kelvin (K).
#'
#' @param TKelvin A numeric vector of temperature in degree Kelvin (K)
#'
#' @return A numeric vector of temperature in Celsius (degreeC)
#'
#' @section Notes:
#' Exact conversion.
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
#'
#' @examples
#' GetTCelsiusFromTKelvin(300:400)
#'
#' @export
GetTCelsiusFromTKelvin <- function (TKelvin) {
    TKelvin - ZERO_CELSIUS_AS_KELVIN
}

#######################################################################################################
# Conversions between dew point, wet bulb, and relative humidity
#######################################################################################################

#' Return wet-bulb temperature given dry-bulb temperature, dew-point temperature, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param TDewPoint A numeric vector of dew-point temperature in degreeF [IP] or degreeC [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of wet-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @examples
#' SetUnitSystem("IP")
#' GetTWetBulbFromTDewPoint(80:100, 40.0, 14.696)
#'
#' SetUnitSystem("SI")
#' GetTWetBulbFromTDewPoint(25:40, 20.0, 101325.0)
#'
#' @export
GetTWetBulbFromTDewPoint <- function (TDryBulb, TDewPoint, Pressure) {
    CheckLength(TDryBulb, TDewPoint, Pressure)
    CheckTDewPoint(TDewPoint, TDryBulb)

    HumRatio <- GetHumRatioFromTDewPoint(TDewPoint, Pressure)
    GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
}

#' Return wet-bulb temperature given dry-bulb temperature, relative humidity, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param RelHum A numeric vector of relative humidity in range [0, 1]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of wet-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @examples
#' SetUnitSystem("IP")
#' GetTWetBulbFromRelHum(80:100, 0.2, 14.696)
#'
#' SetUnitSystem("SI")
#' GetTWetBulbFromRelHum(25:40, 0.2, 101325.0)
#'
#' @export
GetTWetBulbFromRelHum <- function (TDryBulb, RelHum, Pressure) {
    CheckRelHum(RelHum)
    CheckLength(TDryBulb, RelHum, Pressure)

    HumRatio <- GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure)
    GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
}

#' Return relative humidity given dry-bulb temperature and dew-point temperature.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param TDewPoint A numeric vector of dew-point temperature in degreeF [IP] or degreeC [SI]
#'
#' @return A numeric vector of relative humidity in range [0, 1]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 22
#'
#' @examples
#' SetUnitSystem("IP")
#' GetRelHumFromTDewPoint(80:100, 65)
#'
#' SetUnitSystem("SI")
#' GetRelHumFromTDewPoint(20:30, 15)
#'
#' @export
GetRelHumFromTDewPoint <- function (TDryBulb, TDewPoint) {
    CheckLength(TDryBulb, TDewPoint)
    CheckTDewPoint(TDewPoint, TDryBulb)

    VapPres <- GetSatVapPres(TDewPoint)
    SatVapPres <- GetSatVapPres(TDryBulb)
    VapPres / SatVapPres
}

#' Return relative humidity given dry-bulb temperature, wet bulb temperature and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param TWetBulb A numeric vector of wet-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of relative humidity in range [0, 1]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @examples
#' SetUnitSystem("IP")
#' GetRelHumFromTWetBulb(80:100, 79.9, 14.696)
#'
#' SetUnitSystem("SI")
#' GetRelHumFromTWetBulb(25:40, 20, 101325.0)
#'
#' @export
GetRelHumFromTWetBulb <- function (TDryBulb, TWetBulb, Pressure) {
    CheckLength(TDryBulb, TWetBulb, Pressure)
    CheckTWetBulb(TWetBulb, TDryBulb)

    HumRatio <- GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
}

#' Return dew-point temperature given dry-bulb temperature and relative humidity.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param RelHum A numeric vector of relative humidity in range [0, 1]
#'
#' @return A numeric vector of dew-point temperature in degreeF [IP] or degreeC [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @examples
#' SetUnitSystem("IP")
#' GetTDewPointFromRelHum(80:100, 0.2)
#'
#' SetUnitSystem("SI")
#' GetTDewPointFromRelHum(20:30, 0.4)
#'
#' @export
GetTDewPointFromRelHum <- function (TDryBulb, RelHum) {
    CheckLength(TDryBulb, RelHum)
    CheckRelHum(RelHum)

    VapPres <- GetVapPresFromRelHum(TDryBulb, RelHum)
    GetTDewPointFromVapPres(TDryBulb, VapPres)
}

#' Return dew-point temperature given dry-bulb temperature, wet-bulb temperature, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param TWetBulb A numeric vector of wet-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of dew-point temperature in degreeF [IP] or degreeC [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @examples
#' SetUnitSystem("IP")
#' GetTDewPointFromTWetBulb(80:100, 65.0, 14.696)
#'
#' SetUnitSystem("SI")
#' GetTDewPointFromTWetBulb(25:40, 20, 101325.0)
#'
#' @export
GetTDewPointFromTWetBulb <- function (TDryBulb, TWetBulb, Pressure) {
    CheckLength(TDryBulb, TWetBulb, Pressure)
    CheckTWetBulb(TWetBulb, TDryBulb)

    HumRatio <- GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
}

#######################################################################################################
# Conversions between dew point, or relative humidity and vapor pressure
#######################################################################################################

#' Return partial pressure of water vapor as a function of relative humidity and temperature.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param RelHum A numeric vector of relative humidity in range [0, 1]
#'
#' @return A numeric vector of partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
#'
#' @examples
#' SetUnitSystem("IP")
#' GetVapPresFromRelHum(77, seq(0.1, 0.8, 0.1))
#'
#' SetUnitSystem("SI")
#' GetVapPresFromRelHum(20, seq(0.1, 0.8, 0.1))
#'
#' @export
GetVapPresFromRelHum <- function (TDryBulb, RelHum) {
    CheckLength(TDryBulb, RelHum)
    CheckRelHum(RelHum)

    RelHum * GetSatVapPres(TDryBulb)
}

#' Return relative humidity given dry-bulb temperature and vapor pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param VapPres A numeric vector of partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of relative humidity in range [0, 1]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
#'
#' @examples
#' SetUnitSystem("IP")
#' GetRelHumFromVapPres(70:80, 0.0149)
#'
#' SetUnitSystem("SI")
#' GetRelHumFromVapPres(20:30, 12581)
#'
#' @export
GetRelHumFromVapPres <- function (TDryBulb, VapPres) {
    CheckLength(TDryBulb, VapPres)
    CheckVapPres(VapPres)

    VapPres / GetSatVapPres(TDryBulb)
}

#' Return dew-point temperature given dry-bulb temperature and vapor pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param VapPres A numeric vector of partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of dew-point temperature in degreeF [IP] or degreeC [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 and 6
#'
#' @note
#' \itemize{
#'  \item The dew point temperature is solved by inverting the equation giving water vapor pressure
#'        at saturation from temperature rather than using the regressions provided
#'        by ASHRAE (eqn. 37 and 38), which are much less accurate and have a
#'        narrower range of validity.
#'  \item The Newton-Raphson (NR) method is used on the logarithm of water vapour
#'        pressure as a function of temperature, which is a very smooth function.
#'  \item Convergence is usually achieved in 3 to 5 iterations.
#'  \item TDryBulb is not really needed here, just used for convenience.
#' }
#'
#' @examples
#' SetUnitSystem("IP")
#' GetTDewPointFromVapPres(70:80, seq(0.0149, 0.0249, 0.001))
#'
#' SetUnitSystem("SI")
#' GetTDewPointFromVapPres(70:80, 12581:12591)
#'
#' @export
GetTDewPointFromVapPres <- function (TDryBulb, VapPres) {
    CheckLength(TDryBulb, VapPres)

    if (isIP()) {
        BOUNDS <- c(-148, 392)
    } else {
        BOUNDS <- c(-100, 200)
    }

    # Validity check -- bounds outside which a solution cannot be found
    if (any(VapPres < GetSatVapPres(BOUNDS[1]) | VapPres > GetSatVapPres(BOUNDS[2]))) {
        stop("Partial pressure of water vapor is outside range of validity of equations")
    }

    l <- max(c(length(TDryBulb), length(VapPres)))
    TDryBulb <- rep(TDryBulb, length.out = l)
    VapPres <- rep(VapPres, length.out = l)
    TDewPoint <- numeric(l)

    CV_GetTDewPointFromVapPres(
        TDryBulb, VapPres, BOUNDS[[1]], BOUNDS[[2]],
        PSYCHRO_OPT$MAX_ITER_COUNT, PSYCHRO_OPT$TOLERANCE, isIP()
    )
}

#' Return vapor pressure given dew point temperature.
#'
#' @param TDewPoint A numeric vector of dew-point temperature in degreeF [IP] or degreeC [SI]
#'
#' @return A numeric vector of partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36
#'
#' @examples
#' SetUnitSystem("IP")
#' GetVapPresFromTDewPoint(12:20)
#'
#' SetUnitSystem("SI")
#' GetVapPresFromTDewPoint(12:20)
#'
#' @export
GetVapPresFromTDewPoint <- function (TDewPoint) {
    GetSatVapPres(TDewPoint)
}

#######################################################################################################
# Conversions from wet-bulb temperature, dew-point temperature, or relative humidity to humidity ratio
#######################################################################################################

#' Return wet-bulb temperature given dry-bulb temperature, humidity ratio, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of wet-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35 solved for Tstar
#'
#' @examples
#' SetUnitSystem("IP")
#' GetTWetBulbFromHumRatio(80:100, 0.01, 14.175)
#'
#' SetUnitSystem("SI")
#' GetTWetBulbFromHumRatio(20:30, 0.01, 95461)
#'
#' @export
GetTWetBulbFromHumRatio <- function (TDryBulb, HumRatio, Pressure) {
    CheckLength(TDryBulb, HumRatio, Pressure)
    CheckHumRatio(HumRatio)

    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    TDewPoint <- GetTDewPointFromHumRatio(TDryBulb, BoundedHumRatio, Pressure)

    l <- max(c(length(TDryBulb), length(BoundedHumRatio), length(Pressure)))
    TDryBulb <- rep(TDryBulb, length.out = l)
    BoundedHumRatio <- rep(BoundedHumRatio, length.out = l)
    Pressure <- rep(Pressure, length.out = l)
    TWetBulb <- numeric(l)

    CV_GetTWetBulbFromHumRatio(
        TDryBulb, TDewPoint, BoundedHumRatio, Pressure,
        PSYCHRO_OPT$MIN_HUM_RATIO, PSYCHRO_OPT$MAX_ITER_COUNT, PSYCHRO_OPT$TOLERANCE, isIP()
    )
}

#' Return humidity ratio given dry-bulb temperature, wet-bulb temperature, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param TWetBulb A numeric vector of wet-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param Pressure A numeric vector of atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35
#'
#' @examples
#' SetUnitSystem("IP")
#' GetHumRatioFromTWetBulb(80:100, 77.0, 14.175)
#'
#' SetUnitSystem("SI")
#' GetHumRatioFromTWetBulb(20:30, 19.0, 95461.0)
#'
#' @export
GetHumRatioFromTWetBulb <- function (TDryBulb, TWetBulb, Pressure) {
    x <- AlignLength(TDryBulb, TWetBulb, Pressure)
    TDryBulb <- x$TDryBulb
    TWetBulb <- x$TWetBulb
    Pressure <- x$Pressure

    if (any(TWetBulb > TDryBulb)) {
        stop("Wet bulb temperature is above dry bulb temperature")
    }

    Wsstar <- GetSatHumRatio(TWetBulb, Pressure)
    HumRatio <- numeric(length(TWetBulb))

    if (isIP()) {
        idx <- TWetBulb >= FREEZING_POINT_WATER_IP

        if (any(idx)) {
            HumRatio[idx] <- ((1093.0 - 0.556 * TWetBulb[idx]) * Wsstar[idx] - 0.240 * (TDryBulb[idx] - TWetBulb[idx])) /
                (1093.0 + 0.444 * TDryBulb[idx] - TWetBulb[idx])
        }

        if (any(!idx)) {
            HumRatio[!idx] <- ((1220.0 - 0.04 * TWetBulb[!idx]) * Wsstar[!idx] - 0.240 * (TDryBulb[!idx] - TWetBulb[!idx])) /
                (1220.0 + 0.444 * TDryBulb[!idx] - 0.48 * TWetBulb[!idx])
        }
    } else {
        idx <- TWetBulb >= FREEZING_POINT_WATER_SI

        if (any(idx)) {
            HumRatio[idx] <- ((2501.0 - 2.326 * TWetBulb[idx]) * Wsstar[idx] - 1.006 * (TDryBulb[idx] - TWetBulb[idx])) /
                (2501.0 + 1.86 * TDryBulb[idx] - 4.186 * TWetBulb[idx])
        }

        if (any(!idx)) {
            HumRatio[!idx] <- ((2830.0 - 0.24 * TWetBulb[!idx]) * Wsstar[!idx] - 1.006 * (TDryBulb[!idx] - TWetBulb[!idx])) /
                (2830.0 + 1.86 * TDryBulb[!idx] - 2.1 * TWetBulb[!idx])
        }
    }

    # Validity check.
    pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)
}

#' Return humidity ratio given dry-bulb temperature, relative humidity, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param RelHum A numeric vector of relative humidity in range [0, 1]
#' @param Pressure A numeric vector of atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @examples
#' SetUnitSystem("IP")
#' GetHumRatioFromRelHum(80:100, 0.5, 14.175)
#'
#' SetUnitSystem("SI")
#' GetHumRatioFromRelHum(20:30, 0.5, 95461.0)
#'
#' @export
GetHumRatioFromRelHum <- function (TDryBulb, RelHum, Pressure) {
    CheckLength(TDryBulb, RelHum, Pressure)
    CheckRelHum(RelHum)

    VapPres <- GetVapPresFromRelHum(TDryBulb, RelHum)
    GetHumRatioFromVapPres(VapPres, Pressure)
}

#' Return relative humidity given dry-bulb temperature, humidity ratio, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of relative humidity in range [0, 1]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @examples
#' SetUnitSystem("IP")
#' GetRelHumFromHumRatio(80:100, 0.01, 14.175)
#'
#' SetUnitSystem("SI")
#' GetRelHumFromHumRatio(20:30, 0.01, 95461.0)
#'
#' @export
GetRelHumFromHumRatio <- function (TDryBulb, HumRatio, Pressure) {
    CheckHumRatio(HumRatio)

    VapPres <- GetVapPresFromHumRatio(HumRatio, Pressure)
    GetRelHumFromVapPres(TDryBulb, VapPres)
}

#' Return humidity ratio given dew-point temperature and pressure.
#'
#' @param TDewPoint A numeric vector of dew-point temperature in degreeF [IP] or degreeC [SI]
#' @param Pressure A numeric vector of atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 13
#'
#' @examples
#' SetUnitSystem("IP")
#' GetHumRatioFromTDewPoint(50:80, 14.175)
#'
#' SetUnitSystem("SI")
#' GetHumRatioFromTDewPoint(20:30, 95461.0)
#'
#' @export
GetHumRatioFromTDewPoint <- function (TDewPoint, Pressure) {
    VapPres <- GetSatVapPres(TDewPoint)
    GetHumRatioFromVapPres(VapPres, Pressure)
}

#' Return dew-point temperature given dry-bulb temperature, humidity ratio, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of dew-point temperature in degreeF [IP] or degreeC [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @examples
#' SetUnitSystem("IP")
#' GetTDewPointFromHumRatio(80:100, 0.01, 14.175)
#'
#' SetUnitSystem("SI")
#' GetTDewPointFromHumRatio(20:30, 0.01, 95461.0)
#'
#' @export
GetTDewPointFromHumRatio <- function (TDryBulb, HumRatio, Pressure) {
    CheckHumRatio(HumRatio)

    VapPres <- GetVapPresFromHumRatio(HumRatio, Pressure)
    GetTDewPointFromVapPres(TDryBulb, VapPres)
}

#######################################################################################################
# Conversions between humidity ratio and vapor pressure
#######################################################################################################

#' Return humidity ratio given water vapor pressure and atmospheric pressure.
#'
#' @param VapPres A numeric vector of partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20
#'
#' @examples
#' SetUnitSystem("IP")
#' GetHumRatioFromVapPres(seq(0.4, 0.6, 0.01), 14.175)
#'
#' SetUnitSystem("SI")
#' GetHumRatioFromVapPres(seq(3000, 4000, 100), 95461)
#'
#' @export
GetHumRatioFromVapPres <- function (VapPres, Pressure) {
    CheckLength(VapPres, Pressure)
    CheckVapPres(VapPres)

    HumRatio <- 0.621945 * VapPres / (Pressure - VapPres)

    # Validity check.
    pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)
}

#' Return vapor pressure given humidity ratio and pressure.
#'
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20 solved for pw
#'
#' @examples
#' SetUnitSystem("IP")
#' GetVapPresFromHumRatio(seq(0.02, 0.03, 0.001), 14.175)
#'
#' SetUnitSystem("SI")
#' GetVapPresFromHumRatio(seq(0.02, 0.03, 0.001), 95461)
#'
#' @export
GetVapPresFromHumRatio <- function (HumRatio, Pressure) {
    CheckLength(HumRatio, Pressure)
    CheckHumRatio(HumRatio)

    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)
    Pressure * BoundedHumRatio / (0.621945 + BoundedHumRatio)
}

#######################################################################################################
# Conversions between humidity ratio and specific humidity
#######################################################################################################

#' Return the specific humidity from humidity ratio (aka mixing ratio).
#'
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Dry_Air-1 [IP] or kg_H2O kg_Dry_Air-1 [SI]
#'
#' @return A numeric vector of specific humidity in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b
#'
#' @examples
#' SetUnitSystem("IP")
#' GetSpecificHumFromHumRatio(seq(0.006, 0.016, 0.001))
#'
#' SetUnitSystem("SI")
#' GetSpecificHumFromHumRatio(seq(0.006, 0.016, 0.001))
#'
#' @export
GetSpecificHumFromHumRatio <- function (HumRatio) {
    CheckHumRatio(HumRatio)

    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)
    BoundedHumRatio / (1.0 + BoundedHumRatio)
}

#' Return the humidity ratio (aka mixing ratio) from specific humidity.
#'
#' @param SpecificHum A numeric vector of specific humidity in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @return A numeric vector of humidity ratio in lb_H2O lb_Dry_Air-1 [IP] or kg_H2O kg_Dry_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b (solved for humidity ratio)
#'
#' @examples
#' SetUnitSystem("IP")
#' GetHumRatioFromSpecificHum(seq(0.006, 0.016, 0.001))
#'
#' SetUnitSystem("SI")
#' GetHumRatioFromSpecificHum(seq(0.006, 0.016, 0.001))
#'
#' @export
GetHumRatioFromSpecificHum <- function (SpecificHum) {
    CheckSpecificHum(SpecificHum)

    HumRatio <- SpecificHum / (1.0 - SpecificHum)

    # Validity check.
    pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)
}

#######################################################################################################
# Dry Air Calculations
#######################################################################################################

#' Return dry-air enthalpy given dry-bulb temperature.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @return A numeric vector of dry air enthalpy in Btu lb-1 [IP] or J kg-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 28
#'
#' @examples
#' SetUnitSystem("IP")
#' GetDryAirEnthalpy(77:87)
#'
#' SetUnitSystem("SI")
#' GetDryAirEnthalpy(10:30)
#'
#'
#' @export
GetDryAirEnthalpy <- function (TDryBulb) {
    if (isIP()) {
        0.240 * TDryBulb
    } else {
        1006.0 * TDryBulb
    }
}

#' Return dry-air density given dry-bulb temperature and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of dry air density in lb ft-3 [IP] or kg m-3 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#' \itemize{
#'   \item Eqn 14 for the perfect gas relationship for dry air.
#'   \item Eqn 1 for the universal gas constant.
#'   \item The factor 144 in IP is for the conversion of Psi = lb in-2 to lb ft-2.
#' }
#'
#' @examples
#' SetUnitSystem("IP")
#' GetDryAirDensity(77:87, 14.696)
#'
#' SetUnitSystem("SI")
#' GetDryAirDensity(25:30, 101325)
#'
#' @export
GetDryAirDensity <- function (TDryBulb, Pressure) {
    CheckLength(TDryBulb, Pressure)

    if (isIP()) {
        # The factor 144 is for the conversion of Psi = lb in-2 to lb ft-2.
        (144 * Pressure) / R_DA_IP / GetTRankineFromTFahrenheit(TDryBulb)
    } else {
        Pressure / R_DA_SI / GetTKelvinFromTCelsius(TDryBulb)
    }
}

#' Return dry-air volume given dry-bulb temperature and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of dry air volume in ft3 lb-1 [IP] or in m3 kg-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#' \itemize{
#'   \item Eqn 14 for the perfect gas relationship for dry air.
#'   \item Eqn 1 for the universal gas constant.
#'   \item The factor 144 in IP is for the conversion of Psi = lb in-2 to lb ft-2.
#' }
#'
#' @examples
#' SetUnitSystem("IP")
#' GetDryAirVolume(77:87, 14.696)
#'
#' SetUnitSystem("SI")
#' GetDryAirVolume(25:30, 101325)
#'
#' @export
GetDryAirVolume <- function (TDryBulb, Pressure) {
    CheckLength(TDryBulb, Pressure)

    if (isIP()) {
        # The factor 144 is for the conversion of Psi = lb in-2 to lb ft-2.
        R_DA_IP * GetTRankineFromTFahrenheit(TDryBulb) / (144 * Pressure)
    } else {
        R_DA_SI * GetTKelvinFromTCelsius(TDryBulb) / Pressure
    }
}

#' Return dry bulb temperature from enthalpy and humidity ratio.
#'
#' @param MoistAirEnthalpy A numeric vector of moist air enthalpy in Btu lb-1 [IP] or J kg-1
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @return A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30
#'
#' @note
#' Based on the \code{\link{GetMoistAirEnthalpy}} function, rearranged for temperature.
#'
#' @examples
#' SetUnitSystem("IP")
#' GetTDryBulbFromEnthalpyAndHumRatio(42.6168, seq(0.01, 0.02, 0.001))
#'
#' SetUnitSystem("SI")
#' GetTDryBulbFromEnthalpyAndHumRatio(81316.0, seq(0.01, 0.02, 0.001))
#'
#' @export
GetTDryBulbFromEnthalpyAndHumRatio <- function (MoistAirEnthalpy, HumRatio) {
    CheckLength(MoistAirEnthalpy, HumRatio)
    CheckHumRatio(HumRatio)

    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    if (isIP()) {
        (MoistAirEnthalpy - 1061.0 * BoundedHumRatio) / (0.240 + 0.444 * BoundedHumRatio)
    } else {
        (MoistAirEnthalpy / 1000.0 - 2501.0 * BoundedHumRatio) / (1.006 + 1.86 * BoundedHumRatio)
    }
}

#' Return humidity ratio from enthalpy and dry-bulb temperature.
#'
#' @param MoistAirEnthalpy A numeric vector of moist air enthalpy in Btu lb-1 [IP] or J kg-1
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @return A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30.
#'
#' @note
#' Based on the \code{\link{GetMoistAirEnthalpy}} function, rearranged for humidity ratio.
#'
#' @examples
#' SetUnitSystem("IP")
#' GetHumRatioFromEnthalpyAndTDryBulb(42.6168, 76:86)
#'
#' SetUnitSystem("SI")
#' GetHumRatioFromEnthalpyAndTDryBulb(81316.0, 20:30)
#'
#' @export
GetHumRatioFromEnthalpyAndTDryBulb <- function (MoistAirEnthalpy, TDryBulb) {
    CheckLength(MoistAirEnthalpy, TDryBulb)

    if (isIP()) {
        HumRatio <- (MoistAirEnthalpy - 0.240 * TDryBulb) / (1061.0 + 0.444 * TDryBulb)
    } else {
        HumRatio <- (MoistAirEnthalpy / 1000.0 - 1.006 * TDryBulb) / (2501.0 + 1.86 * TDryBulb)
    }

    # Validity check.
    pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)
}

#######################################################################################################
# Saturated Air Calculations
#######################################################################################################

#' Return saturation vapor pressure given dry-bulb temperature.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @return A numeric vector of vapor pressure of saturated air in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1  eqn 5 & 6
#'
#' @note
#' Important note: the ASHRAE formulae are defined above and below the freezing point but have
#' a discontinuity at the freezing point. This is a small inaccuracy on ASHRAE's part: the formulae
#' should be defined above and below the triple point of water (not the feezing point) in which case
#' the discontinuity vanishes. It is essential to use the triple point of water otherwise function
#' GetTDewPointFromVapPres, which inverts the present function, does not converge properly around
#' the freezing point.
#'
#' @examples
#' SetUnitSystem("IP")
#' GetSatVapPres(80:100)
#'
#' SetUnitSystem("SI")
#' GetSatVapPres(20:30)
#'
#' @export
GetSatVapPres <- function (TDryBulb) {
    LnPws <- numeric(length(TDryBulb))

    if (isIP()) {
        if (any(TDryBulb < -148.0 | TDryBulb > 392.0)) {
            stop("Dry bulb temperature must be in range [-148, 392]\u00B0F")
        }

        TR <- GetTRankineFromTFahrenheit(TDryBulb)

        idx <- TDryBulb <= TRIPLE_POINT_WATER_IP

        if (any(idx)) {
            LnPws[idx] <- -1.0214165E+04 / TR[idx] - 4.8932428 - 5.3765794E-03 * TR[idx] + 1.9202377E-07 * TR[idx] ^ 2 +
                3.5575832E-10 * TR[idx] ^ 3 - 9.0344688E-14 * TR[idx] ^4 + 4.1635019 * log(TR[idx])
        }

        if (any(!idx)) {
            LnPws[!idx] <- -1.0440397E+04 / TR[!idx] - 1.1294650E+01 - 2.7022355E-02* TR[!idx] + 1.2890360E-05 * TR[!idx] ^ 2 +
                -2.4780681E-09 * TR[!idx] ^ 3 + 6.5459673 * log(TR[!idx])
        }
    } else {
        if (any(TDryBulb < -100.0 | TDryBulb > 200.0)) {
            stop("Dry bulb temperature must be in range [-100, 200]\u00B0C")
        }

        TK <- GetTKelvinFromTCelsius(TDryBulb)

        idx <- TDryBulb <= TRIPLE_POINT_WATER_SI

        if (any(idx)) {
            LnPws[idx] <- -5.6745359E+03 / TK[idx] + 6.3925247 - 9.677843E-03 * TK[idx] + 6.2215701E-07 * TK[idx] ^ 2 +
                2.0747825E-09 * TK[idx] ^ 3 - 9.484024E-13 * TK[idx] ^ 4 + 4.1635019 * log(TK[idx])
        }

        if (any(!idx)) {
            LnPws[!idx] <- -5.8002206E+03 / TK[!idx] + 1.3914993 - 4.8640239E-02 * TK[!idx] + 4.1764768E-05 * TK[!idx] ^ 2 +
                -1.4452093E-08 * TK[!idx] ^ 3 + 6.5459673 * log(TK[!idx])
        }
    }

    exp(LnPws)
}

#' Return humidity ratio of saturated air given dry-bulb temperature and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of humidity ratio of saturated air in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36, solved for W
#'
#' @examples
#' SetUnitSystem("IP")
#' GetSatHumRatio(80:100, 14.696)
#'
#' SetUnitSystem("SI")
#' GetSatHumRatio(20:30, 101325)
#'
#' @export
GetSatHumRatio <- function (TDryBulb, Pressure) {
    CheckLength(TDryBulb, Pressure)

    SatVaporPres <- GetSatVapPres(TDryBulb)
    SatHumRatio <- 0.621945 * SatVaporPres / (Pressure - SatVaporPres)

    # Validity check.
    pmax(SatHumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)
}

#' Return saturated air enthalpy given dry-bulb temperature and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of saturated air enthalpy in Btu lb-1 [IP] or J kg-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @examples
#' SetUnitSystem("IP")
#' GetSatAirEnthalpy(80:100, 14.696)
#'
#' SetUnitSystem("SI")
#' GetSatAirEnthalpy(20:30, 101325)
#'
#' @export
GetSatAirEnthalpy <- function (TDryBulb, Pressure) {
    CheckLength(TDryBulb, Pressure)

    SatHumRatio <- GetSatHumRatio(TDryBulb, Pressure)
    GetMoistAirEnthalpy(TDryBulb, SatHumRatio)
}

#######################################################################################################
# Moist Air Calculations
#######################################################################################################

#' Return Vapor pressure deficit given dry-bulb temperature, humidity ratio, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of vapor pressure deficit in Psi [IP] or Pa [SI]
#'
#' @references
#' Oke (1987) eqn 2.13a
#'
#' @examples
#' SetUnitSystem("IP")
#' GetVaporPressureDeficit(80:100, 0.01, 14.175)
#'
#' SetUnitSystem("SI")
#' GetVaporPressureDeficit(20:30, 0.01, 95461.0)
#'
#' @export
GetVaporPressureDeficit <- function (TDryBulb, HumRatio, Pressure) {
    CheckLength(TDryBulb, HumRatio, Pressure)
    CheckHumRatio(HumRatio)

    RelHum <- GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
    GetSatVapPres(TDryBulb) * (1 - RelHum)
}

#' Return the degree of saturation (i.e humidity ratio of the air / humidity ratio of the air at saturation
#' at the same temperature and pressure) given dry-bulb temperature, humidity ratio, and atmospheric pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of degree of saturation in arbitrary unit
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2009) ch. 1 eqn 12
#'
#' @note
#' This definition is absent from the 2017 Handbook. Using 2009 version instead.
#'
#' @examples
#' SetUnitSystem("IP")
#' GetDegreeOfSaturation(80:100, 0.01, 14.175)
#'
#' SetUnitSystem("SI")
#' GetDegreeOfSaturation(20:30, 0.01, 95461.0)
#'
#' @export
GetDegreeOfSaturation <- function (TDryBulb, HumRatio, Pressure) {
    CheckLength(TDryBulb, HumRatio, Pressure)
    CheckHumRatio(HumRatio)
    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    SatHumRatio <- GetSatHumRatio(TDryBulb, Pressure)
    BoundedHumRatio / SatHumRatio
}

#' Return moist air enthalpy given dry-bulb temperature and humidity ratio.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @return A numeric vector of moist air enthalpy in Btu lb-1 [IP] or J kg-1
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30
#'
#' @examples
#' SetUnitSystem("IP")
#' GetMoistAirEnthalpy(80:100, 0.02)
#'
#' SetUnitSystem("SI")
#' GetMoistAirEnthalpy(20:30, 0.02)
#'
#' @export
GetMoistAirEnthalpy <- function (TDryBulb, HumRatio) {
    CheckLength(TDryBulb, HumRatio)
    CheckHumRatio(HumRatio)
    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    if (isIP()) {
        0.240 * TDryBulb + BoundedHumRatio * (1061 + 0.444 * TDryBulb)
    } else {
        (1.006 * TDryBulb + BoundedHumRatio * (2501. + 1.86 * TDryBulb)) * 1000
    }
}

#' Return moist air specific volume given dry-bulb temperature, humidity ratio, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of specific volume of moist air in ft3 lb-1 of dry air [IP] or in m3 kg-1 of dry air [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26
#'
#' @note
#' In IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26.
#'
#' The factor 144 is for the conversion of Psi = lb in-2 to lb ft-2.
#'
#' @examples
#' SetUnitSystem("IP")
#' GetMoistAirVolume(80:100, 0.02, 14.175)
#'
#' SetUnitSystem("SI")
#' GetMoistAirVolume(20:30, 0.02, 95461)
#'
#' @export
GetMoistAirVolume <- function (TDryBulb, HumRatio, Pressure) {
    CheckLength(TDryBulb, HumRatio, Pressure)
    CheckHumRatio(HumRatio)
    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    if (isIP()) {
        # R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26
        # The factor 144 is for the conversion of Psi = lb in-2 to lb ft-2.
        R_DA_IP * GetTRankineFromTFahrenheit(TDryBulb) * (1 + 1.607858 * BoundedHumRatio) / (144 * Pressure)
    } else {
        R_DA_SI * GetTKelvinFromTCelsius(TDryBulb) * (1 + 1.607858 * BoundedHumRatio) / Pressure
    }
}

#' Return dry-bulb temperature given moist air specific volume, humidity ratio, and pressure.
#'
#' @param MoistAirVolume A numeric vector of specific volume of moist air in ft3 lb-1 of dry air [IP] or in m3 kg-1 of dry air [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of tDryBulb : Dry-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26
#'
#' @note
#' \itemize{
#'   \item In IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26.
#'   \item The factor 144 is for the conversion of Psi = lb in-2 to lb ft-2.
#'   \item Based on the `GetMoistAirVolume` function, rearranged for dry-bulb temperature.
#' }
#'
#' @examples
#' SetUnitSystem("IP")
#' GetTDryBulbFromMoistAirVolumeAndHumRatio(14.72, seq(0.02, 0.03, 0.001), 14.175)
#'
#' SetUnitSystem("SI")
#' GetTDryBulbFromMoistAirVolumeAndHumRatio(0.94, seq(0.02, 0.03, 0.001), 95461)
#'
#' @export
GetTDryBulbFromMoistAirVolumeAndHumRatio <- function (MoistAirVolume, HumRatio, Pressure) {
    CheckLength(MoistAirVolume, HumRatio, Pressure)
    CheckHumRatio(HumRatio)
    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    if (isIP()) {
        GetTFahrenheitFromTRankine(MoistAirVolume * (144 * Pressure)
            / (R_DA_IP * (1 + 1.607858 * BoundedHumRatio)))
    } else {
        GetTCelsiusFromTKelvin(MoistAirVolume * Pressure
            / (R_DA_SI * (1 + 1.607858 * BoundedHumRatio)))
    }
}

#' Return moist air density given humidity ratio, dry bulb temperature, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of moistAirDensity: Moist air density in lb ft-3 [IP] or kg m-3 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 11
#'
#' @examples
#' SetUnitSystem("IP")
#' GetMoistAirDensity(80:100, 0.02, 14.175)
#'
#' SetUnitSystem("SI")
#' GetMoistAirDensity(20:30, 0.02, 95461)
#'
#' @export
GetMoistAirDensity <- function (TDryBulb, HumRatio, Pressure) {
    CheckLength(TDryBulb, HumRatio, Pressure)
    CheckHumRatio(HumRatio)
    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    MoistAirVolume <- GetMoistAirVolume(TDryBulb, BoundedHumRatio, Pressure)
    (1 + BoundedHumRatio) / MoistAirVolume
}

#######################################################################################################
# Standard atmosphere
#######################################################################################################

#' Return standard atmosphere barometric pressure, given the elevation (altitude).
#'
#' @param Altitude A numeric vector of altitude in ft [IP] or m [SI]
#'
#' @return A numeric vector of standard atmosphere barometric pressure in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 3
#'
#' @examples
#' SetUnitSystem("IP")
#' GetStandardAtmPressure(seq(-500, 1000, 100))
#'
#' SetUnitSystem("SI")
#' GetStandardAtmPressure(seq(-500, 1000, 100))
#'
#' @export
GetStandardAtmPressure <- function (Altitude) {
    if (isIP()) {
        14.696 * (1 - 6.8754e-06 * Altitude) ^ 5.2559
    } else {
        101325.0 * (1 - 2.25577e-05 * Altitude) ^ 5.2559
    }
}

#' Return standard atmosphere temperature, given the elevation (altitude).
#'
#' @param Altitude A numeric vector of altitude in ft [IP] or m [SI]
#'
#' @return A numeric vector of standard atmosphere dry-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 4
#'
#' @examples
#' SetUnitSystem("IP")
#' GetStandardAtmTemperature(seq(-500, 1000, 100))
#'
#' SetUnitSystem("SI")
#' GetStandardAtmTemperature(seq(-500, 1000, 100))
#'
#' @export
GetStandardAtmTemperature <- function (Altitude) {
    if (isIP()) {
        59.0 - 0.00356620 * Altitude
    } else {
        15.0 - 0.0065 * Altitude
    }
}

#' Return sea level pressure given dry-bulb temperature, altitude above sea level and pressure.
#'
#' @param StationPressure A numeric vector of observed station pressure in Psi [IP] or Pa [SI]
#' @param Altitude A numeric vector of altitude in ft [IP] or m [SI]
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @return A numeric vector of sea level barometric pressure in Psi [IP] or Pa [SI]
#'
#' @references
#' Hess SL, Introduction to theoretical meteorology, Holt Rinehart and Winston, NY 1959,
#' ch. 6.5; Stull RB, Meteorology for scientists and engineers, 2nd edition,
#' Brooks/Cole 2000, ch. 1.
#'
#' @note
#' The standard procedure for the US is to use for TDryBulb the average
#' of the current station temperature and the station temperature from 12 hours ago.
#'
#' @examples
#' SetUnitSystem("IP")
#' GetSeaLevelPressure(14.68, 300:400, 62.94)
#'
#' SetUnitSystem("SI")
#' GetSeaLevelPressure(101226.5, 105:205, 17.19)
#'
#' @export
GetSeaLevelPressure <- function (StationPressure, Altitude, TDryBulb) {
    CheckLength(StationPressure, Altitude, TDryBulb)

    if (isIP()) {
        # Calculate average temperature in column of air, assuming a lapse rate
        # of 3.6 degreeF/1000ft
        TColumn <- TDryBulb + 0.0036 * Altitude / 2

        # Determine the scale height
        H <- 53.351 * GetTRankineFromTFahrenheit(TColumn)
    } else {
        # Calculate average temperature in column of air, assuming a lapse rate
        # of 6.5 degreeC/km
        TColumn <- TDryBulb + 0.0065 * Altitude / 2

        # Determine the scale height
        H <- 287.055 * GetTKelvinFromTCelsius(TColumn) / 9.807
    }

    # Calculate the sea level pressure
    StationPressure * exp(Altitude / H)
}

#' Return station pressure from sea level pressure.
#'
#' @param SeaLevelPressure A numeric vector of sea level barometric pressure in Psi [IP] or Pa [SI]
#' @param Altitude A numeric vector of altitude in ft [IP] or m [SI]
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @return A numeric vector of station pressure in Psi [IP] or Pa [SI]
#'
#' @references See \code{\link{GetSeaLevelPressure}}.
#'
#' @note
#' This function is just the inverse of \code{\link{GetSeaLevelPressure}}.
#'
#' @examples
#' SetUnitSystem("IP")
#' GetStationPressure(14.68, 300:400, 62.94)
#'
#' SetUnitSystem("SI")
#' GetStationPressure(101226.5, 105:205, 17.19)
#'
#' @export
GetStationPressure <- function (SeaLevelPressure, Altitude, TDryBulb) {
    CheckLength(SeaLevelPressure, Altitude, TDryBulb)

    SeaLevelPressure / GetSeaLevelPressure(1, Altitude, TDryBulb)
}

######################################################################################################
# Functions to set all psychrometric values
#######################################################################################################

#' @title Calculate psychrometric values from wet-bulb temperature.
#'
#' @description Utility function to calculate humidity ratio, dew-point temperature, relative humidity,
#' vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
#' dry-bulb temperature, wet-bulb temperature, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param TWetBulb A numeric vector of wet-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A list with named components for each psychrometric value computed:
#' \describe{
#'   \item{HumRatio}{Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]}
#'   \item{TDewPoint}{Dew-point temperature in degreeF [IP] or degreeC [SI]}
#'   \item{RelHum}{Relative humidity in range [0, 1]}
#'   \item{VapPres}{Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]}
#'   \item{MoistAirEnthalpy}{Moist air enthalpy in Btu lb-1 [IP] or J kg-1 [SI]}
#'   \item{MoistAirVolume}{Specific volume of moist air in ft3 lb-1 [IP] or in m3 kg-1 [SI]}
#'   \item{DegreeOfSaturation}{Degree of saturation [unitless]}
#' }
#'
#' @examples
#' SetUnitSystem("IP")
#' CalcPsychrometricsFromTWetBulb(80:100, 65.0, 14.696)
#'
#' SetUnitSystem("SI")
#' CalcPsychrometricsFromTWetBulb(25:40, 20, 101325.0)
#'
#' @export
CalcPsychrometricsFromTWetBulb <- function (TDryBulb, TWetBulb, Pressure) {
    x <- AlignLength(TDryBulb, TWetBulb, Pressure)

    HumRatio <- GetHumRatioFromTWetBulb(x$TDryBulb, x$TWetBulb, x$Pressure)
    list(HumRatio = HumRatio,
         TDewPoint = GetTDewPointFromHumRatio(x$TDryBulb, HumRatio, x$Pressure),
         RelHum = GetRelHumFromHumRatio(x$TDryBulb, HumRatio, x$Pressure),
         VapPres = GetVapPresFromHumRatio(HumRatio, x$Pressure),
         MoistAirEnthalpy = GetMoistAirEnthalpy(x$TDryBulb, HumRatio),
         MoistAirVolume = GetMoistAirVolume(x$TDryBulb, HumRatio, x$Pressure),
         DegreeOfSaturation = GetDegreeOfSaturation(x$TDryBulb, HumRatio, x$Pressure)
    )
}

#' @title Calculate psychrometric values from dew-point temperature.
#'
#' @description Utility function to calculate humidity ratio, wet-bulb temperature, relative humidity,
#' vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
#' dry-bulb temperature, dew-point temperature, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param TDewPoint A numeric vector of dew-point temperature in degreeF [IP] or degreeC [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A list with named components for each psychrometric value computed:
#' \describe{
#'   \item{HumRatio}{Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]}
#'   \item{TWetBulb}{Wet-bulb temperature in degreeF [IP] or degreeC [SI]}
#'   \item{RelHum}{Relative humidity in range [0, 1]}
#'   \item{VapPres}{Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]}
#'   \item{MoistAirEnthalpy}{Moist air enthalpy in Btu lb-1 [IP] or J kg-1 [SI]}
#'   \item{MoistAirVolume}{Specific volume of moist air in ft3 lb-1 [IP] or in m3 kg-1 [SI]}
#'   \item{DegreeOfSaturation}{Degree of saturation [unitless]}
#' }
#'
#' @examples
#' SetUnitSystem("IP")
#' CalcPsychrometricsFromTDewPoint(80:100, 40.0, 14.696)
#'
#' SetUnitSystem("SI")
#' CalcPsychrometricsFromTDewPoint(25:40, 20.0, 101325.0)
#'
#' @export
CalcPsychrometricsFromTDewPoint <- function (TDryBulb, TDewPoint, Pressure) {
    x <- AlignLength(TDryBulb, TDewPoint, Pressure)

    HumRatio <- GetHumRatioFromTDewPoint(x$TDewPoint, x$Pressure)
    list(HumRatio = HumRatio,
         TWetBulb = GetTWetBulbFromHumRatio(x$TDryBulb, HumRatio, x$Pressure),
         RelHum = GetRelHumFromHumRatio(x$TDryBulb, HumRatio, x$Pressure),
         VapPres = GetVapPresFromHumRatio(HumRatio, x$Pressure),
         MoistAirEnthalpy = GetMoistAirEnthalpy(x$TDryBulb, HumRatio),
         MoistAirVolume = GetMoistAirVolume(x$TDryBulb, HumRatio, x$Pressure),
         DegreeOfSaturation = GetDegreeOfSaturation(x$TDryBulb, HumRatio, x$Pressure)
    )
}

#' @title Calculate psychrometric values from relative humidity.
#'
#' @description Utility function to calculate humidity ratio, wet-bulb temperature, dew-point temperature,
#' vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
#' dry-bulb temperature, relative humidity and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param RelHum A numeric vector of relative humidity in range [0, 1]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A list with named components for each psychrometric value computed:
#' \describe{
#'   \item{HumRatio}{Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]}
#'   \item{TWetBulb}{Wet-bulb temperature in degreeF [IP] or degreeC [SI]}
#'   \item{TDewPoint}{Dew-point temperature in degreeF [IP] or degreeC [SI]}
#'   \item{VapPres}{Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]}
#'   \item{MoistAirEnthalpy}{Moist air enthalpy in Btu lb-1 [IP] or J kg-1 [SI]}
#'   \item{MoistAirVolume}{Specific volume of moist air in ft3 lb-1 [IP] or in m3 kg-1 [SI]}
#'   \item{DegreeOfSaturation}{Degree of saturation [unitless]}
#' }
#'
#' @examples
#' SetUnitSystem("IP")
#' CalcPsychrometricsFromRelHum(80:100, 0.13, 14.69)
#'
#' SetUnitSystem("SI")
#' CalcPsychrometricsFromRelHum(25:40, 0.5, 101325.0)
#'
#' @export
CalcPsychrometricsFromRelHum <- function (TDryBulb, RelHum, Pressure) {
    x <- AlignLength(TDryBulb, RelHum, Pressure)

    HumRatio <- GetHumRatioFromRelHum(x$TDryBulb, RelHum, x$Pressure)
    list(HumRatio = HumRatio,
         TWetBulb = GetTWetBulbFromHumRatio(x$TDryBulb, HumRatio, x$Pressure),
         TDewPoint = GetTDewPointFromHumRatio(x$TDryBulb, HumRatio, x$Pressure),
         VapPres = GetVapPresFromHumRatio(HumRatio, x$Pressure),
         MoistAirEnthalpy = GetMoistAirEnthalpy(x$TDryBulb, HumRatio),
         MoistAirVolume = GetMoistAirVolume(x$TDryBulb, HumRatio, x$Pressure),
         DegreeOfSaturation = GetDegreeOfSaturation(x$TDryBulb, HumRatio, x$Pressure)
    )
}
