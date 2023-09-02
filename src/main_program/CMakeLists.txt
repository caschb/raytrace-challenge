add_executable(ray src/main.cpp)

target_link_libraries(
  ray
  PRIVATE ray::ray_options
          ray::ray_warnings
)

target_link_system_libraries(
  ray
  PRIVATE
          CLI11::CLI11
          fmt::fmt
          spdlog::spdlog
)

target_include_directories(ray PRIVATE inc/)