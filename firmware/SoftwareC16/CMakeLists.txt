cmake_minimum_required(VERSION 3.13)

# Plus/4 / C16 embedded selector for 1551-rePico "Load Selector".
# Prebuilt db12b.prg only — no intro, no SoftwareC64 / ACME / dali.

set(PROJECT_INCLUDE ${PROJECT_SOURCE_DIR}/include)

add_custom_target(GenSelector
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS db12b.prg
  COMMAND echo \"\#ifndef _MENU_PRG_H_\\n\#define _MENU_PRG_H_\" > ${PROJECT_INCLUDE}/c64_selector.h
  COMMAND xxd -i -n \"menu_prg\" db12b.prg >> ${PROJECT_INCLUDE}/c64_selector.h
  COMMAND perl -pi -e \"s!unsigned!const unsigned!g\" ${PROJECT_INCLUDE}/c64_selector.h
  COMMAND echo \"\#endif\" >> ${PROJECT_INCLUDE}/c64_selector.h
)
