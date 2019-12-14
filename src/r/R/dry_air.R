#######################################################################################################
# Dry Air Calculations
#######################################################################################################

#' Return dry-air enthalpy given dry-bulb temperature.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @return Dry air enthalpy in Btu lb-1 [IP] or J kg-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 28
#'
#' @export
GetDryAirEnthalpy <- function (TDryBulb) {
    if (isIP()) {
        0.240 * TDryBulb
    } else {
        1006.0 * TDryBulb
    }
}

#' Return dry-air density given dry-bulb temperature and pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param Pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Dry air density in lb ft-3 [IP] or kg m-3 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#' \itemize{
#'   \item Eqn 14 for the perfect gas relationship for dry air.
#'   \item Eqn 1 for the universal gas constant.
#'   \item The factor 144 in IP is for the conversion of Psi = lb in-2 to lb ft-2.
#' }
#'
#' @export
GetDryAirDensity <- function (TDryBulb, Pressure) {
    CheckLength(TDryBulb, Pressure)

    if (isIP()) {
        # The factor 144 is for the conversion of Psi = lb in-2 to lb ft-2.
        (144 * Pressure) / R_DA_IP / GetTRankineFromTFahrenheit(TDryBulb)
    } else {
        Pressure / R_DA_SI / GetTKelvinFromTCelsius(TDryBulb)
    }
}

#' Return dry-air volume given dry-bulb temperature and pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param Pressure Atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return Dry air volume in ft3 lb-1 [IP] or in m3 kg-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#' \itemize{
#'   \item Eqn 14 for the perfect gas relationship for dry air.
#'   \item Eqn 1 for the universal gas constant.
#'   \item The factor 144 in IP is for the conversion of Psi = lb in-2 to lb ft-2.
#' }
#'
#' @export
GetDryAirVolume <- function (TDryBulb, Pressure) {
    CheckLength(TDryBulb, Pressure)

    if (isIP()) {
        # The factor 144 is for the conversion of Psi = lb in-2 to lb ft-2.
        R_DA_IP * GetTRankineFromTFahrenheit(TDryBulb) / (144 * Pressure)
    } else {
        R_DA_SI * GetTKelvinFromTCelsius(TDryBulb) / Pressure
    }
}

#' Return dry bulb temperature from enthalpy and humidity ratio.
#'
#' @param MoistAirEnthalpy Moist air enthalpy in Btu lb-1 [IP] or J kg-1
#' @param HumRatio Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @return Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30
#'
#' @note
#' Based on the `GetMoistAirEnthalpy` function, rearranged for temperature.
#'
#' @export
GetTDryBulbFromEnthalpyAndHumRatio <- function (MoistAirEnthalpy, HumRatio) {
    CheckLength(MoistAirEnthalpy, HumRatio)
    CheckHumRatio(HumRatio)

    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    if (isIP()) {
        (MoistAirEnthalpy - 1061.0 * BoundedHumRatio) / (0.240 + 0.444 * BoundedHumRatio)
    } else {
        (MoistAirEnthalpy / 1000.0 - 2501.0 * BoundedHumRatio) / (1.006 + 1.86 * BoundedHumRatio)
    }
}

#' Return humidity ratio from enthalpy and dry-bulb temperature.
#'
#' @param MoistAirEnthalpy Moist air enthalpy in Btu lb-1 [IP] or J kg-1
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @return Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30.
#'
#' @note
#' Based on the `GetMoistAirEnthalpy` function, rearranged for humidity ratio.
#'
#' @export
GetHumRatioFromEnthalpyAndTDryBulb <- function (MoistAirEnthalpy, TDryBulb) {
    CheckLength(MoistAirEnthalpy, TDryBulb)

    if (isIP()) {
        HumRatio <- (MoistAirEnthalpy - 0.240 * TDryBulb) / (1061.0 + 0.444 * TDryBulb)
    } else {
        HumRatio <- (MoistAirEnthalpy / 1000.0 - 1.006 * TDryBulb) / (2501.0 + 1.86 * TDryBulb)
    }

    # Validity check.
    pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)
}
