#######################################################################################################
# Conversions between humidity ratio and specific humidity
#######################################################################################################

#' Return the specific humidity from humidity ratio (aka mixing ratio).
#'
#' @param HumRatio Humidity ratio in lb_H2O lb_Dry_Air-1 [IP] or kg_H2O kg_Dry_Air-1 [SI]
#'
#' @return Specific humidity in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b
#'
#' @export
GetSpecificHumFromHumRatio <- function (HumRatio) {
    CheckHumRatio(HumRatio)

    BoundedHumRatio <- pmax(HumRatio, MIN_HUM_RATIO)
    BoundedHumRatio / (1.0 + BoundedHumRatio)
}

#' Return the humidity ratio (aka mixing ratio) from specific humidity.
#'
#' @param SpecificHum Specific humidity in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @return Humidity ratio in lb_H2O lb_Dry_Air-1 [IP] or kg_H2O kg_Dry_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b (solved for humidity ratio)
#'
#' @export
GetHumRatioFromSpecificHum <- function (SpecificHum) {
    CheckSpecificHum(SpecificHum)

    HumRatio <- SpecificHum / (1.0 - SpecificHum)

    # Validity check.
    pmax(HumRatio, MIN_HUM_RATIO)
}
