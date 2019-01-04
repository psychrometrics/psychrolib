# Development notes

Contains instructions for developing/testing.

## Local testing

PsychroLib is automatically tested at each commit using continuous integration. If are looking to run the tests locally, make sure you can satisfy the required prerequisites and dependencies.

### Prerequisites

- A C and Fortran compiler
- Python version 3.6 or greater.
- Node.js 10.x or greater

### Dependencies

There are a number of dependencies required to run the tests that need to be installed first. From you command prompt, navigate to the `psychrolib` folder and type the following (I assume that pip and python are for version 3.6 or greater):

```
pip install numpy m2r cffi
cd tests/js && npm install
cd ../..
```

### Run

To run the tests, type the following in your command prompt:

#### C, Fortran, Python
```
python -m pytest -v -s
```

#### JavaScript
```
cd tests/js && npm test
```


