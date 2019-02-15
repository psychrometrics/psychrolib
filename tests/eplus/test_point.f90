! Given temperature, pressure and relative humidity, this program compares,
! and prints to stdout the relative error of `GetTWetBulbFromHumRatio` against `PsyTwbFnTdbWPb`
! corrisponding to the given inputs.
! Copyright 2019 D. Meyer. Licensed under MIT.

program test_point

use psychrolib, only: SetUnitSystem, SI, GetMoistAirDensity, GetTWetBulbFromHumRatio
use Psychrometrics, only: PsyTwbFnTdbWPb, PsyWFnTdbRhPb

implicit none

real :: x, y
real :: T, p, w, RH, rel_err

! Set PsychroLib unit system to SI units
call SetUnitSystem(SI)

T = 7.
p = 130000.00000000000
RH = 2.9999999999999999E-002

w = PsyWFnTdbRhPb(T, RH, p)
x = PsyTwbFnTdbWPb(T, w, real(p))
y = GetTWetBulbFromHumRatio(T, w, real(p))

rel_err = (y-x)/x

print *, "Pressure", p
print *, "RH", RH
print *, "Humidity Ratio", w
print *, "Temperature", T
print *, "Relative error: ", rel_err

end program test_point
