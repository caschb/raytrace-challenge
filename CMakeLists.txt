cmake_minimum_required(VERSION 3.21)

if (NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 20)
endif()

set(CMAKE_CXX_EXTENSIONS OFF)

project(
  ray
  VERSION 0.0.1
  DESCRIPTION ""
  LANGUAGES CXX C)

include(cmake/PreventInSourceBuilds.cmake)
include(ProjectOptions.cmake)

ray_setup_options()

ray_global_options()
include(Dependencies.cmake)
ray_setup_dependencies()

ray_local_options()

set(CMAKE_CXX_VISIBILITY_PRESET hidden)

set(GIT_SHA
    "Unknown"
    CACHE STRING "SHA this build was generated from")
string(
  SUBSTRING "${GIT_SHA}"
            0
            8
            GIT_SHORT_SHA)

target_compile_features(ray_options INTERFACE cxx_std_${CMAKE_CXX_STANDARD})

add_library(ray::ray_options ALIAS ray_options)
add_library(ray::ray_warnings ALIAS ray_warnings)
add_library(ray_configured INTERFACE)
target_include_directories(ray_configured INTERFACE ${CMAKE_BINARY_DIR}/configured_files/include/)
add_library(ray::ray_configured ALIAS ray_configured)
add_subdirectory(configured_files)
add_subdirectory(src)

if(NOT PROJECT_IS_TOP_LEVEL)
  return()
endif()

include(CTest)

if(BUILD_TESTING)
  message("Building Tests.")
  add_subdirectory(tests)
endif()

if(MSVC)
  get_all_installable_targets(all_targets)
  message("all_targets=${all_targets}")
  set_target_properties(${all_targets} PROPERTIES VS_DEBUGGER_ENVIRONMENT "PATH=$(VC_ExecutablePath_x64);%PATH%")
endif()

set_property(DIRECTORY PROPERTY VS_STARTUP_PROJECT intro)