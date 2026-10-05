cmake_minimum_required(VERSION 3.13)

set(PROJECT_INCLUDE ${PROJECT_SOURCE_DIR}/include)

find_program(ACME_TOOL "acme" PATHS "/usr/local/bin;/usr/bin;/bin" NO_CACHE )

option(BUILD_MENUPRG    "Enable compiling of menu.prg" ON)
option(COMPRESS_MENUPRG "Enable compression of menu.prg with dali" ON)

set(MENUPRG_BINARY "menu.prg")
set(ACME_OPTIONS --format cbm --cpu 6510 --vicelabels labels.lab)
set(DALI_OPTIONS --sfx 0x0808)

if(BUILD_MENUPRG)
  if(COMPRESS_MENUPRG)
    list(APPEND ACME_OPTIONS "-DNO_BASIC_HEADER=1")
    set(ACME_OUTPUT "tmp.prg")
  else()
    set(ACME_OUTPUT ${MENUPRG_BINARY})
  endif()

  if(ACME_TOOL)
    add_custom_command(
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      DEPENDS menu.asm
      OUTPUT ${ACME_OUTPUT}
      COMMAND ${ACME_TOOL} ${ACME_OPTIONS} -o ${ACME_OUTPUT} menu.asm
    )
    if(COMPRESS_MENUPRG)
      add_custom_command(
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        DEPENDS ${ACME_OUTPUT}
        OUTPUT ${MENUPRG_BINARY}
        COMMAND dali_tool ${DALI_OPTIONS} -o ${MENUPRG_BINARY} ${ACME_OUTPUT}
      )
    endif()
  else()
    MESSAGE("### ACME not found - using precompiled menu.prg ###")
  endif()
else()
  MESSAGE("### using precompiled menu.prg ###")
endif()

add_custom_target(GenSelector
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS ${MENUPRG_BINARY}
  COMMAND echo \"\#ifndef _MENU_PRG_H_\\n\#define _MENU_PRG_H_\" > ${PROJECT_INCLUDE}/c64_selector.h
  COMMAND xxd -i -n \"menu_prg\" ${MENUPRG_BINARY} >> ${PROJECT_INCLUDE}/c64_selector.h
  COMMAND perl -pi -e \"s!unsigned!const unsigned!g\" ${PROJECT_INCLUDE}/c64_selector.h
  COMMAND echo \"\#endif\" >> ${PROJECT_INCLUDE}/c64_selector.h
)

add_dependencies(GenSelector GenDali)

add_custom_target(GenIntro
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS intro.prg
  COMMAND echo \"\#ifndef _INTRO_PRG_H_\\n\#define _INTRO_PRG_H_\" > ${PROJECT_INCLUDE}/c64_intro.h
  COMMAND xxd -i -n \"intro_prg\" intro.prg >> ${PROJECT_INCLUDE}/c64_intro.h
  COMMAND perl -pi -e \"s!unsigned!const unsigned!g\" ${PROJECT_INCLUDE}/c64_intro.h
  COMMAND echo \"\#endif\" >> ${PROJECT_INCLUDE}/c64_intro.h
)
