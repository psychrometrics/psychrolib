/*
 * PsychroLib (version 2.5.0) (https://github.com/psychrometrics/psychrolib).
 * Copyright (c) 2018-2020 The PsychroLib Contributors for the current library implementation.
 * Copyright (c) 2017 ASHRAE Handbook — Fundamentals for ASHRAE equations and coefficients.
 * Licensed under the MIT License.
*/

#include <Rcpp.h>
using namespace Rcpp;

// Constants
#define ZERO_FAHRENHEIT_AS_RANKINE 459.67  // Zero degree Fahrenheit (degreeF) expressed as degree Rankine (degreeR).
                                           // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 39.

#define ZERO_CELSIUS_AS_KELVIN 273.15      // Zero degree Celsius (degreeC) expressed as Kelvin (K).
                                           // Reference: ASHRAE Handbook - Fundamentals (2017) ch. 39.

#define FREEZING_POINT_WATER_IP 32.0       // Freezing point of water in Fahrenheit.

#define FREEZING_POINT_WATER_SI 0.0        // Freezing point of water in Celsius.

#define TRIPLE_POINT_WATER_IP 32.018       // Triple point of water in Fahrenheit.

#define TRIPLE_POINT_WATER_SI 0.01         // Triple point of water in Celsius.

// Return saturation vapor pressure given dry-bulb temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 & 6
// Important note: the ASHRAE formulae are defined above and below the freezing point but have
// a discontinuity at the freezing point. This is a small inaccuracy on ASHRAE's part: the formulae
// should be defined above and below the triple point of water (not the feezing point) in which case
// the discontinuity vanishes. It is essential to use the triple point of water otherwise function
// GetTDewPointFromVapPres, which inverts the present function, does not converge properly around
// the freezing point.
// (o) Vapor Pressure of saturated air in Psi [IP] or Pa [SI]
double C_GetSatVapPres(const double & TDryBulb, // (i) Dry bulb temperature in degreeF [IP] or degreeC [SI]
                       const bool & inIP) {
    double LnPws, T;

    if (inIP) {
        T = TDryBulb + ZERO_FAHRENHEIT_AS_RANKINE;

        if (TDryBulb <= TRIPLE_POINT_WATER_IP)
            LnPws = (-1.0214165E+04 / T - 4.8932428 - 5.3765794E-03 * T + 1.9202377E-07 * T * T
                + 3.5575832E-10 * pow(T, 3) - 9.0344688E-14 * pow(T, 4) + 4.1635019 * log(T));
        else
            LnPws = -1.0440397E+04 / T - 1.1294650E+01 - 2.7022355E-02 * T + 1.2890360E-05 * T * T
                - 2.4780681E-09 * pow(T, 3) + 6.5459673 * log(T);
    } else {
        T = TDryBulb + ZERO_CELSIUS_AS_KELVIN;

        if (TDryBulb <= TRIPLE_POINT_WATER_SI)
            LnPws = -5.6745359E+03 / T + 6.3925247 - 9.677843E-03 * T + 6.2215701E-07 * T * T
                + 2.0747825E-09 * pow(T, 3) - 9.484024E-13 * pow(T, 4) + 4.1635019 * log(T);
        else
            LnPws = -5.8002206E+03 / T + 1.3914993 - 4.8640239E-02 * T + 4.1764768E-05 * T * T
                - 1.4452093E-08 * pow(T, 3) + 6.5459673 * log(T);
    }

    return exp(LnPws);
}

// Helper function returning the derivative of the natural log of the saturation vapor pressure
// as a function of dry-bulb temperature.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 & 6
// (o) Derivative of natural log of vapor pressure of saturated air in Psi [IP] or Pa [SI]
double C_dLnPws(const double & TDryBulb, // (i) Dry bulb temperature in degreeF [IP] or degreeC [SI]
                const bool & inIP) {
    double dLnPws, T;

    if (inIP) {
        T = TDryBulb + ZERO_FAHRENHEIT_AS_RANKINE;

        if (TDryBulb <= TRIPLE_POINT_WATER_IP)
            dLnPws = 1.0214165E+04 / pow(T, 2) - 5.3765794E-03 + 2 * 1.9202377E-07 * T
                + 3 * 3.5575832E-10 * pow(T, 2) - 4 * 9.0344688E-14 * pow(T, 3) + 4.1635019 / T;
        else
            dLnPws = 1.0440397E+04 / pow(T, 2) - 2.7022355E-02 + 2 * 1.2890360E-05 * T
                - 3 * 2.4780681E-09 * pow(T, 2) + 6.5459673 / T;
    } else {
        T = TDryBulb + ZERO_CELSIUS_AS_KELVIN;

        if (TDryBulb <= TRIPLE_POINT_WATER_SI)
            dLnPws = 5.6745359E+03 / pow(T, 2) - 9.677843E-03 + 2 * 6.2215701E-07 * T
                + 3 * 2.0747825E-09 * pow(T, 2) - 4 * 9.484024E-13 * pow(T, 3) + 4.1635019 / T;
        else
            dLnPws = 5.8002206E+03 / pow(T, 2) - 4.8640239E-02 + 2 * 4.1764768E-05 * T
                - 3 * 1.4452093E-08 * pow(T, 2) + 6.5459673 / T;
    }

    return dLnPws;
}

// Return humidity ratio of saturated air given dry-bulb temperature and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36, solved for W
// (o) Humidity ratio of saturated air in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
double C_GetSatHumRatio(const double & TDryBulb, // (i) Dry bulb temperature in degreeF [IP] or degreeC [SI]
                        const double & Pressure, // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
                        const double & MIN_HUM_RATIO,
                        const bool & inIP) {
    double SatVaporPres, SatHumRatio;

    SatVaporPres = C_GetSatVapPres(TDryBulb, inIP);
    SatHumRatio = 0.621945 * SatVaporPres / (Pressure - SatVaporPres);

    // Validity check.
    return std::max(SatHumRatio, MIN_HUM_RATIO);
}

// Return humidity ratio given dry-bulb temperature, wet-bulb temperature, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35
// (o) Humidity Ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
double C_GetHumRatioFromTWetBulb(const double & TDryBulb, // (i) Dry bulb temperature in degreeF [IP] or degreeC [SI]
                                 const double & TWetBulb, // (i) Wet bulb temperature in degreeF [IP] or degreeC [SI]
                                 const double & Pressure, // (i) Atmospheric pressure in Psi [IP] or Pa [SI],
                                 const double & MIN_HUM_RATIO,
                                 const bool & inIP) {
    double Wsstar;
    double HumRatio = NA_REAL;

    Wsstar = C_GetSatHumRatio(TWetBulb, Pressure, MIN_HUM_RATIO, inIP);

    if (inIP) {
        if (TWetBulb >= FREEZING_POINT_WATER_IP)
            HumRatio = ((1093. - 0.556 * TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb))
                / (1093. + 0.444 * TDryBulb - TWetBulb);
        else
            HumRatio = ((1220. - 0.04 * TWetBulb) * Wsstar - 0.240 * (TDryBulb - TWetBulb))
                / (1220. + 0.444 * TDryBulb - 0.48 * TWetBulb);
    } else {
        if (TWetBulb >= FREEZING_POINT_WATER_SI)
            HumRatio = ((2501. - 2.326 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb))
                / (2501. + 1.86 * TDryBulb - 4.186 * TWetBulb);
        else
            HumRatio = ((2830. - 0.24 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb))
                / (2830. + 1.86 * TDryBulb - 2.1 * TWetBulb);
    }

    // Validity check.
    return std::max(HumRatio, MIN_HUM_RATIO);
}

// Return dew-point temperature given dry-bulb temperature and vapor pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 and 6
// Notes: the dew point temperature is solved by inverting the equation giving water vapor pressure
// at saturation from temperature rather than using the regressions provided
// by ASHRAE (eqn. 37 and 38) which are much less accurate and have a
// narrower range of validity.
// The Newton-Raphson (NR) method is used on the logarithm of water vapour
// pressure as a function of temperature, which is a very smooth function
// Convergence is usually achieved in 3 to 5 iterations.
// TDryBulb is not really needed here, just used for convenience.
// (o) Dew Point temperature in degreeF [IP] or degreeC [SI]
// [[Rcpp::export]]
double C_GetTDewPointFromVapPres(const double & TDryBulb, // (i) Dry bulb temperature in degreeF [IP] or degreeC [SI]
                                 const double & VapPres,  // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
                                 const double & BOUNDS_Lower,
                                 const double & BOUNDS_Upper,
                                 const int & MAX_ITER_COUNT,
                                 const double & TOLERANCE,
                                 const bool & inIP) {
    // We use NR to approximate the solution.
    // First guess
    double TDewPoint = TDryBulb;  // Calculated value of dew point temperatures, solved for iteratively in degreeF [IP] or degreeC [SI]
    double lnVP = log(VapPres);   // Natural logarithm of partial pressure of water vapor pressure in moist air

    double TDewPoint_iter;        // Value of TDewPoint used in NR calculation
    double lnVP_iter;             // Value of log of vapor water pressure used in NR calculation
    int index = 1;

    do {
        TDewPoint_iter = TDewPoint; // TDewPoint used in NR calculation
        lnVP_iter = log(C_GetSatVapPres(TDewPoint_iter, inIP));

        // Derivative of function, calculated analytically
        double d_lnVP = C_dLnPws(TDewPoint_iter, inIP);

        // New estimate, bounded by domain of validity of eqn. 5 and 6
        TDewPoint = TDewPoint_iter - (lnVP_iter - lnVP) / d_lnVP;
        TDewPoint = std::max(TDewPoint, BOUNDS_Lower);
        TDewPoint = std::min(TDewPoint, BOUNDS_Upper);

        if (index > MAX_ITER_COUNT) {
            stop("Convergence not reached in 'GetTDewPointFromVapPres()'. Stopping.");
        }

        index++;
    } while (std::abs(TDewPoint - TDewPoint_iter) > TOLERANCE);

    return std::min(TDewPoint, TDryBulb);
}

// A wrapper of C_GetTDewPointFromVapPres that takes vector inputs
// [[Rcpp::export]]
NumericVector CV_GetTDewPointFromVapPres(const NumericVector & TDryBulb, // (i) Dry bulb temperature in degreeF [IP] or degreeC [SI]
                                         const NumericVector & VapPres,  // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
                                         const double & BOUNDS_Lower,
                                         const double & BOUNDS_Upper,
                                         const int & MAX_ITER_COUNT,
                                         const double & TOLERANCE,
                                         const bool & inIP) {
    int n = TDryBulb.size();
    NumericVector TDewPoint(n);

    for (int i = 0; i < n; ++i) {
        TDewPoint[i] = C_GetTDewPointFromVapPres(
            TDryBulb[i], VapPres[i], BOUNDS_Lower, BOUNDS_Upper,
            MAX_ITER_COUNT, TOLERANCE, inIP
        );
    }

    return TDewPoint;
}

// Return wet-bulb temperature given dry-bulb temperature, humidity ratio, and pressure.
// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35 solved for Tstar
// (o) Wet bulb temperature in degreeF [IP] or degreeC [SI]
// [[Rcpp::export]]
double C_GetTWetBulbFromHumRatio(const double & TDryBulb,        // (i) Dry bulb temperature in degreeF [IP] or degreeC [SI]
                                 const double & TDewPoint,       // (i) Dew point temperature in degreeF [IP] or degreeC [SI]
                                 const double & BoundedHumRatio, // (i) Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
                                 const double & Pressure,        // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
                                 const double & MIN_HUM_RATIO,
                                 const int & MAX_ITER_COUNT,
                                 const double & TOLERANCE,
                                 const bool & inIP) {
    // Declarations
    double Wstar;
    double TWetBulb, TWetBulbSup, TWetBulbInf;
    int index = 1;

    // Initial guesses
    TWetBulbSup = TDryBulb;
    TWetBulbInf = TDewPoint;
    TWetBulb = (TWetBulbInf + TWetBulbSup) / 2.;

    // Bisection loop
    while ((TWetBulbSup - TWetBulbInf) > TOLERANCE) {
        // Compute humidity ratio at temperature Tstar
        Wstar = C_GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure, MIN_HUM_RATIO, inIP);

        // Get new bounds
        if (Wstar > BoundedHumRatio)
            TWetBulbSup = TWetBulb;
        else
            TWetBulbInf = TWetBulb;

        // New guess of wet bulb temperature
        TWetBulb = (TWetBulbSup+TWetBulbInf) / 2.;

        if (index > MAX_ITER_COUNT) {
            stop("Convergence not reached in 'GetTWetBlbFromHumRatio()'. Stopping.");
        }

        index++;
    }

    return TWetBulb;
}

// A wrapper of C_GetTWetBulbFromHumRatio that takes vector inputs
// [[Rcpp::export]]
NumericVector CV_GetTWetBulbFromHumRatio(const NumericVector & TDryBulb, // (i) Dry bulb temperature in degreeF [IP] or degreeC [SI]
                                         const NumericVector & TDewPoint,// (i) Dew point temperature in degreeF [IP] or degreeC [SI]
                                         const NumericVector & BoundedHumRatio, // (i) Humidity ratio in lb_H2O lb_Air-1 [IP] or kg_H2O kg_Air-1 [SI]
                                         const NumericVector & Pressure,        // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
                                         const double & MIN_HUM_RATIO,
                                         const int & MAX_ITER_COUNT,
                                         const double & TOLERANCE,
                                         const bool & inIP) {
    int n = TDryBulb.size();
    NumericVector TWetBulb(n);

    for (int i = 0; i < n; ++i) {
        TWetBulb[i] = C_GetTWetBulbFromHumRatio(
            TDryBulb[i], TDewPoint[i], BoundedHumRatio[i], Pressure[i],
            MIN_HUM_RATIO, MAX_ITER_COUNT, TOLERANCE, inIP
        );
    }

    return TWetBulb;
}

