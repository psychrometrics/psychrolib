#######################################################################################################
# Conversion between temperature units
#######################################################################################################

#' Utility function to convert temperature to degree Rankine (degreeR)
#' given temperature in degree Fahrenheit (degreeF).
#'
#' @param TFahrenheit A numeric vector of temperature in degree Fahrenheit (degreeF)
#'
#' @return A numeric vector of temperature in degree Rankine (degreeR)
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

#' Utility function to convert temperature to degree Fahrenheit (degreeF)
#' given temperature in degree Rankine (degreeR).
#'
#' @param TRankine A numeric vector of temperature in degree Rankine (degreeR)
#'
#' @return A numeric vector of temperature in degree Fahrenheit (degreeF)
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
#' given temperature in degree Celsius (degreeC).
#'
#' @param TCelsius A numeric vector of temperature in degree Celsius (degreeC)
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

#' Utility function to convert temperature to degree Celsius (degreeC)
#' given temperature in Kelvin (K).
#'
#' @param TKelvin A numeric vector of temperature in degree Kelvin (K)
#'
#' @return A numeric vector of temperature in Celsius (degreeC)
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
