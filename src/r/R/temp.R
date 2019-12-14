#######################################################################################################
# Conversion between temperature units
#######################################################################################################

#' Utility function to convert temperature to degree Rankine (°R)
#' given temperature in degree Fahrenheit (°F).
#'
#' @param TFahrenheit Temperature in degree Fahrenheit (°F)
#'
#' @return Temperature in degree Rankine (°R)
#'
#' @section Notes:
#' Exact conversion.
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
#'
#' @export
GetTRankineFromTFahrenheit <- function (TFahrenheit) {
    TFahrenheit + ZERO_FAHRENHEIT_AS_RANKINE
}

#' Utility function to convert temperature to degree Fahrenheit (°F)
#' given temperature in degree Rankine (°R).
#'
#' @param TRankine Temperature in degree Rankine (°R)
#'
#' @return Temperature in degree Fahrenheit (°F)
#'
#' @section Notes:
#' Exact conversion.
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
#'
#' @export
GetTFahrenheitFromTRankine <- function (TRankine) {
    TRankine - ZERO_FAHRENHEIT_AS_RANKINE
}

#' Utility function to convert temperature to Kelvin (K)
#' given temperature in degree Celsius (°C).
#'
#' @param TCelsius Temperature in degree Celsius (°C)
#'
#' @return Temperature in Kelvin (K)
#'
#' @section Notes:
#' Exact conversion.
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
#'
#' @export
GetTKelvinFromTCelsius <- function (TCelsius) {
    TCelsius + ZERO_CELSIUS_AS_KELVIN
}

#' Utility function to convert temperature to degree Celsius (°C)
#' given temperature in Kelvin (K).
#'
#' @param TKelvin Temperature in degree Kelvin (K)
#'
#' @return Temperature in Celsius (°C)
#'
#' @section Notes:
#' Exact conversion.
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
#'
#' @export
GetTCelsiusFromTKelvin <- function (TKelvin) {
    TKelvin - ZERO_CELSIUS_AS_KELVIN
}
