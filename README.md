<p align="center"><img src="assets/psychrolib_logo.svg" alt="PsychroLib Logo" height="60" width="60"></p>

# PsychroLib

|CI and Tests | Paper DOI | Software DOI |
|---|---|------|
[![Build Status](https://travis-ci.com/psychrometrics/psychrolib.svg?branch=master)](https://travis-ci.com/psychrometrics/psychrolib) | [![DOI](https://joss.theoj.org/papers/10.21105/joss.01137/status.svg)](https://doi.org/10.21105/joss.01137) | [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2537945.svg)](https://doi.org/10.5281/zenodo.2537945)|

PsychroLib is a library of functions written in Python, C, Fortran, JavaScript, and Microsoft Excel Visual Basic for Applications (VBA) to enable the calculation of psychrometric properties of moist and dry air. For a general overview and a list of currently available functions, please see the [overview page](docs/overview.md).


## Documentation

The API documentation is available [here](https://psychrometrics.github.io/psychrolib/api_docs.html). Please note that although the API describes the Python version of the library, the API is common across all the supported language implementations.

Examples on how to use PsychroLib in Python, C, Fortran, JavaScript, and Microsoft Excel Visual Basic for Applications (VBA) are described in [this guide](docs/how_to_use_psychrolib.md).


## Installing

In Python, PsychroLib is available though the Python Package Index (PyPI) and can be installed from the command prompt with the following command: `pip install psychrolib`.

In Excel, you can download ready-made spreadsheets from the [release tab](https://github.com/psychrometrics/psychrolib/releases).

For all C, Fortran and JavaScript, simply clone the repository, and boundle PsychroLib with your code.


## Citing

If you are using PsychroLib, **please cite both the paper, and the software**.

For the paper, please use, or adapt from, the following:
```
Meyer, D., & Thevenard, D. (2019). PsychroLib: a library of psychrometric
functions to calculate thermodynamic properties of air. Journal of Open Source
Software, 4(33), 1137. https://doi.org/10.21105/joss.01137
```

For the software, **please cite the specific version of PsychroLib you are using** as listed on Zenodo -- see https://doi.org/10.5281/zenodo.2537945


## Contributing

If you are looking to contribute, please read our [Contributors' guide](CONTRIBUTING.md) for details.


## Copyright and license

Copyright 2018 D. Thevenard and D. Meyer for the current library implementation.

Copyright 2017 ASHRAE Handbook — Fundamentals (https://www.ashrae.org) for equations and coefficients published ASHRAE Handbook — Fundamentals Chapter 1.

Licensed under the [MIT License](LICENSE.txt).


## Acknowledgements

Many thanks to Tom Worster ([@tom--](https://github.com/tom--)) for his suggestions with the original JavaScript library implementation.