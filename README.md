# <img src="assets/psychrolib_logo.svg" alt="PsychroLib Logo" height="40" width="40"> PsychroLib


|CI and Tests | Paper DOI | Software DOI |
|---|---|------|
[![Build Status](https://travis-ci.com/psychrometrics/psychrolib.svg?branch=master)](https://travis-ci.com/psychrometrics/psychrolib) | [![DOI](https://joss.theoj.org/papers/10.21105/joss.01137/status.svg)](https://doi.org/10.21105/joss.01137) | [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2537945.svg)](https://doi.org/10.5281/zenodo.2537945)|

PsychroLib is a library of functions to enable the calculation of psychrometric properties of moist and dry air. Versions of PsychroLib are available for Python, C, Fortran, JavaScript, Microsoft Excel Visual Basic for Applications (VBA), and .NET Programming Languages (C#, F#, and Visual Basic). The library works in both metric (SI) and imperial (IP) systems of units. For a general overview and a list of currently available functions, please see the [overview page](docs/overview.md).


## Documentation

The API documentation is available [here](https://psychrometrics.github.io/psychrolib/api_docs.html). Please note that although the API describes the Python version of the library, the API is common across all the supported language implementations.

Examples on how to use PsychroLib in all the supported languages are described in [this guide](docs/examples.md).


## Installing

- Python: from the command prompt with `pip install psychrolib`.

- C#, F#, and Visual Basic: from the [NuGet package](https://www.nuget.org/packages/PsychroLib/) manager or clone the repository, and bundle according to your requirements.

- VBA/Excel: download the ready-made spreadsheets from the [release tab](https://github.com/psychrometrics/psychrolib/releases).

- C, Fortran and JavaScript: clone the repository, and bundle according to your requirements.


## Citing

If you are using PsychroLib, please cite the specific version you are using (https://doi.org/10.5281/zenodo.2537945), and the summary paper (https://doi.org/10.21105/joss.01137).


## Contributing

If you are looking to contribute, please read our [Contributors' guide](CONTRIBUTING.md) for details.


## Copyright and license

Copyright 2018 D. Thevenard and D. Meyer for the current library implementation.

Copyright 2017 ASHRAE Handbook — Fundamentals (https://www.ashrae.org) for equations and coefficients published ASHRAE Handbook — Fundamentals Chapter 1.

Licensed under the [MIT License](LICENSE.txt).


## Acknowledgements

Many thanks to ([@tom--](https://github.com/tom--)) for his suggestions with the original JavaScript library implementation and ([@DJGosnell](https://github.com/DJGosnell)) for the C# port.