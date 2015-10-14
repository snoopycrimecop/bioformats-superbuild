# Build boost
include("${EP_SCRIPT_CONFIG}")
include("${GENERIC_CMAKE_ENVIRONMENT}")

if (CONFIG MATCHES Rel)
  set(BOOST_VARIANT release)
else()
  set(BOOST_VARIANT debug)
endif()

if(WIN32)

  execute_process(COMMAND ./b2 install
                               --prefix=${BIOFORMATS_EP_INSTALL_DIR}
                               --without-python
                               "cxxflags=${CMAKE_CXX_FLAGS}"
                               "linkflags=${CMAKE_SHARED_LINKER_FLAGS}"
                               "toolset=${BOOST_TOOLSET}"
                               "variant=${BOOST_VARIANT}"
                               "address-model=${EP_PLATFORM_BITS}"
                               "link=shared"
                               "runtime-link=shared"
                               "threading=multi"
                               "-d+2"
                  WORKING_DIRECTORY "${SOURCE_DIR}"
                  RESULT_VARIABLE build_result)

  # Boost installs the DLLs into lib; move to bin for consistency.
  file(GLOB BOOST_DLLS "${BIOFORMATS_EP_LIB_DIR}/boost*.dll")
  foreach(dll ${BOOST_DLLS})
    get_filename_component(dllbase "${dll}" NAME)
    file(RENAME "${dll}" "${BIOFORMATS_EP_BIN_DIR}/${dllbase}")
  endforeach()

else(WIN32)

  message(STATUS "Building boost (Unix) with toolset=${BOOST_TOOLSET} cxxflags=${CMAKE_CXX_FLAGS} linkflags=${CMAKE_SHARED_LINKER_FLAGS}")

  execute_process(COMMAND ./b2 install
                               "cxxflags=${CMAKE_CXX_FLAGS}"
                               "linkflags=${CMAKE_SHARED_LINKER_FLAGS}"
                               "toolset=${BOOST_TOOLSET}"
                               "-d+2"
                  WORKING_DIRECTORY "${SOURCE_DIR}"
                  RESULT_VARIABLE build_result)

endif(WIN32)

if (build_result)
  message(FATAL_ERROR "boost: Build failed")
endif()