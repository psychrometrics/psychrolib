 

<div class="style1" align="left">Library of Psychrometric Functions in C: Reference</div>

 |
|  
 [](javascript:;)

 | 

<span class="bodyText"></span>

<span class="bodyText">This reference page provides a short description of all the functions available in the Psychrometrics Library. It describes the C version of the library. Versions in other languages are very similar to this one, only the syntax changes. </span>

<span class="bodyText">This is the list of functions available in the library:</span>

Conversions between dew point, wet bulb, and relative humidity

[GetTWetBulbFromTDewPoint](#GetTWetBulbFromTDewPoint)
[GetTWetBulbFromRelHum](#GetTWetBulbFromRelHum)
[GetRelHumFromTDewPoint](#GetRelHumFromTDewPoint)
[GetRelHumFromTWetBulb](#GetRelHumFromTWetBulb)
[GetTDewPointFromRelHum](#GetTDewPointFromRelHum)
[GetTDewPointFromTWetBulb](#GetTDewPointFromTWetBulb)

Conversions between dew point, or relative humidity and vapor pressure

[GetVapPresFromRelHum](#GetVapPresFromRelHum)
[GetRelHumFromVapPres](#GetRelHumFromVapPres)
[GetTDewPointFromVapPres](#GetTDewPointFromVapPres)
[GetVapPresFromTDewPoint](#GetVapPresFromTDewPoint)

Conversions between wet bulb temperature, dew point temperature, or relative humidity and humidity ratio

[GetTWetBulbFromHumRatio](#GetTWetBulbFromHumRatio)
[GetHumRatioFromTWetBulb](#GetHumRatioFromTWetBulb)
[GetHumRatioFromRelHum](#GetHumRatioFromRelHum)
[GetRelHumFromHumRatio](#GetRelHumFromHumRatio)
[GetHumRatioFromTDewPoint](#GetHumRatioFromTDewPoint)
[GetTDewPointFromHumRatio](#GetTDewPointFromHumRatio)

Conversions between humidity ratio and vapor pressure

[GetHumRatioFromVapPres](#GetHumRatioFromVapPres)
[GetVapPresFromHumRatio](#GetVapPresFromHumRatio)

Dry Air Calculations

[GetDryAirEnthalpy](#GetDryAirEnthalpy)
[GetDryAirDensity](#GetDryAirDensity)
[GetDryAirVolume](#GetDryAirVolume)

Saturated Air Calculations

[GetSatVapPres](#GetSatVapPres)
[GetSatHumRatio](#GetSatHumRatio)
[GetSatAirEnthalpy](#GetSatAirEnthalpy)

Moist Air Calculations

[GetVPD](#GetVPD)
[GetDegreeOfSaturation](#GetDegreeOfSaturation)
[GetMoistAirEnthalpy](#GetMoistAirEnthalpy)
[GetMoistAirVolume](#GetMoistAirVolume)
[GetMoistAirDensity](#GetMoistAirDensity)

Functions to calculate all psychrometric values at once

[CalcPsychrometricsFromTWetBulb](#CalcPsychrometricsFromTWetBulb)
[CalcPsychrometricsFromTDewPoint](#CalcPsychrometricsFromTDewPoint)
[CalcPsychrometricsFromRelHum](#CalcPsychrometricsFromRelHum)

Standard atmosphere

<span class="style2">[GetStandardAtmPressure](#GetStandardAtmPressure)
[GetStandardAtmTemperature](#GetStandardAtmTemperature)
[GetSeaLevelPressure](#GetSeaLevelPressure)
[GetStationPressure](#GetStationPressure)</span>

[Back to the Psychrometrics page](psychrometrics.html)

_**Comments or questions?**_

Please send us your comments or questions at:
![numlog email](../email.PNG)

* * *

_**Full description of functions** _(in alphabetical order)

* * *

## <a name="CalcPsychrometricsFromRelHum" id="CalcPsychrometricsFromRelHum">CalcPsychrometricsFromRelHum</a>

void CalcPsychrometricsFromRelHum
    ( double *TWetBulb             /* (o) Wet bulb temperature [C] */
    , double *TDewPoint            /* (o) Dew point temperature [C] */
    , double *HumRatio             /* (o) Humidity ratio [kgH2O/kgAIR] */
    , double *VapPres  /* (o) Partial pressure of water vapor in moist air [Pa] */
    , double *MoistAirEnthalpy     /* (o) Moist Air Enthalpy [J/kg] */
    , double *MoistAirVolume       /* (o) Specific Volume [m3/kg] */
    , double *DegSaturation        /* (o) Degree of saturation [] */
    , double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double Pressure               /* (i) Atmospheric pressure [Pa] */
    , double RelHum                /* (i) Relative humidity [0-1] */
    );

### Description

Calculates moist air properties given dry bulb temperature, atmospheric pressure, and relative humidity.  The function first calculates the humidity ratio, then calls various functions to calculate other psychrometric quantities from the humidity ratio.

### See Also

_CalcPsychrometricsFromTDewPoint_ to calculate moist air properties knowing the dew point temperature.
_CalcPsychrometricsFromTWetBulb_ to calculate moist air properties knowing the wet bulb temperature.

## <a name="CalcPsychrometricsFromTDewPoint" id="CalcPsychrometricsFromTDewPoint">CalcPsychrometricsFromTDewPoint</a>

void CalcPsychrometricsFromTDewPoint
    ( double *TWetBulb             /* (o) Wet bulb temperature [C] */
    , double *RelHum               /* (o) Relative humidity [0-1] */
    , double *HumRatio             /* (o) Humidity ratio [kgH2O/kgAIR] */
    , double *VapPres  /* (o) Partial pressure of water vapor in moist air [Pa] */
    , double *MoistAirEnthalpy     /* (o) Moist Air Enthalpy [J/kg] */
    , double *MoistAirVolume       /* (o) Specific Volume [m3/kg] */
    , double *DegSaturation        /* (o) Degree of saturation [] */
    , double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    , double TDewPoint             /* (i) Dew point temperature [C] */
    );

### Description

Calculates moist air properties given dry bulb temperature, atmospheric pressure, and dew point temperature.  The function first calculates the humidity ratio, then calls various functions to calculate other psychrometric quantities from the humidity ratio.

### See Also

_CalcPsychrometricsFromRelHum_ to calculate moist air properties knowing the relative humidity.
_CalcPsychrometricsFromTWetBulb_ to calculate moist air properties knowing the wet bulb temperature.

## <a name="CalcPsychrometricsFromTWetBulb" id="CalcPsychrometricsFromTWetBulb">CalcPsychrometricsFromTWetBulb</a>

void CalcPsychrometricsFromTWetBulb
    ( double *TDewPoint            /* (o) Dew point temperature [C] */
    , double *RelHum               /* (o) Relative humidity [0-1] */
    , double *HumRatio             /* (o) Humidity ratio [kgH2O/kgAIR] */
    , double *VapPres  /* (o) Partial pressure of water vapor in moist air [Pa] */
    , double *MoistAirEnthalpy     /* (o) Moist Air Enthalpy [J/kg] */
    , double *MoistAirVolume       /* (o) Specific Volume [m3/kg] */
    , double *DegSaturation        /* (o) Degree of saturation [] */
    , double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    , double TWetBulb              /* (i) Wet bulb temperature [C] */
    );

### Description

Calculates moist air properties given dry bulb temperature, atmospheric pressure, and wet bulb temperature.  The function first calculates the humidity ratio, then calls various functions to calculate other psychrometric quantities from the humidity ratio.

### See Also

_CalcPsychrometricsFromTDewPoint_ to calculate moist air properties knowing the dew point temperature.
_CalcPsychrometricsFromRelHum_ to calculate moist air properties knowing the relative humidity.

## <a name="GetDegreeOfSaturation" id="GetDegreeOfSaturation">GetDegreeOfSaturation</a>

double GetDegreeOfSaturation    /* (o) Degree of saturation [] */
    ( double TDryBulb       /* (i) Dry bulb temperature [C] */
    , double HumRatio       /* (i) Humidity ratio kgH2O/kgAIR] */
    , double Pressure       /* (i) Atmospheric pressure [Pa] */
    );

### Description

Compute the degree of saturation given the dry bulb temperature, humidity ratio, and atmospheric pressure.  The degree of saturation is calculated from the quotient of the humidity ratio to the saturated humidity ratio and is dimensionless.

### See Also

_GetHumRatioFrom…_ to compute the humidity ratio from other psychrometric variables.

## <a name="GetDryAirDensity" id="GetDryAirDensity">GetDryAirDensity</a>

double GetDryAirDensity            /* (o) Dry air density [kg/m3] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the dry air density in kilograms per cubic meter given the dry bulb temperature and atmospheric pressure.

### See Also

_GetMoistAirDensity_ to compute the density of moist air.
_GetDryAirVolume_ to compute the specific volume of dry air.

## <a name="GetDryAirEnthalpy" id="GetDryAirEnthalpy">GetDryAirEnthalpy</a>

double GetDryAirEnthalpy           /* (o) Dry air enthalpy [J/kg] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    );

### Description

Computes the specific enthalpy of dry air, given the dry bulb temperature.

### See Also

_GetMoistAirEnthalpy_ to compute the enthalpy of moist air.
_GetSatAirEnthalpy_ to compute the enthalpy of saturated air.

## <a name="GetDryAirVolume" id="GetDryAirVolume">GetDryAirVolume</a>

double GetDryAirVolume             /* (o) Dry air volume [m3/kg] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the dry air volume in cubic meter per kilogram, given the dry bulb temperature and atmospheric pressure.

### See Also

_GetMoistAirVolume_ to compute the volume of moist air.
_GetDryAirDensity_ to compute the density of dry air.

## <a name="GetHumRatioFromRelHum" id="GetHumRatioFromRelHum">GetHumRatioFromRelHum</a>

double GetHumRatioFromRelHum       /* (o) Humidity Ratio [kgH2O/kgAIR] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double RelHum                /* (i) Relative humidity [0-1] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the humidity ratio in kilograms of water per kilograms of dry air. This function first calculates the vapor pressure from the relative humidity, then calculates the humidity ratio from the vapor pressure.

### See Also

_GetVapPresFromRelHum_ for vapor pressure calculation.
_GetHumRatioFrom…_ to compute humidity ratio from other psychrometric variables.
_GetRelHumFromHumRatio_ to compute relative humidity from humidity ratio.

## <a name="GetHumRatioFromTDewPoint" id="GetHumRatioFromTDewPoint">GetHumRatioFromTDewPoint</a>

double GetHumRatioFromTDewPoint    /* (o) Humidity Ratio [kgH2O/kgAIR] */
    ( double TDewPoint             /* (i) Dew point temperature [C] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the humidity ratio in kilograms of water per kilograms of dry air. This function first calculates the vapor pressure from the dew point temperature, then calculates the humidity ratio from the vapor pressure.

### See Also

_GetVapPresFromTDewPoint_ for vapor pressure calculation.
_GetHumRatioFrom…_ to compute humidity ratio from other psychrometric variables.
_GetTDewPointFromHumRatio_ to compute dew point temperature from humidity ratio.

## <a name="GetHumRatioFromTWetBulb" id="GetHumRatioFromTWetBulb">GetHumRatioFromTWetBulb</a>

double GetHumRatioFromTWetBulb     /* (o) Humidity Ratio [kgH2O/kgAIR] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double TWetBulb              /* (i) Wet bulb temperature [C] */
    , double Pressure
    );

### Description

Computes the humidity ratio in kilograms of water per kilograms of dry air. This function first calculates the vapor pressure from the wet bulb temperature, then calculates the humidity ratio from the vapor pressure.

### See Also

_GetVapPresFromTWetBulb_ for vapor pressure calculation.
_GetHumRatioFrom…_ to compute humidity ratio from other psychrometric variables.
_GetTWetBulbFromHumRatio_ to compute wet bulb temperature from humidity ratio.

## <a name="GetHumRatioFromVapPres" id="GetHumRatioFromVapPres">GetHumRatioFromVapPres</a>

double GetHumRatioFromVapPres   /* (o) Humidity Ratio [kgH2O/kgAIR] */
    ( double VapPres            /* (i) Partial pressure of water vapor in moist air [Pa] */
    , double Pressure           /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the humidity ratio in kilograms of water per kilograms of dry air from the vapor pressure and the atmospheric pressure.

### See Also

_GetHumRatioFrom…_ to compute humidity ratio from other psychrometric variables.
_GetVapPresFromHumRatio_ to compute vapor pressure from humidity ratio.

## <a name="GetMoistAirDensity" id="GetMoistAirDensity">GetMoistAirDensity</a>

double GetMoistAirDensity          /* (o) Moist air density [kg/m3] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double HumRatio              /* (i) Humidity ratio [kgH2O/kgAIR] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the moist air density in kilograms per cubic meter from the dry bulb temperature, humidity ratio, and atmospheric pressure.

### See Also

_GetHumRatioFrom…_ to calculate the humidity ratio from other psychrometric variables.
_GetMoistAirVolume_ for  moist air volume calculation.
_GetDryAirDensity_ for dry air density calculation.

## <a name="GetMoistAirEnthalpy" id="GetMoistAirEnthalpy">GetMoistAirEnthalpy</a>

double GetMoistAirEnthalpy         /* (o) Moist Air Enthalpy [J/kg] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double HumRatio              /* (i) Humidity ratio [kgH2O/kgAIR] */
    );

### Description

Computes the specific enthalpy of moist air in Joules per kilogram given the dry bulb temperature and humidity ratio.

### See Also

_GetHumRatioFrom…_ to calculate the humidity ratio from other psychrometric variables.
_GetDryAirEnthalpy_ for dry air enthalpy calculation.
_GetSatAirEnthalpy_ for saturated air enthalpy calculation.

## <a name="GetMoistAirVolume" id="GetMoistAirVolume">GetMoistAirVolume</a>

double GetMoistAirVolume           /* (o) Specific Volume [m3/kg] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double HumRatio              /* (i) Humidity ratio [kgH2O/kgAIR] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the moist air volume in cubic meters per kilogram of dry air given the dry bulb temperature, humidity ratio, and pressure.

### See Also

_GetHumRatioFrom…_ to calculate the humidity ratio from other psychrometric variables.
_GetMoistAirDensity_ for moist air density calculation.

## <a name="GetRelHumFromHumRatio" id="GetRelHumFromHumRatio">GetRelHumFromHumRatio</a>

double GetRelHumFromHumRatio       /* (o) Relative humidity [0-1] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double HumRatio              /* (i) Humidity ratio [kgH2O/kgAIR] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the relative humidity in decimal form given the humidity ratio, dry bulb temperature, and atmospheric pressure.  The function first computes the vapor pressure from the humidity ratio, then computes the relative humidity from the vapor pressure.

### See Also

_GetHumRatioFrom_… to calculate the humidity ratio from other psychrometric variables
_GetVapPresFromHumRatio_ for calculation of vapor pressure.

## <a name="GetRelHumFromTDewPoint" id="GetRelHumFromTDewPoint">GetRelHumFromTDewPoint</a>

double GetRelHumFromTDewPoint      /* (o) Relative humidity [0-1] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double TDewPoint             /* (i) Dew point temperature [C] */
    );

### Description

Computes the relative humidity in decimal form given the dew point temperature and dry bulb temperature. This function first calculates the vapour pressure from the dew point temperature, then calculates the relative humidity from the vapour pressure.

### See Also

_GetRelHumFrom_… to compute relative humidity from other psychrometric variables.
_GetTDewPointFromRelHum_ to compute dew point temperature from relative humidity.

## <a name="GetRelHumFromTWetBulb" id="GetRelHumFromTWetBulb">GetRelHumFromTWetBulb</a>

double GetRelHumFromTWetBulb       /* (o) Relative humidity [0-1] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double TWetBulb              /* (i) Wet bulb temperature [C] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the relative humidity in decimal form given the wet bulb temperature, dry bulb temperature, and atmospheric pressure.  This function first calculates the humidity ratio from the wet bulb temperature, then calculates the relative humidity from the humidity ratio.

### See Also

_GetHumRatioFromTWetBulb_ for calculation of humidity ratio.
_GetRelHumFrom_… to compute relative humidity from other psychrometric variables.
_GetTWetBulbFromRelHum_ to compute wet bulb temperature from relative humidity.

## <a name="GetRelHumFromVapPres" id="GetRelHumFromVapPres">GetRelHumFromVapPres</a>

double GetRelHumFromVapPres        /* (o) Relative humidity [0-1] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double VapPres               /* (i) Partial pressure of water vapor in moist air [Pa] */
    );

### Description

Computes the relative humidity in decimal form from the dry bulb temperature and vapor pressure.

### See Also

_GetRelHumFrom_… to compute relative humidity from other psychrometric variables.
_GetVapPresFromRelHum_ to compute vapor pressure from relative humidity.

## <a name="GetSatAirEnthalpy" id="GetSatAirEnthalpy">GetSatAirEnthalpy</a>

double GetSatAirEnthalpy           /* (o) Saturated air enthalpy [J/kg] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    );

### Description

Computes the enthalpy of saturated air in Joules per kilogram, given the dry bulb temperature.

### See Also

_GetMoistAirEnthalpy_ for most air enthalpy calculation.
_GetDryAirEnthalpy_ for dry air enthalpy calculation.

## <a name="GetSatHumRatio" id="GetSatHumRatio">GetSatHumRatio</a>

double GetSatHumRatio           /* (o) Humidity ratio of saturated air [kgH2O/kgAIR] */
    ( double TDryBulb           /* (i) Dry bulb temperature [C] */
    , double Pressure           /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the humidity ratio of saturated air in kilograms of water per kilograms of dry air, given the dry bulb temperature and pressure.  The function first calculates the saturated vapor pressure, then the saturated humidity ratio.

### See Also

_GetSatVapPres_ for calculation of the saturated vapor pressure.

## <a name="GetSatVapPres" id="GetSatVapPres">GetSatVapPres</a>

double GetSatVapPres               /* (o) Vapor Pressure of saturated air [Pa] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    );

### Description

Computes the partial pressure of water vapor in saturated air in Pascals given the dry bulb temperature.

## <a name="GetSeaLevelPressure" id="GetSeaLevelPressure"></a>GetSeaLevelPressure

double GetSeaLevelPressure         /* (o) sea level barometric pressure [Pa] */
    ( double StnPressure           /* (i) observed station pressure [Pa] */
    , double Altitude              /* (i) altitude above sea level [m] */
    , double TDryBulb              /* (i) dry bulb temperature [°C] */
    );

### Description

Calculate the sea level pressure, given the atmospheric pressure at station elevation.

### See also

_GetStationPressure_ to compute station pressure from sea level pressure.

## <a name="GetStandardAtmPressure" id="GetStandardAtmPressure"></a>GetStandardAtmPressure

double GetStandardAtmPressure      /* (o) standard atmosphere barometric pressure [Pa] */
    ( double Altitude              /* (i) altitude [m] */                     
    );

### Description

Compute the barometric pressure of the US standard atmosphere, in Pascals, given the elevation (altitude) in meters.

### See also

_GetStandardAtmTemperature_ to compute the temperature of the standard atmosphere.

## <a name="GetStationPressure" id="GetStationPressure"></a>GetStationPressure

double GetStationPressure          /* (o) station pressure [Pa] */
    ( double SeaLevelPressure      /* (i) sea level barometric pressure [Pa] */
    , double Altitude              /* (i) altitude above sea level [m] */
    , double TDryBulb              /* (i) dry bulb temperature [°C] */
    );

### Description

Calculate the stationl pressure, given the sea level pressure.

### See also

_GetSeaLevelPressure_ to compute station pressure from sea level pressure.

## <a name="GetStandardAtmTemperature" id="GetStandardAtmTemperature"></a>GetStandardAtmTemperature

double GetStandardAtmTemperature   /* (o) standard atmosphere dry bulb temperature [C] */
    ( double Altitude              /* (i) altitude [m] */                     
    );

### Description

Compute the dry-bulb temperature of the US standard atmosphere, in C, given the elevation (altitude) in meters.

### See also

_GetStandardAtmPressure _ to compute the barometric pressure of the standard atmosphere.

## <a name="GetTDewPointFromHumRatio" id="GetTDewPointFromHumRatio">GetTDewPointFromHumRatio</a>

double GetTDewPointFromHumRatio    /* (o) Dew Point temperature [C] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double HumRatio              /* (i) Humidity ratio [kgH2O/kgAIR] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the dew point temperature in degrees Celsius given the humidity ratio, dry bulb temperature, and atmospheric pressure.  The function first computes the vapor pressure from the humidity ratio, then computes the dew point temperature from the vapor pressure.

### See Also

_GetVapPresFromHumRatio_ for calculation of vapor pressure
_GetTDewPointFrom_… to compute dew point temperature from other psychrometric variables.
_GetHumRatioFromTDewPoint_ to compute humidity ratio from dew point temperature.

## <a name="GetTDewPointFromRelHum" id="GetTDewPointFromRelHum">GetTDewPointFromRelHum</a>

double GetTDewPointFromRelHum      /* (o) Dew Point temperature [C] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double RelHum                /* (i) Relative humidity [0-1] */
    );

### Description

Computes the dew point temperature in degrees Celsius given the relative humidity, and dry bulb temperature.  The function first calculates the saturated vapor pressure, then calculates the vapor pressure and uses the vapor pressure to calculate the dew point temperature.

### See Also

_GetSatVapPres_ for calculation of saturated vapor pressure.
_GetTDewPointFrom_… to compute dew point temperature from other psychrometric variables.
_GetRelHumFromTDewPoint_ to compute relative humidity from dew point temperature.

## <a name="GetTDewPointFromTWetBulb" id="GetTDewPointFromTWetBulb">GetTDewPointFromTWetBulb</a>

double GetTDewPointFromTWetBulb    /* (o) Dew Point temperature [C] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double TWetBulb              /* (i) Wet bulb temperature [C] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the dew point temperature in degrees Celsius given the wet bulb temperature, dry bulb temperature, and atmospheric pressure.  The humidity ratio is first calculated from the wet bulb temperature, then the dew point temperature is calculated from the humidity ratio.

### See Also

_GetHumRatioFromTWetBulb_ for calculation of humidity ratio.
_GetTDewPointFrom_… to compute dew point temperature from other psychrometric variables.
_GetTWetBulbFromTDewPoint_ to compute wet bulb temperature from dew point temperature.

## <a name="GetTDewPointFromVapPres" id="GetTDewPointFromVapPres">GetTDewPointFromVapPres</a>

double GetTDewPointFromVapPres     /* (o) Dew Point temperature [C] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double VapPres               /* (i) Partial pressure of water vapor in moist air [Pa] */
    );

### Description

Computes the dew point temperature in degrees Celsius from the dry bulb temperature and vapor pressure.

### See Also

_GetTDewPointFrom_… to compute dew point temperature from other psychrometric variables.
_GetVapPresFromTDewPoint_ to compute vapor pressure from dew point temperature.

## <a name="GetTWetBulbFromHumRatio" id="GetTWetBulbFromHumRatio">GetTWetBulbFromHumRatio</a>

double GetTWetBulbFromHumRatio     /* (o) Wet bulb temperature [C] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double HumRatio              /* (i) Humidity ratio [kgH2O/kgAIR] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the wet bulb temperature in degrees Celsius given the humidity ratio, dry bulb temperature, and atmospheric pressure.  The calculation is made using an iterative procedure.

### See Also

_GetTWetBulbFrom_… to compute wet bulb temperature from other psychrometric variables.
_GetHumRatioFromTWetBulb_ to compute humidity ratio from wet bulb temperature.

## <a name="GetTWetBulbFromRelHum" id="GetTWetBulbFromRelHum">GetTWetBulbFromRelHum</a>

double GetTWetBulbFromRelHum       /* (o) Wet bulb temperature [C] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double RelHum                /* (i) Relative humidity [0-1] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the wet bulb temperature in degrees Celsius given the relative humidity, dry bulb temperature, and pressure.  The function calculates the humidity ratio from the relative humidity, then calculates the wet bulb temperature from the humidity ratio.

### See Also

_GetHumRatioFromRelHum_ to compute the humidity ratio.
_GetTWetBulbFrom_… to compute wet bulb temperature from other psychrometric variables.
_GetRelHumFromTWetBulb_ to compute relative humidity from wet bulb temperature.

## <a name="GetTWetBulbFromTDewPoint" id="GetTWetBulbFromTDewPoint">GetTWetBulbFromTDewPoint</a>

double GetTWetBulbFromTDewPoint    /* (o) Wet bulb temperature [C] */
    ( double TDryBulb              /* (i) Dry bulb temperature [C] */
    , double TDewPoint             /* (i) Dew point temperature [C] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the wet bulb temperature in degrees Celsius given the dew point temperature, dry bulb temperature, and atmospheric pressure.  The function calculates the humidity ratio from the dew point temperature, then calculates the wet bulb temperature from the humidity ratio.

### See Also

_GetHumRatioFromTDewPoint_ to compute the humidity ratio.
_GetTWetBulbFrom_… to compute wet bulb temperature from other psychrometric variables.
_GetTDewPointFromTWetBulb_ to compute dew point temperature from wet bulb temperature.

## <a name="GetVapPresFromHumRatio" id="GetVapPresFromHumRatio">GetVapPresFromHumRatio</a>

double GetVapPresFromHumRatio   /* (o) Partial pressure of water vapor in moist air [Pa] */
    ( double HumRatio           /* (i) Humidity ratio [kgH2O/kgAIR] */
    , double Pressure           /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the partial pressure of water vapor in moist air in Pascals, given the humidity ratio and atmospheric pressure.

### See Also

_GetVapPresFrom_… to compute vapor pressure from other psychrometric variables.
_GetHumRatioFromVapPres_ to compute humidity ratio from vapor pressure.

## <a name="GetVapPresFromRelHum" id="GetVapPresFromRelHum">GetVapPresFromRelHum</a>

double GetVapPresFromRelHum     /* (o) Partial pressure of water vapor in moist air [Pa] */
    ( double TDryBulb           /* (i) Dry bulb temperature [C] */
    , double RelHum             /* (i) Relative humidity [0-1] */
    );

### Description

Computes the vapor pressure in Pascals given the relative humidity and dry bulb temperature.

### See Also

_GetVapPresFrom_… to compute vapor pressure from other psychrometric variables.
_GetRelHumFromVapPres_ to compute relative humidity from vapor pressure.

## <a name="GetVapPresFromTDewPoint" id="GetVapPresFromTDewPoint">GetVapPresFromTDewPoint</a>

double GetVapPresFromTDewPoint  /* (o) Partial pressure of water vapor in moist air[Pa] */
    ( double TDewPoint          /* (i) Dew point temperature [C] */
    );

### Description

Computes the vapor pressure in Pascals given the dew point temperature.

### See Also

_GetVapPresFrom_… to compute vapor pressure from other psychrometric variables.
_GetTDewPointFromVapPres_ to compute dew point temperature from vapor pressure.

## <a name="GetVPD" id="GetVPD">GetVPD</a>

double GetVPD                      /* (o) Vapor pressure deficit [Pa] */
( double TDryBulb          /* (i) Dry bulb temperature [C] */
    , double HumRatio              /* (i) Humidity ratio [kgH2O/kgAIR] */
    , double Pressure              /* (i) Atmospheric pressure [Pa] */
    );

### Description

Computes the vapor pressure deficit in Pascals given the humidity ratio, dry bulb temperature, and atmospheric pressure.

### See Also

_GetHumRatioFrom_… to compute humidity ratio from other psychrometric variables.

 |
