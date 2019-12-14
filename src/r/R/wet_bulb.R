#######################################################################################################
# Conversions from wet-bulb temperature, dew-point temperature, or relative humidity to humidity ratio
#######################################################################################################

#' Return wet-bulb temperature given dry-bulb temperature, humidity ratio, and pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param HumRatio Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure Atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return Wet-bulb temperature in °F [IP] or °C [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35 solved for Tstar
#'
#' @export
GetTWetBulbFromHumRatio <- function (TDryBulb, HumRatio, Pressure) {
    CheckLength(TDryBulb, HumRatio, Pressure)
    CheckHumRatio(HumRatio)

    BoundedHumRatio <- pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)

    TDewPoint <- GetTDewPointFromHumRatio(TDryBulb, BoundedHumRatio, Pressure)

    l <- max(c(length(TDryBulb), length(BoundedHumRatio), length(Pressure)))
    TDryBulb <- rep(TDryBulb, length.out = l)
    BoundedHumRatio <- rep(BoundedHumRatio, length.out = l)
    Pressure <- rep(Pressure, length.out = l)
    TWetBulb <- numeric(l)

    for (i in seq_along(TDryBulb)) {
        TWetBulb[[i]] <- C_GetTWetBulbFromHumRatio(
            TDryBulb[[i]], TDewPoint[[i]], BoundedHumRatio[[i]], Pressure[[i]],
            PSYCHRO_OPT$MIN_HUM_RATIO, PSYCHRO_OPT$MAX_ITER_COUNT, PSYCHRO_OPT$TOLERANCE, isIP()
        )
    }

    TWetBulb
}

#' Return humidity ratio given dry-bulb temperature, wet-bulb temperature, and pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param TWetBulb Wet-bulb temperature in °F [IP] or °C [SI]
#' @param Pressure Atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35
#'
#' @export
GetHumRatioFromTWetBulb <- function (TDryBulb, TWetBulb, Pressure) {

    if (any(TWetBulb > TDryBulb)) {
        stop("Wet bulb temperature is above dry bulb temperature")
    }

    Wsstar <- GetSatHumRatio(TWetBulb, Pressure)
    HumRatio <- numeric(length(TWetBulb))

    if (isIP()) {
        idx <- TWetBulb >= FREEZING_POINT_WATER_IP

        if (any(idx)) {
            HumRatio[idx] <- ((1093.0 - 0.556 * TWetBulb[idx]) * Wsstar[idx] - 0.240 * (TDryBulb[idx] - TWetBulb[idx])) /
                (1093.0 + 0.444 * TDryBulb[idx] - TWetBulb[idx])
        }

        if (any(!idx)) {
            HumRatio[!idx] <- ((1220.0 - 0.04 * TWetBulb[!idx]) * Wsstar[!idx] - 0.240 * (TDryBulb[!idx] - TWetBulb[!idx])) /
                (1220.0 + 0.444 * TDryBulb[!idx] - 0.48 * TWetBulb[!idx])
        }
    } else {
        idx <- TWetBulb >= FREEZING_POINT_WATER_SI

        if (any(idx)) {
            HumRatio[idx] <- ((2501.0 - 2.326 * TWetBulb[idx]) * Wsstar[idx] - 1.006 * (TDryBulb[idx] - TWetBulb[idx])) /
                (2501.0 + 1.86 * TDryBulb[idx] - 4.186 * TWetBulb[idx])
        }

        if (any(!idx)) {
            HumRatio[!idx] <- ((2830.0 - 0.24 * TWetBulb[!idx]) * Wsstar[!idx] - 1.006 * (TDryBulb[!idx] - TWetBulb[!idx])) /
                (2830.0 + 1.86 * TDryBulb[!idx] - 2.1 * TWetBulb[!idx])
        }
    }

    # Validity check.
    pmax(HumRatio, PSYCHRO_OPT$MIN_HUM_RATIO)
}

#' Return humidity ratio given dry-bulb temperature, relative humidity, and pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param RelHum Relative humidity in range [0, 1]
#' @param Pressure Atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @export
GetHumRatioFromRelHum <- function (TDryBulb, RelHum, Pressure) {
    CheckRelHum(RelHum)

    VapPres <- GetVapPresFromRelHum(TDryBulb, RelHum)
    GetHumRatioFromVapPres(VapPres, Pressure)
}

#' Return relative humidity given dry-bulb temperature, humidity ratio, and pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param HumRatio Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure Atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return Relative humidity in range [0, 1]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @export
GetRelHumFromHumRatio <- function (TDryBulb, HumRatio, Pressure) {
    CheckHumRatio(HumRatio)

    VapPres <- GetVapPresFromHumRatio(HumRatio, Pressure)
    GetRelHumFromVapPres(TDryBulb, VapPres)
}

#' Return humidity ratio given dew-point temperature and pressure.
#'
#' @param TDewPoint Dew-point temperature in °F [IP] or °C [SI]
#' @param Pressure Atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 13
#'
#' @export
GetHumRatioFromTDewPoint <- function (TDewPoint, Pressure) {
    VapPres <- GetSatVapPres(TDewPoint)
    GetHumRatioFromVapPres(VapPres, Pressure)
}

#' Return dew-point temperature given dry-bulb temperature, humidity ratio, and pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param HumRatio Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
#' @param Pressure Atmospheric Pressure in Psi [IP] or Pa [SI]
#'
#' @return Dew-point temperature in °F [IP] or °C [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1
#'
#' @export
GetTDewPointFromHumRatio <- function (TDryBulb, HumRatio, Pressure) {
    CheckHumRatio(HumRatio)

    VapPres <- GetVapPresFromHumRatio(HumRatio, Pressure)
    GetTDewPointFromVapPres(TDryBulb, VapPres)
}
