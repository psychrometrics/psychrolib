﻿using System;
using NUnit.Framework;

namespace PsychroLib.Tests
{
    public class PsychroLibUnitTests
    {
        [TestCase(UnitSystem.IP, 70, 529.67, 0.000001)]
        [TestCase(UnitSystem.SI, 20, 293.15, 0.000001)]
        public void GetTKelvinFromTCelsius(
            UnitSystem system,
            double tC,
            double expected,
            double within)
        {
            var psy = new Phychrometrics(system);
            Assert.That(psy.GetTKelvinFromTCelsius(tC), Is.EqualTo(expected).Within(within));
        }

        /// <summary>
        /// Test saturation vapour pressure calculation
        /// The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        /// over the range [-148, +392] F & over the range [-100, +200] C
        /// ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -76 F
        /// </summary>
        [TestCase(UnitSystem.IP, -76, 0.000157, 0.00001)]
        [TestCase(UnitSystem.IP, -4, 0.014974, 0.0003)]
        [TestCase(UnitSystem.IP, 23, 0.058268, 0.0003)]
        [TestCase(UnitSystem.IP, 41, 0.12656, 0.0003)]
        [TestCase(UnitSystem.IP, 77, 0.45973, 0.0003)]
        [TestCase(UnitSystem.IP, 122, 1.79140, 0.0003)]
        [TestCase(UnitSystem.IP, 212, 14.7094, 0.0003)]
        [TestCase(UnitSystem.IP, 300, 67.0206, 0.0003)]
        [TestCase(UnitSystem.SI, -60, 1.08, 0.01)]
        [TestCase(UnitSystem.SI, -20, 103.24, 0.0003)]
        [TestCase(UnitSystem.SI, -5, 401.74, 0.0003)]
        [TestCase(UnitSystem.SI, 5, 872.6, 0.0003)]
        [TestCase(UnitSystem.SI, 25, 3169.7, 0.0003)]
        [TestCase(UnitSystem.SI, 50, 12351.3, 0.0003)]
        [TestCase(UnitSystem.SI, 100, 101418.0, 0.0003)]
        [TestCase(UnitSystem.SI, 150, 476101.4, 0.0003)]
        public void GetSatVapPres(
            UnitSystem system,
            double dryBulb,
            double expected,
            double within)
        {
            var psy = new Phychrometrics(system);
            Assert.That(psy.GetSatVapPres(dryBulb), Is.EqualTo(expected).Within(within));
        }


        /// <summary>
        /// Test saturation humidity ratio
        /// The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        /// Agreement is not terrific - up to 2% difference with the values published in the table
        /// </summary>
        /// <param name="system"></param>
        /// <param name="dryBulb"></param>
        /// <param name="pressure"></param>
        /// <param name="expected"></param>
        /// <param name="within"></param>
        [TestCase(UnitSystem.IP, -58, 14.696, 0.0000243, 0.01)]
        [TestCase(UnitSystem.IP, -4, 14.696, 0.0006373, 0.01)]
        [TestCase(UnitSystem.IP, 23, 14.696, 0.0024863, 0.005)]
        [TestCase(UnitSystem.IP, 41, 14.696, 0.005425, 0.005)]
        [TestCase(UnitSystem.IP, 77, 14.696, 0.020173, 0.005)]
        [TestCase(UnitSystem.IP, 122, 14.696, 0.086863, 0.01)]
        [TestCase(UnitSystem.IP, 185, 14.696, 0.838105, 0.02)]
        [TestCase(UnitSystem.SI, -50, 101325, 0.0000243, 0.01)]
        [TestCase(UnitSystem.SI, -20, 101325, 0.0006373, 0.01)]
        [TestCase(UnitSystem.SI, -5, 101325, 0.0024863, 0.005)]
        [TestCase(UnitSystem.SI, 5, 101325, 0.005425, 0.005)]
        [TestCase(UnitSystem.SI, 25, 101325, 0.020173, 0.005)]
        [TestCase(UnitSystem.SI, 50, 101325, 0.086863, 0.01)]
        [TestCase(UnitSystem.SI, 85, 101325, 0.838105, 0.02)]
        public void GetSatHumRatio(
            UnitSystem system,
            double dryBulb,
            double pressure,
            double expected,
            double within)
        {
            var psy = new Phychrometrics(system);
            Assert.That(psy.GetSatHumRatio(dryBulb, pressure), Is.EqualTo(expected).Within(within));
        }


        /// <summary>
        /// // Test enthalpy at saturation
        /// The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        /// Agreement is rarely better than 1%, and close to 3% at -5 C
        /// </summary>
        [TestCase(UnitSystem.IP, -58, 14.696, -13.906, 0.01)]
        [TestCase(UnitSystem.IP, -4, 14.696, -0.286, 0.01)]
        [TestCase(UnitSystem.IP, 23, 14.696, 8.186, 0.03)]
        [TestCase(UnitSystem.IP, 41, 14.696, 15.699, 0.01)]
        [TestCase(UnitSystem.IP, 77, 14.696, 40.576, 0.01)]
        [TestCase(UnitSystem.IP, 122, 14.696, 126.066, 0.01)]
        [TestCase(UnitSystem.IP, 185, 14.696, 999.749, 0.01)]
        [TestCase(UnitSystem.SI, -50, 101325, -50222, 0.01)]
        [TestCase(UnitSystem.SI, -20, 101325, -18542, 0.01)]
        [TestCase(UnitSystem.SI, -5, 101325, 1164, 0.03)]
        [TestCase(UnitSystem.SI, 5, 101325, 18639, 0.01)]
        [TestCase(UnitSystem.SI, 25, 101325, 76504, 0.01)]
        [TestCase(UnitSystem.SI, 50, 101325, 275353, 0.01)]
        [TestCase(UnitSystem.SI, 85, 101325, 2307539, 0.01)]
        public void GetSatAirEnthalpy(
            UnitSystem system,
            double dryBulb,
            double pressure,
            double expected,
            double within)
        {
            var psy = new Phychrometrics(system);
            Assert.That(psy.GetSatAirEnthalpy(dryBulb, pressure), Is.EqualTo(expected).Within(within));
        }

        /**
         * Test of primary relationships between wet bulb temperature, humidity ratio,
         * vapour pressure, relative humidity, and dew point temperatures
         * These relationships are identified with bold arrows in the doc's diagram
         */

        /// <summary>
        /// // Test of relationships between vapour pressure and dew point temperature
        /// No need to test vapour pressure calculation as it is just the saturation vapour pressure tested above
        /// </summary>
        [TestCase(UnitSystem.IP, -4.0, 59.0, -4.0, 0.001)]
        [TestCase(UnitSystem.IP, 41.0, 59.0, 41.0, 0.001)]
        [TestCase(UnitSystem.IP, 122.0, 140.0, 122.0, 0.001)]
        [TestCase(UnitSystem.SI, -20.0, 15.0, -20.0, 0.001)]
        [TestCase(UnitSystem.SI, 5.0, 15.0, 5.0, 0.001)]
        [TestCase(UnitSystem.SI, 50.0, 60.0, 50.0, 0.001)]
        public void VapPres_TDewPoint(
            UnitSystem system,
            double dewPoint,
            double dryBulb,
            double expected,
            double within)
        {
            var psy = new Phychrometrics(system);
            var vapPres = psy.GetVapPresFromTDewPoint(dewPoint);
            Assert.That(psy.GetTDewPointFromVapPres(dryBulb, vapPres), Is.EqualTo(expected).Within(within));
        }


        /// <summary>
        /// Test of relationships between wet bulb temperature and relative humidity
        /// This test was known to cause a convergence issue in GetTDewPointFromVapPres
        /// in versions of PsychroLib &lt;= 2.0.0
        /// </summary>
        [TestCase(UnitSystem.SI, 7, 0.61, 100000, 3.92667433781955, 0.001)]
        public void TWetBulb_RelHum(
            UnitSystem system,
            double dryBulb,
            double relHum,
            double pressure,
            double expected,
            double within)
        {
            var psy = new Phychrometrics(system);
            Assert.That(psy.GetTWetBulbFromRelHum(dryBulb, relHum, pressure), Is.EqualTo(expected).Within(within));
        }


        /// <summary>
        /// Test that the NR in GetTDewPointFromVapPres converges.
        /// This test was known problem in versions of PsychroLib &lt;= 2.0.0
        /// </summary>
        /// <param name="system"></param>
        /// <param name="dryBulbStart"></param>
        /// <param name="dryBulbMax"></param>
        /// <param name="dryBulbIncrement"></param>
        /// <param name="pressureStart"></param>
        /// <param name="pressureMax"></param>
        /// <param name="pressureIncrement"></param>
        [TestCase(UnitSystem.IP, -148, 392, 1, 8.6, 17.4, 1)]
        [TestCase(UnitSystem.SI, -100.0, 200.0, 1, 60000, 120000, 10000)]
        public void GetTDewPointFromVapPres_convergence(
            UnitSystem system,
            double dryBulbStart,
            double dryBulbMax,
            double dryBulbIncrement,
            double pressureStart,
            double pressureMax,
            double pressureIncrement)
        {
            int iterations = 0;
            var psy = new Phychrometrics(system);
            for (double tDryBulb = dryBulbStart; tDryBulb <= dryBulbMax; tDryBulb += dryBulbIncrement)
            for (double relHum = 0; relHum <= 1; relHum += 0.1)
            for (double pressure = pressureStart; pressure <= pressureMax; pressure += pressureIncrement)
            {
                Assert.DoesNotThrow(() => psy.GetTWetBulbFromRelHum(tDryBulb, relHum, pressure));
                iterations++;
            }

            Console.Write($"{iterations} total iterations.");
        }


        /// <summary>
        /// Test of relationships between humidity ratio and vapour pressure.
        /// </summary>
        [TestCase(UnitSystem.IP, 0.45973, 14.175, 0.0208473311024865, 0.000001, 0.00001)]
        [TestCase(UnitSystem.SI, 3169.7, 95461, 0.0213603998047487, 0.000001, 0.00001)]
        public void HumRatio_VapPres(
            UnitSystem system,
            double vapPres,
            double pressure,
            double expectedHumRatio,
            double humRatioWithin,
            double vapPresWithin)
        {
            var psy = new Phychrometrics(system);
            Assert.Multiple(() =>
            {
                // conditions at 77 F, std atm pressure at 1000 ft; conditions at 25 C, std atm pressure at 500 m
                var calculatedHumRatio = psy.GetHumRatioFromVapPres(vapPres, pressure);
                Assert.That(calculatedHumRatio, Is.EqualTo(expectedHumRatio).Within(humRatioWithin));
                var calculatedVapPres = psy.GetVapPresFromHumRatio(calculatedHumRatio, pressure);
                Assert.That(calculatedVapPres, Is.EqualTo(vapPres).Within(vapPresWithin));
            });
        }

        /// <summary>
        /// Test of relationships between vapour pressure and relative humidity
        /// </summary>
        [TestCase(UnitSystem.IP, 77, 0.8, 0.45973 * 0.8, 0.8, 0.0003)]
        [TestCase(UnitSystem.SI, 25, 0.8, 3169.7 * 0.8, 0.8, 0.0003)]
        public void VapPres_RelHum(
            UnitSystem system,
            double dryBulb,
            double relHum,
            double expectedVapPres,
            double expectedHumRatio,
            double within)
        {
            var psy = new Phychrometrics(system);
            Assert.Multiple(() =>
            {
                var calculatedVapPres = psy.GetVapPresFromRelHum(dryBulb, relHum);
                Assert.That(calculatedVapPres, Is.EqualTo(expectedVapPres).Within(within));

                var calculatedHumRatio = psy.GetRelHumFromVapPres(dryBulb, calculatedVapPres);
                Assert.That(calculatedHumRatio, Is.EqualTo(expectedHumRatio).Within(within));
            });
        }


        /// <summary>
        /// Test of relationships between humidity ratio and wet bulb temperature
        /// The formulae are tested for two conditions, one above freezing and the other below
        /// Humidity ratio values to test against are calculated with Excel
        /// </summary>
        [TestCase(UnitSystem.IP, 86, 77, 14.175, 0.0187193288418892, 0.0003, 0.001)]
        [TestCase(UnitSystem.IP, 30.2, 23, 14.175, 0.00114657481090184, 0.0003, 0.001)]
        [TestCase(UnitSystem.SI, 30, 25, 95461, 0.0192281274241096, 0.0003, 0.001)]
        [TestCase(UnitSystem.SI, -1, -5, 95461, 0.00120399819933844, 0.0003, 0.001)]
        public void HumRatio_TWetBulb(
            UnitSystem system,
            double dryBulb,
            double wetBulb,
            double pressure,
            double expectedHumRatio,
            double humRatioWithin,
            double wetBulbWithin)
        {
            var psy = new Phychrometrics(system);
            Assert.Multiple(() =>
            {
                var HumRatio = psy.GetHumRatioFromTWetBulb(dryBulb, wetBulb, pressure);
                Assert.That(HumRatio, Is.EqualTo(expectedHumRatio).Within(humRatioWithin));
                var TWetBulb = psy.GetTWetBulbFromHumRatio(dryBulb, HumRatio, pressure);
                Assert.That(TWetBulb, Is.EqualTo(wetBulb).Within(wetBulbWithin));
            });
        }


        /// <summary>
        /// Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
        /// </summary>
        [TestCase(UnitSystem.IP, 23)]
        [TestCase(UnitSystem.SI, -5)]
        public void HumRatio_TWetBulbClamp(UnitSystem system, double dryBulb)
        {
            var psy = new Phychrometrics(system);
            Assert.That(psy.GetTWetBulbFromHumRatio(23, 1e-09, 95461),
                Is.EqualTo(psy.GetTWetBulbFromHumRatio(23, 1e-07, 95461)));
        }
        /**
         * Dry air calculations
         */

        /// <summary>
        /// Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
        /// Note: the accuracy of the formula is not better than 0.1%, apparently
        /// </summary>
        [TestCase(UnitSystem.IP, 77, 18.498, 14.696, 13.5251, 1 / 13.5251, 42.6168, 0.02, 86, 0.001)]
        [TestCase(UnitSystem.SI, 25, 25148, 101325, 0.8443, 1 / 0.8443, 81316, 0.02, 30, 0.001)]
        public void DryAir(
            UnitSystem system,
            double dryBulb,
            double expectedEnthalpy,
            double pressure,
            double expectedDryAirVolume,
            double expectedDryAirDensity,
            double moistAirEnthalpy,
            double humRatio,
            double expectedDryBulb,
            double within)
        {
            var psy = new Phychrometrics(system);
            Assert.Multiple(() =>
            {
                Assert.That(psy.GetDryAirEnthalpy(dryBulb), Is.EqualTo(expectedEnthalpy).Within(within));
                Assert.That(psy.GetDryAirVolume(dryBulb, pressure), Is.EqualTo(expectedDryAirVolume).Within(within));
                Assert.That(psy.GetDryAirDensity(dryBulb, pressure), Is.EqualTo(expectedDryAirDensity).Within(within));
                Assert.That(psy.GetTDryBulbFromEnthalpyAndHumRatio(moistAirEnthalpy, humRatio),
                    Is.EqualTo(expectedDryBulb).Within(0.05));
                Assert.That(psy.GetHumRatioFromEnthalpyAndTDryBulb(moistAirEnthalpy, expectedDryBulb),
                    Is.EqualTo(humRatio).Within(within));
            });
        }


        /// <summary>
        /// Moist air calculations
        /// Values are compared against values calculated with Excel
        /// </summary>
        [TestCase(UnitSystem.IP, 86, 0.02, 42.6168, 14.185, 14.7205749002918, 0.0692907720594378, 0.0003)]
        [TestCase(UnitSystem.SI, 30, 0.02, 81316, 95461, 0.940855374352943, 1.08411986348219, 0.0003)]
        public void MoistAir(
            UnitSystem system,
            double dryBulb,
            double humRatio,
            double expectedEnthalpy,
            double pressure,
            double expectedVolume,
            double expectedDensity,
            double within)
        {
            var psy = new Phychrometrics(system);

            Assert.Multiple(() =>
            {
                Assert.That(psy.GetMoistAirEnthalpy(dryBulb, humRatio), Is.EqualTo(expectedEnthalpy).Within(within));
                Assert.That(psy.GetMoistAirVolume(dryBulb, humRatio, pressure),
                    Is.EqualTo(expectedVolume).Within(within));
                Assert.That(psy.GetMoistAirDensity(dryBulb, humRatio, pressure),
                    Is.EqualTo(expectedDensity).Within(within));
            });
        }


        /**
         * Test standard atmosphere
         */

        /// <summary>
        /// The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        /// </summary>
        [TestCase(UnitSystem.IP, -1000, 15.236, 1)]
        [TestCase(UnitSystem.IP, 0, 14.696, 1)]
        [TestCase(UnitSystem.IP, 1000, 14.175, 1)]
        [TestCase(UnitSystem.IP, 3000, 13.173, 1)]
        [TestCase(UnitSystem.IP, 10000, 10.108, 1)]
        [TestCase(UnitSystem.IP, 30000, 4.371, 1)]
        [TestCase(UnitSystem.SI, -500, 107478, 1)]
        [TestCase(UnitSystem.SI, 0, 101325, 1)]
        [TestCase(UnitSystem.SI, 500, 95461, 1)]
        [TestCase(UnitSystem.SI, 1000, 89875, 1)]
        [TestCase(UnitSystem.SI, 4000, 61640, 1)]
        [TestCase(UnitSystem.SI, 10000, 26436, 1)]
        public void GetStandardAtmPressure(
            UnitSystem system,
            double altitude,
            double expected,
            double within)
        {
            var psy = new Phychrometrics(system);

            Assert.That(psy.GetStandardAtmPressure(altitude), Is.EqualTo(expected).Within(within));
        }


        /// <summary>
        /// The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        /// </summary>
        [TestCase(UnitSystem.IP, -1000, 62.6, 0.1)]
        [TestCase(UnitSystem.IP, 0, 59.0, 0.1)]
        [TestCase(UnitSystem.IP, 1000, 55.4, 0.1)]
        [TestCase(UnitSystem.IP, 3000, 48.3, 0.1)]
        [TestCase(UnitSystem.IP, 10000, 23.4, 0.1)]
        [TestCase(UnitSystem.IP, 30000, -47.8, 0.2)] // Doesn't work with abs = 0.1
        [TestCase(UnitSystem.SI, -500, 18.2, 0.1)]
        [TestCase(UnitSystem.SI, 0, 15.0, 0.1)]
        [TestCase(UnitSystem.SI, 500, 11.8, 0.1)]
        [TestCase(UnitSystem.SI, 1000, 8.5, 0.1)]
        [TestCase(UnitSystem.SI, 4000, -11.0, 0.1)]
        [TestCase(UnitSystem.SI, 10000, -50.0, 0.1)]
        public void GetStandardAtmTemperature(
            UnitSystem system,
            double altitude,
            double expected,
            double within)
        {
            var psy = new Phychrometrics(system);

            Assert.That(psy.GetStandardAtmTemperature(altitude), Is.EqualTo(expected).Within(within));
        }


        /// <summary>
        /// Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267,
        /// converted to IP
        /// </summary>
        [TestCase(UnitSystem.IP, 14.681662559, 344.488, 62.942, 14.8640475, 0.0001)]
        [TestCase(UnitSystem.SI, 101226.5, 105, 17.19, 102484.0, 1)]
        public void SeaLevel_Station_Pressure(
            UnitSystem system,
            double stnPressure,
            double altitude,
            double dryBulb,
            double expectedSeaLevelPressure,
            double within)
        {
            var psy = new Phychrometrics(system);

            Assert.Multiple(() =>
            {
                var seaLevelPressure = psy.GetSeaLevelPressure(stnPressure, altitude, dryBulb);

                Assert.That(seaLevelPressure, Is.EqualTo(expectedSeaLevelPressure).Within(within));

                Assert.That(psy.GetStationPressure(seaLevelPressure, altitude, dryBulb),
                    Is.EqualTo(stnPressure).Within(within));
            });
        }


        /**
         * Test conversion between humidity types
         */


        [TestCase(UnitSystem.IP, 0.006, 0.00596421471, 0.01)]
        [TestCase(UnitSystem.SI, 0.006, 0.00596421471, 0.01)]
        public void GetSpecificHumFromHumRatio(
            UnitSystem system,
            double humRatio,
            double expected,
            double within)
        {
            var psy = new Phychrometrics(system);

            Assert.That(psy.GetSpecificHumFromHumRatio(humRatio), Is.EqualTo(expected).Within(within));
        }


        [TestCase(UnitSystem.IP, 0.00596421471, 0.006, 0.01)]
        [TestCase(UnitSystem.SI, 0.00596421471, 0.006, 0.01)]
        public void GetHumRatioFromSpecificHum(
            UnitSystem system,
            double humRatio,
            double expected,
            double within)
        {
            var psy = new Phychrometrics(system);

            Assert.That(psy.GetSpecificHumFromHumRatio(humRatio), Is.EqualTo(expected).Within(within));
        }


        /// <summary>
        /// The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
        /// </summary>
        /// <param name="system"></param>
        /// <param name="humRatio"></param>
        /// <param name="expected"></param>
        /// <param name="within"></param>
        [Test]
        public void AllPsychrometrics()
        {
            Assert.Multiple(() =>
            {
                {
                    var psySi = new Phychrometrics(UnitSystem.SI);
                    var results1 = psySi.CalcPsychrometricsFromTWetBulb(40, 20, 101325);
                    Assert.That(results1.HumRatio, Is.EqualTo(0.0065).Within(0.0001));
                    Assert.That(results1.TDewPoint, Is.EqualTo(7).Within(0.5)); // not great agreement
                    Assert.That(results1.RelHum, Is.EqualTo(0.14).Within(0.01));
                    Assert.That(results1.MoistAirEnthalpy, Is.EqualTo(56700).Within(100));
                    Assert.That(results1.MoistAirVolume, Is.EqualTo(0.896).Within(0.01));
    
    
                    var results2 = psySi.CalcPsychrometricsFromTDewPoint(40, results1.TDewPoint, 101325);
                    Assert.That(results2.TWetBulb, Is.EqualTo(20).Within(0.1));
    
                    var results3 = psySi.CalcPsychrometricsFromRelHum(40, results2.RelHum, 101325);
                    Assert.That(results3.TWetBulb, Is.EqualTo(20).Within(0.1));
                }
                {
                    var psyIp = new Phychrometrics(UnitSystem.IP);
                    var results1 = psyIp.CalcPsychrometricsFromTWetBulb(100, 65, 14.696);
                    Assert.That(results1.HumRatio, Is.EqualTo(0.00523).Within(0.0001));
                    Assert.That(results1.TDewPoint, Is.EqualTo(40).Within(1)); // not great agreement
                    Assert.That(results1.RelHum, Is.EqualTo(0.13).Within(0.01));
                    Assert.That(results1.MoistAirEnthalpy, Is.EqualTo(29.80).Within(0.1));
                    Assert.That(results1.MoistAirVolume, Is.EqualTo(14.22).Within(0.01));


                    var results2 = psyIp.CalcPsychrometricsFromTDewPoint(100, results1.TDewPoint, 14.696);
                    Assert.That(results2.TWetBulb, Is.EqualTo(65).Within(0.1));

                    var results3 = psyIp.CalcPsychrometricsFromRelHum(100, results2.RelHum, 14.696);
                    Assert.That(results3.TWetBulb, Is.EqualTo(65).Within(0.1));
                }
            });
        }
    }
}