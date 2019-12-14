#######################################################################################################
# Moist Air Calculations
#######################################################################################################

#' Return Vapor pressure deficit given dry-bulb temperature, humidity ratio, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in °F [IP] or °C [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of vapor pressure deficit in Psi [IP] or Pa [SI]
#'
#' @references
#' Oke (1987) eqn 2.13a
#'
#' @examples
#' SetUnitSystem("IP")
#' GetVaporPressureDeficit(80:100, 0.01, 14.175)
#'
#' SetUnitSystem("SI")
#' GetVaporPressureDeficit(20:30, 0.01, 95461.0)
#'
#' @export
GetVaporPressureDeficit <- function (TDryBulb, HumRatio, Pressure) {
    CheckLength(TDryBulb, HumRatio, Pressure)
    CheckHumRatio(HumRatio)

    RelHum <- GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
    GetSatVapPres(TDryBulb) * (1 - RelHum)
}

#' Return the degree of saturation (i.e humidity ratio of the air / humidity ratio of the air at saturation
#' at the same temperature and pressure) given dry-bulb temperature, humidity ratio, and atmospheric pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in °F [IP] or °C [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of degree of saturation in arbitrary unit
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2009) ch. 1 eqn 12
#'
#' @note
#' This definition is absent from the 2017 Handbook. Using 2009 version instead.
#'
#' @examples
#' SetUnitSystem("IP")
#' GetDegreeOfSaturation(80:100, 0.01, 14.175)
#'
#' SetUnitSystem("SI")
#' GetDegreeOfSaturation(20:30, 0.01, 95461.0)
#'
#' @export
GetDegreeOfSaturation <- function (TDryBulb, HumRatio, Pressure) {
    CheckLength(TDryBulb, HumRatio, Pressure)
    CheckHumRatio(HumRatio)
    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    SatHumRatio <- GetSatHumRatio(TDryBulb, Pressure)
    BoundedHumRatio / SatHumRatio
}

#' Return moist air enthalpy given dry-bulb temperature and humidity ratio.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in °F [IP] or °C [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @return A numeric vector of moist air enthalpy in Btu lb-1 [IP] or J kg-1
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30
#'
#' @examples
#' SetUnitSystem("IP")
#' GetMoistAirEnthalpy(80:100, 0.02)
#'
#' SetUnitSystem("SI")
#' GetMoistAirEnthalpy(20:30, 0.02)
#'
#' @export
GetMoistAirEnthalpy <- function (TDryBulb, HumRatio) {
    CheckLength(TDryBulb, HumRatio)
    CheckHumRatio(HumRatio)
    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    if (isIP()) {
        0.240 * TDryBulb + BoundedHumRatio * (1061 + 0.444 * TDryBulb)
    } else {
        (1.006 * TDryBulb + BoundedHumRatio * (2501. + 1.86 * TDryBulb)) * 1000
    }
}

#' Return moist air specific volume given dry-bulb temperature, humidity ratio, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in °F [IP] or °C [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of specific volume of moist air in ft³ lb-1 of dry air [IP] or in m³ kg-1 of dry air [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26
#'
#' @note
#' In IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26.
#'
#' The factor 144 is for the conversion of Psi = lb in-2 to lb ft-2.
#'
#' @examples
#' SetUnitSystem("IP")
#' GetMoistAirVolume(80:100, 0.02, 14.175)
#'
#' SetUnitSystem("SI")
#' GetMoistAirVolume(20:30, 0.02, 95461)
#'
#' @export
GetMoistAirVolume <- function (TDryBulb, HumRatio, Pressure) {
    CheckLength(TDryBulb, HumRatio, Pressure)
    CheckHumRatio(HumRatio)
    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    if (isIP()) {
        # R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26
        # The factor 144 is for the conversion of Psi = lb in-2 to lb ft-2.
        R_DA_IP * GetTRankineFromTFahrenheit(TDryBulb) * (1 + 1.607858 * BoundedHumRatio) / (144 * Pressure)
    } else {
        R_DA_SI * GetTKelvinFromTCelsius(TDryBulb) * (1 + 1.607858 * BoundedHumRatio) / Pressure
    }
}

#' Return dry-bulb temperature given moist air specific volume, humidity ratio, and pressure.
#'
#' @param MoistAirVolume A numeric vector of specific volume of moist air in ft3 lb-1 of dry air [IP] or in m3 kg-1 of dry air [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of tDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26
#'
#' @note
#' \itemize{
#'   \item In IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26.
#'   \item The factor 144 is for the conversion of Psi = lb in-2 to lb ft-2.
#'   \item Based on the `GetMoistAirVolume` function, rearranged for dry-bulb temperature.
#' }
#'
#' @examples
#' SetUnitSystem("IP")
#' GetTDryBulbFromMoistAirVolumeAndHumRatio(14.72, seq(0.02, 0.03, 0.001), 14.175)
#'
#' SetUnitSystem("SI")
#' GetTDryBulbFromMoistAirVolumeAndHumRatio(0.94, seq(0.02, 0.03, 0.001), 95461)
#'
#' @export
GetTDryBulbFromMoistAirVolumeAndHumRatio <- function (MoistAirVolume, HumRatio, Pressure) {
    CheckLength(MoistAirVolume, HumRatio, Pressure)
    CheckHumRatio(HumRatio)
    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    if (isIP()) {
        GetTFahrenheitFromTRankine(MoistAirVolume * (144 * Pressure)
            / (R_DA_IP * (1 + 1.607858 * BoundedHumRatio)))
    } else {
        GetTCelsiusFromTKelvin(MoistAirVolume * Pressure
            / (R_DA_SI * (1 + 1.607858 * BoundedHumRatio)))
    }
}

#' Return moist air density given humidity ratio, dry bulb temperature, and pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in °F [IP] or °C [SI]
#' @param HumRatio A numeric vector of humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure A numeric vector of atmospheric pressure in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of moistAirDensity: Moist air density in lb ft-3 [IP] or kg m-3 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 11
#'
#' @examples
#' SetUnitSystem("IP")
#' GetMoistAirDensity(80:100, 0.02, 14.175)
#'
#' SetUnitSystem("SI")
#' GetMoistAirDensity(20:30, 0.02, 95461)
#'
#' @export
GetMoistAirDensity <- function (TDryBulb, HumRatio, Pressure) {
    CheckLength(TDryBulb, HumRatio, Pressure)
    CheckHumRatio(HumRatio)
    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    MoistAirVolume <- GetMoistAirVolume(TDryBulb, BoundedHumRatio, Pressure)
    (1 + BoundedHumRatio) / MoistAirVolume
}
