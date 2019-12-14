.onLoad <- function(libname, pkgname) {
    SetUnitSystem("SI")
}

.onAttach <- function(libname, pkgname) {
    packageStartupMessage("Setting unit system to 'SI'. See '?SetUnitSystem' for details.")
    SetUnitSystem("SI")
}
