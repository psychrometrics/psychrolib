# <img src="assets/psychrolib_logo.svg" alt="PsychroLib Logo" height="40" width="40"> PsychroLib [![PyPI](https://img.shields.io/pypi/v/psychrolib)](https://pypi.org/project/PsychroLib) [![NuGet](https://img.shields.io/nuget/v/PsychroLib.svg?maxAge=600)](https://www.nuget.org/packages/PsychroLib) [![CRAN](http://www.r-pkg.org/badges/version/psychrolib)](https://cran.r-project.org/package=psychrolib)


|CI and Tests | Paper DOI | Software DOI |
|---|---|------|
[![Build Status](https://travis-ci.com/psychrometrics/psychrolib.svg?branch=master)](https://travis-ci.com/psychrometrics/psychrolib) | [![DOI](https://joss.theoj.org/papers/10.21105/joss.01137/status.svg)](https://doi.org/10.21105/joss.01137) | [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2537945.svg)](https://doi.org/10.5281/zenodo.2537945)|

PsychroLib is a library of functions to enable the calculation of psychrometric properties of moist and dry air. Versions of PsychroLib are available for Python, C, C#, Fortran, R, JavaScript, Microsoft Excel Visual Basic for Applications (VBA). The library works in both metric (SI) and imperial (IP) systems of units. For a general overview and a list of currently available functions, please see the [overview page](docs/overview.md).


## Documentation

The API documentation is available [here](https://psychrometrics.github.io/psychrolib/api_docs.html). Please note that although the API describes the Python version of the library, the API is common across all the supported language implementations. In R please note that (1) constants, like `ZERO_FAHRENHEIT_AS_RANKINE` are not exported (i.e. not directly accessible to users), (2) functions accept a vector, not a scalar (3) bulk calculations, like `CalcPsychrometricsFromRelHum` return a list.

Examples on how to use PsychroLib in all the supported languages are described in [this guide](docs/examples.md).


## Installing

- Python: from the [Python Package Index (PyPI)](https://pypi.org/project/PsychroLib/).
- C# (.NET): from the [NuGet package](https://www.nuget.org/packages/PsychroLib/) manager or clone the repository, and bundle according to your requirements.
- C, Fortran and JavaScript: clone the repository, and bundle according to your requirements.
- VBA/Excel: download the ready-made spreadsheets from the [release tab](https://github.com/psychrometrics/psychrolib/releases).
- R: from the [Comprehensive R Archive Network (CRAN)](https://cran.r-project.org/package=psychrolib).


## Citing

If you are using PsychroLib, please cite the the summary paper (https://doi.org/10.21105/joss.01137) *together* with the specific version of PsychroLib you are using (see [list on Zenodo](https://doi.org/10.5281/zenodo.2537945) for all available versions).


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