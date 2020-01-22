/*
 * PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
 * Copyright (c) 2018-2020 The PsychroLib Contributors for the current library implementation.
 * Copyright (c) 2017 ASHRAE Handbook — Fundamentals for ASHRAE equations and coefficients.
 * Licensed under the MIT License.
*/

using System;

namespace PsychroLib
{
    /// <summary>
    /// Class of functions to enable the calculation of psychrometric properties of moist and dry air.
    /// </summary>
    public class Psychrometrics
    {
        /******************************************************************************************************
         * Global constants
         *****************************************************************************************************/

        /// <summary>
        /// Zero degree Fahrenheit (°F) expressed as degree Rankine (°R).
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 39.
        /// </summary>
        private const double ZERO_FAHRENHEIT_AS_RANKINE = 459.67;

        /// <summary>
        /// Zero degree Celsius (°C) expressed as Kelvin (K).
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 39.
        /// </summary>
        private const double ZERO_CELSIUS_AS_KELVIN = 273.15;

        /// <summary>
        /// Universal gas constant for dry air (IP version) in ft lb_Force lb_DryAir⁻¹ R⁻¹.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1.
        /// </summary>
        private const double R_DA_IP = 53.350;

        /// <summary>
        /// Universal gas constant for dry air (SI version) in J kg_DryAir⁻¹ K⁻¹.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1.
        /// </summary>
        private const double R_DA_SI = 287.042;

        /// <summary>
        /// Invalid value (dimensionless).
        /// </summary>
        private const double INVALID = -99999;

        /// <summary>
        /// Maximum number of iterations before exiting while loops.
        /// </summary>
        private const double MAX_ITER_COUNT = 100;

        /// <summary>
        /// Minimum acceptable humidity ratio used/returned by any functions.
        /// Any value above 0 or below the MIN_HUM_RATIO will be reset to this value.
        /// </summary>
        private const double MIN_HUM_RATIO = 1e-7;

        /// <summary>
        /// Freezing point of water in Fahrenheit.
        /// </summary>
        private const double FREEZING_POINT_WATER_IP = 32.0;

        /// <summary>
        /// Freezing point of water in Celsius.
        /// </summary>
        private const double FREEZING_POINT_WATER_SI = 0.0;

        /// <summary>
        /// Triple point of water in Fahrenheit.
        /// </summary>
        private const double TRIPLE_POINT_WATER_IP = 32.018;

        /// <summary>
        /// Triple point of water in Celsius.
        /// </summary>
        private const double TRIPLE_POINT_WATER_SI = 0.01;

        /// <summary>
        /// Gets or Sets the current system of units for the calculations.
        /// </summary>
        public UnitSystem UnitSystem
        {
            get => _unitSystem;
            set
            {
                _unitSystem = value;
                if (value == UnitSystem.IP)
                    PSYCHROLIB_TOLERANCE = 0.001 * 9.0 / 5.0;
                else
                    PSYCHROLIB_TOLERANCE = 0.001;
            }
        }

        private double PSYCHROLIB_TOLERANCE;
        private UnitSystem _unitSystem;

        /// <summary>
        /// Constructor to create instance with the specified unit system.
        /// </summary>
        /// <param name="unitSystem">System of units to utilize for calculations.</param>
        public Psychrometrics(UnitSystem unitSystem)
        {
            UnitSystem = unitSystem;
        }


        /******************************************************************************************************
         * Conversion between temperature units
         *****************************************************************************************************/

        /// <summary>
        /// Utility function to convert temperature to degree Rankine (°R)
        /// given temperature in degree Fahrenheit (°F).
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
        /// </summary>
        /// <param name="tF">Temperature in Fahrenheit (°F)</param>
        /// <returns>Rankine (°R)</returns>
        public double GetTRankineFromTFahrenheit(double tF)
        {
            return tF + ZERO_FAHRENHEIT_AS_RANKINE; /* exact */
        }

        /// <summary>
        /// Utility function to convert temperature to degree Fahrenheit (°F)
        /// given temperature in degree Rankine (°R).
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
        /// </summary>
        /// <param name="tR">Temperature in Rankine (°R)</param>
        /// <returns>Fahrenheit (°F)</returns>
        public double GetTFahrenheitFromTRankine(double tR)
        {
            return tR - ZERO_FAHRENHEIT_AS_RANKINE; /* exact */
        }

        /// <summary>
        /// Utility function to convert temperature to Kelvin (K)
        /// given temperature in degree Celsius (°C).
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
        /// </summary>
        /// <param name="tC">Temperature in Celsius (°C)</param>
        /// <returns>Rankine (°R)</returns>
        public double GetTKelvinFromTCelsius(double tC)
        {
            return tC + ZERO_CELSIUS_AS_KELVIN; /* exact */
        }

        /// <summary>
        /// Utility function to convert temperature to degree Celsius (°C)
        /// given temperature in Kelvin (K).
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
        /// </summary>
        /// <param name="tK">Temperature in Rankine (°R)</param>
        /// <returns>Celsius (°C)</returns>
        public double GetTCelsiusFromTKelvin(double tK)
        {
            return tK - ZERO_CELSIUS_AS_KELVIN; /* exact */
        }


        /******************************************************************************************************
         * Conversions between dew point, wet bulb, and relative humidity
         *****************************************************************************************************/

        /// <summary>
        /// Return wet-bulb temperature given dry-bulb temperature, dew-point temperature, and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="tDewPoint">Dew point temperature in °F [IP] or °C [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Wet bulb temperature in °F [IP] or °C [SI]</returns>
        public double GetTWetBulbFromTDewPoint(double tDryBulb, double tDewPoint, double pressure)
        {
            if (!(tDewPoint <= tDryBulb))
                throw new InvalidOperationException("Dew point temperature is above dry bulb temperature");

            var humRatio = GetHumRatioFromTDewPoint(tDewPoint, pressure);
            return GetTWetBulbFromHumRatio(tDryBulb, humRatio, pressure);
        }


        /// <summary>
        /// Return wet-bulb temperature given dry-bulb temperature, relative humidity, and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="relHum">Relative humidity [0-1]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Wet bulb temperature in °F [IP] or °C [SI]</returns>
        public double GetTWetBulbFromRelHum(double tDryBulb, double relHum, double pressure)
        {
            if (!(relHum >= 0.0 && relHum <= 1.0))
                throw new InvalidOperationException("Relative humidity is outside range [0,1]");

            var humRatio = GetHumRatioFromRelHum(tDryBulb, relHum, pressure);
            return GetTWetBulbFromHumRatio(tDryBulb, humRatio, pressure);
        }


        /// <summary>
        /// Return relative humidity given dry-bulb temperature and dew-point temperature.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 22
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="tDewPoint">Dew point temperature in °F [IP] or °C [SI]</param>
        /// <returns>Relative humidity [0-1]</returns>
        public double GetRelHumFromTDewPoint(double tDryBulb, double tDewPoint)
        {
            if (!(tDewPoint <= tDryBulb))
                throw new InvalidOperationException("Dew point temperature is above dry bulb temperature");

            var vapPres = GetSatVapPres(tDewPoint);
            var satVapPres = GetSatVapPres(tDryBulb);
            return vapPres / satVapPres;
        }

        /// <summary>
        /// Return relative humidity given dry-bulb temperature, wet bulb temperature and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="tWetBulb">Wet bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Relative humidity [0-1]</returns>
        public double GetRelHumFromTWetBulb(double tDryBulb, double tWetBulb, double pressure)
        {
            if (!(tWetBulb <= tDryBulb))
                throw new InvalidOperationException("Wet bulb temperature is above dry bulb temperature");

            var humRatio = GetHumRatioFromTWetBulb(tDryBulb, tWetBulb, pressure);
            return GetRelHumFromHumRatio(tDryBulb, humRatio, pressure);
        }

        /// <summary>
        /// Return dew-point temperature given dry-bulb temperature and relative humidity.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="relHum">Relative humidity [0-1]</param>
        /// <returns>Dew Point temperature in °F [IP] or °C [SI]</returns>
        public double GetTDewPointFromRelHum(double tDryBulb, double relHum)
        {
            if (!(relHum >= 0.0 && relHum <= 1.0))
                throw new InvalidOperationException("Relative humidity is outside range [0,1]");

            var vapPres = GetVapPresFromRelHum(tDryBulb, relHum);
            return GetTDewPointFromVapPres(tDryBulb, vapPres);
        }

        /// <summary>
        /// Return dew-point temperature given dry-bulb temperature, wet-bulb temperature, and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="tWetBulb">Wet bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Dew Point temperature in °F [IP] or °C [SI]</returns>
        public double GetTDewPointFromTWetBulb(double tDryBulb, double tWetBulb, double pressure)
        {
            if (!(tWetBulb <= tDryBulb))
                throw new InvalidOperationException("Wet bulb temperature is above dry bulb temperature");

            var humRatio = GetHumRatioFromTWetBulb(tDryBulb, tWetBulb, pressure);
            return GetTDewPointFromHumRatio(tDryBulb, humRatio, pressure);
        }


        /******************************************************************************************************
         * Conversions between dew point, or relative humidity and vapor pressure
         *****************************************************************************************************/

        /// <summary>
        /// Return partial pressure of water vapor as a function of relative humidity and temperature.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="relHum">Relative humidity [0-1]</param>
        /// <returns>Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]</returns>
        public double GetVapPresFromRelHum(double tDryBulb, double relHum)
        {
            if (!(relHum >= 0.0 && relHum <= 1.0))
                throw new InvalidOperationException("Relative humidity is outside range [0,1]");

            return relHum * GetSatVapPres(tDryBulb);
        }

        /// <summary>
        /// Return relative humidity given dry-bulb temperature and vapor pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="vapPres">Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]</param>
        /// <returns>Relative humidity [0-1]</returns>
        public double GetRelHumFromVapPres(double tDryBulb, double vapPres)
        {
            if (!(vapPres >= 0.0))
                throw new InvalidOperationException("Partial pressure of water vapor in moist air is negative");

            return vapPres / GetSatVapPres(tDryBulb);
        }

        /// <summary>
        /// Helper function returning the derivative of the natural log of the saturation vapor pressure
        /// as a function of dry-bulb temperature.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 &amp; 6
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <returns>Derivative of natural log of vapor pressure of saturated air in Psi [IP] or Pa [SI]</returns>
        private double dLnPws_(double tDryBulb)
        {
            double dLnPws, T;

            if (UnitSystem == UnitSystem.IP)
            {
                T = GetTRankineFromTFahrenheit(tDryBulb);

                if (tDryBulb <= TRIPLE_POINT_WATER_IP)
                    dLnPws = 1.0214165E+04 / Math.Pow(T, 2) - 5.3765794E-03 + 2 * 1.9202377E-07 * T
                             + 3 * 3.5575832E-10 * Math.Pow(T, 2) - 4 * 9.0344688E-14 * Math.Pow(T, 3) 
                             + 4.1635019 / T;
                else
                    dLnPws = 1.0440397E+04 / Math.Pow(T, 2) - 2.7022355E-02 + 2 * 1.2890360E-05 * T
                             - 3 * 2.4780681E-09 * Math.Pow(T, 2) + 6.5459673 / T;
            }
            else
            {
                T = GetTKelvinFromTCelsius(tDryBulb);

                if (tDryBulb <= TRIPLE_POINT_WATER_SI)
                    dLnPws = 5.6745359E+03 / Math.Pow(T, 2) - 9.677843E-03 + 2 * 6.2215701E-07 * T
                             + 3 * 2.0747825E-09 * Math.Pow(T, 2) - 4 * 9.484024E-13 * Math.Pow(T, 3) 
                             + 4.1635019 / T;
                else
                    dLnPws = 5.8002206E+03 / Math.Pow(T, 2) - 4.8640239E-02 + 2 * 4.1764768E-05 * T
                             - 3 * 1.4452093E-08 * Math.Pow(T, 2) + 6.5459673 / T;
            }

            return dLnPws;
        }

        /// <summary>
        /// Return dew-point temperature given dry-bulb temperature and vapor pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 and 6
        /// Notes: the dew point temperature is solved by inverting the equation giving water vapor pressure
        /// at saturation from temperature rather than using the regressions provided
        /// by ASHRAE (eqn. 37 and 38) which are much less accurate and have a
        /// narrower range of validity.
        /// The Newton-Raphson (NR) method is used on the logarithm of water vapour
        /// pressure as a function of temperature, which is a very smooth function
        /// Convergence is usually achieved in 3 to 5 iterations.
        /// tDryBulb is not really needed here, just used for convenience.
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="vapPres">Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]</param>
        /// <returns>(o) Dew Point temperature in °F [IP] or °C [SI]</returns>
        public double GetTDewPointFromVapPres(double tDryBulb, double vapPres)
        {
            // Bounds function of the system of units

            var bounds = UnitSystem == UnitSystem.IP
                ? new[] {-148.0, 392.0}
                : new[] {-100.0, 200.0};

            // Bounds outside which a solution cannot be found
            if (vapPres < GetSatVapPres(bounds[0]) || vapPres > GetSatVapPres(bounds[1]))
                throw new InvalidOperationException(
                    "Partial pressure of water vapor is outside range of validity of equations");

            // We use NR to approximate the solution.
            // First guess
            var tDewPoint =
                tDryBulb; // Calculated value of dew point temperatures, solved for iteratively in °F [IP] or °C [SI]
            var lnVP = Math.Log(vapPres); // Natural logarithm of partial pressure of water vapor pressure in moist air

            double tDewPoint_iter; // Value of tDewPoint used in NR calculation
            double lnVP_iter; // Value of log of vapor water pressure used in NR calculation
            var index = 1;
            do
            {
                // Current point
                tDewPoint_iter = tDewPoint;
                lnVP_iter = Math.Log(GetSatVapPres(tDewPoint_iter));

                // Derivative of function, calculated analytically
                var d_lnVP = dLnPws_(tDewPoint_iter);

                // New estimate, bounded by domain of validity of eqn. 5 and 6
                tDewPoint = tDewPoint_iter - (lnVP_iter - lnVP) / d_lnVP;
                tDewPoint = Math.Max(tDewPoint, bounds[0]);
                tDewPoint = Math.Min(tDewPoint, bounds[1]);

                if (index > MAX_ITER_COUNT)
                    throw new InvalidOperationException(
                        "Convergence not reached in GetTDewPointFromVapPres. Stopping.");

                index++;
            } while (Math.Abs(tDewPoint - tDewPoint_iter) > PSYCHROLIB_TOLERANCE);

            return Math.Min(tDewPoint, tDryBulb);
        }

        /// <summary>
        /// Return vapor pressure given dew point temperature.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 36
        /// </summary>
        /// <param name="tDewPoint">Dew point temperature in °F [IP] or °C [SI]</param>
        /// <returns>Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]</returns>
        public double GetVapPresFromTDewPoint(double tDewPoint)
        {
            return GetSatVapPres(tDewPoint);
        }


        /******************************************************************************************************
         * Conversions from wet-bulb temperature, dew-point temperature, or relative humidity to humidity ratio
         *****************************************************************************************************/

        /// <summary>
        /// Return wet-bulb temperature given dry-bulb temperature, humidity ratio, and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35 solved for Tstar
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="humRatio">Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Wet bulb temperature in °F [IP] or °C [SI]</returns>
        public double GetTWetBulbFromHumRatio(double tDryBulb, double humRatio, double pressure)
        {
            // Declarations
            double Wstar;
            double tDewPoint, tWetBulb, tWetBulbSup, tWetBulbInf, boundedHumRatio;
            var index = 1;

            if (!(humRatio >= 0.0))
                throw new InvalidOperationException("Humidity ratio is negative");
            boundedHumRatio = Math.Max(humRatio, MIN_HUM_RATIO);

            tDewPoint = GetTDewPointFromHumRatio(tDryBulb, boundedHumRatio, pressure);

            // Initial guesses
            tWetBulbSup = tDryBulb;
            tWetBulbInf = tDewPoint;
            tWetBulb = (tWetBulbInf + tWetBulbSup) / 2.0;

            // Bisection loop
            while ((tWetBulbSup - tWetBulbInf) > PSYCHROLIB_TOLERANCE)
            {
                // Compute humidity ratio at temperature Tstar
                Wstar = GetHumRatioFromTWetBulb(tDryBulb, tWetBulb, pressure);

                // Get new bounds
                if (Wstar > boundedHumRatio)
                    tWetBulbSup = tWetBulb;
                else
                    tWetBulbInf = tWetBulb;

                // New guess of wet bulb temperature
                tWetBulb = (tWetBulbSup + tWetBulbInf) / 2.0;

                if (index > MAX_ITER_COUNT)
                    throw new InvalidOperationException(
                        "Convergence not reached in GetTWetBulbFromHumRatio. Stopping.");

                index++;
            }

            return tWetBulb;
        }

        /// <summary>
        /// Return humidity ratio given dry-bulb temperature, wet-bulb temperature, and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="tWetBulb">Wet bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</returns>
        public double GetHumRatioFromTWetBulb(double tDryBulb, double tWetBulb, double pressure)
        {
            double wsstar;
            double humRatio = INVALID;

            if (!(tWetBulb <= tDryBulb))
                throw new InvalidOperationException("Wet bulb temperature is above dry bulb temperature");

            wsstar = GetSatHumRatio(tWetBulb, pressure);

            if (UnitSystem == UnitSystem.IP)
            {
                if (tWetBulb >= FREEZING_POINT_WATER_IP)
                    humRatio = ((1093.0 - 0.556 * tWetBulb) * wsstar - 0.240 * (tDryBulb - tWetBulb))
                               / (1093.0 + 0.444 * tDryBulb - tWetBulb);
                else
                    humRatio = ((1220.0 - 0.04 * tWetBulb) * wsstar - 0.240 * (tDryBulb - tWetBulb))
                               / (1220.0 + 0.444 * tDryBulb - 0.48 * tWetBulb);
            }
            else
            {
                if (tWetBulb >= FREEZING_POINT_WATER_SI)
                    humRatio = ((2501.0 - 2.326 * tWetBulb) * wsstar - 1.006 * (tDryBulb - tWetBulb))
                               / (2501.0 + 1.86 * tDryBulb - 4.186 * tWetBulb);
                else
                    humRatio = ((2830.0 - 0.24 * tWetBulb) * wsstar - 1.006 * (tDryBulb - tWetBulb))
                               / (2830.0 + 1.86 * tDryBulb - 2.1 * tWetBulb);
            }

            // Validity check.
            return Math.Max(humRatio, MIN_HUM_RATIO);
        }


        /// <summary>
        /// Return humidity ratio given dry-bulb temperature, relative humidity, and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="relHum">Relative humidity [0-1]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</returns>
        public double GetHumRatioFromRelHum(double tDryBulb, double relHum, double pressure)
        {
            if (!(relHum >= 0.0 && relHum <= 1.0))
                throw new InvalidOperationException("Relative humidity is outside range [0,1]");

            var vapPres = GetVapPresFromRelHum(tDryBulb, relHum);
            return GetHumRatioFromVapPres(vapPres, pressure);
        }


        /// <summary>
        /// Return relative humidity given dry-bulb temperature, humidity ratio, and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="humRatio">Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Relative humidity [0-1]</returns>
        public double GetRelHumFromHumRatio(double tDryBulb, double humRatio, double pressure)
        {
            if (!(humRatio >= 0.0))
                throw new InvalidOperationException("Humidity ratio is negative");

            var vapPres = GetVapPresFromHumRatio(humRatio, pressure);
            return GetRelHumFromVapPres(tDryBulb, vapPres);
        }

        /// <summary>
        /// Return humidity ratio given dew-point temperature and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
        /// </summary>
        /// <param name="tDewPoint">Dew point temperature in °F [IP] or °C [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</returns>
        public double GetHumRatioFromTDewPoint(double tDewPoint, double pressure)
        {
            var vapPres = GetSatVapPres(tDewPoint);
            return GetHumRatioFromVapPres(vapPres, pressure);
        }

        /// <summary>
        /// Return dew-point temperature given dry-bulb temperature, humidity ratio, and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="humRatio">Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Dew Point temperature in °F [IP] or °C [SI]</returns>
        public double GetTDewPointFromHumRatio(double tDryBulb, double humRatio, double pressure)
        {
            if (!(humRatio >= 0.0))
                throw new InvalidOperationException("Humidity ratio is negative");

            var vapPres = GetVapPresFromHumRatio(humRatio, pressure);
            return GetTDewPointFromVapPres(tDryBulb, vapPres);
        }


        /******************************************************************************************************
         * Conversions between humidity ratio and vapor pressure
         *****************************************************************************************************/

        /// <summary>
        /// Return humidity ratio given water vapor pressure and atmospheric pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20
        /// </summary>
        /// <param name="vapPres">Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</returns>
        public double GetHumRatioFromVapPres(double vapPres, double pressure)
        {
            if (!(vapPres >= 0.0))
                throw new InvalidOperationException("Partial pressure of water vapor in moist air is negative");

            var humRatio = 0.621945 * vapPres / (pressure - vapPres);

            // Validity check.
            return Math.Max(humRatio, MIN_HUM_RATIO);
        }


        /// <summary>
        /// Return vapor pressure given humidity ratio and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20 solved for pw
        /// </summary>
        /// <param name="humRatio">Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]</returns>
        public double GetVapPresFromHumRatio(double humRatio, double pressure)
        {
            if (!(humRatio >= 0.0))
                throw new InvalidOperationException("Humidity ratio is negative");
            var boundedHumRatio = Math.Max(humRatio, MIN_HUM_RATIO);

            var vapPres = pressure * boundedHumRatio / (0.621945 + boundedHumRatio);
            return vapPres;
        }


        /******************************************************************************************************
         * Conversions between humidity ratio and specific humidity
         *****************************************************************************************************/

        /// <summary>
        /// Return the specific humidity from humidity ratio (aka mixing ratio)
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b
        /// </summary>
        /// <param name="humRatio">Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</param>
        /// <returns>Specific humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</returns>
        public double GetSpecificHumFromHumRatio(double humRatio)
        {
            if (!(humRatio >= 0.0))
                throw new InvalidOperationException("Humidity ratio is negative");
            var boundedHumRatio = Math.Max(humRatio, MIN_HUM_RATIO);

            return boundedHumRatio / (1.0 + boundedHumRatio);
        }


        /// <summary>
        /// Return the humidity ratio (aka mixing ratio) from specific humidity
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b (solved for humidity ratio)
        /// </summary>
        /// <param name="specificHum"></param>
        /// <returns>Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]</returns>
        public double GetHumRatioFromSpecificHum(double specificHum)
        {
            if (!(specificHum >= 0.0 && specificHum < 1.0))
                throw new InvalidOperationException("Specific humidity is outside range [0, 1]");

            var humRatio = specificHum / (1.0 - specificHum);

            // Validity check
            return Math.Max(humRatio, MIN_HUM_RATIO);
        }


        /******************************************************************************************************
         * Dry Air Calculations
         *****************************************************************************************************/

        /// <summary>
        /// Return dry-air enthalpy given dry-bulb temperature.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 28
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <returns>Dry air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]</returns>
        public double GetDryAirEnthalpy(double tDryBulb)
        {
            if (UnitSystem == UnitSystem.IP)
                return 0.240 * tDryBulb;

            return 1006.0 * tDryBulb;
        }


        /// <summary>
        /// Return dry-air density given dry-bulb temperature and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
        /// Notes: eqn 14 for the perfect gas relationship for dry air.
        /// Eqn 1 for the universal gas constant.
        /// The factor 144 in IP is for the conversion of Psi = lb in⁻² to lb ft⁻².
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Dry air density in lb ft⁻³ [IP] or kg m⁻³ [SI]</returns>
        public double GetDryAirDensity(double tDryBulb, double pressure)
        {
            if (UnitSystem == UnitSystem.IP)
                return (144.0 * pressure) / R_DA_IP / GetTRankineFromTFahrenheit(tDryBulb);

            return pressure / R_DA_SI / GetTKelvinFromTCelsius(tDryBulb);
        }


        /// <summary>
        /// Return dry-air volume given dry-bulb temperature and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1.
        /// Notes: eqn 14 for the perfect gas relationship for dry air.
        /// Eqn 1 for the universal gas constant.
        /// The factor 144 in IP is for the conversion of Psi = lb in⁻² to lb ft⁻².
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Dry air volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]</returns>
        public double GetDryAirVolume(double tDryBulb, double pressure)
        {
            if (UnitSystem == UnitSystem.IP)
                return R_DA_IP * GetTRankineFromTFahrenheit(tDryBulb) / (144.0 * pressure);

            return R_DA_SI * GetTKelvinFromTCelsius(tDryBulb) / pressure;
        }


        /// <summary>
        /// Return dry bulb temperature from enthalpy and humidity ratio.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30.
        /// Notes: based on the `GetMoistAirEnthalpy` function, rearranged for temperature.
        /// </summary>
        /// <param name="moistAirEnthalpy">Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹</param>
        /// <param name="humRatio">Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</param>
        /// <returns>Dry-bulb temperature in °F [IP] or °C [SI]</returns>
        public double GetTDryBulbFromEnthalpyAndHumRatio(double moistAirEnthalpy, double humRatio)
        {
            if (!(humRatio >= 0.0))
                throw new InvalidOperationException("Humidity ratio is negative");
            var boundedHumRatio = Math.Max(humRatio, MIN_HUM_RATIO);

            if (UnitSystem == UnitSystem.IP)
                return (moistAirEnthalpy - 1061.0 * boundedHumRatio) / (0.240 + 0.444 * boundedHumRatio);

            return (moistAirEnthalpy / 1000.0 - 2501.0 * boundedHumRatio) / (1.006 + 1.86 * boundedHumRatio);
        }


        /// <summary>
        /// Return humidity ratio from enthalpy and dry-bulb temperature.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30.
        /// Notes: based on the `GetMoistAirEnthalpy` function, rearranged for humidity ratio.
        /// </summary>
        /// <param name="moistAirEnthalpy">Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹</param>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <returns>Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻</returns>
        public double GetHumRatioFromEnthalpyAndTDryBulb(double moistAirEnthalpy, double tDryBulb)
        {
            {
                double humRatio;
                if (UnitSystem == UnitSystem.IP)
                    humRatio = (moistAirEnthalpy - 0.240 * tDryBulb) / (1061.0 + 0.444 * tDryBulb);
                else
                    humRatio = (moistAirEnthalpy / 1000.0 - 1.006 * tDryBulb) / (2501.0 + 1.86 * tDryBulb);

                // Validity check.
                return Math.Max(humRatio, MIN_HUM_RATIO);
            }
        }


        /******************************************************************************************************
         * Saturated Air Calculations
         *****************************************************************************************************/

        /// <summary>
        /// Return saturation vapor pressure given dry-bulb temperature.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 &amp; 6
        /// Important note: the ASHRAE formulae are defined above and below the freezing point but have
        /// a discontinuity at the freezing point. This is a small inaccuracy on ASHRAE's part: the formulae
        /// should be defined above and below the triple point of water (not the feezing point) in which case
        /// the discontinuity vanishes. It is essential to use the triple point of water otherwise function
        /// GetTDewPointFromVapPres, which inverts the present function, does not converge properly around
        /// the freezing point.
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <returns>Vapor pressure of saturated air in Psi [IP] or Pa [SI]</returns>
        public double GetSatVapPres(double tDryBulb)
        {
            double lnPws;

            if (UnitSystem == UnitSystem.IP)
            {
                if (!(tDryBulb >= -148.0 && tDryBulb <= 392.0))
                    throw new InvalidOperationException("Dry bulb temperature is outside range [-148, 392]");

                var T = GetTRankineFromTFahrenheit(tDryBulb);
                if (tDryBulb <= TRIPLE_POINT_WATER_IP)
                    lnPws = (-1.0214165E+04 / T - 4.8932428 - 5.3765794E-03 * T + 1.9202377E-07 * T * T
                                                                                + 3.5575832E-10 * Math.Pow(T, 3) -
                             9.0344688E-14 * Math.Pow(T, 4) + 4.1635019 * Math.Log(T));
                else
                    lnPws = -1.0440397E+04 / T - 1.1294650E+01 - 2.7022355E-02 * T + 1.2890360E-05 * T * T
                            - 2.4780681E-09 * Math.Pow(T, 3) + 6.5459673 * Math.Log(T);
            }
            else
            {
                if (!(tDryBulb >= -100.0 && tDryBulb <= 200.0))
                    throw new InvalidOperationException("Dry bulb temperature is outside range [-100, 200]");

                var T = GetTKelvinFromTCelsius(tDryBulb);
                if (tDryBulb <= TRIPLE_POINT_WATER_SI)
                    lnPws = -5.6745359E+03 / T + 6.3925247 - 9.677843E-03 * T + 6.2215701E-07 * T * T
                                                                              + 2.0747825E-09 * Math.Pow(T, 3) -
                            9.484024E-13 * Math.Pow(T, 4) + 4.1635019 * Math.Log(T);
                else
                    lnPws = -5.8002206E+03 / T + 1.3914993 - 4.8640239E-02 * T + 4.1764768E-05 * T * T
                            - 1.4452093E-08 * Math.Pow(T, 3) + 6.5459673 * Math.Log(T);
            }

            return Math.Exp(lnPws);
        }


        /// <summary>
        /// Return humidity ratio of saturated air given dry-bulb temperature and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36, solved for W
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Humidity ratio of saturated air in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</returns>
        public double GetSatHumRatio(double tDryBulb, double pressure)
        {
            var satVaporPres = GetSatVapPres(tDryBulb);
            var satHumRatio = 0.621945 * satVaporPres / (pressure - satVaporPres);

            // Validity check.
            return Math.Max(satHumRatio, MIN_HUM_RATIO);
        }

        /// <summary>
        /// Return saturated air enthalpy given dry-bulb temperature and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Saturated air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]</returns>
        public double GetSatAirEnthalpy(double tDryBulb, double pressure)
        {
            return GetMoistAirEnthalpy(tDryBulb, GetSatHumRatio(tDryBulb, pressure));
        }


        /******************************************************************************************************
         * Moist Air Calculations
         *****************************************************************************************************/

        /// <summary>
        /// Return Vapor pressure deficit given dry-bulb temperature, humidity ratio, and pressure.
        /// Reference: see Oke (1987) eqn. 2.13a
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="humRatio">Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Vapor pressure deficit in Psi [IP] or Pa [SI]</returns>
        public double GetVaporPressureDeficit(double tDryBulb, double humRatio, double pressure)
        {
            if (!(humRatio >= 0.0))
                throw new InvalidOperationException("Humidity ratio is negative");

            var relHum = GetRelHumFromHumRatio(tDryBulb, humRatio, pressure);
            return GetSatVapPres(tDryBulb) * (1.0 - relHum);
        }


        /// <summary>
        /// Return the degree of saturation (i.e humidity ratio of the air / humidity ratio of the air at saturation
        /// at the same temperature and pressure) given dry-bulb temperature, humidity ratio, and atmospheric pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2009) ch. 1 eqn. 12
        /// Notes: the definition is absent from the 2017 Handbook
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="humRatio">Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Degree of saturation (unitless)</returns>
        public double GetDegreeOfSaturation(double tDryBulb, double humRatio, double pressure)
        {
            if (!(humRatio >= 0.0))
                throw new InvalidOperationException("Humidity ratio is negative");
            var boundedHumRatio = Math.Max(humRatio, MIN_HUM_RATIO);

            return boundedHumRatio / GetSatHumRatio(tDryBulb, pressure);
        }

        /// <summary>
        /// Return moist air enthalpy given dry-bulb temperature and humidity ratio.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 30
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="humRatio">Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</param>
        /// <returns>Moist Air Enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]</returns>
        public double GetMoistAirEnthalpy(double tDryBulb, double humRatio)
        {
            if (!(humRatio >= 0.0))
                throw new InvalidOperationException("Humidity ratio is negative");

            var boundedHumRatio = Math.Max(humRatio, MIN_HUM_RATIO);

            if (UnitSystem == UnitSystem.IP)
                return 0.240 * tDryBulb + boundedHumRatio * (1061.0 + 0.444 * tDryBulb);

            return (1.006 * tDryBulb + boundedHumRatio * (2501.0 + 1.86 * tDryBulb)) * 1000.0;
        }


        /// <summary>
        /// Return moist air specific volume given dry-bulb temperature, humidity ratio, and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 26
        /// Notes: in IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26.
        /// The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="humRatio">Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Specific Volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]</returns>
        public double GetMoistAirVolume(double tDryBulb, double humRatio, double pressure)
        {
            if (!(humRatio >= 0.0))
                throw new InvalidOperationException("Humidity ratio is negative");
            var boundedHumRatio = Math.Max(humRatio, MIN_HUM_RATIO);

            if (UnitSystem == UnitSystem.IP)
                return R_DA_IP * GetTRankineFromTFahrenheit(tDryBulb) * (1.0 + 1.607858 * boundedHumRatio) /
                       (144.0 * pressure);

            return R_DA_SI * GetTKelvinFromTCelsius(tDryBulb) * (1.0 + 1.607858 * boundedHumRatio) / pressure;
        }


        /// <summary>
        /// Return dry-bulb temperature given moist air specific volume, humidity ratio, and pressure.
        /// Reference:
        /// ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26
        /// Notes:
        /// In IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26
        /// The factor 144 is for the conversion of Psi = lb in⁻² to lb ft⁻².
        /// Based on the `GetMoistAirVolume` function, rearranged for dry-bulb temperature.
        /// </summary>
        /// <param name="MoistAirVolume">Specific volume of moist air in ft³ lb⁻¹ of dry air [IP] or in m³ kg⁻¹ of dry air [SI]</param>
        /// <param name="humRatio">Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Dry-bulb temperature in °F [IP] or °C [SI]</returns>
        public double GetTDryBulbFromMoistAirVolumeAndHumRatio(double MoistAirVolume, double humRatio, double pressure)
        {
            if (!(humRatio >= 0.0))
                throw new InvalidOperationException("Humidity ratio is negative");
            var boundedHumRatio = Math.Max(humRatio, MIN_HUM_RATIO);

            if (UnitSystem == UnitSystem.IP)
                return  GetTFahrenheitFromTRankine(MoistAirVolume * (144 * pressure) / (R_DA_IP * (1 + 1.607858 * boundedHumRatio)));

            return GetTCelsiusFromTKelvin(MoistAirVolume * pressure / (R_DA_SI * (1 + 1.607858 * boundedHumRatio)));
        }


        /// <summary>
        /// Return moist air density given humidity ratio, dry bulb temperature, and pressure.
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 11
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="humRatio">Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Moist air density in lb ft⁻³ [IP] or kg m⁻³ [SI]</returns>
        public double GetMoistAirDensity(double tDryBulb, double humRatio, double pressure)
        {
            if (!(humRatio >= 0.0))
                throw new InvalidOperationException("Humidity ratio is negative");

            var boundedHumRatio = Math.Max(humRatio, MIN_HUM_RATIO);

            return (1.0 + boundedHumRatio) / GetMoistAirVolume(tDryBulb, boundedHumRatio, pressure);
        }


        /******************************************************************************************************
         * Standard atmosphere
         *****************************************************************************************************/

        /// <summary>
        /// Return standard atmosphere barometric pressure, given the elevation (altitude).
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 3
        /// </summary>
        /// <param name="altitude">altitude in ft [IP] or m [SI]</param>
        /// <returns>Standard atmosphere barometric pressure in Psi [IP] or Pa [SI]</returns>
        public double GetStandardAtmPressure(double altitude)
        {
            if (UnitSystem == UnitSystem.IP)
                return 14.696 * Math.Pow(1.0 - 6.8754e-06 * altitude, 5.2559);

            return 101325.0 * Math.Pow(1.0 - 2.25577e-05 * altitude, 5.2559);
        }


        /// <summary>
        /// Return standard atmosphere temperature, given the elevation (altitude).
        /// Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 4
        /// </summary>
        /// <param name="altitude">altitude in ft [IP] or m [SI]</param>
        /// <returns> Standard atmosphere dry bulb temperature in °F [IP] or °C [SI]</returns>
        public double GetStandardAtmTemperature(double altitude)
        {
            if (UnitSystem == UnitSystem.IP)
                return 59.0 - 0.00356620 * altitude;

            return 15.0 - 0.0065 * altitude;
        }

        /// <summary>
        /// Return sea level pressure given dry-bulb temperature, altitude above sea level and pressure.
        /// Reference: Hess SL, Introduction to theoretical meteorology, Holt Rinehart and Winston, NY 1959,
        /// ch. 6.5; Stull RB, Meteorology for scientists and engineers, 2nd edition,
        /// Brooks/Cole 2000, ch. 1.
        /// Notes: the standard procedure for the US is to use for tDryBulb the average
        /// of the current station temperature and the station temperature from 12 hours ago.
        /// </summary>
        /// <param name="stnPressure">Observed station pressure in Psi [IP] or Pa [SI]</param>
        /// <param name="altitude">Altitude above sea level in ft [IP] or m [SI]</param>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <returns>Sea level barometric pressure in Psi [IP] or Pa [SI]</returns>
        public double GetSeaLevelPressure(double stnPressure, double altitude, double tDryBulb)
        {
            double h;
            if (UnitSystem == UnitSystem.IP)
            {
                // Calculate average temperature in column of air, assuming a lapse rate
                // of 3.6 °F/1000ft
                var tColumn = tDryBulb + 0.0036 * altitude / 2.0;

                // Determine the scale height
                h = 53.351 * GetTRankineFromTFahrenheit(tColumn);
            }
            else
            {
                // Calculate average temperature in column of air, assuming a lapse rate
                // of 6.5 °C/km
                var tColumn = tDryBulb + 0.0065 * altitude / 2.0;

                // Determine the scale height
                h = 287.055 * GetTKelvinFromTCelsius(tColumn) / 9.807;
            }

            // Calculate the sea level pressure
            var seaLevelPressure = stnPressure * Math.Exp(altitude / h);
            return seaLevelPressure;
        }


        /// <summary>
        /// Return station pressure from sea level pressure
        /// Reference: see 'GetSeaLevelPressure'
        /// Notes: this function is just the inverse of 'GetSeaLevelPressure'.
        /// </summary>
        /// <param name="seaLevelPressure">Sea level barometric pressure in Psi [IP] or Pa [SI]</param>
        /// <param name="altitude">Altitude above sea level in ft [IP] or m [SI]</param>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <returns>Station pressure in Psi [IP] or Pa [SI]</returns>
        public double GetStationPressure(double seaLevelPressure, double altitude, double tDryBulb)
        {
            return seaLevelPressure / GetSeaLevelPressure(1.0, altitude, tDryBulb);
        }


        /******************************************************************************************************
         * Functions to set all psychrometric values
         *****************************************************************************************************/

        /// <summary>
        /// Utility function to calculate humidity ratio, dew-point temperature, relative humidity,
        /// vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
        /// dry-bulb temperature, wet-bulb temperature, and pressure.
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="tWetBulb">Wet bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Calculated values.</returns>
        public PsychrometricValue CalcPsychrometricsFromTWetBulb(double tDryBulb, double tWetBulb, double pressure)
        {
            var value = new PsychrometricValue
            {
                TDryBulb = tDryBulb,
                TWetBulb = tWetBulb,
                Pressure = pressure
            };

            value.HumRatio = GetHumRatioFromTWetBulb(tDryBulb, tWetBulb, pressure);
            value.TDewPoint = GetTDewPointFromHumRatio(tDryBulb, value.HumRatio, pressure);
            value.RelHum = GetRelHumFromHumRatio(tDryBulb, value.HumRatio, pressure);
            value.VapPres = GetVapPresFromHumRatio(value.HumRatio, pressure);
            value.MoistAirEnthalpy = GetMoistAirEnthalpy(tDryBulb, value.HumRatio);
            value.MoistAirVolume = GetMoistAirVolume(tDryBulb, value.HumRatio, pressure);
            value.DegreeOfSaturation = GetDegreeOfSaturation(tDryBulb, value.HumRatio, pressure);

            return value;
        }


        /// <summary>
        /// Utility function to calculate humidity ratio, wet-bulb temperature, relative humidity,
        /// vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
        /// dry-bulb temperature, dew-point temperature, and pressure.
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="tDewPoint">Dew point temperature in °F [IP] or °C [SI]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Calculated values.</returns>
        public PsychrometricValue CalcPsychrometricsFromTDewPoint(double tDryBulb, double tDewPoint, double pressure)
        {
            var value = new PsychrometricValue
            {
                TDryBulb = tDryBulb,
                TDewPoint = tDewPoint,
                Pressure = pressure
            };

            value.HumRatio = GetHumRatioFromTDewPoint(tDewPoint, pressure);
            value.TWetBulb = GetTWetBulbFromHumRatio(tDryBulb, value.HumRatio, pressure);
            value.RelHum = GetRelHumFromHumRatio(tDryBulb, value.HumRatio, pressure);
            value.VapPres = GetVapPresFromHumRatio(value.HumRatio, pressure);
            value.MoistAirEnthalpy = GetMoistAirEnthalpy(tDryBulb, value.HumRatio);
            value.MoistAirVolume = GetMoistAirVolume(tDryBulb, value.HumRatio, pressure);
            value.DegreeOfSaturation = GetDegreeOfSaturation(tDryBulb, value.HumRatio, pressure);

            return value;
        }


        /// <summary>
        /// Utility function to calculate humidity ratio, wet-bulb temperature, dew-point temperature,
        /// vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
        /// dry-bulb temperature, relative humidity and pressure.
        /// </summary>
        /// <param name="tDryBulb">Dry bulb temperature in °F [IP] or °C [SI]</param>
        /// <param name="relHum">Relative humidity [0-1]</param>
        /// <param name="pressure">Atmospheric pressure in Psi [IP] or Pa [SI]</param>
        /// <returns>Calculated values.</returns>
        public PsychrometricValue CalcPsychrometricsFromRelHum(double tDryBulb, double relHum, double pressure)
        {
            var value = new PsychrometricValue
            {
                TDryBulb = tDryBulb,
                RelHum = relHum,
                Pressure = pressure
            };

            value.HumRatio = GetHumRatioFromRelHum(tDryBulb, relHum, pressure);
            value.TWetBulb = GetTWetBulbFromHumRatio(tDryBulb, value.HumRatio, pressure);
            value.TDewPoint = GetTDewPointFromHumRatio(tDryBulb, value.HumRatio, pressure);
            value.VapPres = GetVapPresFromHumRatio(value.HumRatio, pressure);
            value.MoistAirEnthalpy = GetMoistAirEnthalpy(tDryBulb, value.HumRatio);
            value.MoistAirVolume = GetMoistAirVolume(tDryBulb, value.HumRatio, pressure);
            value.DegreeOfSaturation = GetDegreeOfSaturation(tDryBulb, value.HumRatio, pressure);

            return value;
        }
    }

    /// <summary>
    /// Contains output results of a Psychrometric calculation.
    /// </summary>
    public class PsychrometricValue
    {
        /// <summary>
        /// Dry bulb temperature in °F [IP] or °C [SI]
        /// </summary>
        public double TDryBulb { get; set; }

        /// <summary>
        /// Wet bulb temperature in °F [IP] or °C [SI]
        /// </summary>
        public double TWetBulb { get; set; }

        /// <summary>
        /// Atmospheric pressure in Psi [IP] or Pa [SI]
        /// </summary>
        public double Pressure { get; set; }

        /// <summary>
        /// Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
        /// </summary>
        public double HumRatio { get; set; }

        /// <summary>
        /// Dew point temperature in °F [IP] or °C [SI]
        /// </summary>
        public double TDewPoint { get; set; }

        /// <summary>
        /// Relative humidity [0-1]
        /// </summary>
        public double RelHum { get; set; }

        /// <summary>
        /// Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
        /// </summary>
        public double VapPres { get; set; }

        /// <summary>
        /// Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
        /// </summary>
        public double MoistAirEnthalpy { get; set; }

        /// <summary>
        /// Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
        /// </summary>
        public double MoistAirVolume { get; set; }

        /// <summary>
        /// Degree of saturation [unitless]
        /// </summary>
        public double DegreeOfSaturation { get; set; }
    }

    /// <summary>
    /// Standard unit systems
    /// </summary>
    public enum UnitSystem
    {
        /// <summary>
        /// Imperial Units
        /// </summary>
        IP = 1,

        /// <summary>
        /// Metric System Units
        /// </summary>
        SI = 2
    }
}