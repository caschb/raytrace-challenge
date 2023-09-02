#include <CLI/CLI.hpp>
#include <spdlog/spdlog.h>
#include <config.hpp>

int main(int argc, char ** argv)
{
  CLI::App app("We're doing a raytracer");
  CLI11_PARSE(app, argc, argv)
  spdlog::info("Ray version: {}", ray::info::project_version);

}