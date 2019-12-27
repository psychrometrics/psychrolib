#' psychrolib: Psychrometric Properties of Moist and Dry Air
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
