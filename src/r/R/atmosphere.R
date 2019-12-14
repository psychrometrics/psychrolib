#######################################################################################################
# Standard atmosphere
#######################################################################################################

#' Return standard atmosphere barometric pressure, given the elevation (altitude).
#'
#' @param Altitude Altitude in ft [IP] or m [SI]
#'
#' @return Standard atmosphere barometric pressure in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 3
#'
#' @export
GetStandardAtmPressure <- function (Altitude) {
    if (isIP()) {
        14.696 * (1 - 6.8754e-06 * Altitude) ^ 5.2559
    } else {
        101325.0 * (1 - 2.25577e-05 * Altitude) ^ 5.2559
    }
}

#' Return standard atmosphere temperature, given the elevation (altitude).
#'
#' @param altitude Altitude in ft [IP] or m [SI]
#'
#' @return Standard atmosphere dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 4
#'
#' @export
GetStandardAtmTemperature <- function (Altitude) {
    if (isIP()) {
        59.0 - 0.00356620 * Altitude
    } else {
        15.0 - 0.0065 * Altitude
    }
}

#' Return sea level pressure given dry-bulb temperature, altitude above sea level and pressure.
#'
#' @param station_pressure Observed station pressure in Psi [IP] or Pa [SI]
#' @param altitude Altitude in ft [IP] or m [SI]
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @return Sea level barometric pressure in Psi [IP] or Pa [SI]
#'
#' @references
#' Hess SL, Introduction to theoretical meteorology, Holt Rinehart and Winston, NY 1959,
#' ch. 6.5; Stull RB, Meteorology for scientists and engineers, 2nd edition,
#' Brooks/Cole 2000, ch. 1.
#'
#' @note
#' The standard procedure for the US is to use for TDryBulb the average
#' of the current station temperature and the station temperature from 12 hours ago.
#'
#' @export
GetSeaLevelPressure <- function (StationPressure, Altitude, TDryBulb) {
    CheckLength(StationPressure, Altitude, TDryBulb)

    if (isIP()) {
        # Calculate average temperature in column of air, assuming a lapse rate
        # of 3.6 °F/1000ft
        TColumn <- TDryBulb + 0.0036 * Altitude / 2

        # Determine the scale height
        H <- 53.351 * GetTRankineFromTFahrenheit(TColumn)
    } else {
        # Calculate average temperature in column of air, assuming a lapse rate
        # of 6.5 °C/km
        TColumn <- TDryBulb + 0.0065 * Altitude / 2

        # Determine the scale height
        H <- 287.055 * GetTKelvinFromTCelsius(TColumn) / 9.807
    }

    # Calculate the sea level pressure
    StationPressure * exp(Altitude / H)
}

#' Return station pressure from sea level pressure.
#'
#' @param SeaLevelPressure Sea level barometric pressure in Psi [IP] or Pa [SI]
#' @param Altitude Altitude in ft [IP] or m [SI]
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @return Station pressure in Psi [IP] or Pa [SI]
#'
#' @references See \code{\link{GetSeaLevelPressure}}.
#'
#' @note
#' This function is just the inverse of \code{\link{GetSeaLevelPressure}}.
#'
#' @export
GetStationPressure <- function (SeaLevelPressure, Altitude, TDryBulb) {
    CheckLength(StationPressure, Altitude, TDryBulb)

    SeaLevelPressure / GetSeaLevelPressure(1, Altitude, TDryBulb)
}
