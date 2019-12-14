######################################################################################################
# Functions to set all psychrometric values
#######################################################################################################

#' @title Calculate psychrometric values from wet-bulb temperature.
#'
#' @description Utility function to calculate humidity ratio, dew-point temperature, relative humidity,
#' vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
#' dry-bulb temperature, wet-bulb temperature, and pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param TWetBulb Wet-bulb temperature in °F [IP] or °C [SI]
#' @param Pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Vector with named components for each psychrometric value computed:
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
#' @export
CalcPsychrometricsFromTWetBulb <- function (TDryBulb, TWetBulb, Pressure) {
    CheckLength(TDryBulb, TWetBulb, Pressure)

    HumRatio <- GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
    list(HumRatio = HumRatio,
         TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure),
         RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure),
         VapPres = GetVapPresFromHumRatio(HumRatio, Pressure),
         MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio),
         MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure),
         DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)
    )
}

#' @title Calculate psychrometric values from dew-point temperature.
#'
#' @description Utility function to calculate humidity ratio, wet-bulb temperature, relative humidity,
#' vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
#' dry-bulb temperature, dew-point temperature, and pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param TDewPoint Dew-point temperature in °F [IP] or °C [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Vector with named components for each psychrometric value computed:
#' \describe{
#'   \item{HumRatio}{Humidity ratio in lb_H₂O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]}
#'   \item{TWetBulb}{Wet-bulb temperature in °F [IP] or °C [SI]}
#'   \item{RelHum}{Relative humidity in range [0, 1]}
#'   \item{VapPres}{Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]}
#'   \item{MoistAirEnthalpy}{Moist air enthalpy in Btu lb-1 [IP] or J kg-1 [SI]}
#'   \item{MoistAirVolume}{Specific volume of moist air in ft3 lb-1 [IP] or in m3 kg-1 [SI]}
#'   \item{DegreeOfSaturation}{Degree of saturation [unitless]}
#' }
#'
#' @export
CalcPsychrometricsFromTDewPoint <- function (TDryBulb, TDewPoint, Pressure) {
    CheckLength(TDryBulb, TDewPoint, Pressure)

    HumRatio <- GetHumRatioFromTDewPoint(TDewPoint, Pressure)
    list(HumRatio = HumRatio,
         TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure),
         RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure),
         VapPres = GetVapPresFromHumRatio(HumRatio, Pressure),
         MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio),
         MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure),
         DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)
    )
}

#' @title Calculate psychrometric values from relative humidity.
#'
#' @description Utility function to calculate humidity ratio, wet-bulb temperature, dew-point temperature,
#' vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
#' dry-bulb temperature, relative humidity and pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param RelHum Relative humidity in range [0, 1]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Vector with named components for each psychrometric value computed:
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
#' @export
CalcPsychrometricsFromRelHum <- function (TDryBulb, RelHum, Pressure) {
    CheckLength(TDryBulb, RelHum, Pressure)

    HumRatio <- GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure)
    list(HumRatio = HumRatio,
         TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure),
         TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure),
         VapPres = GetVapPresFromHumRatio(HumRatio, Pressure),
         MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio),
         MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure),
         DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)
    )
}
