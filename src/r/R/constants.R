# PsychroLib (version 2.4.0) (https://github.com/psychrometrics/psychrolib).
# Copyright (c) 2018-2020 The PsychroLib Contributors for the current library implementation.
# Copyright (c) 2017 ASHRAE Handbook — Fundamentals for ASHRAE equations and coefficients.
# Licensed under the MIT License.

#######################################################################################################
# Global constants
#######################################################################################################

# Zero degree Fahrenheit (degreeF) expressed as degree Rankine (degreeR)
#
# Units:
# degreeR
#
# Reference:
# ASHRAE Handbook - Fundamentals (2017) ch. 39
ZERO_FAHRENHEIT_AS_RANKINE <- 459.67

# Zero degree Celsius (degreeC) expressed as Kelvin (K)
#
# Units:
# K
#
# Reference:
# ASHRAE Handbook - Fundamentals (2017) ch. 39
ZERO_CELSIUS_AS_KELVIN <- 273.15

# Universal gas constant for dry air (IP version)
#
# Units:
# ft lb_Force lb_DryAir-1 R-1
#
# Reference:
# ASHRAE Handbook - Fundamentals (2017) ch. 1
R_DA_IP <- 53.350

# Universal gas constant for dry air (SI version)
#
# Units:
# J kg_DryAir-1 K-1
#
# Reference:
# ASHRAE Handbook - Fundamentals (2017) ch. 1
R_DA_SI <- 287.042

# Freezing point of water in Fahrenheit.
FREEZING_POINT_WATER_IP <- 32.0

# Freezing point of water in Celsius.
FREEZING_POINT_WATER_SI <- 0.0

# Triple point of water in Fahrenheit.
TRIPLE_POINT_WATER_IP <- 32.018

# Triple point of water in Celsius.
TRIPLE_POINT_WATER_SI <- 0.01
