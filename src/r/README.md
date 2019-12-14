
<!-- README.md is generated from README.Rmd. Please edit that file -->

# psychrolib

A port of the original python
[psychrolib](https://github.com/psychrometrics/psychrolib) library
written by D. Meyer & D. Thevenard, which provides functions to enable
the calculation of psychrometric properties of moist and dry air. The
library works in both metric (SI) and imperial (IP) systems of units.

## Installation

You can install the released version of psychro from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("psychrolib")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("psychrometrics/psychrolib", subdir = "src/r")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(psychrolib)
#> Setting unit system to 'SI'. See '?SetUnitSystem' for details.

# Calculate the dew point temperature for a dry bulb temperature of 25 C and a relative humidity of 80%
GetTDewPointFromRelHum(25.0, 0.80)
#> [1] 21.3094
```
