find_package(MKL QUIET)

if(NOT TARGET caffe2::mkl)
  add_library(caffe2::mkl INTERFACE IMPORTED)
endif()

set_property(
  TARGET caffe2::mkl PROPERTY INTERFACE_INCLUDE_DIRECTORIES
  ${MKL_INCLUDE_DIR})
set_property(
  TARGET caffe2::mkl PROPERTY INTERFACE_LINK_LIBRARIES
  ${ONEMKL_LIBRARIES} ${MKL_THREAD_LIB})
# TODO: This is a hack, it will not pick up architecture dependent
# MKL libraries correctly; see https://github.com/pytorch/pytorch/issues/73008
set_property(
  TARGET caffe2::mkl PROPERTY INTERFACE_LINK_DIRECTORIES
  ${MKL_ROOT}/lib ${MKL_ROOT}/lib/intel64 ${MKL_ROOT}/lib/intel64_win ${MKL_ROOT}/lib/win-x64)

if(UNIX)
  if(${USE_STATIC_MKL})
    foreach(MKL_LIB_PATH IN LISTS ONEMKL_LIBRARIES)
      if(EXISTS "${MKL_LIB_PATH}")
        get_filename_component(MKL_LIB_NAME "${MKL_LIB_PATH}" NAME)
        # Match archive libraries starting with "libmkl_"
        if(MKL_LIB_NAME MATCHES "^libmkl_" AND MKL_LIB_NAME MATCHES ".a$")
          target_link_options(caffe2::mkl INTERFACE "-Wl,--exclude-libs,${MKL_LIB_NAME}")
        endif()
      endif()
    endforeach()
  endif()
endif()
