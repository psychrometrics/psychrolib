The following psychrometric functions are currently available across all the supported languages:

|Function Name|Description|
|-------------|-----------|
|`GetTRankineFromTFahrenheit`|Utility function to convert temperature to degree Rankine given temperature in degree Fahrenheit.|
|`GetTKelvinFromTCelsius`|Utility function to convert temperature to Kelvin given temperature in degree Celsius.|
|`GetTWetBulbFromTDewPoint`|Return wet-bulb temperature given dry-bulb temperature, dew-point temperature, and pressure.|
|`GetTWetBulbFromRelHum`|Return wet-bulb temperature given dry-bulb temperature, relative humidity, and pressure.|
|`GetRelHumFromTDewPoint`|Return relative humidity given dry-bulb temperature and dew-point temperature.|
|`GetRelHumFromTWetBulb`|Return relative humidity given dry-bulb temperature, wet bulb temperature and pressure.|
|`GetTDewPointFromRelHum`|Return dew-point temperature given dry-bulb temperature and relative humidity.|
|`GetTDewPointFromTWetBulb`|Return dew-point temperature given dry-bulb temperature, wet-bulb temperature, and pressure.|
|`GetVapPresFromRelHum`|Return partial pressure of water vapor as a function of relative humidity and temperature.|
|`GetRelHumFromVapPres`| Return relative humidity given dry-bulb temperature and vapor pressure.|
|`GetTWetBulbFromHumRatio`|Return wet-bulb temperature given dry-bulb temperature, humidity ratio, and pressure.|
|`GetHumRatioFromTWetBulb`|Return humidity ratio given dry-bulb temperature, wet-bulb temperature, and pressure.|
|`GetHumRatioFromRelHum`|Return humidity ratio given dry-bulb temperature, relative humidity, and pressure.|
|`GetRelHumFromHumRatio`|Return relative humidity given dry-bulb temperature, humidity ratio, and pressure.|
|`GetHumRatioFromTDewPoint`|Return humidity ratio given dew-point temperature and pressure.|
|`GetTDewPointFromHumRatio`|Return dew-point temperature given dry-bulb temperature, humidity ratio, and pressure.|
|`GetHumRatioFromVapPres`|Return humidity ratio given water vapor pressure and atmospheric pressure.|
|`GetVapPresFromHumRatio`|Return vapor pressure given humidity ratio and pressure.|
|`GetDryAirEnthalpy`|Return dry-air enthalpy given dry-bulb temperature.|
|`GetDryAirDensity`|Return dry-air density given dry-bulb temperature and pressure.|
|`GetDryAirVolume`|Return dry-air volume given dry-bulb temperature and pressure.|
|`GetSatVapPres`|Return saturation vapor pressure given dry-bulb temperature.|
|`GetSatHumRatio`|Return humidity ratio of saturated air given dry-bulb temperature and pressure.|
|`GetSatAirEnthalpy`|Return saturated air enthalpy given dry-bulb temperature and pressure.|
|`GetVaporPressureDeficit`|Return vapor pressure deficit given dry-bulb temperature, humidity ratio, and pressure.|
|`GetDegreeOfSaturation`|Return the degree of saturation (i.e humidity ratio of the air / humidity ratio of the air at saturation at the same temperature and pressure) given dry-bulb temperature, humidity ratio, and atmospheric pressure.|
|`GetMoistAirEnthalpy`|Return moist air enthalpy given dry-bulb temperature and humidity ratio.|
|`GetMoistAirVolume`|Return moist air specific volume given dry-bulb temperature, humidity ratio, and pressure.|
|`GetMoistAirDensity`|Return moist air density given humidity ratio, dry bulb temperature, and pressure.|
|`GetStandardAtmPressure`|Return standard atmosphere barometric pressure, given the elevation (altitude).|
|`GetStandardAtmTemperature`|Return standard atmosphere temperature, given the elevation (altitude).|
|`GetSeaLevelPressure`|Return sea level pressure given dry-bulb temperature, altitude above sea level and pressure.|
|`GetStationPressure`|Return station pressure from sea level pressure.|
|`CalcPsychrometricsFromTWetBulb`|Utility function to calculate humidity ratio, dew-point temperature, relative humidity, vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given dry-bulb temperature, wet-bulb temperature, and pressure.|
|`CalcPsychrometricsFromTDewPoint`|Utility function to calculate humidity ratio, wet-bulb temperature, relative humidity, vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given dry-bulb temperature, dew-point temperature, and pressure.|
|`CalcPsychrometricsFromRelHum`|Utility function to calculate humidity ratio, wet-bulb temperature, dew-point temperature, vapour pressure, moist air enthalpy, moist air volume, and degree of saturation of air given dry-bulb temperature, relative humidity and pressure.|
