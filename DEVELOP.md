# Development notes

## Coding conventions

The followings are minimal guidelines for new contributors aiming to contribute to the source code. To become acquainted with the conventions it may be easier to first read some of the functions already implemented in the language you are interested to contribute to.

- Always use the language-specific syntax except when defining function names where camel case (e.g. `GetTRankineFromTFahrenheit`) is used irrespective of the language.
- Include a clear description of the function, its inputs, outputs and types.
- Include references.
- Write clear and comprehensive tests.


## Versioning

This project uses [semantic versioning](https://semver.org/).


## Deployment

### Python 

From the command prompt, navigate to `src/python`. Then you can create and upload a new release with the following commands:

```
python3 setup.py sdist --formats=zip
python3 -m pip install --user --upgrade twine
python3 -m twine upload dist/*
```

### R

From the command prompt, navigate to `src/r`. To install the package, open R and run:

```r
source("tools/deploy.R")
```

It will copy LICENSE, README.md from the main repo into `src/r`, create package documentation and install psychrolib for you.

If you are a package developer, you can get more options by running:

```
Rscript tools/deploy.R [OPTION]
```

Where `[OPTION]` can be one of:

* `--prepare` or `-p`: copy LICENSE.txt, README.md and update links in README.md
* `--doc` or `-d`: create/update package documentation
* `--install` or `-i`: create/update package documentation and install package
* `--help` or `-h`: show help messages

*NOTE*: In order to run command above, `Rscript.exe` (on Windows) or `Rscript` (on Linux and MacOS) should be in system `PATH`.

## Testing

PsychroLib is automatically tested at each commit using continuous integration. If are looking to run the tests locally, make sure you can satisfy the required prerequisites and dependencies.

### Prerequisites

- A C and Fortran compiler
- Python version 3.6 or greater.
- Node.js 10.x or greater
- Microsoft Excel
- Microsoft .NET Core SDK
- R version 3.0.0 or greater


### Dependencies

There are a number of dependencies required to run the tests that need to be installed first. From you command prompt, navigate to the `psychrolib` folder and type the following (I assume that pip and python are for version 3.6 or greater):

```
pip install numpy m2r cffi pytest
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


#### Microsoft .NET (C#, Visual Basic, and F#)

```
cd src/c_sharp && dotnet test # `dotnet-sdk.dotnet test` if installed with Snapcraft.
```

#### VBA/Excel
For VBA/Excel, navigate to `tests/vba` and open `test_psychrolib_ip.xlsm` and `test_psychrolib_si.xlsm`. For each file, enable macros and launch the Visual Basic Editor (VBE) (Alt+F11 on Windows). Go to `Edit` and activate the 'Immediate Window' (Alt+F11 on Windows) and click on 'RunAllTests' from the right hand side drop down menu at the top next to '(General)'.   But in essence go in the VBA editor, click on RunAllTests, then press on the Run icon or go to 'Run' > 'Run' menu. The results will appear in the 'Immediate Window' at the bottom of the screen.

![VBA/Excel Test](assets/excel_test.png)


#### R

Navigate to `src/r`, run:

```
R CMD build .
R CMD check psychrolib*tar.gz
```
