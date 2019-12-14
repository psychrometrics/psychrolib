#######################################################################################################
# Helper functions
#######################################################################################################

PSYCHRO_ENV <- new.env(parent = emptyenv())

# The system of units in use
PSYCHRO_ENV$UNITS <- NA_character_

# Tolerance of temperature calculations
PSYCHRO_ENV$TOLERANCE <- NA_real_

# The options for PSYCHROLIB_UNITS
PSYCHROLIB_UNITS_OPTIONS <- c("IP", "SI")

#' Set the system of units to use (SI or IP).
#'
#' @param units string indicating the system of units chosen ("SI" or "IP")
#'
#' @note
#' The default unit system is "SI".
#'
#' @export
SetUnitSystem <- function (units) {

    # Define tolerance on temperature calculations
    # The tolerance is the same in IP and SI
    PSYCHROLIB_TOLERANCES <- c(IP = 0.001 * 9. / 5., SI = 0.001)

    if (units %in% PSYCHROLIB_UNITS_OPTIONS) {
        PSYCHRO_ENV$UNITS <- units
        PSYCHRO_ENV$TOLERANCE <- PSYCHROLIB_TOLERANCES[units]
    } else {
        stop("The system of units has to be either SI or IP.")
    }
}

#' Return system of units in use.
#'
#' @return string indicating system of units in use ("SI" or "IP")
#' @export
GetUnitSystem <- function () {
    PSYCHRO_ENV$UNITS
}

#' Check whether the system in use is IP or SI.
#'
#' @return boolean TRUE if unit system is IP
#' @export
isIP <- function () {
    if (is.na(PSYCHRO_ENV$UNITS)) {
        stop("The system of units has not been defined.")
    } else if (PSYCHRO_ENV$UNITS == "IP") {
        return(TRUE)
    } else if (PSYCHRO_ENV$UNITS == "SI") {
        return(FALSE)
    } else {
        stop("The system of units is not correctly defined.")
    }
}
