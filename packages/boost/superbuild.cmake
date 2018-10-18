# boost superbuild

# Set dependency list
ome_add_dependencies(boost THIRD_PARTY_DEPENDENCIES zlib bzip2 icu)

if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  # VS 12.0
  if(NOT MSVC_VERSION VERSION_LESS 1800 AND MSVC_VERSION VERSION_LESS 1900)
    set(BOOST_TOOLSET msvc-12.0)
  # VS 14.0
  elseif(NOT MSVC_VERSION VERSION_LESS 1900 AND MSVC_VERSION VERSION_LESS 2000)
    set(BOOST_TOOLSET msvc-14.0)
  else()
    set(BOOST_TOOLSET msvc)
  endif()
elseif (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set(BOOST_TOOLSET clang)
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(BOOST_TOOLSET gcc)
else()
  message(FATAL_ERROR "Unsupported Boost toolset for compiler type ${CMAKE_CXX_COMPILER_ID}.  Please report this deficiency.")
endif()

# Notes:
# Builds boost without Boost.Python (not currently used)

ExternalProject_Add(${EP_PROJECT}
  ${OME_EP_COMMON_ARGS}
  URL "http://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.bz2"
  URL_HASH "SHA512=f5ca2e0425af40eca7722712b985b863c88780e5be5ac24c78bcfdc63651bb67a39605d4f84089d76cab344fd34113fcb7befaa9a90481b381f6c53e9612b5f9"
  SOURCE_DIR "${EP_SOURCE_DIR}"
  INSTALL_DIR ""
  PATCH_COMMAND
    ${CMAKE_COMMAND}
    ${boost_CLANG_ARG}
    "-DSOURCE_DIR:PATH=${EP_SOURCE_DIR}"
    "-DBOOST_TOOLSET=${BOOST_TOOLSET}"
    "-DCONFIG:INTERNAL=$<CONFIG>"
    "-DEP_SCRIPT_CONFIG=${EP_SCRIPT_CONFIG}"
    "-DPATCH_DIR:PATH=${CMAKE_CURRENT_LIST_DIR}/patches"
    "-DGENERIC_PATCH=${GENERIC_PATCH}"
    -P ${CMAKE_CURRENT_LIST_DIR}/patch.cmake
  CONFIGURE_COMMAND
    ${CMAKE_COMMAND}
    ${boost_CLANG_ARG}
    "-DSOURCE_DIR:PATH=${EP_SOURCE_DIR}"
    "-DBOOST_TOOLSET=${BOOST_TOOLSET}"
    "-DCONFIG:INTERNAL=$<CONFIG>"
    "-DEP_SCRIPT_CONFIG=${EP_SCRIPT_CONFIG}"
    -P ${CMAKE_CURRENT_LIST_DIR}/configure.cmake
  BUILD_IN_SOURCE 1
  BUILD_COMMAND ${CMAKE_COMMAND}
    "-DSOURCE_DIR:PATH=${EP_SOURCE_DIR}"
    "-DEP_INSTALL_DIR:PATH=${OME_EP_INSTALL_DIR}"
    "-DBOOST_TOOLSET=${BOOST_TOOLSET}"
    "-DBOOST_BITS=${BOOST_BITS}"
    "-DCONFIG:INTERNAL=$<CONFIG>"
    "-DEP_SCRIPT_CONFIG=${EP_SCRIPT_CONFIG}"
    -P "${CMAKE_CURRENT_LIST_DIR}/build.cmake"
  INSTALL_COMMAND ""
  DEPENDS
    ${EP_PROJECT}-prerequisites
)
