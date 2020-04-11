/*
 * PsychroLib (version 2.5.0) (https://github.com/psychrometrics/psychrolib).
 * Copyright (c) 2018-2020 The PsychroLib Contributors for the current library implementation.
 * Copyright (c) 2017 ASHRAE Handbook — Fundamentals for ASHRAE equations and coefficients.
 * Licensed under the MIT License.
*/

/******************************************************************************************************
 * Helper functions
 *****************************************************************************************************/

enum UnitSystem { UNDEFINED, IP, SI };

void SetUnitSystem
  ( enum UnitSystem Units       // (i) System of units (IP or SI)
  );

enum UnitSystem GetUnitSystem  // (o) System of units (SI or IP)
  (
  );


/******************************************************************************************************
 * Conversion between temperature units
 *****************************************************************************************************/

double GetTRankineFromTFahrenheit(double T_F);

double GetTFahrenheitFromTRankine(double T_R);

double GetTKelvinFromTCelsius(double T_C);

double GetTCelsiusFromTKelvin(double T_K);


/******************************************************************************************************
 * Conversions between dew point, wet bulb, and relative humidity
 *****************************************************************************************************/

double GetTWetBulbFromTDewPoint // (o) Wet bulb temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetTWetBulbFromRelHum    // (o) Wet bulb temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double RelHum               // (i) Relative humidity [0-1]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetRelHumFromTDewPoint   // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  );

double GetRelHumFromTWetBulb    // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TWetBulb             // (i) Wet bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetTDewPointFromRelHum   // (o) Dew Point temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double RelHum               // (i) Relative humidity [0-1]
  );

double GetTDewPointFromTWetBulb // (o) Dew Point temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TWetBulb             // (i) Wet bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );


/******************************************************************************************************
 * Conversions between dew point, or relative humidity and vapor pressure
 *****************************************************************************************************/

double GetVapPresFromRelHum     // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double RelHum               // (i) Relative humidity [0-1]
  );

double GetRelHumFromVapPres     // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double VapPres              // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  );

double GetTDewPointFromVapPres  // (o) Dew Point temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double VapPres              // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  );

double GetVapPresFromTDewPoint  // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  ( double TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  );


/******************************************************************************************************
 * Conversions from wet-bulb temperature, dew-point temperature, or relative humidity to humidity ratio
 *****************************************************************************************************/

double GetTWetBulbFromHumRatio  // (o) Wet bulb temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetHumRatioFromTWetBulb  // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TWetBulb             // (i) Wet bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetHumRatioFromRelHum    // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double RelHum               // (i) Relative humidity [0-1]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetRelHumFromHumRatio    // (o) Relative humidity [0-1]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetHumRatioFromTDewPoint // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( double TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetTDewPointFromHumRatio // (o) Dew Point temperature in °F [IP] or °C [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );


/******************************************************************************************************
 * Conversions between humidity ratio and vapor pressure
 *****************************************************************************************************/

double GetHumRatioFromVapPres   // (o) Humidity Ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( double VapPres              // (i) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetVapPresFromHumRatio   // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  ( double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );


/******************************************************************************************************
 * Conversions between humidity ratio and specific humidity
 *****************************************************************************************************/

double GetSpecificHumFromHumRatio // (o) Specific humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( double HumRatio               // (i) Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]
  );

double GetHumRatioFromSpecificHum // (o) Humidity ratio in lb_H₂O lb_Dry_Air⁻¹ [IP] or kg_H₂O kg_Dry_Air⁻¹ [SI]
  ( double SpecificHum            // (i) Specific humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  );


/******************************************************************************************************
 * Dry Air Calculations
 *****************************************************************************************************/

double GetDryAirEnthalpy                  // (o) Dry air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  ( double TDryBulb                       // (i) Dry bulb temperature in °F [IP] or °C [SI]
  );

double GetDryAirDensity                   // (o) Dry air density in lb ft⁻³ [IP] or kg m⁻³ [SI]
  ( double TDryBulb                       // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double Pressure                       // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetDryAirVolume                    // (o) Dry air volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  ( double TDryBulb                       // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double Pressure                       // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetTDryBulbFromEnthalpyAndHumRatio    // (o) Dry-bulb temperature in °F [IP] or °C [SI]
  ( double MoistAirEnthalpy                  // (i) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
  , double HumRatio                          // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  );

double GetHumRatioFromEnthalpyAndTDryBulb  // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( double MoistAirEnthalpy                // (i) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹
  , double TDryBulb                        // (i) Dry-bulb temperature in °F [IP] or °C [SI]
  );


/******************************************************************************************************
 * Saturated Air Calculations
 *****************************************************************************************************/

double GetSatVapPres            // (o) Vapor Pressure of saturated air in Psi [IP] or Pa [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  );

double GetSatHumRatio           // (o) Humidity ratio of saturated air in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetSatAirEnthalpy        // (o) Saturated air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );


/******************************************************************************************************
 * Moist Air Calculations
 *****************************************************************************************************/
double GetVaporPressureDeficit  // (o) Vapor pressure deficit in Psi [IP] or Pa [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetDegreeOfSaturation    // (o) Degree of saturation []
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetMoistAirEnthalpy      // (o) Moist Air Enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  );

double GetMoistAirVolume        // (o) Specific Volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetTDryBulbFromMoistAirVolumeAndHumRatio   // (o) Dry-bulb temperature in °F [IP] or °C [SI]
  ( double MoistAirVolume                         // (i) Specific volume of moist air in ft³ lb⁻¹ of dry air [IP] or in m³ kg⁻¹ of dry air [SI]
  , double HumRatio                               // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure                               // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );

double GetMoistAirDensity       // (o) Moist air density in lb ft⁻³ [IP] or kg m⁻³ [SI]
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double HumRatio             // (i) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  );


/******************************************************************************************************
 * Standard atmosphere
 *****************************************************************************************************/

double GetStandardAtmPressure   // (o) Standard atmosphere barometric pressure in Psi [IP] or Pa [SI]
  ( double Altitude             // (i) Altitude in ft [IP] or m [SI]
  );

double GetStandardAtmTemperature // (o) Standard atmosphere dry bulb temperature in °F [IP] or °C [SI]
  ( double Altitude              // (i) Altitude in ft [IP] or m [SI]
  );

double GetSeaLevelPressure   // (o) Sea level barometric pressure in Psi [IP] or Pa [SI]
  ( double StnPressure       // (i) Observed station pressure in Psi [IP] or Pa [SI]
  , double Altitude          // (i) Altitude above sea level in ft [IP] or m [SI]
  , double TDryBulb          // (i) Dry bulb temperature ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  );

double GetStationPressure    // (o) Station pressure in Psi [IP] or Pa [SI]
  ( double SeaLevelPressure  // (i) Sea level barometric pressure in Psi [IP] or Pa [SI]
  , double Altitude          // (i) Altitude above sea level in ft [IP] or m [SI]
  , double TDryBulb          // (i) Dry bulb temperature in °F [IP] or °C [SI]
  );


/******************************************************************************************************
 * Functions to set all psychrometric values
 *****************************************************************************************************/

void CalcPsychrometricsFromTWetBulb
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TWetBulb             // (i) Wet bulb temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  , double *HumRatio            // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double *TDewPoint           // (o) Dew point temperature in °F [IP] or °C [SI]
  , double *RelHum              // (o) Relative humidity [0-1]
  , double *VapPres             // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  , double *MoistAirVolume      // (o) Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  , double *DegreeOfSaturation  // (o) Degree of saturation [unitless]
  );

void CalcPsychrometricsFromTDewPoint
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double TDewPoint            // (i) Dew point temperature in °F [IP] or °C [SI]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  , double *HumRatio            // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double *TWetBulb            // (o) Wet bulb temperature in °F [IP] or °C [SI]
  , double *RelHum              // (o) Relative humidity [0-1]
  , double *VapPres             // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  , double *MoistAirVolume      // (o) Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  , double *DegreeOfSaturation  // (o) Degree of saturation [unitless]
  );

void CalcPsychrometricsFromRelHum
  ( double TDryBulb             // (i) Dry bulb temperature in °F [IP] or °C [SI]
  , double RelHum               // (i) Relative humidity [0-1]
  , double Pressure             // (i) Atmospheric pressure in Psi [IP] or Pa [SI]
  , double *HumRatio            // (o) Humidity ratio in lb_H₂O lb_Air⁻¹ [IP] or kg_H₂O kg_Air⁻¹ [SI]
  , double *TWetBulb            // (o) Wet bulb temperature in °F [IP] or °C [SI]
  , double *TDewPoint           // (o) Dew point temperature in °F [IP] or °C [SI]
  , double *VapPres             // (o) Partial pressure of water vapor in moist air in Psi [IP] or Pa [SI]
  , double *MoistAirEnthalpy    // (o) Moist air enthalpy in Btu lb⁻¹ [IP] or J kg⁻¹ [SI]
  , double *MoistAirVolume      // (o) Specific volume ft³ lb⁻¹ [IP] or in m³ kg⁻¹ [SI]
  , double *DegreeOfSaturation  // (o) Degree of saturation [unitless]
  );