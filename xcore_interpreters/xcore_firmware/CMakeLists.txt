cmake_minimum_required(VERSION 3.14)

#**********************
# Setup XMOS toolchain
#**********************
include("${CMAKE_CURRENT_SOURCE_DIR}/../cmake/xmos_toolchain.cmake")

project(xcore_interpreter VERSION 1.0.0)

enable_language(CXX C ASM)

#**********************
# Disable in-source build.
#**********************
if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "In-source build is not allowed! Please specify a build folder.\n\tex:cmake -B build")
endif()

#**********************
# install
#**********************
set(INSTALL_DIR "${PROJECT_SOURCE_DIR}/bin")

#**********************
# Build flags
#**********************
# Optimization 
# -DNDEBUG                        # define this for remove debug and profiling 
# -DTF_LITE_STRIP_ERROR_STRINGS   # define this to remove logging

set(BUILD_FLAGS
  "-fxscope"
  "${CMAKE_CURRENT_SOURCE_DIR}/config.xscope"
  "-target=XCORE-AI-EXPLORER"
  "-mcmodel=large"
  "-report"
  "-Wno-xcore-fptrgroup"
  "-Wno-unknown-pragmas"
  "-fno-rtti"
  "-fno-exceptions"
  "-DXCORE"
  "-D_clock_defined"       # workaround for tools bug id=18509
  "-DTF_LITE_STATIC_MEMORY"
  "-Os"
)

#**********************
# interpreter library
#**********************
include("${PROJECT_SOURCE_DIR}/../../ai_deployment_framework.cmake")

add_library(libxcore_interpreters OBJECT ${XCORE_INTERPRETER_SOURCES})

target_compile_options(libxcore_interpreters PRIVATE ${BUILD_FLAGS})
set_target_properties(libxcore_interpreters PROPERTIES PREFIX "")

target_include_directories(libxcore_interpreters
  PRIVATE ${XCORE_INTERPRETER_INCLUDES}
)

#**********************
# firmware targets
#**********************
add_executable(xcore_interpreter_xscope)
target_compile_options(xcore_interpreter_xscope PRIVATE ${BUILD_FLAGS})
target_link_libraries(xcore_interpreter_xscope PRIVATE libxcore_interpreters)
target_link_options(xcore_interpreter_xscope PRIVATE ${BUILD_FLAGS} -lquadspi -w)
set_target_properties(xcore_interpreter_xscope PROPERTIES OUTPUT_NAME xcore_interpreter_xscope.xe)

add_executable(xcore_interpreter_cmdline)
target_compile_options(xcore_interpreter_cmdline PRIVATE ${BUILD_FLAGS})
target_link_libraries(xcore_interpreter_cmdline PRIVATE libxcore_interpreters)
target_link_options(xcore_interpreter_cmdline PRIVATE ${BUILD_FLAGS} -lquadspi -w -fcmdline-buffer-bytes=2048)
set_target_properties(xcore_interpreter_cmdline PROPERTIES OUTPUT_NAME xcore_interpreter_cmdline.xe)

target_sources(xcore_interpreter_xscope
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/main_xscope.c"
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/model_runner.cc"
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/test_ops_resolver.cc"
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/main.xc"
)
set_source_files_properties("${CMAKE_CURRENT_SOURCE_DIR}/src/main.xc" PROPERTIES LANGUAGE C)
# workaround for tools bug id=18509
set_property(SOURCE "${PROJECT_SOURCE_DIR}/src/main.xc" PROPERTY COMPILE_FLAGS -U_clock_defined)

target_sources(xcore_interpreter_cmdline
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/main_cmdline.c"
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/model_runner.cc"
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/test_ops_resolver.cc"
)

target_include_directories(xcore_interpreter_xscope
  PRIVATE ${XCORE_INTERPRETER_INCLUDES}
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

target_include_directories(xcore_interpreter_cmdline
  PRIVATE ${XCORE_INTERPRETER_INCLUDES}
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

install(TARGETS xcore_interpreter_xscope xcore_interpreter_cmdline DESTINATION ${INSTALL_DIR})
