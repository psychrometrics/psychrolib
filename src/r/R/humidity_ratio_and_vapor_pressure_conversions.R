#######################################################################################################
# Conversions between humidity ratio and vapor pressure
#######################################################################################################

#' Return humidity ratio given water vapor pressure and atmospheric pressure.
#'
#' @param vap_pres Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20
#' @export
get_hum_ratio_from_vap_pres <- function(vap_pres, pressure) {
  if (vap_pres < 0) {
    stop("Partial pressure of water vapor in moist air cannot be negative")
  }
  hum_ratio <- 0.621945 * vap_pres / (pressure - vap_pres)
  max(hum_ratio, MIN_HUM_RATIO)
}

#' Return vapor pressure given humidity ratio and pressure.
#'
#' @param hum_ratio Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20 solved for pw
#' @export
get_vap_pres_from_hum_ratio <- function(hum_ratio, pressure) {
  if (hum_ratio < 0) {
    stop("Humidity ratio is negative")
  }
  bounded_hum_ratio <- max(hum_ratio, MIN_HUM_RATIO)
  pressure * bounded_hum_ratio / (0.621945 + bounded_hum_ratio)
}

