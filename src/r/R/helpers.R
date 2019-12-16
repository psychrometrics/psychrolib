#######################################################################################################
# Helper functions
#######################################################################################################

PSYCHRO_OPT <- new.env(parent = emptyenv())

# The system of units in use
PSYCHRO_OPT$UNITS <- getOption("psychrolib.units", NA_character_)

# Tolerance of temperature calculations
PSYCHRO_OPT$TOLERANCE <- NA_real_

# Maximum number of iterations before exiting while loops.
PSYCHRO_OPT$MAX_ITER_COUNT <- 100L

# Minimum acceptable humidity ratio used/returned by any functions.
# Any value above 0 or below the MIN_HUM_RATIO will be reset to this value.
PSYCHRO_OPT$MIN_HUM_RATIO <- 1e-7

# The options for PSYCHROLIB_UNITS
PSYCHROLIB_UNITS_OPTIONS <- c("IP", "SI")

#' Set the system of units to use (SI or IP).
#'
#' @param units A string indicating the system of units chosen. Should be either
#'        \code{"SI"} or \code{"IP"}
#'
#' @export
SetUnitSystem <- function (units) {

    # Define tolerance on temperature calculations
    # The tolerance is the same in IP and SI
    PSYCHROLIB_TOLERANCES <- c(IP = 0.001 * 9. / 5., SI = 0.001)

    if (units %in% PSYCHROLIB_UNITS_OPTIONS) {
        PSYCHRO_OPT$UNITS <- units
        PSYCHRO_OPT$TOLERANCE <- PSYCHROLIB_TOLERANCES[units]
    } else {
        stop("The system of units has to be either SI or IP.")
    }
}

#' Return system of units in use.
#'
#' @return A string indicating system of units in use (\code{"SI"} or \code{"IP"})
#' @export
GetUnitSystem <- function () {
    PSYCHRO_OPT$UNITS
}

#' Check whether the system in use is IP or SI.
#'
#' @return \code{TRUE} if unit system is IP
#' @export
isIP <- function () {
    if (is.na(PSYCHRO_OPT$UNITS)) {
        stop("The system of units has not been defined.")
    } else if (PSYCHRO_OPT$UNITS == "IP") {
        return(TRUE)
    } else if (PSYCHRO_OPT$UNITS == "SI") {
        return(FALSE)
    } else {
        stop("The system of units is not correctly defined.")
    }
}
