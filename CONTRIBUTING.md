# How to contribute

Thank you for considering contributing to PsychroLib. In general, you can contribute by reporting an issue or by directly contributing to the source code. For the latter, fork our repository, clone the fork, make your changes, and create a pull request (PR) with a **clear description** of your changes -- if you are unfamiliar about forking/creating PR, please see [this guide](https://guides.github.com/activities/forking/) first. If/when your changes are merged, you will appear as one of our [Contributors](https://github.com/psychrometrics/psychrolib/graphs/contributors). For specific instructions on how to report a bug, test PsychroLib locally or to learn about our coding conventions please see the sections below.

- [Report a bug](#report-a-bug)
- [Testing](#testing)
- [Coding conventions](#coding-conventions)


## Report a bug

Before creating bug reports, please check if similar issue have already been reported [here](https://github.com/psychrometrics/psychrolib/issues). If none exist please create a new issue and include as many details as possible using the required template.

## Testing

PsychroLib is automatically tested at each commit using continuous integration. If are looking to run the tests locally, make sure you can satisfy the required prerequisites and dependencies.

### Prerequisites

- A C and Fortran compiler
- Python version 3.6 or greater.
- Node.js 10.x or greater
- Microsoft Excel


### Dependencies

There are a number of dependencies required to run the tests that need to be installed first. From you command prompt, navigate to the `psychrolib` folder and type the following (I assume that pip and python are for version 3.6 or greater):

```
pip install numpy m2r cffi
cd tests/js && npm install
cd ../..
```


### Run

To run the tests, type the following in your command prompt:


#### Python, C, Fortran
```
python -m pytest -v -s
```


#### JavaScript
```
cd tests/js && npm test
```


#### VBA/Excel
For VBA/Excel, navigate to `tests/vba` and launch the `test_psychrolib_ip.xlsm` and `test_psychrolib_si.xlsm` files. In Microsoft Excel, after enabling macros, from Visual Basic Editor (VBE) (Alt+F11 on Windows), select `test_psychrolib_<unit_system>` and run (F5 on Windows).


## Coding conventions

The followings are minimal guidelines for new contributors aiming to contribute to the source code. To become acquainted with the conventions it may be easier to first read some of the functions already implemented in the language you are interested to contribute to.

- Always use the language-specific syntax except for function name where we title case must be used irrespective of the language used (e.g. `GetTRankineFromTFahrenheit`).
- Include a clear description of the function, its inputs, outputs and types.
- Include the reference.
- Include clear and comprehensive tests.

Thank you!