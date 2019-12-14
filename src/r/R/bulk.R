######################################################################################################
# Functions to set all psychrometric values
#######################################################################################################

#' @title Calculate psychrometric values from wet-bulb temperature.
#'
#' @description Utility function to calculate humidity ratio, dew-point temperature, relative humidity,
#' vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
#' dry-bulb temperature, wet-bulb temperature, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in °F [IP] or °C [SI]
#' @param TWetBulb A numeric vector of wet-bulb temperature in °F [IP] or °C [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A list with named components for each psychrometric value computed:
#' \describe{
#'   \item{HumRatio}{Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]}
#'   \item{TDewPoint}{Dew-point temperature in °F [IP] or °C [SI]}
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
#' @param TDryBulb A numeric vector of dry-bulb temperature in °F [IP] or °C [SI]
#' @param TDewPoint A numeric vector of dew-point temperature in °F [IP] or °C [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A list with named components for each psychrometric value computed:
#' \describe{
#'   \item{HumRatio}{Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]}
#'   \item{TWetBulb}{Wet-bulb temperature in °F [IP] or °C [SI]}
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
#' @param TDryBulb A numeric vector of dry-bulb temperature in °F [IP] or °C [SI]
#' @param RelHum A numeric vector of relative humidity in range [0, 1]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A list with named components for each psychrometric value computed:
#' \describe{
#'   \item{HumRatio}{Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]}
#'   \item{TWetBulb}{Wet-bulb temperature in °F [IP] or °C [SI]}
#'   \item{TDewPoint}{Dew-point temperature in °F [IP] or °C [SI]}
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
