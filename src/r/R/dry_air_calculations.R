#######################################################################################################
# Dry Air Calculations
#######################################################################################################

#' Return dry-air enthalpy given dry-bulb temperature.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @return Dry air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 28
#' @export
get_dry_air_enthalpy <- function(t_dry_bulb) {
  if (is_ip()) {
    dry_air_enthalpy <- 0.240 * t_dry_bulb
  } else {
    dry_air_enthalpy <- 1006.0 * t_dry_bulb
  }
  return(dry_air_enthalpy)
}

#' Return dry-air density given dry-bulb temperature and pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Dry air density in lb ft⁻³ [IP] or kg m⁻³ [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1
#'   \itemize{
#'     \item Eqn 14 for the perfect gas relationship for dry air.
#'     \item Eqn 1 for the universal gas constant.
#'   }
#' @export
get_dry_air_density <- function(t_dry_bulb, pressure) {
  if (is_ip()) {
    # The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².
    dry_air_density <- (144.0 * pressure) / R_DA_IP / get_t_rankine_from_t_fahrenheit(t_dry_bulb)
  } else {
    dry_air_density <- pressure / R_DA_SI / get_t_kelvin_from_t_celsius(t_dry_bulb)
  }
  return(dry_air_density)
}

#' Return dry-air volume given dry-bulb temperature and pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Dry air volume in ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1
#'   \itemize{
#'     \item Eqn 14 for the perfect gas relationship for dry air.
#'     \item Eqn 1 for the universal gas constant.
#'   }
#' @export
get_dry_air_volume <- function(t_dry_bulb, pressure) {
  if (is_ip()) {
    # The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².
    dry_air_volume <- R_DA_IP * get_t_rankine_from_t_fahrenheit(t_dry_bulb) / (144.0 * pressure)
  } else {
    dry_air_volume <- R_DA_SI * get_t_kelvin_from_t_celsius(t_dry_bulb) / pressure
  }
  return(dry_air_volume)
}

#' Return dry bulb temperature from enthalpy and humidity ratio.
#'
#' @param moist_air_enthalpy Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
#' @param hum_ratio Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
#'
#' @return Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30
#' @export
get_t_dry_bulb_from_enthalpy_and_hum_ratio <- function(moist_air_enthalpy, hum_ratio) {

  # Based on the get_moist_air_enthalpy function, rearranged for temperature.

  if (hum_ratio < 0.0) {
    stop("Humidity ratio is negative")
  }
  bounded_hum_ratio <- max(hum_ratio, MIN_HUM_RATIO)

  if (is_ip()) {
    t_dry_bulb <- (moist_air_enthalpy - 1061.0 * bounded_hum_ratio) / (0.240 + 0.444 * bounded_hum_ratio)
  } else {
    t_dry_bulb <- (moist_air_enthalpy / 1000.0 - 2501.0 * bounded_hum_ratio) / (1.006 + 1.86 * bounded_hum_ratio)
  }
  return(t_dry_bulb)
}

#' Return humidity ratio from enthalpy and dry-bulb temperature.
#'
#' @param moist_air_enthalpy Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @return Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30.
#' @export
get_hum_ratio_from_enthalpy_and_t_dry_bulb <- function(moist_air_enthalpy, t_dry_bulb) {

  # Based on the get_moist_air_enthalpy function, rearranged for humidity ratio.

  if (is_ip()) {
    hum_ratio <- (moist_air_enthalpy - 0.240 * t_dry_bulb) / (1061.0 + 0.444 * t_dry_bulb)
  } else {
    hum_ratio <- (moist_air_enthalpy / 1000.0 - 1.006 * t_dry_bulb) / (2501.0 + 1.86 * t_dry_bulb)
  }

  # Validity check.
  max(hum_ratio, MIN_HUM_RATIO)
}
