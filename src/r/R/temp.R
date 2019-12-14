#######################################################################################################
# Conversion between temperature units
#######################################################################################################

#' Utility function to convert temperature to degree Rankine (°R)
#' given temperature in degree Fahrenheit (°F).
#'
#' @param TFahrenheit A numeric vector of temperature in degree Fahrenheit (°F)
#'
#' @return A numeric vector of temperature in degree Rankine (°R)
#'
#' @section Notes:
#' Exact conversion.
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
#'
#' @examples
#' GetTRankineFromTFahrenheit(1:100)
#'
#' @export
GetTRankineFromTFahrenheit <- function (TFahrenheit) {
    TFahrenheit + ZERO_FAHRENHEIT_AS_RANKINE
}

#' Utility function to convert temperature to degree Fahrenheit (°F)
#' given temperature in degree Rankine (°R).
#'
#' @param TRankine A numeric vector of temperature in degree Rankine (°R)
#'
#' @return A numeric vector of temperature in degree Fahrenheit (°F)
#'
#' @section Notes:
#' Exact conversion.
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
#'
#' @examples
#' GetTFahrenheitFromTRankine(500:600)
#'
#' @export
GetTFahrenheitFromTRankine <- function (TRankine) {
    TRankine - ZERO_FAHRENHEIT_AS_RANKINE
}

#' Utility function to convert temperature to Kelvin (K)
#' given temperature in degree Celsius (°C).
#'
#' @param TCelsius A numeric vector of temperature in degree Celsius (°C)
#'
#' @return A numeric vector of temperature in Kelvin (K)
#'
#' @section Notes:
#' Exact conversion.
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
#'
#' @examples
#' GetTKelvinFromTCelsius(20:30)
#'
#' @export
GetTKelvinFromTCelsius <- function (TCelsius) {
    TCelsius + ZERO_CELSIUS_AS_KELVIN
}

#' Utility function to convert temperature to degree Celsius (°C)
#' given temperature in Kelvin (K).
#'
#' @param TKelvin A numeric vector of temperature in degree Kelvin (K)
#'
#' @return A numeric vector of temperature in Celsius (°C)
#'
#' @section Notes:
#' Exact conversion.
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
#'
#' @examples
#' GetTCelsiusFromTKelvin(300:400)
#'
#' @export
GetTCelsiusFromTKelvin <- function (TKelvin) {
    TKelvin - ZERO_CELSIUS_AS_KELVIN
}
