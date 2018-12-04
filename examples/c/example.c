// PsychroLib c example

#include <stdio.h>
#include "../../src/c/psychrolib.h"

int main(void)
{
    // Set the unit system, for example to SI (can be either 'SI' or 'IP') - this needs to be done only once
    SetUnitSystem(SI);
    // Calculate the dew point temperature for a dry bulb temperature of 25 C and a relative humidity of 80%
    double TDewPoint = GetTDewPointFromRelHum(25.0, 0.80);
    printf("TDewPoint: %f degree C\n", TDewPoint);
}