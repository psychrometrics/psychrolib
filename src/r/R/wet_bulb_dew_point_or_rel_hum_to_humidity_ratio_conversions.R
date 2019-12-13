#######################################################################################################
# Conversions from wet-bulb temperature, dew-point temperature, or relative humidity to humidity ratio
#######################################################################################################

#' Return wet-bulb temperature given dry-bulb temperature, humidity ratio, and pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param hum_ratio Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Wet-bulb temperature in °F [IP] or °C [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35 solved for Tstar
#' @export
get_t_wet_bulb_from_hum_ratio <- function(t_dry_bulb, hum_ratio, pressure) {

  if (hum_ratio < 0.0) {
    stop("Humidity ratio cannot be negative")
  }
  bounded_hum_ratio <- max(hum_ratio, MIN_HUM_RATIO)

  t_dew_point <- get_t_dew_point_from_hum_ratio(t_dry_bulb, hum_ratio, pressure)

  # Initial guess
  t_wet_bulb_sup <- t_dry_bulb
  t_wet_bulb_inf <- t_dew_point
  t_wet_bulb <- (t_wet_bulb_inf + t_wet_bulb_sup) / 2.0

  index <- 1
  # Bisection loop
  while((t_wet_bulb_sup - t_wet_bulb_inf) > PKG_ENV$TOLERANCE) {

    # Compute humidity ratio at temperature Tstar
    w_star <- get_hum_ratio_from_t_wet_bulb(t_dry_bulb, t_wet_bulb, pressure)

    # Get new boundds
    if (w_star > bounded_hum_ratio) {
      t_wet_bulb_sup <- t_wet_bulb
    } else {
      t_wet_bulb_inf <- t_wet_bulb
    }

    # New guess of wet bulb temperature
    t_wet_bulb <- (t_wet_bulb_inf + t_wet_bulb_sup) / 2.0

    if (index >= MAX_ITER_COUNT) {
      stop("Convergence not reached in GetTWetBulbFromHumRatio. Stopping.")
    }

    index <- index + 1
  }
  return(t_wet_bulb)
}

#' Return humidity ratio given dry-bulb temperature, wet-bulb temperature, and pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param t_wet_bulb Wet-bulb temperature in °F [IP] or °C [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35
#' @export
get_hum_ratio_from_t_wet_bulb <- function(t_dry_bulb, t_wet_bulb, pressure) {

  if (t_wet_bulb > t_dry_bulb) {
    stop("Wet bulb temperature is above dry bulb temperature")
  }

  ws_star <- get_sat_hum_ratio(t_wet_bulb, pressure)

  if (is_ip()) {
    if (t_wet_bulb >= 32.0) {
      hum_ratio <- ((1093.0 - 0.556 * t_wet_bulb) * ws_star - 0.240 * (t_dry_bulb - t_wet_bulb)) /
                    (1093.0 + 0.444 * t_dry_bulb - t_wet_bulb)
    } else {
      hum_ratio <- ((1220.0 - 0.04 * t_wet_bulb) * ws_star - 0.240 * (t_dry_bulb - t_wet_bulb)) /
                   (1220.0 + 0.444 * t_dry_bulb - 0.48 * t_wet_bulb)
    }
  } else {
    if (t_wet_bulb >= 0.0) {
      hum_ratio <- ((2501.0 - 2.326 * t_wet_bulb) * ws_star - 1.006 * (t_dry_bulb - t_wet_bulb)) /
                   (2501.0 + 1.86 * t_dry_bulb - 4.186 * t_wet_bulb)
    } else {
      hum_ratio <- ((2830.0 - 0.24 * t_wet_bulb) * ws_star - 1.006 * (t_dry_bulb - t_wet_bulb)) /
                   (2830.0 + 1.86 * t_dry_bulb - 2.1 * t_wet_bulb)
    }
  }
  max(hum_ratio, MIN_HUM_RATIO)
}

#' Return humidity ratio given dry-bulb temperature, relative humidity, and pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param rel_hum Relative humidity in range [0, 1]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1
#' @export
get_hum_ratio_from_rel_hum <- function(t_dry_bulb, rel_hum, pressure) {
  if (rel_hum < 0.0 || rel_hum > 1.0) {
    stop("Relative humidity is outside range [0, 1]")
  }
  vap_pres <- get_vap_pres_from_rel_hum(t_dry_bulb, rel_hum)
  get_hum_ratio_from_vap_pres(vap_pres, pressure)
}

#' Return relative humidity given dry-bulb temperature, humidity ratio, and pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param hum_ratio Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Relative humidity in range [0, 1]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1
#' @export
get_rel_hum_from_hum_ratio <- function(t_dry_bulb, hum_ratio, pressure) {
  if(hum_ratio < 0.0) {
    stop("Humidity ratio cannot be negative")
  }
  vap_pres <- get_vap_pres_from_hum_ratio(hum_ratio, pressure)
  get_rel_hum_from_vap_pres(t_dry_bulb, vap_pres)
}

#' Return humidity ratio given dew-point temperature and pressure.
#'
#' @param t_dew_point Dew-point temperature in °F [IP] or °C [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 13
#' @export
get_hum_ratio_from_t_dew_point <- function(t_dew_point, pressure) {
  vap_pres <- get_sat_vap_pres(t_dew_point)
  get_hum_ratio_from_vap_pres(vap_pres, pressure)
}

#' Return dew-point temperature given dry-bulb temperature, humidity ratio, and pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param hum_ratio Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
#' @param pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Dew-point temperature in °F [IP] or °C [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1
#' @export
get_t_dew_point_from_hum_ratio <- function(t_dry_bulb, hum_ratio, pressure) {
  if (hum_ratio < 0.0) {
    stop("Humidity ratio cannot be negative")
  }
  vap_pres <- get_vap_pres_from_hum_ratio(hum_ratio, pressure)
  get_t_dew_point_from_vap_pres(t_dry_bulb, vap_pres)
}
