/**********************************
 * header - 1551-rePico board support
 *
 * GPIO0: 2 MHz PHI0 (50% PWM), isolated from /PHI0 by JP2 until bridged
 * GPIO3: 100 Hz IRQ experiment (brief active-low pulses), JP5/JP6 swap
***********************************/
#ifndef BOARD1551_H
#define BOARD1551_H

#include "board_config.h"

#if REPICO1551

#define REPICO1551_PHI0_HZ      2000000u
#define REPICO1551_IRQ_HZ       100u
#define REPICO1551_IRQ_LOW_US   10u

void init_board1551(void);

#endif

#endif
