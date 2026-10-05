/**********************************
 * header - target hardware selection
 *
 * REPICO1551 is enabled by default (CMake option REPICO1551=ON).
 * Set -DREPICO1551=OFF when configuring to build for 1541-rePico.
***********************************/
#ifndef BOARD_CONFIG_H
#define BOARD_CONFIG_H

#ifndef REPICO1551
#define REPICO1551 1
#endif

#if REPICO1551
#define REPICO1541 0
#elif !defined(REPICO1541)
#define REPICO1541 1
#endif

#endif
