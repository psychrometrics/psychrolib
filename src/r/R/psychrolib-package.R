# PsychroLib (version 2.5.0) (https://github.com/psychrometrics/psychrolib).
# Copyright (c) 2018-2020 The PsychroLib Contributors for the current library implementation.
# Copyright (c) 2017 ASHRAE Handbook — Fundamentals for ASHRAE equations and coefficients.
# Licensed under the MIT License.

#' PsychroLib: Psychrometric Properties of Moist and Dry Air
#'
#' Contains functions for calculating thermodynamic properties of gas-vapor
#' mixtures and standard atmosphere suitable for most engineering, physical and
#' meteorological applications.
#'
#' Most of the functions are an implementation of the formulae found in the
#' 2017 ASHRAE Handbook - Fundamentals, in both International System (SI), and
#' Imperial (IP) units. Please refer to the information included in each
#' function for their respective reference.
#'
#' psychroLib is a port of the
#' \href{https://github.com/psychrometrics/psychrolib}{psychrolib} library for
#' R.
#'
#' @note
#' We have made every effort to ensure that the code is adequate, however, we
#' make no representation with respect to its accuracy. Use at your own risk.
#' Should you notice an error, or if you have a suggestion, please notify us
#' through GitHub at https://github.com/psychrometrics/psychrolib/issues.
#'
#' @examples
#' library(psychrolib)
#' # Set the unit system, for example to SI (can be either SI or IP)
#' SetUnitSystem("SI")
#'
#' # Calculate the dew point temperature for a dry bulb temperature of 25 C
#' # and a relative humidity of 80%
#' GetTDewPointFromRelHum(25.0, 0.80)
#'
#' @section Pakcage options:
#'
#' \itemize{
#'   \item \code{psychrolib.units} The default unit system. Should be
#'         either be \code{"SI"} or \code{"IP"}.
#' }
#'
#' @importFrom Rcpp sourceCpp
#' @useDynLib psychrolib, .registration = TRUE
#' @author
#' \itemize{
#'   \item Hongyuan Jia and Jason Banfelder for R implementation.
#'   \item D. Thevenard and D. Meyer for the core library implementations.
#'   \item Equations and coefficients published ASHRAE Handbook — Fundamentals,
#'         Chapter 1 Copyright (c) 2017 ASHRAE Handbook — Fundamentals
#'         (https://www.ashrae.org)
#' }
"_PACKAGE"
