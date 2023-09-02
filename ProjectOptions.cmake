include(cmake/SystemLink.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)

macro(ray_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(ray_setup_options)
  option(ray_ENABLE_HARDENING "Enable hardening" OFF)
  option(ray_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    ray_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    ray_ENABLE_HARDENING
    OFF)

  ray_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR ray_PACKAGING_MAINTAINER_MODE)
    option(ray_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(ray_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(ray_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(ray_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(ray_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(ray_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(ray_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(ray_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(ray_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(ray_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(ray_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(ray_ENABLE_PCH "Enable precompiled headers" OFF)
    option(ray_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(ray_ENABLE_IPO "Enable IPO/LTO" ON)
    option(ray_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(ray_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(ray_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(ray_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(ray_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(ray_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(ray_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(ray_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(ray_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(ray_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(ray_ENABLE_PCH "Enable precompiled headers" OFF)
    option(ray_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      ray_ENABLE_IPO
      ray_WARNINGS_AS_ERRORS
      ray_ENABLE_USER_LINKER
      ray_ENABLE_SANITIZER_ADDRESS
      ray_ENABLE_SANITIZER_LEAK
      ray_ENABLE_SANITIZER_UNDEFINED
      ray_ENABLE_SANITIZER_THREAD
      ray_ENABLE_SANITIZER_MEMORY
      ray_ENABLE_UNITY_BUILD
      ray_ENABLE_CLANG_TIDY
      ray_ENABLE_CPPCHECK
      ray_ENABLE_COVERAGE
      ray_ENABLE_PCH
      ray_ENABLE_CACHE)
  endif()

endmacro()

macro(ray_global_options)
  if(ray_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    ray_enable_ipo()
  endif()

  ray_supports_sanitizers()

  if(ray_ENABLE_HARDENING AND ray_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN
       OR ray_ENABLE_SANITIZER_UNDEFINED
       OR ray_ENABLE_SANITIZER_ADDRESS
       OR ray_ENABLE_SANITIZER_THREAD
       OR ray_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${ray_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${ray_ENABLE_SANITIZER_UNDEFINED}")
    ray_enable_hardening(ray_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(ray_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(ray_warnings INTERFACE)
  add_library(ray_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  ray_set_project_warnings(
    ray_warnings
    ${ray_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(ray_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    configure_linker(ray_options)
  endif()

  include(cmake/Sanitizers.cmake)
  ray_enable_sanitizers(
    ray_options
    ${ray_ENABLE_SANITIZER_ADDRESS}
    ${ray_ENABLE_SANITIZER_LEAK}
    ${ray_ENABLE_SANITIZER_UNDEFINED}
    ${ray_ENABLE_SANITIZER_THREAD}
    ${ray_ENABLE_SANITIZER_MEMORY})

  set_target_properties(ray_options PROPERTIES UNITY_BUILD ${ray_ENABLE_UNITY_BUILD})

  if(ray_ENABLE_PCH)
    target_precompile_headers(
      ray_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(ray_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    ray_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(ray_ENABLE_CLANG_TIDY)
    ray_enable_clang_tidy(ray_options ${ray_WARNINGS_AS_ERRORS})
  endif()

  if(ray_ENABLE_CPPCHECK)
    ray_enable_cppcheck(${ray_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(ray_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    ray_enable_coverage(ray_options)
  endif()

  if(ray_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(ray_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(ray_ENABLE_HARDENING AND NOT ray_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN
       OR ray_ENABLE_SANITIZER_UNDEFINED
       OR ray_ENABLE_SANITIZER_ADDRESS
       OR ray_ENABLE_SANITIZER_THREAD
       OR ray_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    ray_enable_hardening(ray_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()