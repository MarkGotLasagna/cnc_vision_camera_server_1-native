################################################################## CMAKE SPECIFIC CONFIGURATION
# CMAKE configuration for QEM Camera Server in C++.
# This is exclusively for the CMake configuration phase.
# This configuration is paired with cross-compilation configuration (see toolchain-pi4.cmake).
#
# The "Cmake Tools" extension works with this configuration.
# To change the "Build type", simply open the CMake Tools menu, go to the "Configure" tab
# and change the build by clicking on the little pencil like icon.
##################################################################

cmake_minimum_required(VERSION 3.16)
project(cnc_vision_camera_server_1-native)

# Set C++ and C standards
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Default build type
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
endif()

# Define source directory
set(SRC_DIR ${PROJECT_SOURCE_DIR}/src)

# Gather source files
file(GLOB_RECURSE SRC_FILES
    ${SRC_DIR}/*.cpp
    ${SRC_DIR}/*.c
)

# Add executable
add_executable(${PROJECT_NAME} ${SRC_FILES})

# Include directories (scoped)
target_include_directories(${PROJECT_NAME}
    PRIVATE
    ${PROJECT_SOURCE_DIR}/include
)

# Link libraries
# Uncomment as needed
# target_link_libraries(${PROJECT_NAME} pthread)

# Install target
install(TARGETS ${PROJECT_NAME} DESTINATION bin)
