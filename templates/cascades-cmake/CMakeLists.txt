cmake_minimum_required(VERSION 3.20)
project(cascadeshello LANGUAGES CXX)

include(${CMAKE_SOURCE_DIR}/../../cmake/BB10Qt4.cmake)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/arm/o.le-v7-g")

add_executable(cascadeshello
  src/main.cpp
)

target_include_directories(cascadeshello PRIVATE
  $ENV{QNX_TARGET}/usr/include
)

target_link_libraries(cascadeshello
  bbcascades
  QtCore
  QtDeclarative
)
