#include <CLI/CLI.hpp>

int main(int argc, char ** argv)
{
  CLI::App app("We're doing a raytracer");

  CLI11_PARSE(app, argc, argv)

}