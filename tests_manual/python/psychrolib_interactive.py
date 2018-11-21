# Program to interactively test PsychroLib.
# Copyright (c) 2018 D. Thevenard and D. Meyer. Licensed under the MIT License.

import sys
from psychrolib import *

# Global variables
TDryBulb = 0                # Dry bulb temperature [F or C]
Pressure = 0                # Atmospheric pressure [Psi or Pa]
TDewPoint = 0               # Dew point temperature [F or C]
TWetBulb = 0                # Wet bulb temperature [F or C]
RelHum = 0                  # Relative humidity [0-1]
HumRatio = 0                # Humidity ratio [lbH2O/lbAir or kgH2O/kgAIR]
VapPres = 0                 # Partial pressure of water vapor in moist air [Psi or Pa]
MoistAirEnthalpy = 0        # Moist air enthalpy [Btu/lb or J/kg]
MoistAirVolume = 0          # Specific volume [ft3/lb or m3/kg]
DegSaturation = 0           # Degree of saturation []

TempUnits = ""              # units used for temperature
PresUnits = ""              # units used for pressure
HuRaUnits = ""              # units for humidity ratio
EnthUnits = ""              # units for enthalpy
SVolUnits = ""              # units for specific volume


# Function to let the user enter a float 
def GetFloat(Prompt: str) -> float:
    while (True):
        ans = input(Prompt)
        try:
            val = float(ans)
            break
        except:
            print("Invalid entry, please try again.\n")
    return val

def printf(format, *args):
    sys.stdout.write(format % args)

def PrintPsychrometrics():
    printf("\n")
    printf("Pressure %s                        : %.3f\n", PresUnits, Pressure)
    printf("Dry bulb temperature %s              : %f\n", TempUnits, TDryBulb)
    printf("Wet bulb temperature %s              : %f\n", TempUnits, TWetBulb)
    printf("Dew point temperature %s             : %f\n", TempUnits, TDewPoint)
    printf("Relative humidity [0-1]               : %f\n", RelHum)
    printf("Humidity ratio %s          : %f\n", HuRaUnits, HumRatio)
    printf("Partial pressure of water vapor %s : %f\n", PresUnits, VapPres)
    printf("Moist air enthalpy %s           : %f\n", EnthUnits, MoistAirEnthalpy)
    printf("Moist air volume %s             : %f\n", SVolUnits, MoistAirVolume)
    printf("Degree of saturation []               : %f\n", DegSaturation)

def PsychrometricsFromTDewPoint():
    global Pressure, TDryBulb, TDewPoint, TWetBulb, RelHum, HumRatio, VapPres, MoistAirEnthalpy, MoistAirVolume, DegSaturation

    TDryBulb  = GetFloat("Enter dry bulb temperature " + TempUnits + "        : ")
    TDewPoint = GetFloat("Enter dew point temperature " + TempUnits + "       : ")
    Pressure  = GetFloat("Enter pressure " + PresUnits + "                  : ")

    if (TDewPoint <= TDryBulb):
        TDryBulb, TWetBulb, TDewPoint, RelHum, HumRatio, VapPres, MoistAirEnthalpy, MoistAirVolume, DegSaturation = CalcPsychrometricsFromTDewPoint(TDryBulb, TDewPoint,Pressure)
        PrintPsychrometrics()
    else:
        printf("Dew point temperature has to be lower than dry bulb temperature.\n")


def PsychrometricsFromTWetBulb():
    global Pressure, TDryBulb, TDewPoint, TWetBulb, RelHum, HumRatio, VapPres, MoistAirEnthalpy, MoistAirVolume, DegSaturation

    TDryBulb  = GetFloat("Enter dry bulb temperature " + TempUnits + "        : ")
    TWetBulb  = GetFloat("Enter wet bulb temperature "+ TempUnits + "        : ")
    Pressure  = GetFloat("Enter pressure " + PresUnits + "                  : ")

    if (TWetBulb <= TDryBulb):
        TDryBulb, TWetBulb, TDewPoint, RelHum, HumRatio, VapPres, MoistAirEnthalpy, MoistAirVolume, DegSaturation = CalcPsychrometricsFromTWetBulb(TDryBulb, TWetBulb, Pressure)
        PrintPsychrometrics()
    else:
        printf("Wet bulb temperature has to be lower than dry bulb temperature.\n")


def PsychrometricsFromRelHum():
    global Pressure, TDryBulb, TDewPoint, TWetBulb, RelHum, HumRatio, VapPres, MoistAirEnthalpy, MoistAirVolume, DegSaturation

    TDryBulb = GetFloat("Enter dry bulb temperature " + TempUnits + "        : ")
    RelHum   = GetFloat("Enter relative humidity [0-1]         : ")
    Pressure = GetFloat("Enter pressure " + PresUnits + "                  : ")

    if (RelHum >= 0 and RelHum <= 1):
        TDryBulb, TWetBulb, TDewPoint, RelHum, HumRatio, VapPres, MoistAirEnthalpy, MoistAirVolume, DegSaturation = CalcPsychrometricsFromRelHum(TDryBulb, RelHum, Pressure)
        PrintPsychrometrics();
    else:
        printf("Relative humidity has to be in the range [0-1].\n")

def ToggleUnits():
    global TempUnits, PresUnits, HuRaUnits, EnthUnits, SVolUnits
    if (GetUnitSystem() == "SI"):
        SetUnitSystem("IP")
        TempUnits = "[F]"             # units used for temperature
        PresUnits = "[Psi]"           # units used for pressure
        HuRaUnits = "[lbH2O/lbAir]"   # units for humidity ratio
        EnthUnits = "[Btu/lb]"        # units for enthalpy
        SVolUnits = "[ft3/lb]"        # units for specific volume
    else:
        SetUnitSystem("SI")
        TempUnits = "[C]"             # units used for temperature
        PresUnits = "[Pa] "           # units used for pressure
        HuRaUnits = "[kgH2O/kgAir]"   # units for humidity ratio
        EnthUnits = "[J/kg]  "        # units for enthalpy
        SVolUnits = "[m3/kg] "        # units for specific volume


# Main program
Choice = 0

# Set system of units
SetUnitSystem("IP")
ToggleUnits()                   # This sets the units for printing

printf("Psychrometric calculator\n\n")
while (True):
    printf("\n");
    printf("Calculation of psychrometric properties - enter choice:\n")
    printf("  1: from dry bulb and dew point temperatures\n")
    printf("  2: from dry bulb and wet bulb temperatures\n")
    printf("  3: from dry bulb temperature and relative humidity\n")
    printf("  9: toggle system of units (current: %s)\n", "SI")
    printf("  0: exit\n")
    Choice = input("> ")

    if (Choice == '1'):
        PsychrometricsFromTDewPoint()
    elif (Choice == '2'):
        PsychrometricsFromTWetBulb()
    elif (Choice == '3'):
        PsychrometricsFromRelHum()
    elif (Choice == '9'):
        ToggleUnits()
    elif (Choice == '0'):
        break

