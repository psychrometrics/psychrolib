CheckRelHum <- function (RelHum) {
    stopifnot(is.numeric(RelHum))

    if (any(RelHum < 0.0 | RelHum > 1.0)) {
        stop("Relative humidity is outside range [0, 1]")
    }

    RelHum
}

CheckSpecificHum <- function (SpecificHum) {
    stopifnot(is.numeric(SpecificHum))

    if (any(SpecificHum < 0.0 | SpecificHum > 1.0)) {
        stop("Specific humidity is outside range [0, 1]")
    }

    SpecificHum
}

CheckVapPres <- function (VapPres) {
    stopifnot(is.numeric(VapPres))

    if (any(VapPres < 0.0)) {
        stop("Partial pressure of water vapor in moist air cannot be negative")
    }

    VapPres
}

CheckHumRatio <- function (HumRatio) {
    stopifnot(is.numeric(HumRatio))

    if (any(HumRatio < 0.0)) {
        stop("Humidity ratio cannot be negative")
    }

    HumRatio
}

CheckTDewPoint <- function (TDewPoint, TDryBulb) {
    if (any(TDewPoint > TDryBulb)) {
        stop("Dew point temperature is above dry bulb temperature")
    }

    TDewPoint
}

CheckTWetPoint <- function (TWetPoint, TDryBulb) {
    if (any(TWetPoint > TDryBulb)) {
        stop("Wet bulb temperature is above dry bulb temperature")
    }

    TWetPoint
}
