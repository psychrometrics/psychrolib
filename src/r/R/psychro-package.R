#' psychrolib: Psychrometric Properties of Moist and Dry Air
#'
#' Psychrometrics are the study of physical and thermodynamic properties of
#' moist air. These properties include, for example, the air's dew point
#' temperature, its wet bulb temperature, relative humidity, humidity ratio,
#' enthalpy.
#'
#' The estimation of these properties is critical in several engineering and
#' scientific applications such as heating, ventilation, and air conditioning
#' (HVAC) and meteorology.
#'
#' psychroLib is a port of the
#' \href{https://github.com/psychrometrics/psychrolib}{psychrolib} library for
#' R. It provides functions to enable calculating psychrometric properties of
#' moist and dry air, working in both metric (SI) and imperial (IP) systems of
#' units. The functions are based of formulae from the 2017 ASHRAE Handbook —
#' Fundamentals, Chapter 1, SI and IP editions.
#'
#' @section Pakcage options:
#'
#' \itemize{
#'   \item \code{psychrolib.unitsystem} The default unit system. Should be
#'         either be \code{"SI"} or \code{"IP"}.
#' }
#'
#' @importFrom Rcpp sourceCpp
#' @useDynLib psychrolib, .registration = TRUE
#' @author
#' \itemize{
#'   \item Hongyuan Jia and Jason Banfelder for R implementation.
#'   \item D. Thevenard and D. Meyer for the core library implementations.
#' }
"_PACKAGE"
