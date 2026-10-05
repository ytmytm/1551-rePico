/**********************************
 * header - target hardware selection
 *
 * 1551-III-Pico is always built with REPICO1551=1 (CMake forces it).
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
