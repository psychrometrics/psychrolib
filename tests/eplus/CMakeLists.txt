# Copyright 2019 D. Meyer. Licensed under MIT.

cmake_minimum_required(VERSION 3.0)

project(EplusTest Fortran)

# https://github.com/llvm-mirror/llvm/blob/632c2834200b33571d51b91164efe5b8c6c44150/CMakeLists.txt#L52-L55
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "No build type selected, default to Debug")
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type (default Debug)" FORCE)
endif()

if(CMAKE_Fortran_COMPILER_ID MATCHES "GNU")
    set(dialect "-ffree-form -std=gnu -fimplicit-none -fno-unsafe-math-optimizations -frounding-math -fsignaling-nans -ggdb -fdefault-real-8 -fdefault-double-8")
    set(bounds "-fbounds-check")
endif()
if(CMAKE_Fortran_COMPILER_ID MATCHES "Intel")
	if(WIN32)
		set(dialect "/stand:f08 /free")
		set(bounds "/check:bounds")
	else()
		set(dialect "-stand f08 -free -implicitnone")
		set(bounds "-check bounds")
	endif()
endif()

set(CMAKE_Fortran_FLAGS_DEBUG "${CMAKE_Fortran_FLAGS_DEBUG} ${bounds}")
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} ${dialect}")
set( CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/fmodules )

include(ExternalProject)

set (EnergyPlus_GIT_REPO "https://github.com/dmey/EnergyPlusFortran.git")

if(NOT OFFLINE)
    SET(OFFLINE FALSE)
endif()

# detect build config (like "Debug") for single- and multi-configuration generators
# (e.g. Makefile vs Visual Studio)
if(CMAKE_CONFIGURATION_TYPES)
    set(configuration $<CONFIGURATION>)
else()
    set(configuration ${CMAKE_BUILD_TYPE})
endif()

ExternalProject_Add(EnergyPlus-Fortran
    GIT_REPOSITORY ${EnergyPlus_GIT_REPO}
    CMAKE_GENERATOR ${CMAKE_GENERATOR}
    CMAKE_ARGS
        "-DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}"
        "-DCMAKE_INSTALL_PREFIX=install"
        "-DCMAKE_BUILD_TYPE=${configuration}"
        "-DUSE_SQLIGHT=OFF"
        "-DDISABLE_PSYCHROMETRICS_CACHE=TRUE"
    INSTALL_COMMAND
        "${CMAKE_COMMAND}" --build . --target install --config ${configuration}
    EXCLUDE_FROM_ALL TRUE
    STEP_TARGETS install
    UPDATE_DISCONNECTED ${OFFLINE}
)

# Default back to pull repo from github unless specified with flag at configure time
# i.e. -DOFFLINE=ON
UNSET(OFFLINE CACHE)


add_executable(test_point ../../src/fortran/psychrolib.f90 test_point.f90)

add_dependencies(test_point EnergyPlus-Fortran-install)

ExternalProject_Get_Property(EnergyPlus-Fortran binary_dir)
set(ENERGYPLUS_FORTRAN_LIBRARY ${binary_dir}/install/lib/${CMAKE_STATIC_LIBRARY_PREFIX}energyplus${CMAKE_STATIC_LIBRARY_SUFFIX})
include_directories(${binary_dir}/install/mod)

target_link_libraries(test_point ${ENERGYPLUS_FORTRAN_LIBRARY})

install(TARGETS test_point
    RUNTIME DESTINATION bin
)

add_executable(test_range ../../src/fortran/psychrolib.f90 test_range.f90)

add_dependencies(test_range EnergyPlus-Fortran-install)

ExternalProject_Get_Property(EnergyPlus-Fortran binary_dir)
set(ENERGYPLUS_FORTRAN_LIBRARY ${binary_dir}/install/lib/${CMAKE_STATIC_LIBRARY_PREFIX}energyplus${CMAKE_STATIC_LIBRARY_SUFFIX})
include_directories(${binary_dir}/install/mod)

target_link_libraries(test_range ${ENERGYPLUS_FORTRAN_LIBRARY})

install(TARGETS test_range
    RUNTIME DESTINATION bin
)

# install Fortran mod files, see https://cmake.org/pipermail/cmake/2010-May/037106.html
INSTALL ( CODE
  "EXECUTE_PROCESS (COMMAND \"${CMAKE_COMMAND}\" -E copy_directory \"${CMAKE_Fortran_MODULE_DIRECTORY}/\${BUILD_TYPE}\" \"${CMAKE_INSTALL_PREFIX}/mod\")"
)