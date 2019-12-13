#######################################################################################################
# Global constants
#######################################################################################################
# Universal gas constant for dry air (IP version)
#
# Units:
# ft lb_Force lb_DryAir⁻¹ R⁻¹
#
# Reference:
# ASHRAE Handbook - Fundamentals (2017) ch. 1
R_DA_IP <- 53.350

# Universal gas constant for dry air (SI version)
#
# Units:
# J kg_DryAir⁻¹ K⁻¹
#
# Reference:
# ASHRAE Handbook - Fundamentals (2017) ch. 1
R_DA_SI <- 287.042

# Maximum number of iterations before exiting while loops.
MAX_ITER_COUNT <- 100

# Minimum acceptable humidity ratio used/returned by any functions.
# Any value above 0 and below the MIN_HUM_RATIO will be reset to this value.
MIN_HUM_RATIO <- 1e-7
