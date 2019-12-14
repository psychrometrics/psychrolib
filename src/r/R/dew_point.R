#######################################################################################################
# Conversions between dew point, or relative humidity and vapor pressure
#######################################################################################################

#' Return partial pressure of water vapor as a function of relative humidity and temperature.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param RelHum Relative humidity in range [0, 1]
#'
#' @return Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
#'
#' @export
GetVapPresFromRelHum <- function (TDryBulb, RelHum) {
    CheckLength(TDryBulb, RelHum)
    CheckRelHum(RelHum)

    RelHum * GetSatVapPres(TDryBulb)
}

#' Return relative humidity given dry-bulb temperature and vapor pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param VapPres Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @return Relative humidity in range [0, 1]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
#'
#' @export
GetRelHumFromVapPres <- function (TDryBulb, VapPres) {
    CheckLength(TDryBulb, VapPres)
    CheckVapPres(VapPres)

    VapPres / GetSatVapPres(TDryBulb)
}

#' Helper function returning the derivative of the natural log of the saturation vapor pressure
#' as a function of dry-bulb temperature.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#'
#' @return Derivative of natural log of vapor pressure of saturated air in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1  eqn 5 & 6
#'
#' @keywords internal
dLnPws_ <- function (TDryBulb) {
    dLnPws <- numeric(length(TDryBulb))

    if (isIP()) {
        TR <- GetTRankineFromTFahrenheit(TDryBulb)
        idx <- TDryBulb <= TRIPLE_POINT_WATER_IP

        if (any(idx)) {
            dLnPws[idx] <- 1.0214165E+04 / TR[idx] ^ 2.0 - 5.3765794E-03 + 2 * 1.9202377E-07 * TR[idx] +
                2.0 * 3.5575832E-10 * TR[idx] ^ 2.0 - 4 * 9.0344688E-14 * TR[idx] ^ 3.0 + 4.1635019 / TR[idx]
        }

        if (any(!idx)) {
            dLnPws[!idx] <- 1.0440397E+04 / TR[!idx] ^ 2.0 - 2.7022355E-02 + 2 * 1.2890360E-05 * TR[!idx] +
                -3.0 * 2.4780681E-09 * TR[!idx] ^ 2.0 + 6.5459673 / TR[!idx]
        }

    } else {
        TK <- GetTKelvinFromTCelsius(TDryBulb)
        idx <- TDryBulb <= TRIPLE_POINT_WATER_SI

        if (any(idx)) {
            dLnPws[idx] <- 5.6745359E+03 / TK[idx] ^ 2.0 - 9.677843E-03 + 2 * 6.2215701E-07 * TK[idx] +
                3.0 * 2.0747825E-09 * TK[idx] ^ 2.0 - 4 * 9.484024E-13 * TK[idx] ^ 3.0 + 4.1635019 / TK[idx]
        }

        if (any(!idx)) {
            dLnPws[!idx] <- 5.8002206E+03 / TK[!idx] ^ 2.0 - 4.8640239E-02 + 2 * 4.1764768E-05 * TK[!idx] +
                -3.0 * 1.4452093E-08 * TK[!idx] ^ 2.0 + 6.5459673 / TK[!idx]
        }
    }

    dLnPws
}

#' Return dew-point temperature given dry-bulb temperature and vapor pressure.
#'
#' @param TDryBulb Dry-bulb temperature in °F [IP] or °C [SI]
#' @param VapPres Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @return Dew-point temperature in °F [IP] or °C [SI]
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

    # We use NR to approximate the solution.
    # First guess
    TDewPoint <- TDryBulb        # Calculated value of dew point temperatures, solved for iteratively
    lnVP <- log(VapPres)         # Partial pressure of water vapor in moist air

    find_root <- function (TDewPoint) {
        index <- 1L
        while (TRUE) {
            TDewPoint_iter <- TDewPoint   # TDewPoint used in NR calculation
            lnVP_iter <- log(GetSatVapPres(TDewPoint_iter))

            # Derivative of function, calculated analytically
            d_lnVP <- dLnPws_(TDewPoint_iter)

            # New estimate, bounded by the search domain defined above
            TDewPoint <- TDewPoint_iter - (lnVP_iter - lnVP) / d_lnVP
            TDewPoint <- max(TDewPoint, BOUNDS[1])
            TDewPoint <- min(TDewPoint, BOUNDS[2])

            if ((abs(TDewPoint - TDewPoint_iter) <= PSYCHRO_OPT$TOLERANCE)) break

            if (index > PSYCHRO_OPT$MAX_ITER_COUNT) {
                stop("Convergence not reached in GetTDewPointFromVapPres. Stopping.")
            }

            index <- index + 1L
        }

        TDewPoint
    }

    TDewPoint <- vapply(TDewPoint, find_root, 0.0)

    pmin(TDewPoint, TDryBulb)
}

#' Return vapor pressure given dew point temperature.
#'
#' @param TDewPoint Dew-point temperature in °F [IP] or °C [SI]
#'
#' @return Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
#'
#' @references
#' ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36
#'
#' @export
GetVapPresFromTDewPoint <- function (TDewPoint) {
    GetSatVapPres(TDewPoint)
}
