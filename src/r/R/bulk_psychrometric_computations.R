######################################################################################################
# Functions to set all psychrometric values
#######################################################################################################
# TODO: consider including the input parameters in output vectors, so you get the complete picture

#' @title Calculate psychrometric values from wet-bulb temperature.
#'
#' @description Utility function to calculate humidity ratio, dew-point temperature, relative humidity,
#'  vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
#'  dry-bulb temperature, wet-bulb temperature, and pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param t_wet_bulb Wet-bulb temperature in °F [IP] or °C [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Vector with named components for each psychrometric value computed:
#'   \describe{
#'     \item{hum_ratio}{Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]}
#'     \item{t_dew_point}{Dew-point temperature in °F [IP] or °C [SI]}
#'     \item{rel_hum}{Relative humidity in range [0, 1]}
#'     \item{vap_pres}{Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]}
#'     \item{moist_air_enthalpy}{Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]}
#'     \item{moist_air_volume}{Specific volume of moist air in ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]}
#'     \item{degree_of_saturation}{Degree of saturation [unitless]}
#'   }
#' @export
calc_psychrometrics_from_t_wet_bulb <- function(t_dry_bulb, t_wet_bulb, pressure) {

  hum_ratio <- get_hum_ratio_from_t_wet_bulb(t_dry_bulb, t_wet_bulb, pressure)
  t_dew_point <- get_t_dew_point_from_hum_ratio(t_dry_bulb, hum_ratio, pressure)
  rel_hum <- get_rel_hum_from_hum_ratio(t_dry_bulb, hum_ratio, pressure)
  vap_pres <- get_vap_pres_from_hum_ratio(hum_ratio, pressure)
  moist_air_enthalpy <- get_moist_air_enthalpy(t_dry_bulb, hum_ratio)
  moist_air_volume <- get_moist_air_volume(t_dry_bulb, hum_ratio, pressure)
  degree_of_saturation <- get_degree_of_saturation(t_dry_bulb, hum_ratio, pressure)

  c(hum_ratio = hum_ratio, t_dew_point = t_dew_point, rel_hum = rel_hum, vap_pres = vap_pres,
    moist_air_enthalpy = moist_air_enthalpy, moist_air_volume = moist_air_volume,
    degree_of_saturation = degree_of_saturation)
}

#' @title Calculate psychrometric values from dew-point temperature.
#'
#' @description Utility function to calculate humidity ratio, wet-bulb temperature, relative humidity,
#'  vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
#'  dry-bulb temperature, dew-point temperature, and pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param t_dew_point Dew-point temperature in °F [IP] or °C [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Vector with named components for each psychrometric value computed:
#'   \describe{
#'     \item{hum_ratio}{Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]}
#'     \item{t_wet_bulb}{Wet-bulb temperature in °F [IP] or °C [SI]}
#'     \item{rel_hum}{Relative humidity in range [0, 1]}
#'     \item{vap_pres}{Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]}
#'     \item{moist_air_enthalpy}{Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]}
#'     \item{moist_air_volume}{Specific volume of moist air in ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]}
#'     \item{degree_of_saturation}{Degree of saturation [unitless]}
#'   }
#' @export
calc_psychrometrics_from_t_dew_point <- function(t_dry_bulb, t_dew_point, pressure) {

  hum_ratio <- get_hum_ratio_from_t_dew_point(t_dew_point, pressure)
  t_wet_bulb <- get_t_wet_bulb_from_hum_ratio(t_dry_bulb, hum_ratio, pressure)
  rel_hum <- get_rel_hum_from_hum_ratio(t_dry_bulb, hum_ratio, pressure)
  vap_pres <- get_vap_pres_from_hum_ratio(hum_ratio, pressure)
  moist_air_enthalpy <- get_moist_air_enthalpy(t_dry_bulb, hum_ratio)
  moist_air_volume <- get_moist_air_volume(t_dry_bulb, hum_ratio, pressure)
  degree_of_saturation <- get_degree_of_saturation(t_dry_bulb, hum_ratio, pressure)

  c(hum_ratio = hum_ratio, t_wet_bulb = t_wet_bulb, rel_hum = rel_hum, vap_pres = vap_pres,
    moist_air_enthalpy = moist_air_enthalpy, moist_air_volume = moist_air_volume,
    degree_of_saturation = degree_of_saturation)
}

#' @title Calculate psychrometric values from relative humidity.
#'
#' @description Utility function to calculate humidity ratio, wet-bulb temperature, dew-point temperature,
#'  vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
#'  dry-bulb temperature, relative humidity and pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param rel_hum Relative humidity in range [0, 1]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Vector with named components for each psychrometric value computed:
#'   \describe{
#'     \item{hum_ratio}{Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]}
#'     \item{t_wet_bulb}{Wet-bulb temperature in °F [IP] or °C [SI]}
#'     \item{t_dew_point}{Dew-point temperature in °F [IP] or °C [SI]}
#'     \item{vap_pres}{Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]}
#'     \item{moist_air_enthalpy}{Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]}
#'     \item{moist_air_volume}{Specific volume of moist air in ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]}
#'     \item{degree_of_saturation}{Degree of saturation [unitless]}
#'   }
#' @export
calc_psychrometrics_from_rel_hum <- function(t_dry_bulb, rel_hum, pressure) {

  hum_ratio <- get_hum_ratio_from_rel_hum(t_dry_bulb, rel_hum, pressure)
  t_wet_bulb <- get_t_wet_bulb_from_hum_ratio(t_dry_bulb, hum_ratio, pressure)
  t_dew_point <- get_t_dew_point_from_hum_ratio(t_dry_bulb, hum_ratio, pressure)
  vap_pres <- get_vap_pres_from_hum_ratio(hum_ratio, pressure)
  moist_air_enthalpy <- get_moist_air_enthalpy(t_dry_bulb, hum_ratio)
  moist_air_volume <- get_moist_air_volume(t_dry_bulb, hum_ratio, pressure)
  degree_of_saturation <- get_degree_of_saturation(t_dry_bulb, hum_ratio, pressure)

  c(hum_ratio = hum_ratio, t_wet_bulb = t_wet_bulb, t_dew_point = t_dew_point, vap_pres = vap_pres,
    moist_air_enthalpy = moist_air_enthalpy, moist_air_volume = moist_air_volume,
    degree_of_saturation = degree_of_saturation)
}
