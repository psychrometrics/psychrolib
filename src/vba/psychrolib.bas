' PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
' Copyright (c) 2018-2020 The PsychroLib Contributors for the current library implementation.
' Copyright (c) 2017 ASHRAE Handbook — Fundamentals for ASHRAE equations and coefficients.
' Licensed under the MIT License.
'
' psychrolib.vba
'
' Contains functions for calculating thermodynamic properties of gas-vapor mixtures
' and standard atmosphere suitable for most engineering, physical and meteorological
' applications.
'
' Most of the functions are an implementation of the formulae found in the
' 2017 ASHRAE Handbook - Fundamentals, in both International System (SI),
' and Imperial (IP) units. Please refer to the information included in
' each function for their respective reference.
'
' Example
'     ' Set the unit system, for example to SI (can be either ' SI'  or ' IP' )
'     ' by uncommenting the following line in the psychrolib module
'     Const PSYCHROLIB_UNITS = UnitSystem.SI
'
'     ' Calculate the dew point temperature for a dry bulb temperature of 25 C and a relative humidity of 80%
'     TDewPoint = GetTDewPointFromRelHum(25.0, 0.80)
'     Debug.Print(TDewPoint)
'     21.309397163661785
'
' Copyright
'     - For the current library implementation
'         Copyright (c) 2018-2020 The PsychroLib Contributors.
'     - For equations and coefficients published ASHRAE Handbook — Fundamentals, Chapter 1
'         Copyright (c) 2017 ASHRAE Handbook — Fundamentals (https://www.ashrae.org)
'
' License
'     MIT (https://github.com/psychrometrics/psychrolib/LICENSE.txt)
'
' Note from the Authors
'     We have made every effort to ensure that the code is adequate, however, we make no
'     representation with respect to its accuracy. Use at your own risk. Should you notice
'     an error, or if you have a suggestion, please notify us through GitHub at
'     https://github.com/psychrometrics/psychrolib/issues.
'

Option Explicit


'******************************************************************************************************
' IMPORTANT: Manually uncomment the system of units to use
'******************************************************************************************************

'Enumeration to define systems of units
Enum UnitSystem
  IP = 1
  SI = 2
End Enum

' Uncomment one of these two lines to define the system of units ("IP" or "SI")
'Const PSYCHROLIB_UNITS = UnitSystem.IP
'Const PSYCHROLIB_UNITS = UnitSystem.SI


'******************************************************************************************************
' Global constants
'******************************************************************************************************

Private Const ZERO_FAHRENHEIT_AS_RANKINE = 459.67   ' Zero degree Fahrenheit (°F) expressed as degree Rankine (°R).
                                                    'Reference: ASHRAE Handbook - Fundamentals (2017) ch. 39.

Private Const ZERO_CELSIUS_AS_KELVIN = 273.15       ' Zero degree Celsius (°C) expressed as Kelvin (K).
                                                    ' Reference: ASHRAE Handbook - Fundamentals (2017) ch. 39.

Private Const R_DA_IP = 53.35                 ' Universal gas constant for dry air (IP version) in ft lbf/lb_DryAir/R.

Private Const R_DA_SI = 287.042               ' Universal gas constant for dry air (SI version) in J/kg_DryAir/K.

Private Const MAX_ITER_COUNT = 100            ' Maximum number of iterations before exiting while loops.

Private Const MIN_HUM_RATIO = 1e-7            ' Minimum acceptable humidity ratio used/returned by any functions.
                                              ' Any value above 0 or below the MIN_HUM_RATIO will be reset to this value.

Private Const FREEZING_POINT_WATER_IP = 32.0  ' Freezing point of water, in °F

Private Const FREEZING_POINT_WATER_SI = 0.0   ' Freezing point of water, in °C

Private Const TRIPLE_POINT_WATER_IP = 32.018  ' Triple point of water, in °F

Private Const TRIPLE_POINT_WATER_SI = 0.01    ' Triple point of water, in °C

'******************************************************************************************************
' Helper functions
'******************************************************************************************************

Function GetUnitSystem() As UnitSystem
'
' This function returns the system of units currently in use (SI or IP).
'
' Args:
'        none
'
' Returns:
'        The system of units currently in use ('SI' or 'IP')
'
' Note:
'
'        If you get an error here, it's because you have not uncommented one of the two lines
'        defining PSYCHROLIB_UNITS (see Global Constants section)
'
    GetUnitSystem = PSYCHROLIB_UNITS

End Function

Private Function isIP() As Variant
'
' This function checks whether the system of units currently in use is IP or SI.
'
' Args:
'         none
'
' Returns:
'         True if IP, False if SI, and raises error if undefined
'
  If (PSYCHROLIB_UNITS = UnitSystem.IP) Then
    isIP = True
  ElseIf (PSYCHROLIB_UNITS = UnitSystem.SI) Then
    isIP = False
  Else
    MsgBox ("The system of units has not been defined.")
    isIP = CVErr(xlErrNA)
  End If

End Function

Private Function GetTol() As Variant
'
' This function returns the tolerance on temperatures used for iterative solving.
' The value is physically the same in IP or SI.
'
' Args:
'         none
'
' Returns:
'         Tolerance on temperatures
'
  If (PSYCHROLIB_UNITS = UnitSystem.IP) Then
    GetTol = 0.001 * 9 / 5
  Else
    GetTol = 0.001
  End If
End Function

Private Sub MyMsgBox(ByVal ErrMsg As String)
'
' Error message output
' Override this function with your own if needed, or comment its code out if you don't want to see the messages
'
' Message disabled by default
'  MsgBox (ErrMsg)

End Sub

Private Function Min(ByVal Num1 As Variant, ByVal Num2 As Variant) As Variant
'
' Min function to return minimum of two numbers
'
  If (Num1 <= Num2) Then
    Min = Num1
  Else
    Min = Num2
  End If

End Function

Private Function Max(ByVal Num1 As Variant, ByVal Num2 As Variant) As Variant
'
' Max function to return maximum of two numbers
'
  If (Num1 >= Num2) Then
    Max = Num1
  Else
    Max = Num2
  End If

End Function


'*****************************************************************************
' Conversions between temperature units
'*****************************************************************************

Function GetTRankineFromTFahrenheit(ByVal T_Fahrenheit As Variant) As Variant
'
' Utility function to convert temperature to degree Rankine (°R)
' given temperature in degree Fahrenheit (°F).
'
'Args:
'        T_Fahrenheit: Temperature in degree Fahrenheit (°F)
'
'Returns:
'        Temperature in degree Rankine (°R)
'
'Reference:
'        Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
'
'Notes:
'        Exact conversion.
'
  On Error GoTo ErrHandler

  GetTRankineFromTFahrenheit = (T_Fahrenheit + ZERO_FAHRENHEIT_AS_RANKINE)
  Exit Function

ErrHandler:
  GetTRankineFromTFahrenheit = CVErr(xlErrNA)

End Function

Function GetTFahrenheitFromTRankine(ByVal T_Rankine As Variant) As Variant
'
' Utility function to convert temperature to degree Fahrenheit (°F)
' given temperature in degree Rankine (°R).
'
'Args:
'        TRankine: Temperature in degree Rankine (°R)
'
'Returns:
'        Temperature in degree Fahrenheit (°F)
'
'Reference:
'        Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
'
'Notes:
'        Exact conversion.
'
  On Error GoTo ErrHandler

  GetTFahrenheitFromTRankine = (T_Rankine - ZERO_FAHRENHEIT_AS_RANKINE)
  Exit Function

ErrHandler:
  GetTFahrenheitFromTRankine = CVErr(xlErrNA)

End Function

Function GetTKelvinFromTCelsius(ByVal T_Celsius As Variant) As Variant
'
' Utility function to convert temperature to Kelvin (K)
' given temperature in degree Celsius (°C).
'
'Args:
'        TCelsius: Temperature in degree Celsius (°C)
'
'Returns:
'        Temperature in Kelvin (K)
'
'Reference:
'        Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
'
'Notes:
'        Exact conversion.
'
  On Error GoTo ErrHandler

  GetTKelvinFromTCelsius = (T_Celsius + ZERO_CELSIUS_AS_KELVIN)
  Exit Function

ErrHandler:
  GetTKelvinFromTCelsius = CVErr(xlErrNA)

End Function

Function GetTCelsiusFromTKelvin(ByVal T_Kelvin As Variant) As Variant
'
' Utility function to convert temperature to degree Celsius (°C)
' given temperature in Kelvin (K).
'
'Args:
'        TKelvin: Temperature in Kelvin (K)
'
'Returns:
'        Temperature in degree Celsius (°C)
'
'Reference:
'        Reference: ASHRAE Handbook - Fundamentals (2017) ch. 1 section 3
'
'Notes:
'        Exact conversion.
'
  On Error GoTo ErrHandler

  GetTCelsiusFromTKelvin = (T_Kelvin - ZERO_CELSIUS_AS_KELVIN)
  Exit Function

ErrHandler:
  GetTCelsiusFromTKelvin = CVErr(xlErrNA)

End Function


'******************************************************************************************************
' Conversions between dew point, wet bulb, and relative humidity
'******************************************************************************************************

Function GetTWetBulbFromTDewPoint(ByVal TDryBulb As Variant, ByVal TDewPoint As Variant, ByVal Pressure As Variant) As Variant
'
' Return wet-bulb temperature given dry-bulb temperature, dew-point temperature, and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Wet-bulb temperature in °F [IP] or °C [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1
'
  Dim HumRatio As Variant

  On Error GoTo ErrHandler

  If TDewPoint > TDryBulb Then
    MyMsgBox ("Dew point temperature is above dry bulb temperature")
    GoTo ErrHandler
  End If

  HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure)
  GetTWetBulbFromTDewPoint = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
  Exit Function

ErrHandler:
  GetTWetBulbFromTDewPoint = CVErr(xlErrNA)

End Function

Function GetTWetBulbFromRelHum(ByVal TDryBulb As Variant, ByVal RelHum As Variant, ByVal Pressure As Variant) As Variant
'
' Return wet-bulb temperature given dry-bulb temperature, relative humidity, and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        RelHum : Relative humidity in range [0, 1]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Wet-bulb temperature in °F [IP] or °C [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1
'
  Dim HumRatio As Variant

  On Error GoTo ErrHandler

  If (RelHum < 0 Or RelHum > 1) Then
    MyMsgBox ("Relative humidity is outside range [0,1]")
    GoTo ErrHandler
  End If

  HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure)
  GetTWetBulbFromRelHum = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
  Exit Function

ErrHandler:
  GetTWetBulbFromRelHum = CVErr(xlErrNA)

End Function

Function GetRelHumFromTDewPoint(ByVal TDryBulb As Variant, ByVal TDewPoint As Variant) As Variant
'
' Return relative humidity given dry-bulb temperature and dew-point temperature.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]
'
' Returns:
'        Relative humidity in range [0, 1]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 22
'
  Dim VapPres As Variant
  Dim SatVapPres As Variant

  On Error GoTo ErrHandler

  If (TDewPoint > TDryBulb) Then
    MyMsgBox ("Dew point temperature is above dry bulb temperature")
    GoTo ErrHandler
  End If

  VapPres = GetSatVapPres(TDewPoint)
  SatVapPres = GetSatVapPres(TDryBulb)
  GetRelHumFromTDewPoint = VapPres / SatVapPres
  Exit Function

ErrHandler:
  GetRelHumFromTDewPoint = CVErr(xlErrNA)

End Function

Function GetRelHumFromTWetBulb(ByVal TDryBulb As Variant, ByVal TWetBulb As Variant, ByVal Pressure As Variant) As Variant
'
' Return relative humidity given dry-bulb temperature, wet bulb temperature and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        TWetBulb : Wet-bulb temperature in °F [IP] or °C [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Relative humidity in range [0, 1]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1
'
  Dim HumRatio As Variant

  On Error GoTo ErrHandler

  If TWetBulb > TDryBulb Then
    MyMsgBox ("Wet bulb temperature is above dry bulb temperature")
    GoTo ErrHandler
  End If

  HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
  GetRelHumFromTWetBulb = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
  Exit Function

ErrHandler:
  GetRelHumFromTWetBulb = CVErr(xlErrNA)

End Function

Function GetTDewPointFromRelHum(ByVal TDryBulb As Variant, ByVal RelHum As Variant) As Variant
'
' Return dew-point temperature given dry-bulb temperature and relative humidity.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        RelHum: Relative humidity in range [0, 1]
'
' Returns:
'        Dew-point temperature in °F [IP] or °C [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1
'

  Dim VapPres As Variant

  On Error GoTo ErrHandler

  If RelHum < 0 Or RelHum > 1 Then
    MyMsgBox ("Relative humidity is outside range [0, 1]")
    GoTo ErrHandler
  End If

  VapPres = GetVapPresFromRelHum(TDryBulb, RelHum)
  GetTDewPointFromRelHum = GetTDewPointFromVapPres(TDryBulb, VapPres)
  Exit Function

ErrHandler:
  GetTDewPointFromRelHum = CVErr(xlErrNA)

End Function

Function GetTDewPointFromTWetBulb(ByVal TDryBulb As Variant, ByVal TWetBulb As Variant, ByVal Pressure As Variant) As Variant
'
' Return dew-point temperature given dry-bulb temperature, wet-bulb temperature, and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        TWetBulb : Wet-bulb temperature in °F [IP] or °C [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Dew-point temperature in °F [IP] or °C [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1
'
  Dim HumRatio As Variant

  On Error GoTo ErrHandler

  If TWetBulb > TDryBulb Then
    MyMsgBox ("Wet bulb temperature is above dry bulb temperature")
    GoTo ErrHandler
  End If

  HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
  GetTDewPointFromTWetBulb = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
  Exit Function

ErrHandler:
  GetTDewPointFromTWetBulb = CVErr(xlErrNA)

End Function


'******************************************************************************************************
'  Conversions between dew point, or relative humidity and vapor pressure
'******************************************************************************************************

Function GetVapPresFromRelHum(ByVal TDryBulb As Variant, ByVal RelHum As Variant) As Variant
'
' Return partial pressure of water vapor as a function of relative humidity and temperature.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        RelHum : Relative humidity in range [0, 1]
'
' Returns:
'        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
'
  On Error GoTo ErrHandler

  If RelHum < 0 Or RelHum > 1 Then
    MyMsgBox ("Relative humidity is outside range [0, 1]")
    GoTo ErrHandler
  End If

  GetVapPresFromRelHum = RelHum * GetSatVapPres(TDryBulb)
  Exit Function

ErrHandler:
  GetVapPresFromRelHum = CVErr(xlErrNA)

End Function

Function GetRelHumFromVapPres(ByVal TDryBulb As Variant, ByVal VapPres As Variant) As Variant
' Return relative humidity given dry-bulb temperature and vapor pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        VapPres: Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
'
' Returns:
'        Relative humidity in range [0, 1]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 12, 22
'
  On Error GoTo ErrHandler

  If (VapPres < 0) Then
    MyMsgBox ("Partial pressure of water vapor in moist air is negative")
    GoTo ErrHandler
  End If

  GetRelHumFromVapPres = VapPres / GetSatVapPres(TDryBulb)
  Exit Function

ErrHandler:
  GetRelHumFromVapPres = CVErr(xlErrNA)

End Function


Private Function dLnPws_(TDryBulb As Variant) As Variant
'
'    Helper function returning the derivative of the natural log of the saturation vapor pressure
'    as a function of dry-bulb temperature.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'
' Returns:
'        Derivative of natural log of vapor pressure of saturated air in Psi [IP] or Pa [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1  eqn 5 & 6
'
  Dim T As Variant
  If (isIP()) Then
    T = GetTRankineFromTFahrenheit(TDryBulb)
    If (TDryBulb <= TRIPLE_POINT_WATER_IP) Then
      dLnPws_ = 10214.165 / T ^ 2 - 0.0053765794 + 2 * 0.00000019202377 * T _
             + 3 * 3.5575832E-10 * T ^ 2 - 4 * 9.0344688E-14 * T ^ 3 + 4.1635019 / T
    Else
      dLnPws_ = 10440.397 / T ^ 2 - 0.027022355 + 2 * 0.00001289036 * T _
             - 3 * 2.4780681E-09 * T ^ 2 + 6.5459673 / T
    End If
  Else
    T = GetTKelvinFromTCelsius(TDryBulb)
    If (TDryBulb <= TRIPLE_POINT_WATER_SI) Then
      dLnPws_ = 5674.5359 / T ^ 2 - 0.009677843 + 2 * 0.00000062215701 * T _
             + 3 * 2.0747825E-09 * T ^ 2 - 4 * 9.484024E-13 * T ^ 3 + 4.1635019 / T
    Else
      dLnPws_ = 5800.2206 / T ^ 2 - 0.048640239 + 2 * 0.000041764768 * T _
             - 3 * 0.000000014452093 * T ^ 2 + 6.5459673 / T
    End If
  End If
End Function

Function GetTDewPointFromVapPres(ByVal TDryBulb As Variant, ByVal VapPres As Variant) As Variant
'
' Return dew-point temperature given dry-bulb temperature and vapor pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        VapPres: Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
'
' Returns:
'        Dew-point temperature in °F [IP] or °C [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn. 5 and 6
'
' Notes:
'        The dew point temperature is solved by inverting the equation giving water vapor pressure
'        at saturation from temperature rather than using the regressions provided
'        by ASHRAE (eqn. 37 and 38) which are much less accurate and have a
'        narrower range of validity.
'        The Newton-Raphson (NR) method is used on the logarithm of water vapour
'        pressure as a function of temperature, which is a very smooth function
'        Convergence is usually achieved in 3 to 5 iterations.
'        TDryBulb is not really needed here, just used for convenience.
'
  Dim BOUNDS(2) As Variant
  Dim PSYCHROLIB_TOLERANCE As Variant

  If (isIP()) Then
    BOUNDS(1) = -148.
    BOUNDS(2) = 392.
  Else
    BOUNDS(1) = -100.
    BOUNDS(2) = 200.
  End If

  On Error GoTo ErrHandler

  If ((VapPres < GetSatVapPres(BOUNDS(1))) Or (VapPres > GetSatVapPres(BOUNDS(2)))) Then
    MyMsgBox ("Partial pressure of water vapor is outside range of validity of equations")
    GoTo ErrHandler
  End If

  PSYCHROLIB_TOLERANCE = GetTol()

  Dim TDewPoint As Variant
  Dim lnVP As Variant
  Dim d_lnVP As Variant
  Dim TDewPoint_iter As Variant
  Dim lnVP_iter
  Dim index As Variant
  index = 1

  ' We use NR to approximate the solution.
  ' First guess
  TDewPoint = TDryBulb        ' Calculated value of dew point temperatures, solved for iteratively
  lnVP = Log(VapPres)         ' Partial pressure of water vapor in moist air

  ' Iteration
  Do
    TDewPoint_iter = TDewPoint   ' Value of Tdp used in NR calculation
    lnVP_iter = Log(GetSatVapPres(TDewPoint_iter))

    ' Derivative of function, calculated analytically
    d_lnVP = dLnPws_(TDewPoint_iter)

    ' New estimate, bounded by domain of validity of eqn. 5 and 6 and by the freezing point
    TDewPoint = TDewPoint_iter - (lnVP_iter - lnVP) / d_lnVP
    TDewPoint = Max(TDewPoint, BOUNDS(1))
    TDewPoint = Min(TDewPoint, BOUNDS(2))

    If (index > MAX_ITER_COUNT) Then
      GoTo ErrHandler
    End If

    index = index + 1

  Loop While (Abs(TDewPoint - TDewPoint_iter) > PSYCHROLIB_TOLERANCE)

  TDewPoint = Min(TDewPoint, TDryBulb)
  GetTDewPointFromVapPres = TDewPoint
  Exit Function

ErrHandler:
  GetTDewPointFromVapPres = CVErr(xlErrNA)

End Function

Function GetVapPresFromTDewPoint(ByVal TDewPoint As Variant) As Variant
'
' Return vapor pressure given dew point temperature.
'
' Args:
'        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]
'
' Returns:
'        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36
'
  On Error GoTo ErrHandler
  GetVapPresFromTDewPoint = GetSatVapPres(TDewPoint)
  Exit Function

ErrHandler:
  GetVapPresFromTDewPoint = CVErr(xlErrNA)

End Function


'******************************************************************************************************
'  Conversions from wet-bulb temperature, dew-point temperature, or relative humidity to humidity ratio
'******************************************************************************************************

Function GetTWetBulbFromHumRatio(ByVal TDryBulb As Variant, ByVal HumRatio As Variant, ByVal Pressure As Variant) As Variant
'
' Return wet-bulb temperature given dry-bulb temperature, humidity ratio, and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        HumRatio : Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Wet-bulb temperature in °F [IP] or °C [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35 solved for Tstar
'

  ' Declarations
  Dim Wstar As Variant
  Dim TDewPoint As Variant, TWetBulb As Variant, TWetBulbSup As Variant, TWetBulbInf As Variant
  Dim Tol As Variant, BoundedHumRatio As Variant, index As Variant

  On Error GoTo ErrHandler

  If HumRatio < 0 Then
    MyMsgBox ("Humidity ratio cannot be negative")
    GoTo ErrHandler
  End If
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

  TDewPoint = GetTDewPointFromHumRatio(TDryBulb, BoundedHumRatio, Pressure)

  ' Initial guesses
  TWetBulbSup = TDryBulb
  TWetBulbInf = TDewPoint
  TWetBulb = (TWetBulbInf + TWetBulbSup) / 2

  ' Bisection loop
  Tol = GetTol()
  index = 0
  While ((TWetBulbSup - TWetBulbInf) > Tol)

    ' Compute humidity ratio at temperature Tstar
    Wstar = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)

    ' Get new bounds
    If (Wstar > BoundedHumRatio) Then
      TWetBulbSup = TWetBulb
    Else
      TWetBulbInf = TWetBulb
    End If

    ' New guess of wet bulb temperature
    TWetBulb = (TWetBulbSup + TWetBulbInf) / 2

    If (index > MAX_ITER_COUNT) Then
      GoTo ErrHandler
    End If

    index = index + 1
  Wend

  GetTWetBulbFromHumRatio = TWetBulb
  Exit Function

ErrHandler:
  GetTWetBulbFromHumRatio = CVErr(xlErrNA)

End Function

Function GetHumRatioFromTWetBulb(ByVal TDryBulb As Variant, ByVal TWetBulb As Variant, ByVal Pressure As Variant) As Variant
'
' Return humidity ratio given dry-bulb temperature, wet-bulb temperature, and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        TWetBulb : Wet-bulb temperature in °F [IP] or °C [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 33 and 35

  Dim Wsstar As Variant, HumRatio As Variant
  Wsstar = GetSatHumRatio(TWetBulb, Pressure)

  On Error GoTo ErrHandler

  If TWetBulb > TDryBulb Then
    MyMsgBox ("Wet bulb temperature is above dry bulb temperature")
    GoTo ErrHandler
  End If

  If isIP() Then
    If (TWetBulb >= FREEZING_POINT_WATER_IP) Then
      HumRatio = ((1093 - 0.556 * TWetBulb) * Wsstar - 0.24 * (TDryBulb - TWetBulb)) / (1093 + 0.444 * TDryBulb - TWetBulb)
    Else
      HumRatio = ((1220 - 0.04 * TWetBulb) * Wsstar - 0.24 * (TDryBulb - TWetBulb)) / (1220 + 0.444 * TDryBulb - 0.48 * TWetBulb)
    End If
  Else
    If (TWetBulb >= FREEZING_POINT_WATER_SI) Then
      HumRatio = ((2501 - 2.326 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb)) / (2501 + 1.86 * TDryBulb - 4.186 * TWetBulb)
    Else
      HumRatio = ((2830 - 0.24 * TWetBulb) * Wsstar - 1.006 * (TDryBulb - TWetBulb)) / (2830 + 1.86 * TDryBulb - 2.1 * TWetBulb)
    End If
  End If
  ' Validity check.
  GetHumRatioFromTWetBulb = max(HumRatio, MIN_HUM_RATIO)
  Exit Function

ErrHandler:
  GetHumRatioFromTWetBulb = CVErr(xlErrNA)

End Function

Function GetHumRatioFromRelHum(ByVal TDryBulb As Variant, ByVal RelHum As Variant, ByVal Pressure As Variant) As Variant
'
' Return humidity ratio given dry-bulb temperature, relative humidity, and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        RelHum : Relative humidity in range [0, 1]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1
'
  Dim VapPres As Variant

  On Error GoTo ErrHandler

  If RelHum < 0 Or RelHum > 1 Then
    MyMsgBox ("Relative humidity is outside range [0, 1]")
    GoTo ErrHandler
  End If

  VapPres = GetVapPresFromRelHum(TDryBulb, RelHum)
  GetHumRatioFromRelHum = GetHumRatioFromVapPres(VapPres, Pressure)
  Exit Function

ErrHandler:
  GetHumRatioFromRelHum = CVErr(xlErrNA)

End Function

Function GetRelHumFromHumRatio(ByVal TDryBulb As Variant, ByVal HumRatio As Variant, ByVal Pressure As Variant) As Variant
'
'    Return relative humidity given dry-bulb temperature, humidity ratio, and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        HumRatio : Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Relative humidity in range [0, 1]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1
'
  Dim VapPres As Variant

  On Error GoTo ErrHandler

  If HumRatio < 0 Then
    MyMsgBox ("Humidity ratio is negative")
    GoTo ErrHandler
  End If

  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
  GetRelHumFromHumRatio = GetRelHumFromVapPres(TDryBulb, VapPres)
  Exit Function

ErrHandler:
  GetRelHumFromHumRatio = CVErr(xlErrNA)

End Function


Function GetHumRatioFromTDewPoint(ByVal TDewPoint As Variant, ByVal Pressure As Variant) As Variant
'
' Return humidity ratio given dew-point temperature and pressure.
'
' Args:
'        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 13
'
  Dim VapPres As Variant

  On Error GoTo ErrHandler

  VapPres = GetSatVapPres(TDewPoint)
  GetHumRatioFromTDewPoint = GetHumRatioFromVapPres(VapPres, Pressure)
  Exit Function

ErrHandler:
  GetHumRatioFromTDewPoint = CVErr(xlErrNA)

End Function

Function GetTDewPointFromHumRatio(ByVal TDryBulb As Variant, ByVal HumRatio As Variant, ByVal Pressure As Variant) As Variant
'
' Return dew-point temperature given dry-bulb temperature, humidity ratio, and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        HumRatio : Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Dew-point temperature in °F [IP] or °C [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1
'
  Dim VapPres As Variant

  On Error GoTo ErrHandler

  If HumRatio < 0 Then
    MyMsgBox ("Humidity ratio is negative")
    GoTo ErrHandler
  End If

  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
  GetTDewPointFromHumRatio = GetTDewPointFromVapPres(TDryBulb, VapPres)
  Exit Function

ErrHandler:
  GetTDewPointFromHumRatio = CVErr(xlErrNA)
End Function


'******************************************************************************************************
'       Conversions between humidity ratio and vapor pressure
'******************************************************************************************************

Function GetHumRatioFromVapPres(ByVal VapPres As Variant, ByVal Pressure As Variant) As Variant
'
' Return humidity ratio given water vapor pressure and atmospheric pressure.
'
' Args:
'        VapPres : Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20
'
  Dim HumRatio As Variant

  On Error GoTo ErrHandler

  If VapPres < 0 Then
    MyMsgBox ("Partial pressure of water vapor in moist air is negative")
    GoTo ErrHandler
  End If

  HumRatio = 0.621945 * VapPres / (Pressure - VapPres)
  ' Validity check.
  GetHumRatioFromVapPres = max(HumRatio, MIN_HUM_RATIO)
  Exit Function

ErrHandler:
  GetHumRatioFromVapPres = CVErr(xlErrNA)

End Function

Function GetVapPresFromHumRatio(ByVal HumRatio As Variant, ByVal Pressure As Variant) As Variant
'
' Return vapor pressure given humidity ratio and pressure.
'
' Args:
'        HumRatio : Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 20 solved for pw
'

  Dim VapPres As Variant, BoundedHumRatio As Variant

  On Error GoTo ErrHandler

  If HumRatio < 0 Then
    MyMsgBox ("Humidity ratio is negative")
    GoTo ErrHandler
  End If
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

  VapPres = Pressure * BoundedHumRatio / (0.621945 + BoundedHumRatio)
  GetVapPresFromHumRatio = VapPres
  Exit Function

ErrHandler:
  GetVapPresFromHumRatio = CVErr(xlErrNA)

End Function


'******************************************************************************************************
'       Conversions between humidity ratio and specific humidity
'******************************************************************************************************

Function GetSpecificHumFromHumRatio(ByVal HumRatio As Variant) As Variant
'
' Return the specific humidity from humidity ratio (aka mixing ratio).
'
' Args:
'     HumRatio : Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]
'
' Returns:
'     Specific humidity in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
'
' Reference:
'     ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b
'
'
  Dim SpecificHum As Variant

  On Error GoTo ErrHandler

  If (HumRatio < 0) Then
    MyMsgBox ("Humidity ratio is negative")
    GoTo ErrHandler
  End If

  SpecificHum = HumRatio / (1.0 + HumRatio)
  GetSpecificHumFromHumRatio = SpecificHum
  Exit Function

ErrHandler:
  GetSpecificHumFromHumRatio = CVErr(xlErrNA)

End Function

Function GetHumRatioFromSpecificHum(ByVal SpecificHum As Variant) As Variant
'
' Return the humidity ratio (aka mixing ratio) from specific humidity.
'
' Args:
'     SpecificHum : Specific Humidity in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
'
' Returns:
'     Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]
'
' Reference:
'     ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 9b (solved for humidity ratio)
'
'
  Dim HumRatio as Variant

  On Error GoTo ErrHandler

  If (SpecificHum < 0 Or SpecificHum >= 1) Then
    MyMsgBox ("Specific humidity is outside range [0, 1[")
    GoTo ErrHandler
  End If

    HumRatio = SpecificHum / (1.0 - SpecificHum)
    GetHumRatioFromSpecificHum = max(HumRatio, MIN_HUM_RATIO)
  Exit Function

ErrHandler:
  GetHumRatioFromSpecificHum = CVErr(xlErrNA)

End Function


'******************************************************************************************************
' Dry Air Calculations
'******************************************************************************************************

Function GetDryAirEnthalpy(ByVal TDryBulb As Variant) As Variant
'
' Return dry-air enthalpy given dry-bulb temperature.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'
' Returns:
'        Dry air enthalpy in Btu/lb [IP] or J/kg [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 28
'
  On Error GoTo ErrHandler

  If (isIP()) Then
    GetDryAirEnthalpy = 0.24 * TDryBulb
  Else
    GetDryAirEnthalpy = 1006 * TDryBulb
  End If
  Exit Function

ErrHandler:
  GetDryAirEnthalpy = CVErr(xlErrNA)

End Function

Function GetDryAirDensity(ByVal TDryBulb As Variant, ByVal Pressure As Variant) As Variant
'
' Return dry-air density given dry-bulb temperature and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Dry air density in lb/ft³ [IP] or kg/m³ [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1
'
' Notes:
'        Eqn 14 for the perfect gas relationship for dry air.
'        Eqn 1 for the universal gas constant.
'        The factor 144 in IP is for the conversion of Psi = lb/in² to lb/ft².
'
  On Error GoTo ErrHandler

  If (isIP()) Then
    GetDryAirDensity = (144 * Pressure) / R_DA_IP / GetTRankineFromTFahrenheit(TDryBulb)
  Else
    GetDryAirDensity = Pressure / R_DA_SI / GetTKelvinFromTCelsius(TDryBulb)
  End If
  Exit Function

ErrHandler:
  GetDryAirDensity = CVErr(xlErrNA)

End Function

Function GetDryAirVolume(ByVal TDryBulb As Variant, ByVal Pressure As Variant) As Variant
'
' Return dry-air volume given dry-bulb temperature and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Dry air volume in ft³/lb [IP] or in m³/kg [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1
'
' Notes:
'        Eqn 14 for the perfect gas relationship for dry air.
'        Eqn 1 for the universal gas constant.
'        The factor 144 in IP is for the conversion of Psi = lb/in² to lb/ft².
'
  On Error GoTo ErrHandler

  If (isIP()) Then
    GetDryAirVolume = GetTRankineFromTFahrenheit(TDryBulb) * R_DA_IP / (144 * Pressure)
  Else:
    GetDryAirVolume = GetTKelvinFromTCelsius(TDryBulb) * R_DA_SI / Pressure
  End If
  Exit Function

ErrHandler:
  GetDryAirVolume = CVErr(xlErrNA)

End Function

Function GetTDryBulbFromEnthalpyAndHumRatio(ByVal MoistAirEnthalpy As Variant, ByVal HumRatio As Variant) As Variant
'
' Return dry bulb temperature from enthalpy and humidity ratio.
'
'
' Args:
'     MoistAirEnthalpy : Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
'     HumRatio : Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
'
' Returns:
'     Dry-bulb temperature in °F [IP] or °C [SI]
'
' Reference:
'     ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30
'
' Notes:
'     Based on the `GetMoistAirEnthalpy` function, rearranged for temperature.
'

  On Error GoTo ErrHandler

  If HumRatio < 0 Then
    MyMsgBox ("Humidity ratio is negative")
    GoTo ErrHandler
  End If

  If (isIP()) Then
    GetTDryBulbFromEnthalpyAndHumRatio = (MoistAirEnthalpy - 1061.0 * HumRatio) / (0.24 + 0.444 * HumRatio)
  Else:
    GetTDryBulbFromEnthalpyAndHumRatio = (MoistAirEnthalpy / 1000.0 - 2501.0 * HumRatio) / (1.006 + 1.86 * HumRatio)
  End If
  Exit Function

ErrHandler:
  GetTDryBulbFromEnthalpyAndHumRatio = CVErr(xlErrNA)

End Function

Function GetHumRatioFromEnthalpyAndTDryBulb(ByVal MoistAirEnthalpy As Variant, ByVal TDryBulb As Variant) As Variant
'
' Return humidity ratio from enthalpy and dry-bulb temperature.
'
'
' Args:
'     MoistAirEnthalpy : Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
'     TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'
' Returns:
'     Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
'
' Reference:
'     ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30
'
' Notes:
'     Based on the `GetMoistAirEnthalpy` function, rearranged for humidity ratio.
'

  On Error GoTo ErrHandler

  If (isIP()) Then
    GetHumRatioFromEnthalpyAndTDryBulb = (MoistAirEnthalpy - 0.24 * TDryBulb) / (1061.0 + 0.444 * TDryBulb)
  Else:
    GetHumRatioFromEnthalpyAndTDryBulb = (MoistAirEnthalpy / 1000.0 - 1.006 * TDryBulb) / (2501.0 + 1.86 * TDryBulb)
  End If
  Exit Function

ErrHandler:
  GetHumRatioFromEnthalpyAndTDryBulb = CVErr(xlErrNA)

End Function


'******************************************************************************************************
' Saturated Air Calculations
'******************************************************************************************************

Function GetSatVapPres(ByVal TDryBulb As Variant) As Variant
'
' Return saturation vapor pressure given dry-bulb temperature.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'
' Returns:
'        Vapor pressure of saturated air in Psi [IP] or Pa [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1  eqn 5 & 6
'        Important note: the ASHRAE formulae are defined above and below the freezing point but have
'        a discontinuity at the freezing point. This is a small inaccuracy on ASHRAE's part: the formulae
'        should be defined above and below the triple point of water (not the feezing point) in which case
'        the discontinuity vanishes. It is essential to use the triple point of water otherwise function
'        GetTDewPointFromVapPres, which inverts the present function, does not converge properly around
'        the freezing point.
'
  Dim LnPws As Variant, T As Variant

  On Error GoTo ErrHandler

  If (isIP()) Then
    If (TDryBulb < -148 Or TDryBulb > 392) Then
      MyMsgBox ("Dry bulb temperature is outside range [-148, 392] °F")
      GoTo ErrHandler
    End If

    T = GetTRankineFromTFahrenheit(TDryBulb)

    If (TDryBulb <= TRIPLE_POINT_WATER_IP) Then
      LnPws = (-10214.165 / T - 4.8932428 - 0.0053765794 * T + 0.00000019202377 * T ^ 2 _
            + 3.5575832E-10 * T ^ 3 - 9.0344688E-14 * T ^ 4 + 4.1635019 * Log(T))
    Else
      LnPws = -10440.397 / T - 11.29465 - 0.027022355 * T + 0.00001289036 * T ^ 2 _
            - 2.4780681E-09 * T ^ 3 + 6.5459673 * Log(T)
    End If

  Else
    If (TDryBulb < -100 Or TDryBulb > 200) Then
      MyMsgBox ("Dry bulb temperature is outside range [-100, 200] °C")
      GoTo ErrHandler
    End If

    T = GetTKelvinFromTCelsius(TDryBulb)

    If (TDryBulb <= TRIPLE_POINT_WATER_SI) Then
        LnPws = -5674.5359 / T + 6.3925247 - 0.009677843 * T + 0.00000062215701 * T ^ 2 _
              + 2.0747825E-09 * T ^ 3 - 9.484024E-13 * T ^ 4 + 4.1635019 * Log(T)
    Else
        LnPws = -5800.2206 / T + 1.3914993 - 0.048640239 * T + 0.000041764768 * T ^ 2 _
              - 0.000000014452093 * T ^ 3 + 6.5459673 * Log(T)
    End If
  End If

  GetSatVapPres = Exp(LnPws)
  Exit Function

ErrHandler:
  GetSatVapPres = CVErr(xlErrNA)

End Function

Function GetSatHumRatio(ByVal TDryBulb As Variant, ByVal Pressure As Variant) As Variant
'
' Return humidity ratio of saturated air given dry-bulb temperature and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Humidity ratio of saturated air in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 36, solved for W
'
  Dim SatVaporPres As Variant, SatHumRatio As Variant

  On Error GoTo ErrHandler

  SatVaporPres = GetSatVapPres(TDryBulb)
  SatHumRatio = 0.621945 * SatVaporPres / (Pressure - SatVaporPres)
  GetSatHumRatio = max(SatHumRatio, MIN_HUM_RATIO)
  Exit Function

ErrHandler:
  GetSatHumRatio = CVErr(xlErrNA)

End Function

Function GetSatAirEnthalpy(ByVal TDryBulb As Variant, ByVal Pressure As Variant) As Variant
'
' Return saturated air enthalpy given dry-bulb temperature and pressure.
'
' Args:
'        TDryBulb: Dry-bulb temperature in °F [IP] or °C [SI]
'        Pressure: Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Saturated air enthalpy in Btu/lb [IP] or J/kg [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1
'
  On Error GoTo ErrHandler

  GetSatAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, GetSatHumRatio(TDryBulb, Pressure))
  Exit Function

ErrHandler:
  GetSatAirEnthalpy = CVErr(xlErrNA)

End Function


'******************************************************************************************************
' Moist Air Calculations
'******************************************************************************************************


Function GetVaporPressureDeficit(ByVal TDryBulb As Variant, ByVal HumRatio As Variant, ByVal Pressure As Variant) As Variant
'
' Return Vapor pressure deficit given dry-bulb temperature, humidity ratio, and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        HumRatio : Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Vapor pressure deficit in Psi [IP] or Pa [SI]
'
' Reference:
'        Oke (1987) eqn 2.13a
'
  Dim RelHum As Variant

  On Error GoTo ErrHandler

  If HumRatio < 0 Then
    MyMsgBox ("Humidity ratio is negative")
    GoTo ErrHandler
  End If

  RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
  GetVaporPressureDeficit = GetSatVapPres(TDryBulb) * (1 - RelHum)
  Exit Function

ErrHandler:
  GetVaporPressureDeficit = CVErr(xlErrNA)

End Function

Function GetDegreeOfSaturation(ByVal TDryBulb As Variant, ByVal HumRatio As Variant, ByVal Pressure As Variant) As Variant
'
' Return the degree of saturation (i.e humidity ratio of the air / humidity ratio of the air at saturation
' at the same temperature and pressure) given dry-bulb temperature, humidity ratio, and atmospheric pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        HumRatio : Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Degree of saturation in arbitrary unit
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2009) ch. 1 eqn 12
'
' Notes:
'        This definition is absent from the 2017 Handbook. Using 2009 version instead.
'
  Dim BoundedHumRatio As Variant

  On Error GoTo ErrHandler

  If HumRatio < 0 Then
    MyMsgBox ("Humidity ratio is negative")
    GoTo ErrHandler
  End If
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

  GetDegreeOfSaturation = BoundedHumRatio / GetSatHumRatio(TDryBulb, Pressure)
  Exit Function

ErrHandler:
  GetDegreeOfSaturation = CVErr(xlErrNA)

End Function

Function GetMoistAirEnthalpy(ByVal TDryBulb As Variant, ByVal HumRatio As Variant) As Variant
'
' Return moist air enthalpy given dry-bulb temperature and humidity ratio.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        HumRatio : Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'
' Returns:
'        Moist air enthalpy in Btu/lb [IP] or J/kg
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 30
'
  Dim BoundedHumRatio As Variant

  On Error GoTo ErrHandler

  If (HumRatio < 0) Then
    MyMsgBox ("Humidity ratio is negative")
    GoTo ErrHandler
  End If
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

  If (isIP()) Then
    GetMoistAirEnthalpy = 0.24 * TDryBulb + BoundedHumRatio * (1061 + 0.444 * TDryBulb)
  Else
    GetMoistAirEnthalpy = (1.006 * TDryBulb + BoundedHumRatio * (2501 + 1.86 * TDryBulb)) * 1000
  End If
  Exit Function

ErrHandler:
  GetMoistAirEnthalpy = CVErr(xlErrNA)

End Function

Function GetMoistAirVolume(ByVal TDryBulb As Variant, ByVal HumRatio As Variant, ByVal Pressure As Variant) As Variant
'
' Return moist air specific volume given dry-bulb temperature, humidity ratio, and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        HumRatio : Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Specific volume of moist air in ft³/lb of dry air [IP] or in m³/kg of dry air [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26
'
' Notes:
'        In IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26
'        The factor 144 is for the conversion of Psi = lb/in² to lb/ft².
'
  Dim BoundedHumRatio As Variant

  On Error GoTo ErrHandler

  If (HumRatio < 0) Then
    MyMsgBox ("Humidity ratio is negative")
    GoTo ErrHandler
  End If
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

  If (isIP()) Then
    GetMoistAirVolume = R_DA_IP * GetTRankineFromTFahrenheit(TDryBulb) * (1 + 1.607858 * BoundedHumRatio) / (144 * Pressure)
  Else
    GetMoistAirVolume = R_DA_SI * GetTKelvinFromTCelsius(TDryBulb) * (1 + 1.607858 * BoundedHumRatio) / Pressure
  End If
  Exit Function

ErrHandler:
  GetMoistAirVolume = CVErr(xlErrNA)

End Function

Function GetTDryBulbFromMoistAirVolumeAndHumRatio(ByVal MoistAirVolume As Variant, ByVal HumRatio As Variant, ByVal Pressure As Variant) As Variant
'
' Return dry-bulb temperature given moist air specific volume, humidity ratio, and pressure.
'
' Args:
'        MoistAirVolume: Specific volume of moist air in ft³ lb⁻¹ of dry air [IP] or in m³ kg⁻¹ of dry air [SI]
'        HumRatio : Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Specific volume of moist air in ft³/lb of dry air [IP] or in m³/kg of dry air [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 26
'
' Notes:
'        In IP units, R_DA_IP / 144 equals 0.370486 which is the coefficient appearing in eqn 26
'        The factor 144 is for the conversion of Psi = lb/in² to lb/ft².
'        Based on the `GetMoistAirVolume` function, rearranged for dry-bulb temperature.
'
  Dim BoundedHumRatio As Variant

  On Error GoTo ErrHandler

  If (HumRatio < 0) Then
    MyMsgBox ("Humidity ratio is negative")
    GoTo ErrHandler
  End If
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

  If (isIP()) Then
    GetTDryBulbFromMoistAirVolumeAndHumRatio = GetTFahrenheitFromTRankine(MoistAirVolume * (144 * Pressure) / (R_DA_IP * (1 + 1.607858 * BoundedHumRatio)))
  Else
    GetTDryBulbFromMoistAirVolumeAndHumRatio = GetTCelsiusFromTKelvin(MoistAirVolume * Pressure / (R_DA_SI * (1 + 1.607858 * BoundedHumRatio)))
  End If
  Exit Function

ErrHandler:
  GetTDryBulbFromMoistAirVolumeAndHumRatio = CVErr(xlErrNA)

End Function

Function GetMoistAirDensity(ByVal TDryBulb As Variant, ByVal HumRatio As Variant, ByVal Pressure As Variant) As Variant
'
' Return moist air density given humidity ratio, dry bulb temperature, and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        HumRatio : Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        MoistAirDensity: Moist air density in lb/ft³ [IP] or kg/m³ [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 11
'
  Dim MoistAirVolume As Variant, BoundedHumRatio As Variant

  On Error GoTo ErrHandler

  If (HumRatio < 0) Then
    MyMsgBox ("Humidity ratio is negative")
    GoTo ErrHandler
  End If
  BoundedHumRatio = max(HumRatio, MIN_HUM_RATIO)

  MoistAirVolume = GetMoistAirVolume(TDryBulb, BoundedHumRatio, Pressure)
  GetMoistAirDensity = (1 + BoundedHumRatio) / MoistAirVolume
  Exit Function

ErrHandler:
  GetMoistAirDensity = CVErr(xlErrNA)

End Function


'******************************************************************************************************
' Standard atmosphere
'******************************************************************************************************

Function GetStandardAtmPressure(ByVal Altitude As Variant) As Variant
'
' Return standard atmosphere barometric pressure, given the elevation (altitude).
'
' Args:
'        Altitude: Altitude in ft [IP] or m [SI]
'
' Returns:
'        Standard atmosphere barometric pressure in Psi [IP] or Pa [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 3
'
  On Error GoTo ErrHandler

  If (isIP()) Then
    GetStandardAtmPressure = 14.696 * (1 - 0.0000068754 * Altitude) ^ 5.2559
  Else
    GetStandardAtmPressure = 101325 * (1 - 0.0000225577 * Altitude) ^ 5.2559
  End If
  Exit Function

ErrHandler:
  GetStandardAtmPressure = CVErr(xlErrNA)

End Function

Function GetStandardAtmTemperature(ByVal Altitude As Variant) As Variant
'
' Return standard atmosphere temperature, given the elevation (altitude).
'
' Args:
'        Altitude: Altitude in ft
'
' Returns:
'        Standard atmosphere dry-bulb temperature in °F [IP] or °C [SI]
'
' Reference:
'        ASHRAE Handbook - Fundamentals (2017) ch. 1 eqn 4
'
  On Error GoTo ErrHandler

  If (isIP()) Then
    GetStandardAtmTemperature = 59 - 0.0035662 * Altitude
  Else
    GetStandardAtmTemperature = 15 - 0.0065 * Altitude
  End If
  Exit Function

ErrHandler:
  GetStandardAtmTemperature = CVErr(xlErrNA)

End Function

Function GetSeaLevelPressure(ByVal StationPressure As Variant, ByVal Altitude As Variant, ByVal TDryBulb As Variant) As Variant
'
' Return sea level pressure given dry-bulb temperature, altitude above sea level and pressure.
'
' Args:
'        StationPressure : Observed station pressure in Psi [IP] or Pa [SI]
'        Altitude: Altitude in ft [IP] or m [SI]
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'
' Returns:
'        Sea level barometric pressure in Psi [IP] or Pa [SI]
'
' Reference:
'        Hess SL, Introduction to theoretical meteorology, Holt Rinehart and Winston, NY 1959,
'        ch. 6.5; Stull RB, Meteorology for scientists and engineers, 2nd edition,
'        Brooks/Cole 2000, ch. 1.
'
' Notes:
'        The standard procedure for the US is to use for TDryBulb the average
'        of the current station temperature and the station temperature from 12 hours ago.
'

  ' Calculate average temperature in column of air, assuming a lapse rate
  ' of 6.5 °C/km
  Dim TColumn As Variant
  Dim H As Variant

  On Error GoTo ErrHandler

  If (isIP()) Then
    ' Calculate average temperature in column of air, assuming a lapse rate
    ' of 3.6 °F/1000ft
    TColumn = TDryBulb + 0.0036 * Altitude / 2

    ' Determine the scale height
    H = 53.351 * GetTRankineFromTFahrenheit(TColumn)
  Else
    ' Calculate average temperature in column of air, assuming a lapse rate
    ' of 6.5 °C/km
    TColumn = TDryBulb + 0.0065 * Altitude / 2

    ' Determine the scale height
    H = 287.055 * GetTKelvinFromTCelsius(TColumn) / 9.807
  End If

  ' Calculate the sea level pressure
  GetSeaLevelPressure = StationPressure * Exp(Altitude / H)
  Exit Function

ErrHandler:
  GetSeaLevelPressure = CVErr(xlErrNA)

End Function

Function GetStationPressure(ByVal SeaLevelPressure As Variant, ByVal Altitude As Variant, ByVal TDryBulb As Variant) As Variant
'
' Args:
'        SeaLevelPressure : Sea level barometric pressure in Psi [IP] or Pa [SI]
'        Altitude: Altitude in ft [IP] or m [SI]
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'
' Returns:
'        Station pressure in Psi [IP] or Pa [SI]
'
' Reference:
'        See 'GetSeaLevelPressure'
'
' Notes:
'        This function is just the inverse of 'GetSeaLevelPressure'.
'
  On Error GoTo ErrHandler

  GetStationPressure = SeaLevelPressure / GetSeaLevelPressure(1, Altitude, TDryBulb)
  Exit Function

ErrHandler:
  GetStationPressure = CVErr(xlErrNA)

End Function

'******************************************************************************************************
' Functions to set all psychrometric values
'******************************************************************************************************

Sub CalcPsychrometricsFromTWetBulb(ByVal TDryBulb As Variant, ByVal TWetBulb As Variant, ByVal Pressure As Variant, _
    ByRef HumRatio As Variant, ByRef TDewPoint As Variant, ByRef RelHum As Variant, ByRef VapPres As Variant, _
    ByRef MoistAirEnthalpy As Variant, ByRef MoistAirVolume As Variant, ByRef DegreeOfSaturation As Variant)
'
' Utility function to calculate humidity ratio, dew-point temperature, relative humidity,
' vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
' dry-bulb temperature, wet-bulb temperature, and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        TWetBulb : Wet-bulb temperature in °F [IP] or °C [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'        Dew-point temperature in °F [IP] or °C [SI]
'        Relative humidity in range [0, 1]
'        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
'        Moist air enthalpy in Btu/lb [IP] or J/kg [SI]
'        Specific volume of moist air in ft³/lb [IP] or in m³/kg [SI]
'        Degree of saturation [unitless]
'
  HumRatio = GetHumRatioFromTWetBulb(TDryBulb, TWetBulb, Pressure)
  TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
  RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
  MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio)
  MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
  DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)

End Sub

Sub CalcPsychrometricsFromTDewPoint(ByVal TDryBulb As Variant, ByVal TDewPoint As Variant, ByVal Pressure As Variant, _
    ByRef HumRatio As Variant, ByRef TWetBulb As Variant, ByRef RelHum As Variant, ByRef VapPres As Variant, _
    ByRef MoistAirEnthalpy As Variant, ByRef MoistAirVolume As Variant, ByRef DegreeOfSaturation As Variant)
'
' Utility function to calculate humidity ratio, wet-bulb temperature, relative humidity,
' vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
' dry-bulb temperature, dew-point temperature, and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        TDewPoint : Dew-point temperature in °F [IP] or °C [SI]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'        Wet-bulb temperature in °F [IP] or °C [SI]
'        Relative humidity in range [0, 1]
'        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
'        Moist air enthalpy in Btu/lb [IP] or J/kg [SI]
'        Specific volume of moist air in ft³/lb [IP] or in m³/kg [SI]
'        Degree of saturation [unitless]
'
  HumRatio = GetHumRatioFromTDewPoint(TDewPoint, Pressure)
  TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
  RelHum = GetRelHumFromHumRatio(TDryBulb, HumRatio, Pressure)
  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
  MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio)
  MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
  DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)

End Sub

Sub CalcPsychrometricsFromRelHum(ByVal TDryBulb As Variant, ByVal RelHum As Variant, ByVal Pressure As Variant, _
    ByRef HumRatio As Variant, ByRef TWetBulb As Variant, ByRef TDewPoint As Variant, ByRef VapPres As Variant, _
    ByRef MoistAirEnthalpy As Variant, ByRef MoistAirVolume As Variant, ByRef DegreeOfSaturation As Variant)
'
' Utility function to calculate humidity ratio, wet-bulb temperature, dew-point temperature,
' vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given
' dry-bulb temperature, relative humidity and pressure.
'
' Args:
'        TDryBulb : Dry-bulb temperature in °F [IP] or °C [SI]
'        RelHum : Relative humidity in range [0, 1]
'        Pressure : Atmospheric pressure in Psi [IP] or Pa [SI]
'
' Returns:
'        Humidity ratio in lb_H2O/lb_Air [IP] or kg_H2O/kg_Air [SI]
'        Wet-bulb temperature in °F [IP] or °C [SI]
'        Dew-point temperature in °F [IP] or °C [SI].
'        Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
'        Moist air enthalpy in Btu/lb [IP] or J/kg [SI]
'        Specific volume of moist air in ft³/lb [IP] or in m³/kg [SI]
'        Degree of saturation [unitless]
'
  HumRatio = GetHumRatioFromRelHum(TDryBulb, RelHum, Pressure)
  TWetBulb = GetTWetBulbFromHumRatio(TDryBulb, HumRatio, Pressure)
  TDewPoint = GetTDewPointFromHumRatio(TDryBulb, HumRatio, Pressure)
  VapPres = GetVapPresFromHumRatio(HumRatio, Pressure)
  MoistAirEnthalpy = GetMoistAirEnthalpy(TDryBulb, HumRatio)
  MoistAirVolume = GetMoistAirVolume(TDryBulb, HumRatio, Pressure)
  DegreeOfSaturation = GetDegreeOfSaturation(TDryBulb, HumRatio, Pressure)

End Sub
