' PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
' Copyright (c) 2018-2020 The PsychroLib Contributors. Licensed under the MIT License.

' Test of PsychroLib in SI units
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
  Call test_GetTKelvinFromTCelsius
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
Sub test_GetTKelvinFromTCelsius()
  Call TestExpression("GetTKelvinFromTCelsius", GetTKelvinFromTCelsius(20), 293.15, 0.000001)
End Sub
Sub test_GetTCelsiusFromTKelvin()
  Call TestExpression("GetTCelsiusFromTKelvin", GetTCelsiusFromTKelvin(293.15), 20, 0.000001)
End Sub

'##############################################################################
' Tests at saturation
'##############################################################################

' Test saturation vapour pressure calculation
' The values are tested against the values published in Table 3 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
' over the range [-100, +200] C
' ASHRAE's assertion is that the formula is within 300 ppm of the true values, which is true except for the value at -60 C
Sub test_GetSatVapPres()
  Call TestExpression("GetSatVapPres", GetSatVapPres(-60), 1.08, abst:=0.01)
  Call TestExpression("GetSatVapPres", GetSatVapPres(-20), 103.24, relt:=0.0003)
  Call TestExpression("GetSatVapPres", GetSatVapPres(-5), 401.74, relt:=0.0003)
  Call TestExpression("GetSatVapPres", GetSatVapPres(5), 872.6, relt:=0.0003)
  Call TestExpression("GetSatVapPres", GetSatVapPres(25), 3169.7, relt:=0.0003)
  Call TestExpression("GetSatVapPres", GetSatVapPres(50), 12351.3, relt:=0.0003)
  Call TestExpression("GetSatVapPres", GetSatVapPres(100), 101418#, relt:=0.0003)
  Call TestExpression("GetSatVapPres", GetSatVapPres(150), 476101.4, relt:=0.0003)
End Sub

' Test saturation humidity ratio
' The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
' Agreement is not terrific - up to 2% difference with the values published in the table
Sub test_GetSatHumRatio()
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(-50, 101325), 0.0000243, relt:=0.01)
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(-20, 101325), 0.0006373, relt:=0.01)
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(-5, 101325), 0.0024863, relt:=0.005)
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(5, 101325), 0.005425, relt:=0.005)
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(25, 101325), 0.020173, relt:=0.005)
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(50, 101325), 0.086863, relt:=0.01)
  Call TestExpression("GetSatHumRatio", GetSatHumRatio(85, 101325), 0.838105, relt:=0.02)
End Sub

' Test enthalpy at saturation
' The values are tested against those published in Table 2 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
' Agreement is rarely better than 1%, and close to 3% at -5 C
Sub test_GetSatAirEnthalpy()
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(-50, 101325), -50222, relt:=0.01)
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(-20, 101325), -18542, relt:=0.01)
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(-5, 101325), 1164, relt:=0.03)
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(5, 101325), 18639, relt:=0.01)
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(25, 101325), 76504, relt:=0.01)
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(50, 101325), 275353, relt:=0.01)
  Call TestExpression("GetSatAirEnthalpy", GetSatAirEnthalpy(85, 101325), 2307539, relt:=0.01)
End Sub


'##############################################################################
' Test of primary relationships between wet bulb temperature, humidity ratio, vapour pressure, relative humidity, and dew point temperatures
' These relationships are identified with bold arrows in the doc's diagram
'##############################################################################

' Test of relationships between vapour pressure and dew point temperature
' No need to test vapour pressure calculation as it is just the saturation vapour pressure tested above
Sub test_VapPres_TDewPoint()
  VapPres = GetVapPresFromTDewPoint(-20#)
  Call TestExpression("GetTDewPointFromVapPres", GetTDewPointFromVapPres(15#, VapPres), -20#, abst:=0.001)
  VapPres = GetVapPresFromTDewPoint(5#)
  Call TestExpression("GetTDewPointFromVapPres", GetTDewPointFromVapPres(15#, VapPres), 5#, abst:=0.001)
  VapPres = GetVapPresFromTDewPoint(50#)
  Call TestExpression("GetTDewPointFromVapPres", GetTDewPointFromVapPres(60#, VapPres), 50#, abst:=0.001)
End Sub

' Test of relationships between wet bulb temperature and relative humidity
' This test was known to cause a convergence issue in GetTDewPointFromVapPres
' in versions of PsychroLib <= 2.0.0
Sub test_TWetBulb_RelHum()
TWetBulb = GetTWetBulbFromRelHum(7, 0.61, 100000)
Call TestExpression("GetTWetBulbFromRelHum", TWetBulb, 3.92667433781955, relt:=0.001)
End Sub

' Test of relationships between humidity ratio and vapour pressure
' Humidity ratio values to test against are calculated with Excel
Sub test_HumRatio_VapPres()
  HumRatio = GetHumRatioFromVapPres(3169.7, 95461)          ' conditions at 25 C, std atm pressure at 500 m
  Call TestExpression("GetHumRatioFromVapPres", HumRatio, 2.13603998047487E-02, relt:=0.000001)
  VapPres = GetVapPresFromHumRatio(HumRatio, 95461)
  Call TestExpression("GetHumRatioFromVapPres", VapPres, 3169.7, abst:=0.00001)
End Sub

' Test of relationships between vapour pressure and relative humidity
Sub test_VapPres_RelHum()
  VapPres = GetVapPresFromRelHum(25, 0.8)
  Call TestExpression("GetVapPresFromRelHum", VapPres, 3169.7 * 0.8, relt:=0.0003)
  RelHum = GetRelHumFromVapPres(25, VapPres)
  Call TestExpression("GetVapPresFromRelHum", RelHum, 0.8, relt:=0.0003)
End Sub

' Test of relationships between humidity ratio and wet bulb temperature
' The formulae are tested for two conditions, one above freezing and the other below
' Humidity ratio values to test against are calculated with Excel
Sub test_HumRatio_TWetBulb()
  ' Above freezing
  HumRatio = GetHumRatioFromTWetBulb(30, 25, 95461)
  Call TestExpression("GetHumRatioFromTWetBulb", HumRatio, 1.92281274241096E-02, relt:=0.0003)
  TWetBulb = GetTWetBulbFromHumRatio(30, HumRatio, 95461)
  Call TestExpression("GetHumRatioFromTWetBulb", TWetBulb, 25, abst:=0.001)
  ' Below freezing
  HumRatio = GetHumRatioFromTWetBulb(-1, -5, 95461)
  Call TestExpression("GetHumRatioFromTWetBulb", HumRatio, 1.20399819933844E-03, relt:=0.0003)
  TWetBulb = GetTWetBulbFromHumRatio(-1, HumRatio, 95461)
  Call TestExpression("GetHumRatioFromTWetBulb", TWetBulb, -5, abst:=0.001)
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
  Call TestExpression("GetDryAirEnthalpy", GetDryAirEnthalpy(25), 25148, relt:=0.0003)
  Call TestExpression("GetDryAirVolume", GetDryAirVolume(25, 101325), 0.8443, relt:=0.001)
  Call TestExpression("GetDryAirDensity", GetDryAirDensity(25, 101325), 1 / 0.8443, relt:=0.001)
  Call TestExpression("GetTDryBulbFromEnthalpyAndHumRatio", GetTDryBulbFromEnthalpyAndHumRatio(81316, 0.02), 30, abst:=0.001)
  Call TestExpression("GetHumRatioFromEnthalpyAndTDryBulb", GetHumRatioFromEnthalpyAndTDryBulb(81316, 30), 0.02, relt:=0.001)
End Sub


'##############################################################################
' Moist air calculations
'##############################################################################

' Values are compared against values calculated with Excel
Sub test_MoistAir()
  Call TestExpression("GetMoistAirEnthalpy", GetMoistAirEnthalpy(30, 0.02), 81316, relt:=0.0003)
  Call TestExpression("GetMoistAirVolume", GetMoistAirVolume(30, 0.02, 95461), 0.940855374352943, relt:=0.0003)
  Call TestExpression("GetMoistAirDensity", GetMoistAirDensity(30, 0.02, 95461), 1.08411986348219, relt:=0.0003)
End Sub

Sub test_GetTDryBulbFromMoistAirVolumeAndHumRatio()
  Call TestExpression("GetTDryBulbFromMoistAirVolumeAndHumRatio", GetTDryBulbFromMoistAirVolumeAndHumRatio(0.940855374352943, 0.02, 95461), 30, relt:=0.0003)
End Sub

'##############################################################################
' Test standard atmosphere
'##############################################################################

' The functions are tested against Table 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
Sub test_GetStandardAtmPressure()
  Call TestExpression("GetStandardAtmPressure", GetStandardAtmPressure(-500), 107478, abst:=1)
  Call TestExpression("GetStandardAtmPressure", GetStandardAtmPressure(0), 101325, abst:=1)
  Call TestExpression("GetStandardAtmPressure", GetStandardAtmPressure(500), 95461, abst:=1)
  Call TestExpression("GetStandardAtmPressure", GetStandardAtmPressure(1000), 89875, abst:=1)
  Call TestExpression("GetStandardAtmPressure", GetStandardAtmPressure(4000), 61640, abst:=1)
  Call TestExpression("GetStandardAtmPressure", GetStandardAtmPressure(10000), 26436, abst:=1)
End Sub

Sub test_GetStandardAtmTemperature()
  Call TestExpression("GetStandardAtmTemperature", GetStandardAtmTemperature(-500), 18.2, abst:=0.1)
  Call TestExpression("GetStandardAtmTemperature", GetStandardAtmTemperature(0), 15#, abst:=0.1)
  Call TestExpression("GetStandardAtmTemperature", GetStandardAtmTemperature(500), 11.8, abst:=0.1)
  Call TestExpression("GetStandardAtmTemperature", GetStandardAtmTemperature(1000), 8.5, abst:=0.1)
  Call TestExpression("GetStandardAtmTemperature", GetStandardAtmTemperature(4000), -11#, abst:=0.1)
  Call TestExpression("GetStandardAtmTemperature", GetStandardAtmTemperature(10000), -50#, abst:=0.1)
End Sub


'##############################################################################
' Test sea level pressure conversions
'##############################################################################

' Test sea level pressure calculation against https://keisan.casio.com/exec/system/1224575267
Sub test_SeaLevel_Station_Pressure()
  SeaLevelPressure = GetSeaLevelPressure(101226.5, 105, 17.19)
  Call TestExpression("SeaLevelPressure", SeaLevelPressure, 102484#, abst:=1)
  Call TestExpression("GetStationPressure", GetStationPressure(SeaLevelPressure, 105, 17.19), 101226.5, abst:=1)
End Sub


'##############################################################################
' Test against Example 1 of ch. 1 of the 2017 ASHRAE Handbook - Fundamentals
'##############################################################################

Sub test_AllPsychrometrics()
  Dim TDryBlub As Variant, TWetBulb As Variant, TDewPoint As Variant, RelHum As Variant, HumRatio As Variant
  Dim VapPres As Variant, MoistAirEnthalpy As Variant, MoistAirVolume As Variant, DegreeOfSaturation As Variant
  Dim AtmPres As Variant

  TDryBulb = 40
  TWetBulb = 20
  AtmPres = 101325

  ' This is example 1. The values are provided in the text of the Handbook
  Call CalcPsychrometricsFromTWetBulb(TDryBulb, TWetBulb, AtmPres, HumRatio, TDewPoint, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation)
  Call TestExpression("CalcPsychrometricsFromTWetBulb", HumRatio, 0.0065, abst:=0.0001)
  Call TestExpression("CalcPsychrometricsFromTWetBulb", MoistAirEnthalpy, 56700, abst:=100)
  Call TestExpression("CalcPsychrometricsFromTWetBulb", TDewPoint, 7, abst:=0.5)             ' not great agreement
  Call TestExpression("CalcPsychrometricsFromTWetBulb", RelHum, 0.14, abst:=0.01)
  Call TestExpression("CalcPsychrometricsFromTWetBulb", MoistAirVolume, 0.896, relt:=0.01)

  ' Reverse calculation: recalculate wet bulb temperature from dew point temperature
  Call CalcPsychrometricsFromTDewPoint(TDryBulb, TDewPoint, AtmPres, HumRatio, TWetBulb, RelHum, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation)
  Call TestExpression("CalcPsychrometricsFromTDewPoint", TWetBulb, 20, abst:=0.1)

  ' Reverse calculation: recalculate wet bulb temperature from relative humidity
  Call CalcPsychrometricsFromRelHum(TDryBulb, RelHum, AtmPres, HumRatio, TWetBulb, TDewPoint, VapPres, MoistAirEnthalpy, MoistAirVolume, DegreeOfSaturation)
  Call TestExpression("CalcPsychrometricsFromRelHum", TWetBulb, 20, abst:=0.1)
End Sub

'##############################################################################
' Test of the convergence of the NR method in GetTDewPointFromVapPres
' over a wide range of inputs
' This test was known problem in versions of PsychroLib <= 2.0.0
'##############################################################################
'
Sub test_GetTDewPointFromVapPres_convergence()
  For TDryBulb = -100 To 200 Step 1
    For RelHum = 0 To 1 Step 0.1
      For Pressure = 60000 To 120000 Step 10000
        TWetBulb = GetTWetBulbFromRelHum(TDryBulb, RelHum, Pressure)
      Next Pressure
    Next RelHum
  Next TDryBulb
  Call TestExpression("GetTDewPointFromVapPres convergence test", 1, 1, abst:=0.1)
End Sub

