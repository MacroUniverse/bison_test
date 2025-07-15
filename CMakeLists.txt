cmake_minimum_required(VERSION 3.10)
project(mfcalc)

# Set C++ standard to C++11
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Create the executable
add_executable(mfcalc mfcalc.cpp)

# Link with math library
target_link_libraries(mfcalc m)
