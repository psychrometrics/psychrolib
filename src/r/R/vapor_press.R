#######################################################################################################
# Conversions between humidity ratio and vapor Pressure
#######################################################################################################

#' Return humidity ratio given water vapor Pressure and atmospheric pressure.
#'
#' @param VapPres Partial Pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#' @param Pressure Atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20
#'
#' @export
GetHumRatioFromVapPres <- function (VapPres, Pressure) {
    CheckLength(VapPres, Pressure)
    CheckVapPres(VapPres)

    HumRatio <- 0.621945 * VapPres / (Pressure - VapPres)

    # Validity check.
    pmax(HumRatio, MIN_HUM_RATIO)
}

#' Return vapor Pressure given humidity ratio and pressure.
#'
#' @param HumRatio Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure Atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return Partial Pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20 solved for pw
#'
#' @export
GetVapPresFromHumRatio <- function (HumRatio, Pressure) {
    CheckLength(HumRatio, Pressure)
    CheckHumRatio(HumRatio)

    BoundedHumRatio <- pmax(HumRatio, MIN_HUM_RATIO)
    Pressure * BoundedHumRatio / (0.621945 + BoundedHumRatio)
}
