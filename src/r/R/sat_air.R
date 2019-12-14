#######################################################################################################
# Saturated Air Calculations
#######################################################################################################

#' Return saturation vapor pressure given dry-bulb temperature.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @return Vapor pressure of saturated air in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1  eqn 5 & 6
#'
#' @note
#' Important note: the ASHRAE formulae are defined above and below the freezing point but have
#' a discontinuity at the freezing point. This is a small inaccuracy on ASHRAE's part: the formulae
#' should be defined above and below the triple point of water (not the feezing point) in which case
#' the discontinuity vanishes. It is essential to use the triple point of water otherwise function
#' GetTDewPointFromVapPres, which inverts the present function, does not converge properly around
#' the freezing point.
#'
#' @export
GetSatVapPres <- function (TDryBulb) {
    LnPws <- numeric(length(TDryBulb))

    if (isIP()) {
        if (any(TDryBulb < -148.0 | TDryBulb > 392.0)) {
            stop("Dry bulb temperature must be in range [-148, 392]\u00B0F")
        }

        TR <- GetTRankineFromTFahrenheit(TDryBulb)

        idx <- TDryBulb <= TRIPLE_POINT_WATER_IP

        if (any(idx)) {
            LnPws[idx] <- -1.0214165E+04 / TR[idx] - 4.8932428 - 5.3765794E-03 * TR[idx] + 1.9202377E-07 * TR[idx] ^ 2 +
                3.5575832E-10 * TR[idx] ^ 3 - 9.0344688E-14 * TR[idx] ^4 + 4.1635019 * log(TR[idx])
        }

        if (any(!idx)) {
            LnPws[!idx] <- -1.0440397E+04 / TR[!idx] - 1.1294650E+01 - 2.7022355E-02* TR[!idx] + 1.2890360E-05 * TR[!idx] ^ 2 +
                -2.4780681E-09 * TR[!idx] ^ 3 + 6.5459673 * log(TR[!idx])
        }
    } else {
        if (any(TDryBulb < -100.0 | TDryBulb > 200.0)) {
            stop("Dry bulb temperature must be in range [-100, 200]\u00B0C")
        }

        TK <- GetTKelvinFromTCelsius(TDryBulb)

        idx <- TDryBulb <= TRIPLE_POINT_WATER_SI

        if (any(idx)) {
            LnPws[idx] <- -5.6745359E+03 / TK[idx] + 6.3925247 - 9.677843E-03 * TK[idx] + 6.2215701E-07 * TK[idx] ^ 2 +
                2.0747825E-09 * TK[idx] ^ 3 - 9.484024E-13 * TK[idx] ^ 4 + 4.1635019 * log(TK[idx])
        }

        if (any(!idx)) {
            LnPws[!idx] <- -5.8002206E+03 / TK[!idx] + 1.3914993 - 4.8640239E-02 * TK[!idx] + 4.1764768E-05 * TK[!idx] ^ 2 +
                -1.4452093E-08 * TK[!idx] ^ 3 + 6.5459673 * log(TK[!idx])
        }
    }

    exp(LnPws)
}

#' Return humidity ratio of saturated air given dry-bulb temperature and pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param Pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Humidity ratio of saturated air in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36, solved for W
#'
#' @export
GetSatHumRatio <- function (TDryBulb, Pressure) {
    CheckLength(TDryBulb, Pressure)

    SatVaporPres <- GetSatVapPres(TDryBulb)
    SatHumRatio <- 0.621945 * SatVaporPres / (Pressure - SatVaporPres)

    # Validity check.
    pmax(SatHumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)
}

#' Return saturated air enthalpy given dry-bulb temperature and pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param Pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Saturated air enthalpy in Btu lb-1 [IP] or J kg-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @export
GetSatAirEnthalpy <- function (TDryBulb, Pressure) {
    CheckLength(TDryBulb, Pressure)

    SatHumRatio <- GetSatHumRatio(TDryBulb, Pressure)
    GetMoistAirEnthalpy(TDryBulb, SatHumRatio)
}
