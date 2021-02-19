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
  "-DTF_LITE_STATIC_MEMORY"
  "-Os"
)

#**********************
# sources
#**********************
include("${PROJECT_SOURCE_DIR}/../../ai_deployment_framework.cmake")

set_source_files_properties("${CMAKE_CURRENT_SOURCE_DIR}/src/main.xc" PROPERTIES LANGUAGE C)


#**********************
# targets
#**********************

# xcore_interpreter_xscope app

add_executable(xcore_interpreter_xscope)
target_compile_options(xcore_interpreter_xscope PRIVATE ${BUILD_FLAGS})
target_link_options(xcore_interpreter_xscope PRIVATE ${BUILD_FLAGS} -lquadspi -w)
set_target_properties(xcore_interpreter_xscope PROPERTIES OUTPUT_NAME xcore_interpreter_xscope.xe)

target_sources(xcore_interpreter_xscope
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/main_xscope.c"
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/main.xc"
)

target_include_directories(xcore_interpreter_xscope
  PRIVATE ${XCORE_INTERPRETER_INCLUDES}
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

# xcore_interpreter_cmdline app

add_executable(xcore_interpreter_cmdline)
target_compile_options(xcore_interpreter_cmdline PRIVATE ${BUILD_FLAGS})
target_link_options(xcore_interpreter_cmdline PRIVATE ${BUILD_FLAGS} -lquadspi -w -fcmdline-buffer-bytes=2048)
set_target_properties(xcore_interpreter_cmdline PROPERTIES OUTPUT_NAME xcore_interpreter_cmdline.xe)

target_sources(xcore_interpreter_cmdline
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/main_cmdline.c"
)

target_include_directories(xcore_interpreter_cmdline
  PRIVATE ${XCORE_INTERPRETER_INCLUDES}
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

# xcore_interpreter library
#   NOTE: The xcore_interpreter library is built primarilly to speed up the build of the 
#         app targets given they share most code.
add_library(xcore_interpreter STATIC
  ${XCORE_INTERPRETER_SOURCES}
  "${TENSORFLOW_SOURCE_DIR}/tensorflow/lite/micro/kernels/xcore/xcore_metal_dispatcher.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/test_ops_resolver.cc"
  "${CMAKE_CURRENT_SOURCE_DIR}/src/model_runner.cc"
)

target_include_directories(xcore_interpreter
  PRIVATE ${XCORE_INTERPRETER_INCLUDES}
  PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

target_compile_options(xcore_interpreter PRIVATE ${BUILD_FLAGS})
target_link_libraries(xcore_interpreter_xscope xcore_interpreter)
target_link_libraries(xcore_interpreter_cmdline xcore_interpreter)

#**********************
# install
#**********************
install(TARGETS xcore_interpreter_xscope xcore_interpreter_cmdline DESTINATION ${INSTALL_DIR})
