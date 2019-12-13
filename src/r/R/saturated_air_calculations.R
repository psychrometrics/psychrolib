#######################################################################################################
# Saturated Air Calculations
#######################################################################################################

#' Return saturation vapor pressure given dry-bulb temperature.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @return Vapor pressure of saturated air in Psi [IP] or Pa [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1  eqn 5 & 6
#' @export
get_sat_vap_pres <- function(t_dry_bulb) {

  # TODO: vectorize this function
  if(length(t_dry_bulb) > 1) {
    stop("all arguments must be scalars")
  }

  if (is_ip()) {
    if (t_dry_bulb < -148.0 || t_dry_bulb > 392.0) {
      stop("Dry bulb temperature must be in range [-148, 392]\u00B0F")
    }
    t <- get_t_rankine_from_t_fahrenheit(t_dry_bulb)
    if (t_dry_bulb <= 32.0) {
      ln_pws <- -1.0214165E+04 / t - 4.8932428 - 5.3765794E-03 * t + 1.9202377E-07 * t ^ 2 +
                 3.5575832E-10 * t ^ 3 - 9.0344688E-14 * t ^4 + 4.1635019 * log(t)
    } else {
      ln_pws <- -1.0440397E+04 / t - 1.1294650E+01 - 2.7022355E-02* t + 1.2890360E-05 * t ^ 2 +
                -2.4780681E-09 * t ^ 3 + 6.5459673 * log(t)
    }
  } else {
    if (t_dry_bulb < -100.0 || t_dry_bulb > 200.0) {
      stop("Dry bulb temperature must be in range [-100, 200]\u00B0C")
    }
    t <- get_t_kelvin_from_t_celsius(t_dry_bulb)
    if (t_dry_bulb < 0) {
      ln_pws <- -5.6745359E+03 / t + 6.3925247 - 9.677843E-03 * t + 6.2215701E-07 * t ^ 2 +
                 2.0747825E-09 * t ^ 3 - 9.484024E-13 * t ^ 4 + 4.1635019 * log(t)
    } else {
      ln_pws <- -5.8002206E+03 / t + 1.3914993 - 4.8640239E-02 * t + 4.1764768E-05 * t ^ 2 +
                -1.4452093E-08 * t ^ 3 + 6.5459673 * log(t)
    }
  }

  exp(ln_pws)
}

#' Return humidity ratio of saturated air given dry-bulb temperature and pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Humidity ratio of saturated air in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
#'
#' @section Reference:
#'  ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36, solved for W
#' @export
get_sat_hum_ratio <- function(t_dry_bulb, pressure) {

  # TODO: vectorize this function
  if(length(t_dry_bulb) > 1 || length(pressure) > 1) {
    stop("all arguments must be scalars")
  }

  sat_vapor_pres <- get_sat_vap_pres(t_dry_bulb)
  sat_hum_ratio <- 0.621945 * sat_vapor_pres / (pressure - sat_vapor_pres)

  # Validity check.
  max(sat_hum_ratio, MIN_HUM_RATIO)
}

#' Return saturated air enthalpy given dry-bulb temperature and pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Saturated air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
#'
#' @section Reference:
#'  ASHRAE Handbook - Fundamentals (2017) ch. 1
#' @export
get_sat_air_enthalpy <- function(t_dry_bulb, pressure) {
  sat_hum_ratio <- get_sat_hum_ratio(t_dry_bulb, pressure)
  get_moist_air_enthalpy(t_dry_bulb, sat_hum_ratio)
}
