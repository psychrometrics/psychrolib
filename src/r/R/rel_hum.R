#######################################################################################################
# Conversions between dew point, wet bulb, and relative humidity
#######################################################################################################

#' Return wet-bulb temperature given dry-bulb temperature, dew-point temperature, and pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param TDewPoint Dew-point temperature in °F [IP] or °C [SI]
#' @param Pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Wet-bulb temperature in °F [IP] or °C [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
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
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param RelHum Relative humidity in range [0, 1]
#' @param Pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Wet-bulb temperature in °F [IP] or °C [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @export
GetTWetBulbFromRelHum <- function (TDryBulb, RelHum, Pressure) {
    CheckLength(TDryBulb, RelHum, Pressure)
    CheckRelHum(RelHum)

    HumRatio <- GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure)
    GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
}

#' Return relative humidity given dry-bulb temperature and dew-point temperature.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param TDewPoint Dew-point temperature in °F [IP] or °C [SI]
#'
#' @return Relative humidity in range [0, 1]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 22
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
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param TWetBulb Wet-bulb temperature in °F [IP] or °C [SI]
#' @param Pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Relative humidity in range [0, 1]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
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
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param RelHum Relative humidity in range [0, 1]
#'
#' @return Dew-point temperature in °F [IP] or °C [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
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
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param TWetBulb Wet-bulb temperature in °F [IP] or °C [SI]
#' @param Pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Dew-point temperature in °F [IP] or °C [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @export
GetTDewPointFromTWetBulb <- function (TDryBulb, TWetBulb, Pressure) {
    CheckLength(TDryBulb, TWetBulb, Pressure)
    CheckTWetBulb(TWetBulb, TDryBulb)

    HumRatio <- GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
}
