package psychrolib

import "testing"
//import "fmt"
import "math"

func reltol(value, result, rel float64) {
  res := math.Abs(value - result) / math.Min(math.Abs(value), math.Abs(result))
//  fmt.Printf("rollrel %f\n", res)
  ASSERT (res <= rel, "relative tolerance error")
}

func abstol(value, result, abs float64) {
  res := math.Abs(value - result)
//  fmt.Printf("roll %f\n", res)
  ASSERT (res <= abs, "absolute tolerance error")
}

// Test of helper functions

func TestGetTKelvinFromTCelsius_SI(t *testing.T) {
     SetUnitSystem(SI)
     reltol(GetTKelvinFromTCelsius(20), 293.15, 0.000001)
}

func TestGetTCelsiusFromTKelvin_SI(t *testing.T) {
     SetUnitSystem(SI)
     reltol(GetTCelsiusFromTKelvin(293.15), 20, 0.000001)
}
//
// Tests at saturation
//
// Test saturation vapour pressure calculation
// The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
// over the range [-100, +200] C
// ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -60 C

func TestGetSatVapPres_SI(t *testing.T) {
    SetUnitSystem(SI)
    abstol(GetSatVapPres(-60), 1.08, 0.01)
    reltol(GetSatVapPres(-20), 103.24, 0.0003)
    reltol(GetSatVapPres( -5), 401.74, 0.0003)
    reltol(GetSatVapPres(  5), 872.6, 0.0003)
    reltol(GetSatVapPres( 25), 3169.7, 0.0003)
    reltol(GetSatVapPres( 50), 12351.3, 0.0003)
    reltol(GetSatVapPres(100), 101418.0, 0.0003)
    reltol(GetSatVapPres(150), 476101.4, 0.0003)
}

// Test saturation humidity ratio
// The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
// Agreement is not terrific - up to 2% difference with the values published in the table

func TestGetSatHumRatio_SI(t *testing.T) {
    SetUnitSystem(SI)
    reltol(GetSatHumRatio(-50, 101325), 0.0000243, 0.01)
    reltol(GetSatHumRatio(-20, 101325), 0.0006373, 0.01)
    reltol(GetSatHumRatio( -5, 101325), 0.0024863, 0.005)
    reltol(GetSatHumRatio(  5, 101325), 0.005425, 0.005)
    reltol(GetSatHumRatio( 25, 101325), 0.020173, 0.005)
    reltol(GetSatHumRatio( 50, 101325), 0.086863, 0.01)
    reltol(GetSatHumRatio( 85, 101325), 0.838105, 0.02)
}

// Test enthalpy at saturation
// The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
// Agreement is rarely better than 1%, and close to 3% at -5 C
func TestGetSatAirEnthalpy_SI(t *testing.T) {
    SetUnitSystem(SI)
    reltol(GetSatAirEnthalpy(-50, 101325), -50222,  0.01)
    reltol(GetSatAirEnthalpy(-20, 101325), -18542,  0.01)
    reltol(GetSatAirEnthalpy( -5, 101325),   1164,  0.03)
    reltol(GetSatAirEnthalpy(  5, 101325),  18639,  0.01)
    reltol(GetSatAirEnthalpy( 25, 101325),  76504,  0.01)
    reltol(GetSatAirEnthalpy( 50, 101325), 275353,  0.01)
    reltol(GetSatAirEnthalpy( 85, 101325),2307539,  0.01)
}

// Test of primary relationships between wet bulb temperature, humidity ratio, vapour pressure, relative humidity, and dew point temperatures
// These relationships are identified with bold arrows in the doc's diagram

// Test of relationships between vapour pressure and dew point temperature
// No need to test vapour pressure calculation as it is just the saturation vapour pressure tested above
func TestVapPres_TDewPoint_SI(t *testing.T) {
    SetUnitSystem(SI)
    VapPres := GetVapPresFromTDewPoint(-20.0)
    abstol(GetTDewPointFromVapPres(15.0, VapPres), -20.0, 0.001)
    VapPres = GetVapPresFromTDewPoint(5.0)
    abstol(GetTDewPointFromVapPres(15.0, VapPres), 5.0, 0.001)
    VapPres = GetVapPresFromTDewPoint(50.0)
    abstol(GetTDewPointFromVapPres(60.0, VapPres), 50.0, 0.001)
}

// Test of relationships between wet bulb temperature and relative humidity
// This test was known to cause a convergence issue in GetTDewPointFromVapPres
// in versions of PsychroLib <= 2.0.0
func TestTWetBulb_RelHum_SI(t *testing.T) {
    SetUnitSystem(SI)
    reltol(GetTWetBulbFromRelHum(7, 0.61, 100000), 3.92667433781955, 0.001)
}

// Test that the NR in GetTDewPointFromVapPres converges.
// This test was known problem in versions of PsychroLib <= 2.0.0
//arange(start, stop, step)
func TestGetTDewPointFromVapPres_convergence_SI(t *testing.T) {
    SetUnitSystem(SI)
    for TDryBulb:=-100.0; TDryBulb<= 200.0; TDryBulb+=1.0 {
     for RelHum:=0.0; RelHum <= 1.0; RelHum+=0.1 {
      for Pressure:=60000.0; Pressure <= 120000.0; Pressure += 10000.0 {
                GetTWetBulbFromRelHum(TDryBulb, RelHum, Pressure)
      }
     }
    }
}
// Test of relationships between humidity ratio and vapour pressure
// Humidity ratio values to test against are calculated with Excel
func TestHumRatio_VapPres_SI(t *testing.T) {
    SetUnitSystem(SI)
     HumRatio := GetHumRatioFromVapPres(3169.7, 95461) // conditions at 25 C, std atm pressure at 500 m
     reltol(HumRatio, 0.0213603998047487, 0.000001)
     VapPres := GetVapPresFromHumRatio(HumRatio, 95461)
     abstol(VapPres, 3169.7, 0.0001)
}

// Test of relationships between vapour pressure and relative humidity
func TestVapPres_RelHum_SI(t *testing.T) {
    SetUnitSystem(SI)
    VapPres := GetVapPresFromRelHum(25, 0.8)
    reltol(VapPres, 3169.7*0.8, 0.0003)
    RelHum := GetRelHumFromVapPres(25, VapPres)
    reltol(RelHum, 0.8, 0.0003)
}

// Test of relationships between humidity ratio and wet bulb temperature
// The formulae are tested for two conditions, one above freezing and the other below
// Humidity ratio values to test against are calculated with Excel
func TestHumRatio_TWetBulb_SI(t *testing.T) {
    SetUnitSystem(SI)
    // Above freezing
    HumRatio := GetHumRatioFromTWetBulb(30, 25, 95461)
    reltol(HumRatio, 0.0192281274241096, 0.0003)
    TWetBulb := GetTWetBulbFromHumRatio(30, HumRatio, 95461)
    abstol(TWetBulb, 25, 0.001)
    // Below freezing
    HumRatio = GetHumRatioFromTWetBulb(-1, -5, 95461)
    reltol(HumRatio, 0.00120399819933844, 0.0003)
    TWetBulb = GetTWetBulbFromHumRatio(-1, HumRatio, 95461)
    abstol(TWetBulb, -5, 0.001)
    // Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
    ASSERT(GetTWetBulbFromHumRatio(-5,1e-09,95461) == GetTWetBulbFromHumRatio(-5,1e-07,95461), "Low HumRatio")
}
// ###############################################################################
// # Dry air calculations
// ###############################################################################

// # Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
// # Note: the accuracy of the formula is not better than 0.1%, apparently
func TestDryAir_SI(t *testing.T) {
    SetUnitSystem(SI)
    reltol(GetDryAirEnthalpy(25), 25148, 0.0003)
    reltol(GetDryAirVolume(25, 101325), 0.8443, 0.001)
    reltol(GetDryAirDensity(25, 101325), 1/0.8443, 0.001)
    abstol(GetTDryBulbFromEnthalpyAndHumRatio(81316, 0.02), 30, 0.001)
    reltol(GetHumRatioFromEnthalpyAndTDryBulb(81316, 30), 0.02, 0.001)
}

// ###############################################################################
// # Moist air calculations
// ###############################################################################

// # Values are compared against values calculated with Excel
func TestMoistAir_SI(t *testing.T) {
    SetUnitSystem(SI)
    reltol(GetMoistAirEnthalpy(30, 0.02), 81316, 0.0003)
    reltol(GetMoistAirVolume(30, 0.02, 95461), 0.940855374352943, 0.0003)
    reltol(GetMoistAirDensity(30, 0.02, 95461), 1.08411986348219, 0.0003)
}

func TestGetTDryBulbFromMoistAirVolumeAndHumRatio_SI(t *testing.T) {
    SetUnitSystem(SI)
    reltol(GetTDryBulbFromMoistAirVolumeAndHumRatio(0.940855374352943, 0.02, 95461), 30, 0.0003)
}

// ###############################################################################
// # Test standard atmosphere
// ###############################################################################

// # The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals

func TestGetStandardAtmPressure_SI(t *testing.T) {
    SetUnitSystem(SI)
    abstol(GetStandardAtmPressure( -500), 107478, 1)
    abstol(GetStandardAtmPressure(    0), 101325, 1)
    abstol(GetStandardAtmPressure(  500),  95461, 1)
    abstol(GetStandardAtmPressure( 1000),  89875, 1)
    abstol(GetStandardAtmPressure( 4000),  61640, 1)
    abstol(GetStandardAtmPressure(10000),  26436, 1)
}

func TestGetStandardAtmTemperature_SI(t *testing.T) {
    SetUnitSystem(SI)
    abstol(GetStandardAtmTemperature( -500),  18.2, 0.1)
    abstol(GetStandardAtmTemperature(    0),  15.0, 0.1)
    abstol(GetStandardAtmTemperature(  500),  11.8, 0.1)
    abstol(GetStandardAtmTemperature( 1000),   8.5, 0.1)
    abstol(GetStandardAtmTemperature( 4000), -11.0, 0.1)
    abstol(GetStandardAtmTemperature(10000), -50.0, 0.1)
}

// ###############################################################################
// # Test sea level pressure conversions
// ###############################################################################

// # Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267
func TestSeaLevel_Station_Pressure_SI(t *testing.T) {
    SetUnitSystem(SI)
    SeaLevelPressure := GetSeaLevelPressure(101226.5, 105, 17.19)
    abstol(SeaLevelPressure, 102484.0, 1)
    abstol(GetStationPressure(SeaLevelPressure, 105, 17.19), 101226.5, 1)
}

// Test conversion between humidity types

func TestGetSpecificHumFromHumRatio_SI(t *testing.T) {
     SetUnitSystem(SI)
     reltol(GetSpecificHumFromHumRatio(0.006), 0.00596421471, 0.01)
}

func TestGetHumRatioFromSpecificHum_SI(t *testing.T) {
     SetUnitSystem(SI)
     reltol(GetHumRatioFromSpecificHum(0.00596421471), 0.006, 0.01)
}

// Test against Example 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals

func TestAllPsychrometrics_SI(t *testing.T) {
     SetUnitSystem(SI)
     HumRatio, TDewPoint, RelHum, _, MoistAirEnthalpy, MoistAirVolume, _ := CalcPsychrometricsFromTWetBulb(40, 20, 101325)
     abstol(HumRatio, .0065, 0.0001)
     abstol(TDewPoint, 7, 0.5)
     abstol(RelHum, 0.14, 0.01)
     abstol(MoistAirEnthalpy, 56700, 100)
     reltol(MoistAirVolume, 0.896, 0.01)

    // Reverse calculation: recalculate wet bulb temperature from dew point temperature
    _, TWetBulb, _, _, _, _, _ := CalcPsychrometricsFromTDewPoint(40, TDewPoint, 101325)
    abstol(TWetBulb, 20, 0.1)

    // Reverse calculation: recalculate wet bulb temperature from relative humidity
    _, TWetBulb, _, _, _, _, _ = CalcPsychrometricsFromRelHum(40, RelHum, 101325)
    abstol(TWetBulb, 20, 0.1)
}

// ====================== IP unit system tests

// # Test of helper functions
func TestGetTRankineFromTFahrenheit_IP(t *testing.T) {
    SetUnitSystem(IP)
    reltol(GetTRankineFromTFahrenheit(70), 529.67, 0.000001)
}

func TestGetTFahrenheitFromTRankine_IP(t *testing.T) {
    SetUnitSystem(IP)
    reltol(GetTFahrenheitFromTRankine(529.67), 70, 0.000001)
}

// ###############################################################################
// # Tests at saturation
// ###############################################################################

// # Test saturation vapour pressure calculation
// # The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
// # over the range [-148, +392] F
// # ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -76 F
func TestGetSatVapPres_IP(t *testing.T) {
    SetUnitSystem(IP)
    abstol(GetSatVapPres(-76), 0.000157, 0.00001)
    reltol(GetSatVapPres( -4), 0.014974, 0.0003)
    reltol(GetSatVapPres( 23), 0.058268, 0.0003)
    reltol(GetSatVapPres( 41), 0.12656, 0.0003)
    reltol(GetSatVapPres( 77), 0.45973, 0.0003)
    reltol(GetSatVapPres(122), 1.79140, 0.0003)
    reltol(GetSatVapPres(212), 14.7094, 0.0003)
    reltol(GetSatVapPres(300), 67.0206, 0.0003)
}

// # Test that the NR in GetTDewPointFromVapPres converges.
// # This test was known problem in versions of PsychroLib <= 2.0.0
func TestGetTDewPointFromVapPres_convergence_IP(t *testing.T) {
    SetUnitSystem(IP)
    for TDryBulb:=-148.0; TDryBulb<= 392.0; TDryBulb+=1.0 {
     for RelHum:=0.0; RelHum <= 1.0; RelHum+=0.1 {
      for Pressure:=8.6; Pressure <= 17.4; Pressure += 1.0 {
                GetTWetBulbFromRelHum(TDryBulb, RelHum, Pressure)
      }
     }
    }
}

// # Test saturation humidity ratio
// # The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
// # Agreement is not terrific - up to 2% difference with the values published in the table
func TestGetSatHumRatio_IP(t *testing.T) {
    SetUnitSystem(IP)
    reltol(GetSatHumRatio(-58, 14.696), 0.0000243, 0.01)
    reltol(GetSatHumRatio( -4, 14.696), 0.0006373, 0.01)
    reltol(GetSatHumRatio( 23, 14.696), 0.0024863, 0.005)
    reltol(GetSatHumRatio( 41, 14.696), 0.005425,  0.005)
    reltol(GetSatHumRatio( 77, 14.696), 0.020173,  0.005)
    reltol(GetSatHumRatio(122, 14.696), 0.086863,  0.01)
    reltol(GetSatHumRatio(185, 14.696), 0.838105,  0.02)
}

// # Test enthalpy at saturation
// # The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
// # Agreement is rarely better than 1%, and close to 3% at -5 C
func TestGetSatAirEnthalpy_IP(t *testing.T) {
    SetUnitSystem(IP)
    reltol(GetSatAirEnthalpy(-58, 14.696), -13.906, 0.01)
    reltol(GetSatAirEnthalpy( -4, 14.696),  -0.286, 0.01)
    reltol(GetSatAirEnthalpy( 23, 14.696),   8.186, 0.03)
    reltol(GetSatAirEnthalpy( 41, 14.696),  15.699, 0.01)
    reltol(GetSatAirEnthalpy( 77, 14.696),  40.576, 0.01)
    reltol(GetSatAirEnthalpy(122, 14.696), 126.066, 0.01)
    reltol(GetSatAirEnthalpy(185, 14.696), 999.749, 0.01)
}

// ###############################################################################
// # Test of primary relationships between wet bulb temperature, humidity ratio, vapour pressure, relative humidity, and dew point temperatures
// # These relationships are identified with bold arrows in the doc's diagram
// ###############################################################################

// # Test of relationships between vapour pressure and dew point temperature
// # No need to test vapour pressure calculation as it is just the saturation vapour pressure tested above
func TestVapPres_TDewPoint_IP(t *testing.T) {
    SetUnitSystem(IP)
    VapPres := GetVapPresFromTDewPoint(-4.0)
    abstol(GetTDewPointFromVapPres(59.0, VapPres), -4.0, 0.001)
    VapPres = GetVapPresFromTDewPoint(41.0)
    abstol(GetTDewPointFromVapPres(59.0, VapPres), 41.0, 0.001)
    VapPres = GetVapPresFromTDewPoint(122.0)
    abstol(GetTDewPointFromVapPres(140.0, VapPres), 122.0, 0.001)
}

// ## Test of relationships between humidity ratio and vapour pressure
// ## Humidity ratio values to test against are calculated with Excel
func TestHumRatio_VapPres_IP(t *testing.T) {
    SetUnitSystem(IP)
    HumRatio := GetHumRatioFromVapPres(0.45973, 14.175)         // # conditions at 77 F, std atm pressure at 1000 ft
    reltol(HumRatio, 0.0208473311024865, 0.000001)
    VapPres := GetVapPresFromHumRatio(HumRatio, 14.175)
    abstol(VapPres, 0.45973, 0.00001)
}

// ## Test of relationships between vapour pressure and relative humidity
func TestVapPres_RelHum_IP(t *testing.T) {
    SetUnitSystem(IP)
    VapPres := GetVapPresFromRelHum(77, 0.8)
    reltol(VapPres, 0.45973*0.8, 0.0003)
    RelHum := GetRelHumFromVapPres(77, VapPres)
    reltol(RelHum, 0.8, 0.0003)
}

// ## Test of relationships between humidity ratio and wet bulb temperature
// ## The formulae are tested for two conditions, one above freezing and the other below
// ## Humidity ratio values to test against are calculated with Excel
func TestHumRatio_TWetBulb_IP(t *testing.T) {
    SetUnitSystem(IP)
    // # Above freezing
    HumRatio := GetHumRatioFromTWetBulb(86, 77, 14.175)
    reltol(HumRatio, 0.0187193288418892, 0.0003)
    TWetBulb := GetTWetBulbFromHumRatio(86, HumRatio, 14.175)
    abstol(TWetBulb, 77, 0.001)
    // # Below freezing
    HumRatio = GetHumRatioFromTWetBulb(30.2, 23.0, 14.175)
    reltol(HumRatio, 0.00114657481090184, 0.0003)
    TWetBulb = GetTWetBulbFromHumRatio(30.2, HumRatio, 14.1751)
    abstol(TWetBulb, 23.0, 0.001)
    // # Low HumRatio -- this should evaluate true as we clamp the HumRation to 1e-07.
    ASSERT(GetTWetBulbFromHumRatio(25,1e-09,95461) == GetTWetBulbFromHumRatio(25,1e-07,95461), "Low HumRatio")
}


// ###############################################################################
// # Dry air calculations
// ###############################################################################

// # Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
// # Note: the accuracy of the formula is not better than 0.1%, apparently
func TestDryAir_IP(t *testing.T) {
    SetUnitSystem(IP)
    reltol(GetDryAirEnthalpy(77), 18.498, 0.001)
    reltol(GetDryAirVolume(77, 14.696), 13.5251, 0.001)
    reltol(GetDryAirDensity(77, 14.696), 1/13.5251, 0.001)
    abstol(GetTDryBulbFromEnthalpyAndHumRatio(42.6168, 0.02), 85.97, 0.05)
    reltol(GetHumRatioFromEnthalpyAndTDryBulb(42.6168, 86), 0.02, 0.001)
}

// ###############################################################################
// # Moist air calculations
// ###############################################################################

// # Values are compared against values calculated with Excel
func TestMoistAir_IP(t *testing.T) {
    SetUnitSystem(IP)
    reltol(GetMoistAirEnthalpy(86, 0.02), 42.6168, 0.0003)
    reltol(GetMoistAirVolume(86, 0.02, 14.175), 14.7205749002918, 0.0003)
    reltol(GetMoistAirDensity(86, 0.02, 14.175), 0.0692907720594378, 0.0003)
}

func TestGetTDryBulbFromMoistAirVolumeAndHumRatio_IP(t *testing.T) {
    SetUnitSystem(IP)
    reltol(GetTDryBulbFromMoistAirVolumeAndHumRatio(14.7205749002918, 0.02, 14.175), 86, 0.0003)
}

// ###############################################################################
// # Test standard atmosphere
// ###############################################################################

// # The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
func TestGetStandardAtmPressure_IP(t *testing.T) {
    SetUnitSystem(IP)
    abstol(GetStandardAtmPressure(-1000), 15.236, 1)
    abstol(GetStandardAtmPressure(    0), 14.696, 1)
    abstol(GetStandardAtmPressure( 1000), 14.175, 1)
    abstol(GetStandardAtmPressure( 3000), 13.173, 1)
    abstol(GetStandardAtmPressure(10000), 10.108, 1)
    abstol(GetStandardAtmPressure(30000),  4.371, 1)
}

func TestGetStandardAtmTemperature_IP(t *testing.T) {
    SetUnitSystem(IP)
    abstol(GetStandardAtmTemperature(-1000),  62.6, 0.1)
    abstol(GetStandardAtmTemperature(    0),  59.0, 0.1)
    abstol(GetStandardAtmTemperature( 1000),  55.4, 0.1)
    abstol(GetStandardAtmTemperature( 3000),  48.3, 0.1)
    abstol(GetStandardAtmTemperature(10000),  23.4, 0.1)
    abstol(GetStandardAtmTemperature(30000), -47.8, 0.2)          // # Doesn't work with 0.1
}

// ###############################################################################
// # Test sea level pressure conversions
// ###############################################################################

// # Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267,
// # converted to IP
func TestSeaLevel_Station_Pressure_IP(t *testing.T) {
    SetUnitSystem(IP)
    SeaLevelPressure := GetSeaLevelPressure(14.681662559, 344.488, 62.942)
    abstol(SeaLevelPressure, 14.8640475, 0.0001)
    abstol(GetStationPressure(SeaLevelPressure, 344.488, 62.942), 14.681662559, 0.0001)
}

// ###############################################################################
// # Test conversion between humidity types
// ###############################################################################

func TestGetSpecificHumFromHumRatio_IP(t *testing.T) {
    SetUnitSystem(IP)
    reltol(GetSpecificHumFromHumRatio(0.006), 0.00596421471, 0.01)
}

func TestGetHumRatioFromSpecificHum_IP(t *testing.T) {
    SetUnitSystem(IP)
    reltol(GetHumRatioFromSpecificHum(0.00596421471), 0.006, 0.01)
}



// ###############################################################################
// # Test against Example 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
// ###############################################################################

func TestAllPsychrometrics_IP(t *testing.T) {
    SetUnitSystem(IP)
    // # This is example 1. The values are provided in the text of the Handbook
    HumRatio, TDewPoint, RelHum, _, MoistAirEnthalpy, MoistAirVolume, _ := CalcPsychrometricsFromTWetBulb(100, 65, 14.696)
    abstol(HumRatio, 0.00523, 0.001)
    abstol(TDewPoint, 40, 1.0)             // # not great agreement
    abstol(RelHum, 0.13, 0.01)
    abstol(MoistAirEnthalpy, 29.80, 0.1)
    reltol(MoistAirVolume, 14.22, 0.01)

    // # Reverse calculation: recalculate wet bulb temperature from dew point temperature

    _, TWetBulb, _, _, _, _, _ := CalcPsychrometricsFromTDewPoint(100, TDewPoint, 14.696)
    abstol(TWetBulb, 65, 0.1)

    // # Reverse calculation: recalculate wet bulb temperature from relative humidity
    _, TWetBulb, _, _, _, _, _ = CalcPsychrometricsFromRelHum(100, RelHum, 14.696)
    abstol(TWetBulb, 65, 0.1)
}
