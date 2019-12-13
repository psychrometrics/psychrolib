#######################################################################################################
# Conversions between dew point, or relative humidity and vapor pressure
#######################################################################################################

#' Return partial pressure of water vapor as a function of relative humidity and temperature.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param rel_hum Relative humidity in range [0, 1]
#'
#' @return Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
#' @export
get_vap_pres_from_rel_hum <- function(t_dry_bulb, rel_hum) {

  if (rel_hum < 0.0 || rel_hum > 1.0) {
    stop("Relative humidity is outside range [0, 1]")
  }

  rel_hum * get_sat_vap_pres(t_dry_bulb)
}

#' Return relative humidity given dry-bulb temperature and vapor pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param vap_pres Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @return Relative humidity in range [0, 1]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
#' @export
get_rel_hum_from_vap_pres <- function(t_dry_bulb, vap_pres) {
  if (vap_pres < 0.0) {
    stop("Partial pressure of water vapor in moist air cannot be negative")
  }
  vap_pres / get_sat_vap_pres(t_dry_bulb)
}

# Helper function returning the derivative of the natural log of the saturation vapor pressure
#  as a function of dry-bulb temperature.
#
# @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#
# @return Derivative of natural log of vapor pressure of saturated air in Psi [IP] or Pa [SI]
#
# @section Reference:
#   ASHRAE Handbook - Fundamentals (2017) ch. 1  eqn 5 & 6
#
# Intentionally not exported
d_ln_pws <- function(t_dry_bulb) {

  if (is_ip()) {
    t <- get_t_rankine_from_t_fahrenheit(t_dry_bulb)
    if (t_dry_bulb <= 32.0) {
      d_ln_pws = 1.0214165E+04 / t ^ 2.0 - 5.3765794E-03 + 2 * 1.9202377E-07 * t +
                 2.0 * 3.5575832E-10 * t ^ 2.0 - 4 * 9.0344688E-14 * t ^ 3.0 + 4.1635019 / t
    } else {
      d_ln_pws = 1.0440397E+04 / t ^ 2.0 - 2.7022355E-02 + 2 * 1.2890360E-05 * t +
                -3.0 * 2.4780681E-09 * t ^ 2.0 + 6.5459673 / t
    }
  } else {
    t <- get_t_kelvin_from_t_celsius(t_dry_bulb)
    if (t_dry_bulb <= 0.0) {
      d_ln_pws = 5.6745359E+03 / t ^ 2.0 - 9.677843E-03 + 2 * 6.2215701E-07 * t +
                 3.0 * 2.0747825E-09 * t ^ 2.0 - 4 * 9.484024E-13 * t ^ 3.0 + 4.1635019 / t
    } else {
      d_ln_pws = 5.8002206E+03 / t ^ 2.0 - 4.8640239E-02 + 2 * 4.1764768E-05 * t +
                -3.0 * 1.4452093E-08 * t ^ 2.0 + 6.5459673 / t
    }
  }
  return(d_ln_pws)
}

#' Return dew-point temperature given dry-bulb temperature and vapor pressure.
#'
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param vap_pres Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @return Dew-point temperature in °F [IP] or °C [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 and 6
#'
#' @section Notes:
#' \itemize{
#'  \item The dew point temperature is solved by inverting the equation giving water vapor pressure
#'  at saturation from temperature rather than using the regressions provided
#'  by ASHRAE (eqn. 37 and 38), which are much less accurate and have a
#'  narrower range of validity.
#'  \item The Newton-Raphson (NR) method is used on the logarithm of water vapour
#'  pressure as a function of temperature, which is a very smooth function.
#'  \item Convergence is usually achieved in 3 to 5 iterations.
#'  \item t_dry_bulb is not really needed here, just used for convenience.
#' }
#' @export
get_t_dew_point_from_vap_pres <- function(t_dry_bulb, vap_pres) {

  if(is_ip()) {
    BOUNDS <- c(-148, 392)
    T_WATER_FREEZE <- 32.0
  } else {
    BOUNDS <- c(-100, 200)
    T_WATER_FREEZE <- 0.0
  }

  # Validity check -- bounds outside which a solution cannot be found
  if (vap_pres < get_sat_vap_pres(BOUNDS[1]) || vap_pres > get_sat_vap_pres(BOUNDS[2])) {
    stop("Partial pressure of water vapor is outside range of validity of equations")
  }

  # Vapor pressure contained within the discontinuity of the Pws function: return temperature of freezing
  T_WATER_FREEZE_LOW <- T_WATER_FREEZE - PKG_ENV$TOLERANCE / 10.0          # Temperature just below freezing
  T_WATER_FREEZE_HIGH <- T_WATER_FREEZE + PKG_ENV$TOLERANCE / 10.0         # Temperature just above freezing
  PWS_FREEZE_LOW <- get_sat_vap_pres(T_WATER_FREEZE_LOW)
  PWS_FREEZE_HIGH <- get_sat_vap_pres(T_WATER_FREEZE_HIGH)

  # Restrict iteration to either left or right part of the saturation vapor pressure curve
  # to avoid iterating back and forth across the discontinuity of the curve at the freezing point
  # When the partial pressure of water vapor is within the discontinuity of GetSatVapPres,
  # simply return the freezing point of water.
  if (vap_pres < PWS_FREEZE_LOW) {
    BOUNDS[2] <- T_WATER_FREEZE_LOW
  } else if (vap_pres > PWS_FREEZE_HIGH){
    BOUNDS[1] <- T_WATER_FREEZE_HIGH
  } else {
    return(T_WATER_FREEZE)
  }

  # We use NR to approximate the solution.
  # First guess
  t_dew_point <- t_dry_bulb  # Calculated value of dew point temperatures, solved for iteratively
  ln_vp <- log(vap_pres)     # Partial pressure of water vapor in moist air

  index <- 1

  while(TRUE) {

    t_dew_point_iter <- t_dew_point   # t_dew_point used in NR calculation
    ln_vp_iter <- log(get_sat_vap_pres(t_dew_point_iter))

    # Derivative of function, calculated analytically
    d_ln_vp <- d_ln_pws(t_dew_point_iter)

    t_dew_point <- t_dew_point_iter - (ln_vp_iter - ln_vp) / d_ln_vp
    t_dew_point <- max(t_dew_point, BOUNDS[1])
    t_dew_point <- min(t_dew_point, BOUNDS[2])

    if (abs(t_dew_point - t_dew_point_iter) <= PKG_ENV$TOLERANCE) {
      break
    }

    if (index > MAX_ITER_COUNT) {
      stop("Convergence not reached in get_t_dew_point_from_vap_pres. Stopping.")
    }

    index <- index + 1
  }

  min(t_dew_point, t_dry_bulb)
}

#' Return vapor pressure given dew point temperature.
#'
#' @param t_dew_point Dew-point temperature in °F [IP] or °C [SI]
#'
#' @return Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36
#' @export
get_vap_pres_from_t_dew_point <- function(t_dew_point) {
  get_sat_vap_pres(t_dew_point)
}
