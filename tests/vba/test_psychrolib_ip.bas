' PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
' Copyright (c) 2018-2020 The PsychroLib Contributors. Licensed under the MIT License.

' Test of PsychroLib in IP units
'
' This series of test is modeled after the ones used with pytest
' for the Python version of the library

' Global variable to record the number of issues
Dim IssueCount As Variant
Dim TestCount As Variant

' Run all the tests
Sub RunAllTests()
  IssueCount = 0
  TestCount = 0
  Call test_GetTRankineFromTFahrenheit
  Call test_GetSatVapPres
  Call test_GetSatHumRatio
  Call test_GetSatAirEnthalpy
  Call test_VapPres_TDewPoint
  Call test_HumRatio_VapPres
  Call test_VapPres_RelHum
  Call test_HumRatio_TWetBulb
  Call test_HumRatio_SpecificHum
  Call test_DryAir
  Call test_MoistAir
  Call test_GetStandardAtmPressure
  Call test_GetStandardAtmTemperature
  Call test_SeaLevel_Station_Pressure
  Call test_AllPsychrometrics
  Call test_GetTDewPointFromVapPres_convergence
  Debug.Print "# of tests run   :", TestCount
  Debug.Print "# of issues found:", IssueCount
End Sub

' Test one expression
' Check that Value and Target do not differ by more than abst in an absolute way, or relt in a relative way
' Print Expression and the test result to the immediate window
Sub TestExpression(Expression As String, Value As Variant, Target As Variant, Optional abst As Variant = -1, Optional relt As Variant = -1)
  Dim Tol As Variant, rel As Variant
  TestCount = TestCount + 1
  If abst <> -1 And relt = -1 Then
    Tol = abst
    rel = 0
  ElseIf relt <> -1 And abst = -1 Then
    Tol = relt
    rel = 1
  Else
    Debug.Print Expression, "Undefined test!"
    IssueCount = IssueCount + 1
    Exit Sub
  End If

  If (Abs(Value - Target) < (Tol * Abs(Target) * rel + Tol * (1 - rel))) Then
    Debug.Print Expression, " --> Passed"
  Else
    Debug.Print Expression, " *** FAILED ***"
    Debug.Print "   Value = ", Value, "   Target = ", Target
    IssueCount = IssueCount + 1
  End If
End Sub

' Test of helper functions
Sub test_GetTRankineFromTFahrenheit()
  Call TestExpression("GetTRankineFromTFahrenheit", GetTRankineFromTFahrenheit(70), 529.67, relt:=0.000001)
End Sub
Sub test_GetTFahrenheitFromTRankine()
  Call TestExpression("GetTFahrenheitFromTRankine", GetTFahrenheitFromTRankine(529.67), 70.0, relt:=0.000001)
End Sub

'
'###############################################################################
'' Tests at saturation
'###############################################################################
'
'' Test saturation vapour pressure calculation
'' The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
'' over the range [-148, +392] F
'' ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -76 F
Sub test_GetSatVapPres()
  Call TestExpression("GetSatVapPres", GetSatVapPres(-76), 0.000157, abst:=0.00001)
  Call TestExpression("GetSatVapPres", GetSatVapPres(-4), 0.014974, relt:=0.0003)
  Call TestExpression("GetSatVapPres", GetSatVapPres(23), 0.058268, relt:=0.0003)
  Call TestExpression("GetSatVapPres", GetSatVapPres(41), 0.12656, relt:=0.0003)
  Call TestExpression("GetSatVapPres", GetSatVapPres(77), 0.45973, relt:=0.0003)
  Call TestExpression("GetSatVapPres", GetSatVapPres(122), 1.7914, relt:=0.0003)
  Call TestExpression("GetSatVapPres", GetSatVapPres(212), 14.7094, relt:=0.0003)
  Call TestExpression("GetSatVapPres", GetSatVapPres(300), 67.0206, relt:=0.0003)
End Sub

' Test saturation humidity ratio
' The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
' Agreement is not terrific - up to 2% difference with the values published in the table
Sub test_GetSatHumRatio()
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(-58, 14.696), 0.0000243, relt:=0.01)
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(-4, 14.696), 0.0006373, relt:=0.01)
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(23, 14.696), 0.0024863, relt:=0.005)
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(41, 14.696), 0.005425, relt:=0.005)
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(77, 14.696), 0.020173, relt:=0.005)
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(122, 14.696), 0.086863, relt:=0.01)
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(185, 14.696), 0.838105, relt:=0.02)
End Sub

' Test enthalpy at saturation
' The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
' Agreement is rarely better than 1%, and close to 3% at -5 C
Sub test_GetSatAirEnthalpy()
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(-58, 14.696), -13.906, relt:=0.01)
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(-4, 14.696), -0.286, relt:=0.01)
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(23, 14.696), 8.186, relt:=0.03)
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(41, 14.696), 15.699, relt:=0.01)
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(77, 14.696), 40.576, relt:=0.01)
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(122, 14.696), 126.066, relt:=0.01)
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(185, 14.696), 999.749, relt:=0.01)
End Sub

'##############################################################################
' Test of primary relationships between wet bulb temperature, humidity ratio, vapour pressure, relative humidity, and dew point temperatures
' These relationships are identified with bold arrows in the doc's diagram
'##############################################################################

' Test of relationships between vapour pressure and dew point temperature
' No need to test vapour pressure calculation as it is just the saturation vapour pressure tested above
Sub test_VapPres_TDewPoint()
  VapPres = GetVapPresFromTDewPoint(-4)
  Call TestExpression("GetTDewPointFromVapPres", GetTDewPointFromVapPres(59#, VapPres), -4#, abst:=0.001)
    VapPres = GetVapPresFromTDewPoint(41)
  Call TestExpression("GetTDewPointFromVapPres", GetTDewPointFromVapPres(59#, VapPres), 41#, abst:=0.001)
    VapPres = GetVapPresFromTDewPoint(122)
  Call TestExpression("GetTDewPointFromVapPres", GetTDewPointFromVapPres(140#, VapPres), 122#, abst:=0.001)
End Sub

' Test of relationships between humidity ratio and vapour pressure
' Humidity ratio values to test against are calculated with Excel
Sub test_HumRatio_VapPres()
  HumRatio = GetHumRatioFromVapPres(0.45973, 14.175)          ' conditions at 77 F, std atm pressure at 1000 ft
  Call TestExpression("GetHumRatioFromVapPres", HumRatio, 2.08473311024865E-02, relt:=0.000001)
  VapPres = GetVapPresFromHumRatio(HumRatio, 14.175)
  Call TestExpression("GetHumRatioFromVapPres", VapPres, 0.45973, abst:=0.00001)
End Sub

' Test of relationships between vapour pressure and relative humidity
Sub test_VapPres_RelHum()
  VapPres = GetVapPresFromRelHum(77, 0.8)
  Call TestExpression("GetVapPresFromRelHum", VapPres, 0.45973 * 0.8, relt:=0.0003)
  RelHum = GetRelHumFromVapPres(77, VapPres)
  Call TestExpression("GetVapPresFromRelHum", RelHum, 0.8, relt:=0.0003)
End Sub

' Test of relationships between humidity ratio and wet bulb temperature
' The formulae are tested for two conditions, one above freezing and the other below
' Humidity ratio values to test against are calculated with Excel
Sub test_HumRatio_TWetBulb()
  ' Above freezing
  HumRatio = GetHumRatioFromTWetBulb(86, 77, 14.175)
  Call TestExpression("GetHumRatioFromTWetBulb", HumRatio, 1.87193288418892E-02, relt:=0.0003)
  TWetBulb = GetTWetBulbFromHumRatio(86, HumRatio, 14.175)
  Call TestExpression("GetHumRatioFromTWetBulb", TWetBulb, 77, abst:=0.001)
  ' Below freezing
  HumRatio = GetHumRatioFromTWetBulb(30.2, 23#, 14.175)
  Call TestExpression("GetHumRatioFromTWetBulb", HumRatio, 1.14657481090184E-03, relt:=0.0003)
  TWetBulb = GetTWetBulbFromHumRatio(30.2, HumRatio, 14.1751)
  Call TestExpression("GetHumRatioFromTWetBulb", TWetBulb, 23#, abst:=0.001)
End Sub


' Test of relationships between humidity ratio and specific humidity
Sub test_HumRatio_SpecificHum()
  SpecificHum = GetSpecificHumFromHumRatio(0.006)
  Call TestExpression("GetSpecificHumFromHumRatio", SpecificHum, 0.00596421471, relt:=0.001)
  HumRatio = GetHumRatioFromSpecificHum(0.00596421471)
  Call TestExpression("GetHumRatioFromSpecificHum", HumRatio, 0.006, relt:=0.001)
End Sub


'##############################################################################
' Dry air calculations
'##############################################################################

' Values are compared against values found in Table 2 of ch. 1 of the ASHRAE Handbook - Fundamentals
' Note: the accuracy of the formula is not better than 0.1%, apparently
Sub test_DryAir()
  Call TestExpression("GetDryAirEnthalpy", GetDryAirEnthalpy(77), 18.498, relt:=0.001)
  Call TestExpression("GetDryAirEnthalpy", GetDryAirVolume(77, 14.696), 13.5251, relt:=0.001)
  Call TestExpression("GetDryAirEnthalpy", GetDryAirDensity(77, 14.696), 1 / 13.5251, relt:=0.001)
  Call TestExpression("GetTDryBulbFromEnthalpyAndHumRatio", GetTDryBulbFromEnthalpyAndHumRatio(42.6168, 0.02), 86, abst:=0.05)
  Call TestExpression("GetHumRatioFromEnthalpyAndTDryBulb", GetHumRatioFromEnthalpyAndTDryBulb(42.6168, 86), 0.02, relt:=0.001)
End Sub


'##############################################################################
' Moist air calculations
'##############################################################################

' Values are compared against values calculated with Excel
Sub test_MoistAir()
  Call TestExpression("GetMoistAirEnthalpy", GetMoistAirEnthalpy(86, 0.02), 42.6168, relt:=0.0003)
  Call TestExpression("GetMoistAirEnthalpy", GetMoistAirVolume(86, 0.02, 14.175), 14.7205749002918, relt:=0.0003)
  Call TestExpression("GetMoistAirEnthalpy", GetMoistAirDensity(86, 0.02, 14.175), 6.92907720594378E-02, relt:=0.0003)
End Sub

Sub test_GetTDryBulbFromMoistAirVolumeAndHumRatio()
  Call TestExpression("GetTDryBulbFromMoistAirVolumeAndHumRatio", GetTDryBulbFromMoistAirVolumeAndHumRatio(14.7205749002918, 0.02, 14.175), 86, relt:=0.0003)
End Sub

'##############################################################################
' Test standard atmosphere
'##############################################################################

' The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
Sub test_GetStandardAtmPressure()
  Call TestExpression("GetStandardAtmPressure", GetStandardAtmPressure(-1000), 15.236, abst:=1)
  Call TestExpression("GetStandardAtmPressure", GetStandardAtmPressure(0), 14.696, abst:=1)
  Call TestExpression("GetStandardAtmPressure", GetStandardAtmPressure(1000), 14.175, abst:=1)
  Call TestExpression("GetStandardAtmPressure", GetStandardAtmPressure(3000), 13.173, abst:=1)
  Call TestExpression("GetStandardAtmPressure", GetStandardAtmPressure(10000), 10.108, abst:=1)
  Call TestExpression("GetStandardAtmPressure", GetStandardAtmPressure(30000), 4.371, abst:=1)
End Sub

Sub test_GetStandardAtmTemperature()
  Call TestExpression("GetStandardAtmTemperature", GetStandardAtmTemperature(-1000), 62.6, abst:=0.1)
  Call TestExpression("GetStandardAtmTemperature", GetStandardAtmTemperature(0), 59#, abst:=0.1)
  Call TestExpression("GetStandardAtmTemperature", GetStandardAtmTemperature(1000), 55.4, abst:=0.1)
  Call TestExpression("GetStandardAtmTemperature", GetStandardAtmTemperature(3000), 48.3, abst:=0.1)
  Call TestExpression("GetStandardAtmTemperature", GetStandardAtmTemperature(10000), 23.4, abst:=0.1)
  Call TestExpression("GetStandardAtmTemperature", GetStandardAtmTemperature(30000), -47.8, abst:=0.2)          ' Doesn't work with abs = 0.1
End Sub


'##############################################################################
' Test sea level pressure conversions
'##############################################################################

' Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267,
' converted to IP
Sub test_SeaLevel_Station_Pressure()
  SeaLevelPressure = GetSeaLevelPressure(14.681662559, 344.488, 62.942)
  Call TestExpression("GetSeaLevelPressure", SeaLevelPressure, 14.8640475, abst:=0.0001)
  Call TestExpression("GetStationPressure", GetStationPressure(SeaLevelPressure, 344.488, 62.942), 14.681662559, abst:=0.0001)
End Sub


'##############################################################################
' Test against Example 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
'##############################################################################

Sub test_AllPsychrometrics()
  Dim TDryBlub As Variant, TWetBulb As Variant, TDewPoint As Variant, RelHum As Variant, HumRatio As Variant
  Dim VapPres As Variant, MoistAirEnthalpy As Variant, MoistAirVolume As Variant, DegreeOfSaturation As Variant
  Dim AtmPres As Variant

  TDryBulb = 100
  TWetBulb = 65
  AtmPres = 14.696

  ' This is example 1. The values are provided in the text of the Handbook
  Call CalcPsychrometricsFromTWetBulb(TDryBulb, TWetBulb, AtmPres, HumRatio, TDewPoint, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation)
  Call TestExpression("CalcPsychrometricsFromTWetBulb", HumRatio, 0.00523, abst:=0.001)
  Call TestExpression("CalcPsychrometricsFromTWetBulb", MoistAirEnthalpy, 29.8, abst:=0.1)
  Call TestExpression("CalcPsychrometricsFromTWetBulb", TDewPoint, 40, abst:=1)              ' not great agreement
  Call TestExpression("CalcPsychrometricsFromTWetBulb", RelHum, 0.13, abst:=0.01)
  Call TestExpression("CalcPsychrometricsFromTWetBulb", MoistAirVolume, 14.22, relt:=0.01)

    ' Reverse calculation: recalculate wet bulb temperature from dew point temperature
  Call CalcPsychrometricsFromTDewPoint(TDryBulb, TDewPoint, AtmPres, HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation)
  Call TestExpression("CalcPsychrometricsFromTDewPoint", TWetBulb, 65, abst:=0.1)

   ' Reverse calculation: recalculate wet bulb temperature from relative humidity
  Call CalcPsychrometricsFromRelHum(TDryBulb, RelHum, AtmPres, HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation)
  Call TestExpression("CalcPsychrometricsFromRelHum", TWetBulb, 65, abst:=0.1)
End Sub


'##############################################################################
' Test of the convergence of the NR method in GetTDewPointFromVapPres
' over a wide range of inputs
' This test was known problem in versions of PsychroLib <= 2.0.0
'##############################################################################
'
Sub test_GetTDewPointFromVapPres_convergence()
  For TDryBulb = -148 To 392 Step 2
    For RelHum = 0 To 1 Step 0.1
      For Pressure = 8.6 To 17.4 Step 0.8
        TWetBulb = GetTWetBulbFromRelHum(TDryBulb, RelHum, Pressure)
      Next Pressure
    Next RelHum
  Next TDryBulb
  Call TestExpression("GetTDewPointFromVapPres convergence test", 1, 1, abst:=0.1)
End Sub
