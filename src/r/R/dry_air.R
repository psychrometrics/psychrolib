#######################################################################################################
# Dry Air Calculations
#######################################################################################################

#' Return dry-air enthalpy given dry-bulb temperature.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @return A numeric vector of dry air enthalpy in Btu lb-1 [IP] or J kg-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 28
#'
#' @examples
#' SetUnitSystem("IP")
#' GetDryAirEnthalpy(77:87)
#'
#' SetUnitSystem("SI")
#' GetDryAirEnthalpy(10:30)
#'
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
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of dry air density in lb ft-3 [IP] or kg m-3 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#' \itemize{
#'   \item Eqn 14 for the perfect gas relationship for dry air.
#'   \item Eqn 1 for the universal gas constant.
#'   \item The factor 144 in IP is for the conversion of Psi = lb in-2 to lb ft-2.
#' }
#'
#' @examples
#' SetUnitSystem("IP")
#' GetDryAirDensity(77:87, 14.696)
#'
#' SetUnitSystem("SI")
#' GetDryAirDensity(25:30, 101325)
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
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of dry air volume in ft3 lb-1 [IP] or in m3 kg-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#' \itemize{
#'   \item Eqn 14 for the perfect gas relationship for dry air.
#'   \item Eqn 1 for the universal gas constant.
#'   \item The factor 144 in IP is for the conversion of Psi = lb in-2 to lb ft-2.
#' }
#'
#' @examples
#' SetUnitSystem("IP")
#' GetDryAirVolume(77:87, 14.696)
#'
#' SetUnitSystem("SI")
#' GetDryAirVolume(25:30, 101325)
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
#' @param MoistAirEnthalpy A numeric vector of moist air enthalpy in Btu lb-1 [IP] or J kg-1
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @return A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30
#'
#' @note
#' Based on the \code{\link{GetMoistAirEnthalpy}} function, rearranged for temperature.
#'
#' @examples
#'
#' @examples
#' SetUnitSystem("IP")
#' GetTDryBulbFromEnthalpyAndHumRatio(42.6168, seq(0.01, 0.02, 0.001))
#'
#' SetUnitSystem("SI")
#' GetTDryBulbFromEnthalpyAndHumRatio(81316.0, seq(0.01, 0.02, 0.001))
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
#' @param MoistAirEnthalpy A numeric vector of moist air enthalpy in Btu lb-1 [IP] or J kg-1
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#'
#' @return A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30.
#'
#' @note
#' Based on the \code{\link{GetMoistAirEnthalpy}} function, rearranged for humidity ratio.
#'
#' @examples
#' SetUnitSystem("IP")
#' GetHumRatioFromEnthalpyAndTDryBulb(42.6168, 76:86)
#'
#' SetUnitSystem("SI")
#' GetHumRatioFromEnthalpyAndTDryBulb(81316.0, 20:30)
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
