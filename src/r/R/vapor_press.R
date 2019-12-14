#######################################################################################################
# Conversions between humidity ratio and vapor Pressure
#######################################################################################################

#' Return humidity ratio given water vapor Pressure and atmospheric pressure.
#'
#' @param VapPres A numeric vector of partial Pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#' @param Pressure A numeric vector of atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20
#'
#' @examples
#' SetUnitSystem("IP")
#' GetHumRatioFromVapPres(seq(0.4, 0.6, 0.01), 14.175)
#'
#' SetUnitSystem("SI")
#' GetHumRatioFromVapPres(seq(3000, 4000, 100), 95461)
#'
#' @export
GetHumRatioFromVapPres <- function (VapPres, Pressure) {
    CheckLength(VapPres, Pressure)
    CheckVapPres(VapPres)

    HumRatio <- 0.621945 * VapPres / (Pressure - VapPres)

    # Validity check.
    pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)
}

#' Return vapor Pressure given humidity ratio and pressure.
#'
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of partial Pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20 solved for pw
#'
#' @examples
#' SetUnitSystem("IP")
#' GetVapPresFromHumRatio(seq(0.02, 0.03, 0.001), 14.175)
#'
#' SetUnitSystem("SI")
#' GetVapPresFromHumRatio(seq(0.02, 0.03, 0.001), 95461)
#'
#' @export
GetVapPresFromHumRatio <- function (HumRatio, Pressure) {
    CheckLength(HumRatio, Pressure)
    CheckHumRatio(HumRatio)

    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)
    Pressure * BoundedHumRatio / (0.621945 + BoundedHumRatio)
}
