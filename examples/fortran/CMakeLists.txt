cmake_minimum_required(VERSION 3.1)
project(PsychroLib Fortran)

if (NOT CMAKE_BUILD_TYPE)
    message(STATUS "No build type selected, default to Debug")
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type (default Debug)" FORCE)
endif()

add_library(psychrolib SHARED ../../src/fortran/psychrolib.f90)

add_executable(example example.f90)
target_link_libraries(example psychrolib)