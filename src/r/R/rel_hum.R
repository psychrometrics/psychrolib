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
