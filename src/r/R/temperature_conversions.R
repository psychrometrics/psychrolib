#######################################################################################################
# Conversion between temperature units
#######################################################################################################

#' Utility function to convert temperature to degree Rankine (°R)
#' given temperature in degree Fahrenheit (°F).
#'
#' @param t_fahrenheit Temperature in degree Fahrenheit (°F)
#'
#' @return Temperature in degree Rankine (°R)
#'
#' @section Notes:
#'   Exact conversion.
#'
#' @export
get_t_rankine_from_t_fahrenheit <- function(t_fahrenheit) {

  # Zero degree Fahrenheit (°F) expressed as degree Rankine (°R)
  ZERO_FAHRENHEIT_AS_RANKINE <- 459.67

  t_fahrenheit + ZERO_FAHRENHEIT_AS_RANKINE
}

#' Utility function to convert temperature to Kelvin (K)
#' given temperature in degree Celsius (°C).
#'
#' @param t_celsius Temperature in degree Celsius (°C)
#'
#' @return Temperature in Kelvin (K)
#'
#' @section Notes:
#'   Exact conversion.
#'
#' @export
get_t_kelvin_from_t_celsius <- function(t_celsius) {

  # Zero degree Celsius (°C) expressed as Kelvin (K)
  ZERO_CELSIUS_AS_KELVIN = 273.15

  t_celsius + ZERO_CELSIUS_AS_KELVIN
}
