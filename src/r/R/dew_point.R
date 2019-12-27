#######################################################################################################
# Conversions between dew point, or relative humidity and vapor pressure
#######################################################################################################

#' Return partial pressure of water vapor as a function of relative humidity and temperature.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param RelHum A numeric vector of relative humidity in range [0, 1]
#'
#' @return A numeric vector of partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
#'
#' @examples
#' SetUnitSystem("IP")
#' GetVapPresFromRelHum(77, seq(0.1, 0.8, 0.1))
#'
#' SetUnitSystem("SI")
#' GetVapPresFromRelHum(20, seq(0.1, 0.8, 0.1))
#'
#' @export
GetVapPresFromRelHum <- function (TDryBulb, RelHum) {
    CheckLength(TDryBulb, RelHum)
    CheckRelHum(RelHum)

    RelHum * GetSatVapPres(TDryBulb)
}

#' Return relative humidity given dry-bulb temperature and vapor pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param VapPres A numeric vector of partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of relative humidity in range [0, 1]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
#'
#' @examples
#' SetUnitSystem("IP")
#' GetRelHumFromVapPres(70:80, 0.0149)
#'
#' SetUnitSystem("SI")
#' GetRelHumFromVapPres(20:30, 12581)
#'
#' @export
GetRelHumFromVapPres <- function (TDryBulb, VapPres) {
    CheckLength(TDryBulb, VapPres)
    CheckVapPres(VapPres)

    VapPres / GetSatVapPres(TDryBulb)
}

#' Return dew-point temperature given dry-bulb temperature and vapor pressure.
#'
#' @param TDryBulb A numeric vector of dry-bulb temperature in degreeF [IP] or degreeC [SI]
#' @param VapPres A numeric vector of partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @return A numeric vector of dew-point temperature in degreeF [IP] or degreeC [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 and 6
#'
#' @note
#' \itemize{
#'  \item The dew point temperature is solved by inverting the equation giving water vapor pressure
#'        at saturation from temperature rather than using the regressions provided
#'        by ASHRAE (eqn. 37 and 38), which are much less accurate and have a
#'        narrower range of validity.
#'  \item The Newton-Raphson (NR) method is used on the logarithm of water vapour
#'        pressure as a function of temperature, which is a very smooth function.
#'  \item Convergence is usually achieved in 3 to 5 iterations.
#'  \item TDryBulb is not really needed here, just used for convenience.
#' }
#'
#' @examples
#' SetUnitSystem("IP")
#' GetTDewPointFromVapPres(70:80, seq(0.0149, 0.0249, 0.001))
#'
#' SetUnitSystem("SI")
#' GetTDewPointFromVapPres(70:80, 12581:12591)
#'
#' @export
GetTDewPointFromVapPres <- function (TDryBulb, VapPres) {
    CheckLength(TDryBulb, VapPres)

    if (isIP()) {
        BOUNDS <- c(-148, 392)
    } else {
        BOUNDS <- c(-100, 200)
    }

    # Validity check -- bounds outside which a solution cannot be found
    if (any(VapPres < GetSatVapPres(BOUNDS[1]) | VapPres > GetSatVapPres(BOUNDS[2]))) {
        stop("Partial pressure of water vapor is outside range of validity of equations")
    }

    l <- max(c(length(TDryBulb), length(VapPres)))
    TDryBulb <- rep(TDryBulb, length.out = l)
    VapPres <- rep(VapPres, length.out = l)
    TDewPoint <- numeric(l)

    for (i in seq_along(TDryBulb)) {
        TDewPoint[[i]] <- C_GetTDewPointFromVapPres(
            TDryBulb[[i]], VapPres[[i]], BOUNDS[[1]], BOUNDS[[2]],
            PSYCHRO_OPT$MAX_ITER_COUNT, PSYCHRO_OPT$TOLERANCE, isIP()
        )
    }

    TDewPoint
}

#' Return vapor pressure given dew point temperature.
#'
#' @param TDewPoint A numeric vector of dew-point temperature in degreeF [IP] or degreeC [SI]
#'
#' @return A numeric vector of partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36
#'
#' @examples
#' SetUnitSystem("IP")
#' GetVapPresFromTDewPoint(12:20)
#'
#' SetUnitSystem("SI")
#' GetVapPresFromTDewPoint(12:20)
#'
#' @export
GetVapPresFromTDewPoint <- function (TDewPoint) {
    GetSatVapPres(TDewPoint)
}
