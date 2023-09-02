include(GenerateExportHeader)

add_library(raycommon src/raycommon.cpp)

add_library(ray::raycommon ALIAS raycommon)

target_link_libraries(raycommon PRIVATE ray_options ray_warnings)

target_include_directories(raycommon ${WARNING_GUARD} PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                                                                  $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
                                                                  inc/)

target_compile_features(raycommon PUBLIC cxx_std_20)

set_target_properties(
  raycommon
  PROPERTIES VERSION ${PROJECT_VERSION}
             CXX_VISIBILITY_PRESET hidden
             VISIBILITY_INLINES_HIDDEN YES)

generate_export_header(raycommon EXPORT_FILE_NAME ${PROJECT_BINARY_DIR}/include/ray/raycommon_export.hpp)

if(NOT BUILD_SHARED_LIBS)
  target_compile_definitions(raycommon PUBLIC raycommon_STATIC_DEFINE)
endif()