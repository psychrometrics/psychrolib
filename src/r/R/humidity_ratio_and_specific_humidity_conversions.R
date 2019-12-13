#######################################################################################################
# Conversions between humidity ratio and specific humidity
#######################################################################################################

#' Return the specific humidity from humidity ratio (aka mixing ratio).
#'
#' @param hum_ratio Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]
#'
#' @return Specific humidity in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b
#' @export
get_specific_hum_from_hum_ratio <- function(hum_ratio) {
  if (hum_ratio < 0.0) {
    stop("Humidity ratio cannot be negative")
  }
  bounded_hum_ratio <- max(hum_ratio, MIN_HUM_RATIO)
  bounded_hum_ratio / (1.0 + bounded_hum_ratio)
}

#' Return the humidity ratio (aka mixing ratio) from specific humidity.
#'
#' @param specific_hum Specific humidity in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
#'
#' @return Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]
#'
#' @section Reference:
#'   ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b (solved for humidity ratio)
get_hum_ratio_from_specific_hum <- function(specific_hum) {
  if (specific_hum <0 || specific_hum >= 1.0) {
    stop("Specific humidity is outside range [0, 1[")
  }
  hum_ratio <- specific_hum / (1.0 - specific_hum)
  # Validity check.
  max(hum_ratio, MIN_HUM_RATIO)
}
