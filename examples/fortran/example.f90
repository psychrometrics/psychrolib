! PsychroLib fortran example

program example
    use psychrolib, only: GetTDewPointFromRelHum, SetUnitSystem, SI
    ! Set the unit system, for example to SI (can be either 'SI' or 'IP') - this needs to be done only once
    call SetUnitSystem(SI)
    ! Calculate the dew point temperature for a dry bulb temperature of 25 C and a relative humidity of 80%
    print *, "TDewPoint: ", GetTDewPointFromRelHum(25.0, 0.80), "degree C"
end program example