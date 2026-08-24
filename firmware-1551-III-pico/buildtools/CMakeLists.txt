cmake_minimum_required(VERSION 3.13)

### build dali-packer ...
set(DALI_WORKDIR ${CMAKE_CURRENT_SOURCE_DIR}/bitfire)
set(DALI_EXECUTABLE ${DALI_WORKDIR}/packer/dali/dali)

add_custom_command(
      WORKING_DIRECTORY ${DALI_WORKDIR}
      OUTPUT ${DALI_EXECUTABLE}
      COMMAND make dali
    )

add_custom_target(GenDali ALL
      DEPENDS ${DALI_EXECUTABLE})

add_executable(dali_tool IMPORTED GLOBAL)

set_property(TARGET dali_tool PROPERTY IMPORTED_LOCATION ${DALI_EXECUTABLE} )
