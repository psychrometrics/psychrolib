// PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
// Copyright (c) 2018-2020 The PsychroLib Contributors. Licensed under the MIT License.

// Test of PsychroLib in SI units.

const assert = require('assert');
var expect = require('chai').expect;
var diff = require( 'math-relative-difference' );

var psyjs = require('../../src/js/psychrolib.js')

function checkRelDiff(actual, expected, eps) {
    var d = diff(actual, expected);
    if (d > eps) {
        throw new assert.AssertionError({
            message: 'expected ' + actual + ' to be close to ' + expected + ' with rel error ' + eps,
            actual: actual,
            expected: expected
        });
    }
}

describe('SI', function(){

before(function(){
    psyjs.SetUnitSystem(psyjs.SI);
});

it('test_GetTKelvinFromTCelsius', function () {
    expect(psyjs.GetTKelvinFromTCelsius(20)).to.be.closeTo(293.15, 0.000001)
});

it('test_GetTCelsiusFromTKelvin', function () {
    expect(psyjs.GetTCelsiusFromTKelvin(293.15)).to.be.closeTo(20, 0.000001)
});


/**
 * Tests at saturation
 */

// Test saturation vapour pressure calculation
// The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
// over the range [-100, +200] C
// ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -60 C
it('test_GetSatVapPres', function () {
    expect(psyjs.GetSatVapPres(-60)).to.be.closeTo(1.08, 0.01)
    checkRelDiff(psyjs.GetSatVapPres(-20), 103.24, 0.0003)
    checkRelDiff(psyjs.GetSatVapPres( -5), 401.74, 0.0003)
    checkRelDiff(psyjs.GetSatVapPres(  5), 872.6, 0.0003)
    checkRelDiff(psyjs.GetSatVapPres( 25), 3169.7, 0.0003)
    checkRelDiff(psyjs.GetSatVapPres( 50), 12351.3, 0.0003)
    checkRelDiff(psyjs.GetSatVapPres(100), 101418.0, 0.0003)
    checkRelDiff(psyjs.GetSatVapPres(150), 476101.4, 0.0003)
});


// Test saturation humidity ratio
// The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
// Agreement is not terrific - up to 2% difference with the values published in the table
it('test_GetSatHumRatio', function () {
    checkRelDiff(psyjs.GetSatHumRatio(-50, 101325), 0.0000243, 0.01)
    checkRelDiff(psyjs.GetSatHumRatio(-20, 101325), 0.0006373, 0.01)
    checkRelDiff(psyjs.GetSatHumRatio( -5, 101325), 0.0024863, 0.005)
    checkRelDiff(psyjs.GetSatHumRatio(  5, 101325), 0.005425, 0.005)
    checkRelDiff(psyjs.GetSatHumRatio( 25, 101325), 0.020173, 0.005)
    checkRelDiff(psyjs.GetSatHumRatio( 50, 101325), 0.086863, 0.01)
    checkRelDiff(psyjs.GetSatHumRatio( 85, 101325), 0.838105, 0.02)
});

// Test enthalpy at saturation
// The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
// Agreement is rarely better than 1%, and close to 3% at -5 C
it('test_GetSatAirEnthalpy', function () {
        checkRelDiff(psyjs.GetSatAirEnthalpy(-50, 101325), -50222, 0.01)
        checkRelDiff(psyjs.GetSatAirEnthalpy(-20, 101325), -18542, 0.01)
        checkRelDiff(psyjs.GetSatAirEnthalpy( -5, 101325),   1164, 0.03)
        checkRelDiff(psyjs.GetSatAirEnthalpy(  5, 101325),  18639, 0.01)
        checkRelDiff(psyjs.GetSatAirEnthalpy( 25, 101325),  76504, 0.01)
        checkRelDiff(psyjs.GetSatAirEnthalpy( 50, 101325), 275353, 0.01)
        checkRelDiff(psyjs.GetSatAirEnthalpy( 85, 101325),2307539, 0.01)
});

/**
 * Test of primary relationships between wet bulb temperature, humidity ratio,
 * vapour pressure, relative humidity, and dew point temperatures
 * These relationships are identified with bold arrows in the doc's diagram
 */

// Test of relationships between vapour pressure and dew point temperature
// No need to test vapour pressure calculation as it is just the saturation vapour pressure tested above
it('test_VapPres_TDewPoint', function () {
    var VapPres = psyjs.GetVapPresFromTDewPoint(-20.0)
    expect(psyjs.GetTDewPointFromVapPres(15.0, VapPres)).to.be.closeTo(-20.0, 0.001)
    var VapPres = psyjs.GetVapPresFromTDewPoint(5.0)
    expect(psyjs.GetTDewPointFromVapPres(15.0, VapPres)).to.be.closeTo(5.0, 0.001)
    var VapPres = psyjs.GetVapPresFromTDewPoint(50.0)
    expect(psyjs.GetTDewPointFromVapPres(60.0, VapPres)).to.be.closeTo(50.0, 0.001)
});

// Test of relationships between wet bulb temperature and relative humidity
// This test was known to cause a convergence issue in GetTDewPointFromVapPres
// in versions of PsychroLib <= 2.0.0
it('test_TWetBulb_RelHum', function () {
    var TWetBulb = psyjs.GetTWetBulbFromRelHum(7, 0.61, 100000)
    checkRelDiff(TWetBulb, 3.92667433781955, 0.001)
});

// Test that the NR in GetTDewPointFromVapPres converges.
// This test was known problem in versions of PsychroLib <= 2.0.0
it('test_GetTDewPointFromVapPres_convergence', function () {
    for (var TDryBulb = -100; TDryBulb <= 200; TDryBulb += 1)
        for (var RelHum = 0; RelHum <= 1; RelHum += 0.1)
            for (var Pressure = 60000; Pressure <= 120000; Pressure += 10000)
                psyjs.GetTWetBulbFromRelHum(TDryBulb, RelHum, Pressure)
});

// Test of relationships between humidity ratio and vapour pressure
it('test_HumRatio_VapPres', function () {
        var HumRatio = psyjs.GetHumRatioFromVapPres(3169.7, 95461)          // conditions at 25 C, std atm pressure at 500 m
        checkRelDiff(HumRatio, 0.0213603998047487, 0.000001)
        var VapPres = psyjs.GetVapPresFromHumRatio(HumRatio, 95461)
        expect(VapPres).to.be.closeTo(3169.7, 0.00001)
});

// Test of relationships between vapour pressure and relative humidity
it('test_VapPres_RelHum', function () {
    var VapPres = psyjs.GetVapPresFromRelHum(25, 0.8)
    checkRelDiff(VapPres, 3169.7*0.8, 0.0003)
    var RelHum = psyjs.GetRelHumFromVapPres(25, VapPres)
    expect(RelHum).to.be.closeTo(0.8, 0.0003)
});

// Test of relationships between humidity ratio and wet bulb temperature
// The formulae are tested for two conditions, one above freezing and the other below
// Humidity ratio values to test against are calculated with Excel
it('test_HumRatio_TWetBulb', function () {
        var HumRatio = psyjs.GetHumRatioFromTWetBulb(30, 25, 95461)
        checkRelDiff(HumRatio, 0.0192281274241096, 0.0003)
        var TWetBulb = psyjs.GetTWetBulbFromHumRatio(30, HumRatio, 95461)
        expect(TWetBulb).to.be.closeTo(25, 0.001)

        // Below freezing
        var HumRatio = psyjs.GetHumRatioFromTWetBulb(-1, -5, 95461)
        checkRelDiff(HumRatio, 0.00120399819933844, 0.0003)
        var TWetBulb = psyjs.GetTWetBulbFromHumRatio(-1, HumRatio, 95461)
        expect(TWetBulb).to.be.closeTo(-5, 0.001)

        // Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
        expect(psyjs.GetTWetBulbFromHumRatio(-5,1e-09,95461)).to.equal(psyjs.GetTWetBulbFromHumRatio(-5,1e-07,95461))
});

/**
 * Dry air calculations
 */

// Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
// Note: the accuracy of the formula is not better than 0.1%, apparently
it('test_DryAir', function () {
        checkRelDiff(psyjs.GetDryAirEnthalpy(25), 25148, 0.0003)
        checkRelDiff(psyjs.GetDryAirVolume(25, 101325), 0.8443, 0.001)
        checkRelDiff(psyjs.GetDryAirDensity(25, 101325), 1/0.8443, 0.001)
        expect(psyjs.GetTDryBulbFromEnthalpyAndHumRatio(81316, 0.02)).to.be.closeTo(30, 0.001)
        checkRelDiff(psyjs.GetHumRatioFromEnthalpyAndTDryBulb(81316, 30), 0.02, 0.001)
});


/**
 * Moist air calculations
 */

// Values are compared against values calculated with Excel
it('test_MoistAir', function () {
    checkRelDiff(psyjs.GetMoistAirEnthalpy(30, 0.02), 81316, 0.0003)
    checkRelDiff(psyjs.GetMoistAirVolume(30, 0.02, 95461), 0.940855374352943, 0.0003)
    checkRelDiff(psyjs.GetMoistAirDensity(30, 0.02, 95461), 1.08411986348219, 0.0003)
});


it('test_GetTDryBulbFromMoistAirVolumeAndHumRatio', function () {
    checkRelDiff(psyjs.GetTDryBulbFromMoistAirVolumeAndHumRatio(0.940855374352943, 0.02, 95461), 30, 0.0003)
});

/**
 * Test standard atmosphere
 */

// The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
it('test_GetStandardAtmPressure', function () {
    expect(psyjs.GetStandardAtmPressure( -500)).to.be.closeTo(107478, 1)
    expect(psyjs.GetStandardAtmPressure(    0)).to.be.closeTo(101325, 1)
    expect(psyjs.GetStandardAtmPressure(  500)).to.be.closeTo( 95461, 1)
    expect(psyjs.GetStandardAtmPressure( 1000)).to.be.closeTo( 89875, 1)
    expect(psyjs.GetStandardAtmPressure( 4000)).to.be.closeTo( 61640, 1)
    expect(psyjs.GetStandardAtmPressure(10000)).to.be.closeTo( 26436, 1)
});

it('test_GetStandardAtmTemperature', function () {
    expect(psyjs.GetStandardAtmTemperature( -500)).to.be.closeTo( 18.2, 0.1)
    expect(psyjs.GetStandardAtmTemperature(    0)).to.be.closeTo( 15.0, 0.1)
    expect(psyjs.GetStandardAtmTemperature(  500)).to.be.closeTo( 11.8, 0.1)
    expect(psyjs.GetStandardAtmTemperature( 1000)).to.be.closeTo(  8.5, 0.1)
    expect(psyjs.GetStandardAtmTemperature( 4000)).to.be.closeTo(-11.0, 0.1)
    expect(psyjs.GetStandardAtmTemperature(10000)).to.be.closeTo(-50.0, 0.1)
});

/**
 * Test sea level pressure conversions
 */

// Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267,
// converted to IP
it('test_SeaLevel_Station_Pressure', function () {
    var SeaLevelPressure = psyjs.GetSeaLevelPressure(101226.5, 105, 17.19)
    expect(SeaLevelPressure).to.be.closeTo(102484.0, 1)
    expect(psyjs.GetStationPressure(SeaLevelPressure, 105, 17.19)).to.be.closeTo(101226.5, 1)
});

/**
 * Test conversion between humidity types
 */
it('test_GetSpecificHumFromHumRatio', function () {
    checkRelDiff(psyjs.GetSpecificHumFromHumRatio(0.006),0.00596421471, 0.01)
});

it('test_GetHumRatioFromSpecificHum', function () {
    checkRelDiff(psyjs.GetHumRatioFromSpecificHum(0.00596421471),0.006, 0.01)
});

/**
 * Test against Example 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
 */
// The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
it('test_AllPsychrometrics', function () {
    var [HumRatio, TDewPoint, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation] = psyjs.CalcPsychrometricsFromTWetBulb(40, 20, 101325)
        expect(HumRatio).to.be.closeTo(0.0065, 0.0001)
        expect(TDewPoint).to.be.closeTo(7, abs = 0.5)           // not great agreement
        expect(RelHum).to.be.closeTo(0.14, 0.01)
        expect(MoistAirEnthalpy).to.be.closeTo(56700, 100)
        checkRelDiff(MoistAirVolume, 0.896, 0.01)

    var [HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation] = psyjs.CalcPsychrometricsFromTDewPoint(40, TDewPoint, 101325)
        expect(TWetBulb).to.be.closeTo(20, 0.1)

    var [HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation] = psyjs.CalcPsychrometricsFromRelHum(40, RelHum, 101325)
        expect(TWetBulb).to.be.closeTo(20, 0.1)
});

}); // end of describe()