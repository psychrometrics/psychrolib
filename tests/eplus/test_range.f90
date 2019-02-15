! Given a range of temperature, pressure and relative humidity, this program compares,
! and saves to csv the ranges of relative error of `GetTWetBulbFromHumRatio` against `PsyTwbFnTdbWPb`
! corrisponding to the given inputs.
! Copyright 2019 D. Meyer. Licensed under MIT.

program test_range

use psychrolib, only: SetUnitSystem, SI, GetMoistAirDensity, GetTWetBulbFromHumRatio
use Psychrometrics, only: PsyTwbFnTdbWPb, PsyWFnTdbRhPb

implicit none

real :: x, y
real :: T, p, w, RH, rel_err

! Set PsychroLib unit system to SI units
call SetUnitSystem(SI)

! Open output file and write header
open (unit=10, file="psychrolib-v-eplus.txt", action="write", status="replace")
write (10, '(A220)') "Pressure RH Temperature Humidity-Ratio GetTWetBulbFromHumRatio PsyTwbFnTdbWPb Relative-Error"

do p = 80000., 140000., 10000.
    do RH = 0.0, 1.0, 0.01
        do T = -50., 50, 1.
            w = PsyWFnTdbRhPb(T, RH, p)
            y = GetTWetBulbFromHumRatio(T, w, real(p))
            x = PsyTwbFnTdbWPb(T, w, real(p))
            rel_err = (y-x)/x
            write (10, '(7(ES19.10E2))') p, RH, T, w, y, x, rel_err
        end do
    end do
end do

end program test_range
