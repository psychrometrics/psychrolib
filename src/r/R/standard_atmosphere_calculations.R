#######################################################################################################
# Standard atmosphere
#######################################################################################################

#' Return standard atmosphere barometric pressure, given the elevation (altitude).
#'
#' @param altitude Altitude in ft [IP] or m [SI]
#'
#' @return Standard atmosphere barometric pressure in Psi [IP] or Pa [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 3
#' @export
get_standard_atm_pressure <- function(altitude) {
  if(is_ip()) {
    standard_atm_pressure <- 14.696 * (1 - 6.8754e-06 * altitude) ^ 5.2559
  } else {
    standard_atm_pressure <- 101325.0 * (1 - 2.25577e-05 * altitude) ^ 5.2559
  }
  return(standard_atm_pressure)
}

#' Return standard atmosphere temperature, given the elevation (altitude).
#'
#' @param altitude Altitude in ft [IP] or m [SI]
#'
#' @return Standard atmosphere dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 4
#' @export
get_standard_atm_temperature <- function(altitude) {
  if(is_ip()) {
    standard_atm_temperature <- 59.0 - 0.00356620 * altitude
  } else {
    standard_atm_temperature <- 15.0 - 0.0065 * altitude
  }
  return(standard_atm_temperature)
}

#' Return sea level pressure given dry-bulb temperature, altitude above sea level and pressure.
#'
#' @param station_pressure Observed station pressure in Psi [IP] or Pa [SI]
#' @param altitude Altitude in ft [IP] or m [SI]
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @return Sea level barometric pressure in Psi [IP] or Pa [SI]
#'
#' @section Reference:
#'   Hess SL, Introduction to theoretical meteorology, Holt Rinehart and Winston, NY 1959,
#'   ch. 6.5; Stull RB, Meteorology for scientists and engineers, 2nd edition,
#'   Brooks/Cole 2000, ch. 1.
#'
#' @section Notes:
#'  The standard procedure for the US is to use for TDryBulb the average
#'  of the current station temperature and the station temperature from 12 hours ago.
#' @export
get_sea_level_pressure <- function(station_pressure, altitude, t_dry_bulb) {
  if (is_ip()) {
    # Calculate average temperature in column of air, assuming a lapse rate
    # of 3.6 °F/1000ft
    t_column = t_dry_bulb + 0.0036 * altitude / 2.0
    # Determine the scale height
    H = 53.351 * get_t_rankine_from_t_fahrenheit(t_column)
  } else {
    # Calculate average temperature in column of air, assuming a lapse rate
    # of 6.5 °C/km
    t_column = t_dry_bulb + 0.0065 * altitude / 2.0
    H = 287.055 * get_t_kelvin_from_t_celsius(t_column) / 9.807
  }
  # Calculate the sea level pressure
  sea_level_pressure = station_pressure * exp(altitude / H)
  return(sea_level_pressure)
}

#' Return station pressure from sea level pressure.
#'
#' @param sea_level_pressure Sea level barometric pressure in Psi [IP] or Pa [SI]
#' @param altitude Altitude in ft [IP] or m [SI]
#' @param t_dry_bulb Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @return Station pressure in Psi [IP] or Pa [SI]
#'
#' @section Reference:
#'   See \code{\link{get_sea_level_pressure}}.
#'
#' @section Notes:
#'   This function is just the inverse of \code{\link{get_sea_level_pressure}}.
#'@export
get_station_pressure <- function(sea_level_pressure, altitude, t_dry_bulb) {
  sea_level_pressure / get_sea_level_pressure(1.0, altitude, t_dry_bulb)
}
