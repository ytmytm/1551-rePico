# Plus/4 / C16 embedded selector for 1551-rePico "Load Selector".
# Prebuilt db12b.prg for now; keep this directory so we can rebuild/ship
# additional Plus/4 selector PRGs alongside it later.
cmake_minimum_required(VERSION 3.13)

# Parent project() has already run; PROJECT_SOURCE_DIR is firmware-1551-III-pico/.
set(PROJECT_INCLUDE ${PROJECT_SOURCE_DIR}/include)

add_custom_target(GenSelector
  ALL
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS db12b.prg
  COMMAND echo \"\#ifndef _MENU_PRG_H_\\n\#define _MENU_PRG_H_\" > ${PROJECT_INCLUDE}/c64_selector.h
  COMMAND xxd -i -n \"menu_prg\" db12b.prg >> ${PROJECT_INCLUDE}/c64_selector.h
  COMMAND perl -pi -e \"s!unsigned!const unsigned!g\" ${PROJECT_INCLUDE}/c64_selector.h
  COMMAND echo \"\#endif\" >> ${PROJECT_INCLUDE}/c64_selector.h
  BYPRODUCTS ${PROJECT_INCLUDE}/c64_selector.h
  COMMENT "Generate include/c64_selector.h from db12b.prg"
)
