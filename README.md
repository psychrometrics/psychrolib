#Libraries of Psychrometric Functions in C and VBA##


Psychrometrics are the determination of physical and thermodynamic properties of moist air. These properties include, for example, the air's dew point temperature, its wet bulb temperature, relative humidity, humidity ratio, enthalpy, etc.

The library of freeware functions in C provided here enables the calculation of psychrometric properties of moist and dry air. The functions are based of formulae from the ASHRAE Handbook of Fundamentals, 2009 edition. They can be divided into two categories:

 1. Functions enabling the calculation of dew point temperature,
    wet-bulb temperature, partial vapour pressure of water, humidity
    ratio or relative humidity, knowing any other of these and dry bulb
    temperature and atmospheric pressure;
    
 2. Functions enabling the calculation of other moist air properties. All these use the
    humidity ratio as input.

Relationships between these various functions are illustrated in Figure 1. To compute a moist air property such as enthalpy, knowing a humidity parameter such as dew point temperature, one first has to compute the humidity ratio from the dew point temperature, then compute the enthalpy from the humidity ratio. The functions in point (1) above include primary relationships corresponding to formulae from the ASHRAE Handbook, and secondary relationships which use a combination of primary relationships to calculate the result. For example, to compute dew point temperature knowing the partial pressure of water vapor in moist air, the library uses a formula from the ASHRAE Handbook (primary relationship). On the other hand to compute dew point temperature from relative humidity, the library first computes the partial pressure of water vapor, then computes the dew point temperature (secondary relationship). Primary relationships are shown with bold double arrows in Figure 1.

![Psychrometric relationships](https://github.com/psychrometrics/libraries/blob/master/psychrometrics.gif)

**Figure 1 - Psychrometric relationships.**

 A list of functions available in the library can be found in the Psychrometric Library Documentation page.

###Credits

The formulae used in the psychrometric library and in PsychroCalc are those published in the 2009 ASHRAE Handbook of Fundamentals. This publication is available from ASHRAE ([www.ashrae.org](www.ashrae.org)).

###System requirements

The psychrometrics library is provided in source code; its use requires a C or C++ compiler for the C version, or Excel for the VBA version. There are both SI and IP versions of each library.

###Licensing conditions

This library of psychrometric functions isfreeware; licensing is subject to the GNU General Public License, which enables you (provided you give credit where it is due) to use the functions in your own applications.

###Installation instructions

* **C or C++:** 

  SI version:
  
    Download the psychrometrics_SI.cpp and psychrometrics_SI.h files from this site to the directory of your choice.
  
  IP version:
  
    Download the psychrometrics_IP.cpp and psychrometrics_IP.h files from this site to the directory of your choice.

* **VBA:**
  
  SI version:
  
    Download the psychrometricsVBA_SI.bas from this site to the directory of your choice.
  
  IP version:
  
    Download the psychrometricsVBA_IP.bas from this site to the directory of your choice.




