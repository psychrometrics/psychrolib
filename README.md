<p align="center"><img src="assets/psychrolib-logo.svg" alt="PsychroLib Logo" height="150" width="150"></p>

# PsychroLib: a library of psychrometric functions for Python, C, Fortran, JavaScript and VBA/Excel

[![Build Status](https://travis-ci.com/psychrometrics/psychrolib.svg?branch=master)](https://travis-ci.com/psychrometrics/psychrolib)

Psychrometrics are the study of physical and thermodynamic properties of moist air. These properties include, for example, the air's dew point temperature, its wet bulb temperature, relative humidity, humidity ratio, enthalpy.

The estimation of these properties is critical in several engineering and scientific applications such as heating, ventilation, and air conditioning (HVAC) and meteorology. Although formulae to calculate the psychrometric properties of air are widely available in the literature ([@Stull2011]; [@Wexler1983]; [@Stoecker1982]; [@Dilley1968]; [@Humphreys1920]), their implementation in computer programs or spreadsheets can be challenging and time consuming.

PsychroLib is a library of functions to enable calculating psychrometric properties of moist and dry air. The library is available for Python, C, Fortran, JavaScript, and Microsoft Excel Visual Basic for Applications (VBA). The functions are based of formulae from the  2017 ASHRAE Handbook — Fundamentals, Chapter 1. Functions can be grouped into two categories:

1. Functions for the calculation of dew point temperature, wet-bulb temperature, partial vapour pressure of water, humidity ratio or relative humidity, knowing any other of these and dry bulb temperature and atmospheric pressure.

2. Functions for the calculation of other moist air properties. All these use the humidity ratio as input.

Relationships between these various functions are illustrated in Figure 1. To compute a moist air property such as enthalpy, knowing a humidity parameter such as dew point temperature, one first has to compute the humidity ratio from the dew point temperature, then compute the enthalpy from the humidity ratio. The functions in point (1) above include primary relationships corresponding to formulae from the ASHRAE Handbook, and secondary relationships which use a combination of primary relationships to calculate the result. For example, to compute dew point temperature knowing the partial pressure of water vapor in moist air, the library uses a formula from the ASHRAE Handbook (primary relationship). On the other hand to compute dew point temperature from relative humidity, the library first computes the partial pressure of water vapor, then computes the dew point temperature (secondary relationship). Primary relationships are shown with bold double arrows in Figure 1.

<p align="center"><img src="assets/psychrolib-relationships.svg" alt="Psychrometric relationships"></p>
<p align="center"><b>Figure 1</b> - Psychrometric relationships.</p>


## Documentation

PsychroLib is available for Python, C, Fortran, JavaScript, and Microsoft Excel Visual Basic for Applications (VBA). For an overview of currently available functions, please see the [list of available functions page](docs/available-functions.md). To consult the application programming interface (API), documentation please see the  [API documentation page](https://psychrometrics.github.io/psychrolib/api-docs.html) instead -- although the API describes the Python version of the library, the API is common across all the supported language implementations.


## Installing

To install or bundle the library as part of your program see the language-specific instructions below -- there are no external dependencies required.

### Python

PsychroLib is available though the Python Package Index (PyPI) and can be installed using `pip` with `pip install psychrolib`.


### C, Fortran, JS and VBA

Clone the repository, or download the file directly from the repository, and include PsychroLib to your code according to the language specifications.


## Example usage

For examples on how to use PsychroLib in Python, C, Fortran, JavaScript, and Microsoft Excel Visual Basic for Applications (VBA) please see [this guide](docs/how-to-use-psychrolib.md).


## Contributing

If you are looking to contribute, please read our [Contributors' Guide](CONTRIBUTING.md) for details.


## Versioning

This project uses [semantic versioning](https://semver.org/).


## Copyright and license

Copyright (c) 2018 D. Thevenard and D. Meyer for the current library implementation.

Copyright (c) 2017 ASHRAE Handbook — Fundamentals (https://www.ashrae.org) for equations and coefficients published ASHRAE Handbook — Fundamentals Chapter 1.

Licensed under the [MIT License](LICENSE.txt).


## Acknowledgements

Many thanks to Tom Worster ([@tom--](https://github.com/tom--)) for his suggestions with the original JavaScript library implementation.



[@Dilley1968]: https://dx.doi.org/10.1175/1520-0450(1968)007<0717:otccov>2.0.co;2 "Dilley, A. C. (1968). On the computer calculation of vapor pressure and specific humidity gradients from psychrometric data. Journal of Applied Meteorology, 7(4), 717–719. doi:10.1175/1520-0450(1968)007<0717:otccov>2.0.co;2"

[@Humphreys1920]: https://archive.org/details/physicsofair00hump/page/n9 "Humphreys, W. J. (1920). Physics of the air. Philadelphia, PA: Pub. for the Franklin Institute of the state of Pennsylvania by J.B. Lippincott Company."

[@Stoecker1982]: https://books.google.de/books?id=PrZTAAAAMAAJ&dq "Stoecker, W., & Jones, J. (1982). Refrigeration and air conditioning. McGraw-hill international editions. New York, NY: McGraw-Hill."

[@Stull2011]: https://doi.org/10.1175/JAMC-D-11-0143.1 "Stull, R. (2011). Wet-bulb temperature from relative humidity and air temperature. Journal of Applied Meteorology and Climatology, 50(11), 2267–2269. doi:10.1175/jamc-d11-0143.1"

[@Wexler1983]: https://books.google.de/books?id=MH8URAAACAAJ "Wexler, A., Hyland, R., Stewart, R., & American Society of Heating, Refrigerating and Air-Conditioning Engineers. (1983). Thermodynamic properties of dry air, moist air and water and si psychrometric charts. Atlanta, GA: ASHRAE."