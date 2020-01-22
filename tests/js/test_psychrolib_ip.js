// PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
// Copyright (c) 2018-2020 The PsychroLib Contributors. Licensed under the MIT License.

// Test of PsychroLib in IP units.

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

describe('IP', function(){

before(function(){
    psyjs.SetUnitSystem(psyjs.IP);
});

it('test_GetTRankineFromTFahrenheit', function () {
    expect(psyjs.GetTRankineFromTFahrenheit(70)).to.be.closeTo(529.67, 0.000001)
});

it('test_GetTFahrenheitFromTRankine', function () {
    expect(psyjs.GetTFahrenheitFromTRankine(529.67)).to.be.closeTo(70, 0.000001)
});

/**
 * Tests at saturation
 */

// Test saturation vapour pressure calculation
// The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
// over the range [-148, +392] F
// ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -76 F
it('test_GetSatVapPres', function () {
    expect(psyjs.GetSatVapPres(-76)).to.be.closeTo(0.000157, 0.00001)
    checkRelDiff(psyjs.GetSatVapPres( -4), 0.014974, 0.0003)
    checkRelDiff(psyjs.GetSatVapPres( 23), 0.058268, 0.0003)
    checkRelDiff(psyjs.GetSatVapPres( 41), 0.12656, 0.0003)
    checkRelDiff(psyjs.GetSatVapPres( 77), 0.45973, 0.0003)
    checkRelDiff(psyjs.GetSatVapPres(122), 1.79140, 0.0003)
    checkRelDiff(psyjs.GetSatVapPres(212), 14.7094, 0.0003)
    checkRelDiff(psyjs.GetSatVapPres(300), 67.0206, 0.0003)
});


// Test saturation humidity ratio
// The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
// Agreement is not terrific - up to 2% difference with the values published in the table
it('test_GetSatHumRatio', function () {
    checkRelDiff(psyjs.GetSatHumRatio(-58, 14.696), 0.0000243, 0.01)
    checkRelDiff(psyjs.GetSatHumRatio( -4, 14.696), 0.0006373, 0.01)
    checkRelDiff(psyjs.GetSatHumRatio( 23, 14.696), 0.0024863, 0.005)
    checkRelDiff(psyjs.GetSatHumRatio( 41, 14.696), 0.005425, 0.005)
    checkRelDiff(psyjs.GetSatHumRatio( 77, 14.696), 0.020173, 0.005)
    checkRelDiff(psyjs.GetSatHumRatio(122, 14.696), 0.086863, 0.01)
    checkRelDiff(psyjs.GetSatHumRatio(185, 14.696), 0.838105, 0.02)
});

// Test enthalpy at saturation
// The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
// Agreement is rarely better than 1%, and close to 3% at -5 C
it('test_GetSatAirEnthalpy', function () {
        checkRelDiff(psyjs.GetSatAirEnthalpy(-58, 14.696), -13.906, 0.01)
        checkRelDiff(psyjs.GetSatAirEnthalpy( -4, 14.696),  -0.286, 0.01)
        checkRelDiff(psyjs.GetSatAirEnthalpy( 23, 14.696),   8.186, 0.03)
        checkRelDiff(psyjs.GetSatAirEnthalpy( 41, 14.696),  15.699, 0.01)
        checkRelDiff(psyjs.GetSatAirEnthalpy( 77, 14.696),  40.576, 0.01)
        checkRelDiff(psyjs.GetSatAirEnthalpy(122, 14.696), 126.066, 0.01)
        checkRelDiff(psyjs.GetSatAirEnthalpy(185, 14.696), 999.749, 0.01)
});

/**
 * Test of primary relationships between wet bulb temperature, humidity ratio,
 * vapour pressure, relative humidity, and dew point temperatures
 * These relationships are identified with bold arrows in the doc's diagram
 */

// Test of relationships between vapour pressure and dew point temperature
// No need to test vapour pressure calculation as it is just the saturation vapour pressure tested above
it('test_VapPres_TDewPoint', function () {
    var VapPres = psyjs.GetVapPresFromTDewPoint(-4.0)
    expect(psyjs.GetTDewPointFromVapPres(59.0, VapPres)).to.be.closeTo(-4.0, 0.001)
    var VapPres = psyjs.GetVapPresFromTDewPoint(41.0)
    expect(psyjs.GetTDewPointFromVapPres(59.0, VapPres)).to.be.closeTo(41.0, 0.001)
    var VapPres = psyjs.GetVapPresFromTDewPoint(122.0)
    expect(psyjs.GetTDewPointFromVapPres(140.0, VapPres)).to.be.closeTo(122.0, 0.001)
});

// Test that the NR in GetTDewPointFromVapPres converges.
// This test was known problem in versions of PsychroLib <= 2.0.0
it('test_GetTDewPointFromVapPres_convergence', function () {
    for (var TDryBulb = -148; TDryBulb <= 392; TDryBulb += 1)
        for (var RelHum = 0; RelHum <= 1; RelHum += 0.1)
            for (var Pressure = 8.6; Pressure <= 17.4; Pressure += 1)
                psyjs.GetTWetBulbFromRelHum(TDryBulb, RelHum, Pressure)
});

// Test of relationships between humidity ratio and vapour pressure
it('test_HumRatio_VapPres', function () {
        var HumRatio = psyjs.GetHumRatioFromVapPres(0.45973, 14.175)          // conditions at 77 F, std atm pressure at 1000 ft
        checkRelDiff(HumRatio, 0.0208473311024865, 0.000001)
        var VapPres = psyjs.GetVapPresFromHumRatio(HumRatio, 14.175)
        expect(VapPres).to.be.closeTo(0.45973, 0.00001)
});

// Test of relationships between vapour pressure and relative humidity
it('test_VapPres_RelHum', function () {
    var VapPres = psyjs.GetVapPresFromRelHum(77, 0.8)
    checkRelDiff(VapPres, 0.45973*0.8, 0.0003)
    var RelHum = psyjs.GetRelHumFromVapPres(77, VapPres)
    expect(RelHum).to.be.closeTo(0.8, 0.0003)
});

// Test of relationships between humidity ratio and wet bulb temperature
// The formulae are tested for two conditions, one above freezing and the other below
// Humidity ratio values to test against are calculated with Excel
it('test_HumRatio_TWetBulb', function () {
        var HumRatio = psyjs.GetHumRatioFromTWetBulb(86, 77, 14.175)
        checkRelDiff(HumRatio, 0.0187193288418892, 0.0003)
        var TWetBulb = psyjs.GetTWetBulbFromHumRatio(86, HumRatio, 14.175)
        expect(TWetBulb).to.be.closeTo(77, 0.001)

        // Below freezing
        var HumRatio = psyjs.GetHumRatioFromTWetBulb(30.2, 23.0, 14.175)
        checkRelDiff(HumRatio,0.00114657481090184, 0.0003)
        var TWetBulb = psyjs.GetTWetBulbFromHumRatio(30.2, HumRatio, 14.1751)
        expect(TWetBulb).to.be.closeTo(23.0, 0.001)

        // Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
        expect(psyjs.GetTWetBulbFromHumRatio(23,1e-09,95461)).to.equal(psyjs.GetTWetBulbFromHumRatio(23,1e-07,95461))
});

/**
 * Dry air calculations
 */

// Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
// Note: the accuracy of the formula is not better than 0.1%, apparently
it('test_DryAir', function () {
        checkRelDiff(psyjs.GetDryAirEnthalpy(77), 18.498, 0.001)
        checkRelDiff(psyjs.GetDryAirVolume(77, 14.696), 13.5251, 0.001)
        checkRelDiff(psyjs.GetDryAirDensity(77, 14.696), 1/13.5251, 0.001)
        expect(psyjs.GetTDryBulbFromEnthalpyAndHumRatio(42.6168, 0.02)).to.be.closeTo(86, 0.05)
        checkRelDiff(psyjs.GetHumRatioFromEnthalpyAndTDryBulb(42.6168, 86), 0.02, 0.001)
});


/**
 * Moist air calculations
 */

// Values are compared against values calculated with Excel
it('test_MoistAir', function () {
    checkRelDiff(psyjs.GetMoistAirEnthalpy(86, 0.02), 42.6168, 0.0003)
    checkRelDiff(psyjs.GetMoistAirVolume(86, 0.02, 14.175), 14.7205749002918, 0.0003)
    checkRelDiff(psyjs.GetMoistAirDensity(86, 0.02, 14.175), 0.0692907720594378, 0.0003)
});

it('test_GetTDryBulbFromMoistAirVolumeAndHumRatio', function () {
    checkRelDiff(psyjs.GetTDryBulbFromMoistAirVolumeAndHumRatio(14.7205749002918, 0.02, 14.175), 86, 0.0003)
});

/**
 * Test standard atmosphere
 */

// The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
it('test_GetStandardAtmPressure', function () {
    expect(psyjs.GetStandardAtmPressure(-1000)).to.be.closeTo(15.236, 1)
    expect(psyjs.GetStandardAtmPressure(    0)).to.be.closeTo(14.696, 1)
    expect(psyjs.GetStandardAtmPressure( 1000)).to.be.closeTo(14.175, 1)
    expect(psyjs.GetStandardAtmPressure( 3000)).to.be.closeTo(13.173, 1)
    expect(psyjs.GetStandardAtmPressure(10000)).to.be.closeTo(10.108, 1)
    expect(psyjs.GetStandardAtmPressure(30000)).to.be.closeTo( 4.371, 1)
});

it('test_GetStandardAtmTemperature', function () {
    expect(psyjs.GetStandardAtmTemperature(-1000)).to.be.closeTo(62.6, 0.1)
    expect(psyjs.GetStandardAtmTemperature(    0)).to.be.closeTo(59.0, 0.1)
    expect(psyjs.GetStandardAtmTemperature( 1000)).to.be.closeTo(55.4, 0.1)
    expect(psyjs.GetStandardAtmTemperature( 3000)).to.be.closeTo(48.3, 0.1)
    expect(psyjs.GetStandardAtmTemperature(10000)).to.be.closeTo(23.4, 0.1)
    expect(psyjs.GetStandardAtmTemperature(30000)).to.be.closeTo(-47.8, 0.2)          // Doesn't work with abs = 0.1
});

/**
 * Test sea level pressure conversions
 */

// Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267,
// converted to IP
it('test_SeaLevel_Station_Pressure', function () {
    var SeaLevelPressure = psyjs.GetSeaLevelPressure(14.681662559, 344.488, 62.942)
    expect(SeaLevelPressure).to.be.closeTo(14.8640475, 0.0001)
    expect(psyjs.GetStationPressure(SeaLevelPressure, 344.488, 62.942)).to.be.closeTo(14.681662559, 0.0001)
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
    var [HumRatio, TDewPoint, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation] = psyjs.CalcPsychrometricsFromTWetBulb(100, 65, 14.696);
        expect(HumRatio).to.be.closeTo(0.00523, 0.001);
        expect(TDewPoint).to.be.closeTo(40, 1.0);             // not great agreement
        expect(RelHum).to.be.closeTo(0.13, 0.01);
        expect(MoistAirEnthalpy).to.be.closeTo(29.80, 0.1);
        checkRelDiff(MoistAirVolume, 14.22, 0.01);

    var [HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation] = psyjs.CalcPsychrometricsFromTDewPoint(100, TDewPoint, 14.696);
        expect(TWetBulb).to.be.closeTo(65, 0.1);

    var [HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation] = psyjs.CalcPsychrometricsFromRelHum(100, RelHum, 14.696);
        expect(TWetBulb).to.be.closeTo(65, 0.1);
});

}); // end of describe()