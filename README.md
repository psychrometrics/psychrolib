<div align="center">
<img src="assets/psychrolib_logo.svg" alt="PsychroLib Logo" height="80" width="80"> 

<!-- omit in toc -->
# PsychroLib


[![CI](https://github.com/psychrometrics/psychrolib/actions/workflows/ci.yml/badge.svg)](https://github.com/psychrometrics/psychrolib/actions/workflows/ci.yml) [![PyPI](https://img.shields.io/pypi/v/psychrolib)](https://pypi.org/project/PsychroLib) [![NuGet](https://img.shields.io/nuget/v/PsychroLib.svg?maxAge=600)](https://www.nuget.org/packages/PsychroLib) [![CRAN](https://www.r-pkg.org/badges/version/psychrolib)](https://cran.r-project.org/package=psychrolib) [![DOI](https://joss.theoj.org/papers/10.21105/joss.01137/status.svg)](https://doi.org/10.21105/joss.01137) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2537945.svg)](https://doi.org/10.5281/zenodo.2537945)

[Overview](#overview) | [Documentation](#documentation) | [Installation](#installation) | [How to cite](#how-to-cite) | [Contributing](#contributing) | [Development](#development) | [Copyright and license](#copyright-and-license) | [Acknowledgements](#acknowledgements)

</div>


## Overview

PsychroLib is a software library to enable the calculation of psychrometric properties of moist and dry air. Versions of PsychroLib are available for Python, C, C#, Fortran, R, JavaScript, Microsoft Excel Visual Basic for Applications (VBA). PsychroLib works in both metric (SI) and imperial (IP) systems of units. For a general overview and a list of currently available functions, please see the [overview page](docs/overview.md).


## Documentation

Please see the [Python API documentation](https://psychrometrics.github.io/psychrolib/api_docs.html) for the common API across all the supported language implementations. In Python, array support and improved runtime performance can be optionally enabled by installing [Numba](https://numba.pydata.org/). In R (1) constants, like `ZERO_FAHRENHEIT_AS_RANKINE` are not exported (i.e. not directly accessible to users), (2) functions accept a vector, not a scalar (3) bulk calculations, like `CalcPsychrometricsFromRelHum` return a list.

Examples on how to use PsychroLib in all the supported languages are described in [this guide](docs/examples.md).


## Installation

- Python: from the [Python Package Index (PyPI)](https://pypi.org/project/PsychroLib/). [Numba](https://numba.pydata.org/) can be optionally installed to enable array support and faster runtime performance.
- C# (.NET): from the [NuGet package](https://www.nuget.org/packages/PsychroLib/) manager or clone the repository, and bundle according to your requirements.
- C, Fortran and JavaScript: clone the repository, and bundle according to your requirements.
- VBA/Excel: download the ready-made spreadsheets from the [release tab](https://github.com/psychrometrics/psychrolib/releases).
- R: from the [Comprehensive R Archive Network (CRAN)](https://cran.r-project.org/package=psychrolib).


## How to cite

When using PsychroLib, please cite the software summary paper and software version using the following Digital Object Identifiers (DOIs) to [generate citations in your preferred style](https://citation.crosscite.org/):

| Software summary paper                                                                                                  | Software version*                                                                                                  |
| ----------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| [![DOI](https://joss.theoj.org/papers/10.21105/joss.01137/status.svg)](https://doi.org/10.21105/joss.01137) | [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2537945.svg)](https://doi.org/10.5281/zenodo.2537945) |

*please make sure to cite the same version you are using with the correct DOI. For a list of all available versions see see [more on Zenodo]((https://doi.org/10.5281/zenodo.2537945)).


## Contributing

If you are looking to contribute, please read our [Contributors' guide](CONTRIBUTING.md) for details.


## Development

If you would like to know more about specific development guidelines and testing, please refer to our [development notes](DEVELOP.md).


## Copyright and license

Copyright 2018-2020 [The PsychroLib Contributors](https://github.com/psychrometrics/psychrolib/graphs/contributors) for the current library implementation.

Copyright 2017 ASHRAE Handbook — Fundamentals (https://www.ashrae.org) for equations and coefficients published ASHRAE Handbook — Fundamentals Chapter 1.

Software licensed under the [MIT License](LICENSE.txt).


## Acknowledgements

Special thanks to:
- [@tom--](https://github.com/tom--) for his suggestions with the original JavaScript library implementation
- [@DJGosnell](https://github.com/DJGosnell) for the C# port.
- [@hongyuanjia](https://github.com/hongyuanjia) and [@banfelder](https://github.com/banfelder) for the R port.

For the full list of contributors, please see the [contributors page](https://github.com/psychrometrics/psychrolib/graphs/contributors).