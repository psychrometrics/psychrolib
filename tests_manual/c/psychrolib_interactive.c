// Program to interactively test PsychroLib.
// Copyright (c) 2018 D. Thevenard and D. Meyer. Licensed under the MIT License.

#include <stdio.h>

#include "../../src/c/psychrolib.h"

// Global variables
double TDryBulb;                // Dry bulb temperature [C]
double Pressure;                // Atmospheric pressure [Pa]
double TDewPoint;               // Dew point temperature [C]
double TWetBulb;                // Wet bulb temperature [C]
double RelHum;                  // Relative humidity [0-1]
double HumRatio;                // Humidity ratio [kgH2O/kgAIR]
double VapPres;                 // Partial pressure of water vapor in moist air [Pa]
double MoistAirEnthalpy;        // Moist air enthalpy [J/kg]
double MoistAirVolume;          // Specific volume [m3/kg]
double DegSaturation;           // Degree of saturation []


void PrintPsychrometrics()
{
  printf("Pressure %s                       : %lg\n", GetUnitSystem() == IP ? "[Psi]" : "[Pa] ", Pressure);
  printf("Dry bulb temperature %s             : %lg\n", GetUnitSystem() == IP ? "[F]" : "[C]", TDryBulb);
  printf("Wet bulb temperature %s             : %lg\n", GetUnitSystem() == IP ? "[F]" : "[C]", TWetBulb);
  printf("Dew point temperature %s            : %lg\n", GetUnitSystem() == IP ? "[F]" : "[C]", TDewPoint);
  printf("Relative humidity [0-1]              : %lg\n", RelHum);
  printf("Humidity ratio %s         : %lg\n", GetUnitSystem() == IP ? "[lbH2O/lbAIR]" : "[kgH2O/kgAIR]", HumRatio);
  printf("Partial presure of water vapor %s : %lg\n", GetUnitSystem() == IP ? "[Psi]" : "[Pa] ", VapPres);
  printf("Moist air enthalpy %s          : %lg\n", GetUnitSystem() == IP ? "[Btu/lb]" : "[J/kg]  ", MoistAirEnthalpy);
  printf("Moist air volume %s            : %lg\n", GetUnitSystem() == IP ? "[ft3/lb]" : "[m3/kg] ", MoistAirVolume);
  printf("Degree of saturation []              : %lg\n", DegSaturation);
}

void PsychrometricsFromTDewPoint()
{
  printf("Enter dry bulb temperature %s       : ", GetUnitSystem() == IP ? "[F]" : "[C]");
  scanf_s("%lg", &TDryBulb);
  printf("Enter dew point temperature %s      : ", GetUnitSystem() == IP ? "[F]" : "[C]");
  scanf_s("%lg", &TDewPoint);
  printf("Enter pressure %s                 : ", GetUnitSystem() == IP ? "[Psi]" : "[Pa] ");
  scanf_s("%lg", &Pressure);
  printf("\n");

  if (TDewPoint <= TDryBulb)
  {
    CalcPsychrometricsFromTDewPoint(&TWetBulb, &RelHum, &HumRatio, &VapPres, &MoistAirEnthalpy, &MoistAirVolume, &DegSaturation, TDryBulb, Pressure, TDewPoint);
    PrintPsychrometrics();
  }
  else
    printf("Dew point temperature has to be lower than dry bulb temperature.\n");
}

void PsychrometricsFromTWetBulb()
{
  printf("Enter dry bulb temperature %s       : ", GetUnitSystem() == IP ? "[F]" : "[C]");
  scanf_s("%lg", &TDryBulb);
  printf("Enter wet bulb temperature %s       : ", GetUnitSystem() == IP ? "[F]" : "[C]");
  scanf_s("%lg", &TWetBulb);
  printf("Enter pressure %s                 : ", GetUnitSystem() == IP ? "[Psi]" : "[Pa] ");
  scanf_s("%lg", &Pressure);
  printf("\n");

  if (TWetBulb <= TDryBulb)  {
    CalcPsychrometricsFromTWetBulb(&TDewPoint, &RelHum, &HumRatio, &VapPres, &MoistAirEnthalpy, &MoistAirVolume, &DegSaturation, TDryBulb, Pressure, TWetBulb);
    PrintPsychrometrics();
  }
  else
    printf("Wet bulb temperature has to be lower than dry bulb temperature.\n");
}

void PsychrometricsFromRelHum()
{
  printf("Enter dry bulb temperature %s       : ", GetUnitSystem() == IP ? "[F]" : "[C]");
  scanf_s("%lg", &TDryBulb);
  printf("Enter relative humidity [0-1]        : ");
  scanf_s("%lg", &RelHum);
  printf("Enter pressure %s                 : ", GetUnitSystem() == IP ? "[Psi]" : "[Pa] ");
  scanf_s("%lg", &Pressure);
  printf("\n");

  if (RelHum >= 0 && RelHum <= 1)
  {
    CalcPsychrometricsFromRelHum(&TWetBulb, &TDewPoint, &HumRatio, &VapPres, &MoistAirEnthalpy, &MoistAirVolume, &DegSaturation, TDryBulb, Pressure, RelHum);
    PrintPsychrometrics();
  }
  else
    printf("Relative humidity has to be in the range [0-1].\n");
}

void ToggleUnits()
{
  if (GetUnitSystem() == SI)
    SetUnitSystem(IP);
  else
    SetUnitSystem(SI);
}

int main()
{
  // Units are SI at start
  SetUnitSystem(SI); 

  int Choice = 0;
  printf("Psychrometric calculator\n\n");
  do
  {
    printf("\n");
    printf("Calculation of psychrometric properties - enter choice:\n");
    printf("  1: from dry bulb and dew point temperatures\n");
    printf("  2: from dry bulb and wet bulb temperatures\n");
    printf("  3: from dry bulb temperature and relative humidity\n");
    printf("  9: toggle system of units (current: %s)\n",(GetUnitSystem() == IP) ? "IP" : "SI");
    printf("  0: exit\n");
    printf("> ");
    scanf_s("%d", &Choice);

    switch (Choice)
    {
        case 1: 
        PsychrometricsFromTDewPoint();
        break;
      case 2:
        PsychrometricsFromTWetBulb();
        break;
      case 3:
        PsychrometricsFromRelHum();
        break;
      case 9:
        ToggleUnits();
        break;
      default:
        continue;
    }
  } while (Choice != 0);
  return 0;
}

