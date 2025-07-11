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

option(ENABLE_COVERAGE "Enable coverage reporting" OFF)

if(ENABLE_COVERAGE)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage -g -O0")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage -g -O0")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --coverage")
    endif()
endif()

if(ENABLE_COVERAGE)
    # Find required coverage tools
    find_program(LCOV_PATH lcov)
    find_program(GENHTML_PATH genhtml)
    find_program(GCOVR_PATH gcovr)
    
    if(NOT LCOV_PATH OR NOT GENHTML_PATH)
        message(WARNING "lcov or genhtml not found! Coverage target will not work.")
    endif()
    
    if(NOT GCOVR_PATH)
        message(WARNING "gcovr not found! XML coverage report will not be generated.")
    endif()

    # Add coverage target
    add_custom_target(coverage
        # Clean previous coverage data
        COMMAND ${CMAKE_COMMAND} -E remove -f coverage.info coverage.xml
        COMMAND find ${CMAKE_BINARY_DIR} -name "*.gcda" -delete
        
        # Run the executable first to generate .gcda files
        COMMAND ${CMAKE_BINARY_DIR}/${PROJECT_NAME}
        
        # Generate lcov coverage data
        COMMAND ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --capture --output-file coverage.info
        COMMAND ${LCOV_PATH} --remove coverage.info '/usr/*' '*/build/*' --output-file coverage.info
        
        # Generate HTML report
        COMMAND ${GENHTML_PATH} coverage.info --output-directory coverage_html
        
        # Generate XML report for Codacy
        COMMAND ${GCOVR_PATH} --xml --output coverage.xml ${CMAKE_BINARY_DIR}
        
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        DEPENDS ${PROJECT_NAME}
        COMMENT "Generating coverage reports (HTML and XML)"
    )
    
    # Add a separate target for just XML coverage (useful for CI)
    add_custom_target(coverage-xml
        COMMAND ${CMAKE_COMMAND} -E remove -f coverage.xml
        COMMAND find ${CMAKE_BINARY_DIR} -name "*.gcda" -delete
        COMMAND ${CMAKE_BINARY_DIR}/${PROJECT_NAME}
        COMMAND ${GCOVR_PATH} --xml --output coverage.xml ${CMAKE_BINARY_DIR}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        DEPENDS ${PROJECT_NAME}
        COMMENT "Generating XML coverage report for Codacy"
    )
endif()

# Install target
install(TARGETS ${PROJECT_NAME} DESTINATION bin)