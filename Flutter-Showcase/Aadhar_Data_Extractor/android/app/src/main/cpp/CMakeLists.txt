cmake_minimum_required(VERSION 3.22)
project(jp2decoder)

include(FetchContent)

FetchContent_Declare(
    openjpeg
    GIT_REPOSITORY https://github.com/uclouvain/openjpeg.git
    GIT_TAG        v2.5.0
    GIT_SHALLOW    TRUE
)

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(BUILD_CODEC OFF CACHE BOOL "" FORCE)
set(BUILD_MJ2 OFF CACHE BOOL "" FORCE)
set(BUILD_JPWL OFF CACHE BOOL "" FORCE)
set(BUILD_JPIP OFF CACHE BOOL "" FORCE)
set(BUILD_JP3D OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)

FetchContent_MakeAvailable(openjpeg)

add_library(jp2decoder SHARED jp2_jni.cpp)

target_include_directories(jp2decoder PRIVATE
    ${openjpeg_SOURCE_DIR}/src/lib/openjp2
    ${openjpeg_BINARY_DIR}/src/lib/openjp2
)

target_link_libraries(jp2decoder
    openjp2
    android
    log
)
